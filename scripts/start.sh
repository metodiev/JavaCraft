#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"
# shellcheck source=lib.sh
. "$PROJECT_ROOT/scripts/lib.sh"

jc_require_docker
jc_detect_compose
jc_resolve_worker

if [ "$JC_WORKER" = "1" ]; then
  "${COMPOSE[@]}" -f "$COMPOSE_FILE" --profile execution up --build -d
else
  "${COMPOSE[@]}" -f "$COMPOSE_FILE" up --build -d
fi

printf '\nJavaCraft is starting.\n'
printf 'Frontend:   http://localhost:5173\n'
printf 'API:        http://localhost:8080/api/v1/catalog\n'
printf 'Health:     http://localhost:8080/actuator/health\n'
