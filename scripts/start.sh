#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ "${ENABLE_EXECUTION_WORKER:-false}" = "true" ]; then
  docker compose -f "$PROJECT_ROOT/docker-compose.yml" --profile execution up --build -d
else
  docker compose -f "$PROJECT_ROOT/docker-compose.yml" up --build -d
fi

printf '\nJavaCraft is starting.\n'
printf 'Frontend:   http://localhost:5173\n'
printf 'API:        http://localhost:8080/api/v1/catalog\n'
printf 'Health:     http://localhost:8080/actuator/health\n'
