#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "Setting up in root directory: $ROOT_DIR"

cd "$ROOT_DIR"

# Ensure Docker is available
docker info >/dev/null 2>&1

# Ensure all shell scripts are executable
chmod +x scripts/*.sh

# Create named volumes (idempotent)
docker volume create n8n_data >/dev/null
docker volume create ollama_data >/dev/null

# Pull and build
docker compose pull
docker compose build

echo "Setup complete."