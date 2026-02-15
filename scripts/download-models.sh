#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODELS_FILE="$ROOT_DIR/list-of-models.txt"

if [[ ! -f "$MODELS_FILE" ]]; then
  echo "Models file not found: $MODELS_FILE"
  exit 1
fi

# Ensure Ollama is running
if ! docker compose ps ollama --status running >/dev/null 2>&1; then
  echo "Ollama service is not running. Start it first."
  exit 1
fi

# Pull models line by line (skip empty lines and comments)
while IFS= read -r model || [[ -n "$model" ]]; do
  model="${model%$'\r'}"             # handle Windows line endings
  model="${model%%#*}"               # remove inline comments
  model="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<< "$model")"
  [[ -z "$model" ]] && continue

  echo "Pulling model: $model"
  docker compose exec -T ollama ollama pull "$model" </dev/null
done < "$MODELS_FILE"

echo "Model download complete."