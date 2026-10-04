#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

docker compose -f "$PROJECT_ROOT/docker-compose.yml" down

printf '\nJavaCraft containers are stopped. Database data is preserved.\n'
