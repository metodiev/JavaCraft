# JavaCraft

JavaCraft is an engineering simulator for learning to build production Java systems:
**read → think → code → run → debug → test → submit → review → improve**.

The repository is being built in incremental, runnable slices. It currently provides
the product architecture, a React learning workspace, a Spring Boot API, learner
registration/login, PostgreSQL-backed learning progress, and an opt-in gVisor worker
for public tests on the payment race-condition challenge. Hidden-test grading and
submission scoring remain disabled.

## Run locally

Requirements for the default local platform: Docker with Compose.

```sh
./scripts/start.sh
```

- Frontend: <http://localhost:5173>
- Platform API: <http://localhost:8080/api/v1/catalog>
- Health: <http://localhost:8080/actuator/health>
- PostgreSQL is reachable only on the Compose network. To open a local SQL shell, run
  `docker compose exec db psql -U javacraft -d javacraft`.

Use `./scripts/stop.sh` to stop and remove the JavaCraft containers and network, or
`./scripts/restart.sh` to rebuild and start the platform again. Both scripts preserve
the PostgreSQL data volume.

The execution worker is disabled by default. To enable public challenge tests, deploy on
a dedicated Linux host with Docker Engine configured to use the gVisor `runsc` runtime.
Prefer a rootless Docker daemon on an otherwise disposable runner host. The worker alone
gets access to that daemon socket, which gives it control of that Docker host; neither the
platform API nor sandbox containers get the socket. Do not use this profile on a shared
or sensitive host, or expose it to public submissions. Docker Desktop is not supported
for this setup.

For a local development smoke test on macOS, Colima can provide the Linux Docker daemon.
Install `runsc` inside the Colima VM using the
[official gVisor installation instructions](https://gvisor.dev/docs/user_guide/install/),
then run the worker against the same daemon selected by the `colima` Docker context:

```sh
EXECUTION_DOCKER_SOCKET=/var/run/docker.sock \
EXECUTION_DOCKER_GID="$(colima ssh -- getent group docker | cut -d: -f3)" \
ENABLE_EXECUTION_WORKER=true \
./scripts/start.sh
```

This Colima setup is for single-user development and smoke testing only; do not expose it
to public submissions or use it as a shared production runner.

Set the socket path and its group ID for the dedicated runner daemon, then start:

```sh
DOCKER_HOST=unix:///run/user/1001/docker.sock \
EXECUTION_DOCKER_SOCKET=/run/user/1001/docker.sock \
EXECUTION_DOCKER_GID=1001 \
ENABLE_EXECUTION_WORKER=true \
./scripts/start.sh
```

The worker verifies that Docker advertises `runsc`, checks the applied container limits,
and runs a filesystem/network isolation probe before publishing its heartbeat. Requests
return `503` until those checks pass; it never falls back to `runc`. The challenge editor
currently runs public tests only. Hidden-test execution, grading, and the Submit action
remain disabled.

This repository is not yet ready to expose publicly as-is. Before a public deployment,
replace the development database credentials, require HTTPS and secure cookies, restrict
CORS, configure ingress and abuse controls, and review the deployment security settings.

## Repository map

```text
.
├── backend/                 Spring Boot platform API
├── backend/src/main/resources/db/migration/
│                            Normalized PostgreSQL schema (Flyway)
├── docs/
│   ├── architecture.md      System boundaries and deployment decisions
│   └── openapi.yaml         Versioned REST API contract
├── frontend/                React, TypeScript, Vite, Monaco
├── execution/sandbox/       Restricted Java 21 public-test image
└── docker-compose.yml       Local services and opt-in Linux execution profile
```

## Build sequence

1. Platform foundation: architecture, data/API contracts, content API, and workspace shell.
2. Identity and durable learning: registration/login, database-backed catalog, and learner
   tutorial/skill progress.
3. Isolated execution: opt-in asynchronous public-test jobs on gVisor. Hidden-test
   grading remains a separate security gate and is not enabled by this slice.
4. Learning and feedback: scoring, skill graph, achievements, and guided code review.
5. Operations and authoring: admin workflows, observability, CI, and deployment hardening.

See [docs/architecture.md](docs/architecture.md) and [docs/openapi.yaml](docs/openapi.yaml)
for the foundation design and initial API surface.
