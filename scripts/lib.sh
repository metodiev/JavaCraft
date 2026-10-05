#!/usr/bin/env bash
# Shared helpers for the JavaCraft lifecycle scripts. Source this file; do not run it.

# Resolve the Compose CLI once: prefer the plugin, fall back to the standalone binary.
# Sets COMPOSE for the sourcing script.
jc_detect_compose() {
  if docker compose version >/dev/null 2>&1; then
    # shellcheck disable=SC2034
    COMPOSE=(docker compose)
  elif command -v docker-compose >/dev/null 2>&1; then
    # shellcheck disable=SC2034
    COMPOSE=(docker-compose)
  else
    printf 'Docker Compose is required but not installed.\n' >&2
    exit 1
  fi
}

jc_require_docker() {
  if ! docker info >/dev/null 2>&1; then
    printf 'The Docker daemon is not reachable. Start Docker, or run "colima start" when using Colima, then retry.\n' >&2
    exit 1
  fi
}

jc_is_colima_context() {
  command -v colima >/dev/null 2>&1 \
    && [ "$(docker context show 2>/dev/null)" = "colima" ]
}

jc_daemon_reports_runsc() {
  docker info --format '{{json .Runtimes}}' 2>/dev/null | grep -q '"runsc"'
}

jc_is_docker_desktop() {
  docker info --format '{{.OperatingSystem}}' 2>/dev/null | grep -qi 'docker desktop'
}

# Export the socket settings the worker container needs inside a Colima VM.
# Returns non-zero when the docker group id cannot be derived.
jc_export_colima_sandbox_env() {
  if [ -z "${EXECUTION_DOCKER_GID:-}" ]; then
    local gid
    gid="$(colima ssh -- getent group docker 2>/dev/null | cut -d: -f3 || true)"
    if [ -z "$gid" ]; then
      return 1
    fi
    EXECUTION_DOCKER_GID="$gid"
  fi
  : "${EXECUTION_DOCKER_SOCKET:=/var/run/docker.sock}"
  export EXECUTION_DOCKER_SOCKET EXECUTION_DOCKER_GID
}

# Derive the socket settings from a local Linux Docker daemon.
jc_export_linux_sandbox_env() {
  [ "$(uname -s)" = "Linux" ] || return 1
  local socket
  case "${DOCKER_HOST:-}" in
    unix://*) socket="${DOCKER_HOST#unix://}" ;;
    "") socket=/var/run/docker.sock ;;
    *) return 1 ;;
  esac
  [ -S "$socket" ] || return 1
  if [ -z "${EXECUTION_DOCKER_SOCKET:-}" ]; then
    EXECUTION_DOCKER_SOCKET="$socket"
  fi
  if [ -z "${EXECUTION_DOCKER_GID:-}" ]; then
    EXECUTION_DOCKER_GID="$(stat -c '%g' "$socket" 2>/dev/null || true)"
    if [ -z "$EXECUTION_DOCKER_GID" ]; then
      return 1
    fi
  fi
  export EXECUTION_DOCKER_SOCKET EXECUTION_DOCKER_GID
}

# One-time gVisor setup inside the Colima VM; idempotent and best effort.
jc_provision_colima_runsc() {
  colima ssh -- sudo apt-get update -qq \
    && colima ssh -- sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ca-certificates curl gnupg \
    && colima ssh -- sh -c 'curl -fsSL https://gvisor.dev/archive.key | sudo gpg --dearmor --yes -o /usr/share/keyrings/gvisor-archive-keyring.gpg' \
    && colima ssh -- sh -c 'printf "deb [arch=%s signed-by=/usr/share/keyrings/gvisor-archive-keyring.gpg] https://storage.googleapis.com/gvisor/releases release main\n" "$(dpkg --print-architecture)" | sudo tee /etc/apt/sources.list.d/gvisor.list >/dev/null' \
    && colima ssh -- sudo apt-get update -qq \
    && colima ssh -- sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq runsc \
    && colima ssh -- sudo systemctl reload docker
}

