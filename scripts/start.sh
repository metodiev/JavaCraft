#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

docker compose -f "$PROJECT_ROOT/docker-compose.yml" up --build -d

printf '\nJavaCraft is starting.\n'
printf 'Frontend:   http://localhost:5173\n'
printf 'API:        http://localhost:8080/api/v1/catalog\n'
printf 'Health:     http://localhost:8080/actuator/health\n'
