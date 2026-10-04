#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ "${ENABLE_EXECUTION_WORKER:-false}" = "true" ]; then
  docker compose -f "$PROJECT_ROOT/docker-compose.yml" --profile execution down
else
  docker compose -f "$PROJECT_ROOT/docker-compose.yml" down
fi

printf '\nJavaCraft containers are stopped. Database data is preserved.\n'
