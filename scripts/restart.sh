#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"

docker compose -f "$COMPOSE_FILE" down
docker compose -f "$COMPOSE_FILE" up --build -d

printf '\nJavaCraft is restarting.\n'
printf 'Frontend:   http://localhost:5173\n'
printf 'API:        http://localhost:8080/api/v1/catalog\n'
printf 'Health:     http://localhost:8080/actuator/health\n'
