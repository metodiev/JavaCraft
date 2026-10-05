#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"
# shellcheck source=lib.sh
. "$PROJECT_ROOT/scripts/lib.sh"

jc_require_docker
jc_detect_compose

# Always include the execution profile so the optional worker and sandbox image
# are torn down as well, even if this shell did not enable them.
"${COMPOSE[@]}" -f "$COMPOSE_FILE" --profile execution down

printf '\nJavaCraft containers are stopped. Database data is preserved.\n'
