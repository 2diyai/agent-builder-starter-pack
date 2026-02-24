#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "Setting up in root directory: $ROOT_DIR"

cd "$ROOT_DIR"

# Ensure Docker is available
docker info >/dev/null 2>&1
echo "Docker is available. Proceeding with setup..."

# Ensure all shell scripts are executable
echo "Setting executable permissions for all shell scripts in the 'scripts' directory..."
chmod +x scripts/*.sh
echo "All shell scripts in the 'scripts' directory are now executable."

# Create named volumes (idempotent)
echo "Creating Docker volumes if they do not already exist..."
docker volume create n8n_data >/dev/null
docker volume create ollama_data >/dev/null
echo "Docker volumes 'n8n_data' and 'ollama_data' are ready."

# Pull and build
echo "Pulling and building Docker images..."
docker compose pull
echo "Docker images pulled successfully."
docker compose build
echo "Docker images built successfully."

echo "Setup complete."