# True when the runsc binary is installed inside the Colima VM.
jc_colima_runsc_installed() {
  colima ssh -- sh -c 'command -v runsc >/dev/null 2>&1' 2>/dev/null
}

# Register the gVisor runtime with the VM's Docker daemon and reload it. Colima
# recreates /etc/docker/daemon.json from its own configuration whenever the VM
# boots, so the registration must be re-applied whenever it is missing.
jc_register_colima_runsc() {
  colima ssh -- sudo python3 - <<'PY' || return 1
import json
path = "/etc/docker/daemon.json"
try:
    with open(path) as handle:
        config = json.load(handle)
except FileNotFoundError:
    config = {}
config.setdefault("runtimes", {})["runsc"] = {"path": "/usr/bin/runsc"}
with open(path, "w") as handle:
    json.dump(config, handle, indent=2)
PY
  colima ssh -- sudo systemctl reload docker
}

# Ready when the daemon advertises runsc and the binary exists in the VM.
jc_colima_runsc_ready() {
  jc_daemon_reports_runsc \
    && jc_colima_runsc_installed
}

# Install gVisor when missing, keep its Docker registration current, and wait
# until the VM reports it as ready.
jc_ensure_colima_runsc() {
  if ! jc_colima_runsc_ready; then
    if ! jc_colima_runsc_installed; then
      printf 'JavaCraft: installing the gVisor sandbox runtime (runsc) in the Colima VM, one time only...\n'
      jc_provision_colima_runsc || true
    fi
    if ! jc_daemon_reports_runsc; then
      printf 'JavaCraft: registering the gVisor runtime with the Docker daemon in the Colima VM...\n'
      jc_register_colima_runsc || true
    fi
  fi
  local attempt=0
  while [ "$attempt" -lt 20 ]; do
    if jc_colima_runsc_ready; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 1
  done
  return 1
}

# Decide whether the execution worker should start, exporting its sandbox settings
# when it does. Honors ENABLE_EXECUTION_WORKER=true|false; anything else (or unset)
# enables the worker automatically whenever a gVisor sandbox can be provided.
# Sets JC_WORKER to 1 or 0.
jc_resolve_worker() {
  JC_WORKER=0
  local mode="${ENABLE_EXECUTION_WORKER:-auto}"
  if [ "$mode" != "true" ] && [ "$mode" != "false" ]; then
    mode=auto
  fi
  if [ "$mode" = "false" ]; then
    return 0
  fi

  local reason=""
  if jc_is_colima_context; then
    if jc_ensure_colima_runsc && jc_export_colima_sandbox_env; then
      JC_WORKER=1
    else
      reason="the automatic gVisor setup in the Colima VM did not succeed"
    fi
  elif jc_daemon_reports_runsc; then
    if { [ -n "${EXECUTION_DOCKER_SOCKET:-}" ] && [ -n "${EXECUTION_DOCKER_GID:-}" ]; } \
        || jc_export_linux_sandbox_env; then
      JC_WORKER=1
    else
      reason="the gVisor runtime is present but the Docker socket settings could not be derived; set EXECUTION_DOCKER_SOCKET and EXECUTION_DOCKER_GID"
    fi
  elif jc_is_docker_desktop; then
    reason="Docker Desktop cannot run the gVisor sandbox"
  else
    reason="this Docker host does not provide the gVisor sandbox"
  fi

  if [ "$JC_WORKER" = "0" ]; then
    if [ "$mode" = "true" ]; then
      printf 'JavaCraft: ENABLE_EXECUTION_WORKER=true but %s (see README.md).\n' "$reason" >&2
      exit 1
    fi
    printf 'JavaCraft: challenge execution stays off because %s (see README.md).\n' "$reason"
  fi
  return 0
}
