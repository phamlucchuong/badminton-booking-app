#!/usr/bin/env bash
# Bootstrap dev environment for BadBook Backend & Infra.
# Usage: bash apps/backend/scripts/bootstrap.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
BACKEND_DIR="${REPO_ROOT}/apps/backend"
BACKEND_ENV_FILE="${BACKEND_DIR}/.env"
LEGACY_ENV_FILE="${REPO_ROOT}/.env"

echo "=== BadBook Backend Dev Bootstrap ==="
echo ""

# 1. Check prerequisites
echo "[1/4] Checking prerequisites..."
command -v java >/dev/null 2>&1 || { echo "ERROR: Java not found. Please install JDK 21."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "ERROR: Docker not found."; exit 1; }

JAVA_VER=$(java -version 2>&1 | head -n 1)
DOCKER_VER=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "Unknown")

echo "  - Java: $JAVA_VER"
echo "  - Docker: $DOCKER_VER"

# 2. Setup Environment
echo ""
echo "[2/4] Setting up environment variables..."
if [ ! -f "${BACKEND_ENV_FILE}" ]; then
  if [ -f "${LEGACY_ENV_FILE}" ]; then
    cp "${LEGACY_ENV_FILE}" "${BACKEND_ENV_FILE}"
    echo "Created apps/backend/.env from legacy root .env"
  elif [ -f "${BACKEND_DIR}/.env.example" ]; then
    cp "${BACKEND_DIR}/.env.example" "${BACKEND_ENV_FILE}"
    echo "Created apps/backend/.env from apps/backend/.env.example"
  else
    echo "Warning: apps/backend/.env.example not found. Please create apps/backend/.env manually."
  fi
else
  echo "apps/backend/.env already exists, skipping"
fi

# 3. Backend Build
echo ""
echo "[3/4] Building Backend (Spring Boot)..."
"${BACKEND_DIR}/mvnw" -f "${BACKEND_DIR}/pom.xml" clean install -DskipTests

# 4. Start Infrastructure
echo ""
echo "[4/4] Starting Docker infrastructure..."
docker compose --env-file "${BACKEND_ENV_FILE}" -f "${BACKEND_DIR}/docker-compose.dev.yaml" up -d

echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "Next steps:"
echo "  1. Check containers status: docker compose --env-file apps/backend/.env -f apps/backend/docker-compose.dev.yaml ps"
echo "  2. View logs: docker compose --env-file apps/backend/.env -f apps/backend/docker-compose.dev.yaml logs -f"
echo "  3. Run application: 'make run'"
echo ""
echo "Endpoints (default):"
echo "  - PostgreSQL: localhost:5432"
echo "  - Redis:      localhost:6379"
