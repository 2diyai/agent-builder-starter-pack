#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "Rebuilding containers: $ROOT_DIR"

cd "$ROOT_DIR"

# Ensure Docker is available
docker info >/dev/null 2>&1

docker compose build

echo "Build complete."