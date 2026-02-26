#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_MODELS_DIR="$ROOT_DIR/ollama-models/models"
BACKUP_DIR="$ROOT_DIR/ollama-models/backups"


VOLUME_NAME=""
ASSUME_YES=0
NO_BACKUP=0

usage() {
	cat <<EOF
Usage: $(basename "$0") [options]

Safely imports local Ollama model files into the Docker volume used by the
Ollama container.

Options:
	--source <path>   Source models directory (default: ollama-models/models)
	--volume <name>   Docker volume name (auto-detected if omitted)
	--no-backup       Skip creating a backup archive before import
	-y, --yes         Run non-interactively (skip confirmation prompt)
	-h, --help        Show this help message
EOF
}

# Parsing command-line arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
		--source)
			SOURCE_MODELS_DIR="$2"
			shift 2
			;;
		--volume)
			VOLUME_NAME="$2"
			shift 2
			;;
		--no-backup)
			NO_BACKUP=1
			shift
			;;
		-y|--yes)
			ASSUME_YES=1
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1"
			usage
			exit 1
			;;
	esac
done

cd "$ROOT_DIR"

echo "Project root: $ROOT_DIR"
echo "Source models directory: $SOURCE_MODELS_DIR"

docker info >/dev/null 2>&1

if [[ ! -d "$SOURCE_MODELS_DIR" ]]; then
	echo "Source directory does not exist: $SOURCE_MODELS_DIR"
	exit 1
fi

if [[ ! -d "$SOURCE_MODELS_DIR/blobs" ]]; then
	echo "Missing required source directory: $SOURCE_MODELS_DIR/blobs"
	exit 1
fi

HAS_MANIFEST=0
if [[ -d "$SOURCE_MODELS_DIR/manifests" ]] || [[ -d "$SOURCE_MODELS_DIR/manifest" ]]; then
	HAS_MANIFEST=1
fi

if [[ "$HAS_MANIFEST" -ne 1 ]]; then
	echo "Missing required source manifest directory: expected either"
	echo "  $SOURCE_MODELS_DIR/manifests"
	echo "  $SOURCE_MODELS_DIR/manifest"
	exit 1
fi

resolve_volume_name() {
	local detected=""

	detected="$(docker inspect -f '{{ range .Mounts }}{{ if eq .Destination "/root/.ollama" }}{{ .Name }}{{ end }}{{ end }}' my_ollama 2>/dev/null || true)"
	if [[ -n "$detected" ]]; then
		echo "$detected"
		return 0
	fi

	mapfile -t candidates < <(docker volume ls --format '{{.Name}}' | grep -E '(^ollama_data$|_ollama_data$)' || true)

	if [[ "${#candidates[@]}" -eq 1 ]]; then
		echo "${candidates[0]}"
		return 0
	fi

	return 1
}

if [[ -z "$VOLUME_NAME" ]]; then
	if ! VOLUME_NAME="$(resolve_volume_name)"; then
		echo "Could not uniquely auto-detect the Ollama volume."
		echo "Please provide it explicitly, for example:"
		echo "  ./scripts/add-local-models.sh --volume n8n-ollama-dev_ollama_data"
		exit 1
	fi
fi

docker volume inspect "$VOLUME_NAME" >/dev/null

echo "Target Docker volume: $VOLUME_NAME"
echo "Target path in volume: /root/.ollama/models"

if [[ "$ASSUME_YES" -ne 1 ]]; then
	read -r -p "Proceed with importing local models into '$VOLUME_NAME'? [y/N] " REPLY
	case "$REPLY" in
		[yY]|[yY][eE][sS]) ;;
		*)
			echo "Cancelled."
			exit 0
			;;
	esac
fi

# No need for backup since we are only adding new models and not modifying existing ones
# if [[ "$NO_BACKUP" -ne 1 ]]; then
# 	mkdir -p "$BACKUP_DIR"
# 	BACKUP_FILE="${VOLUME_NAME}_$(date +%Y%m%d-%H%M%S).tar.gz"
# 	echo "Creating backup: $BACKUP_DIR/$BACKUP_FILE"

# 	docker run --rm \
# 		-v "$VOLUME_NAME:/vol:ro" \
# 		-v "$BACKUP_DIR:/backup" \
# 		-e BACKUP_FILE="$BACKUP_FILE" \
# 		alpine:3.20 \
# 		sh -c 'set -eu; cd /vol; tar -czf "/backup/${BACKUP_FILE}" .'

# 	echo "Backup complete."
# else
# 	echo "Backup skipped (--no-backup)."
# fi

OLLAMA_WAS_RUNNING=0
if docker ps --format '{{.Names}}' | grep -qx 'my_ollama'; then
	OLLAMA_WAS_RUNNING=1
	echo "Stopping running Ollama container for a consistent import..."
	docker compose stop ollama
fi

echo "Importing model files into Docker volume..."
docker run --rm \
	-v "$VOLUME_NAME:/target" \
	-v "$SOURCE_MODELS_DIR:/source:ro" \
	alpine:3.20 \
	sh -c '
		set -eu
		mkdir -p /target/models
		cp -a /source/blobs /target/models/
		if [ -d /source/manifests ]; then
			cp -a /source/manifests /target/models/
		fi
		if [ -d /source/manifest ]; then
			cp -a /source/manifest /target/models/
		fi
	'

if [[ "$OLLAMA_WAS_RUNNING" -eq 1 ]]; then
	echo "Starting Ollama container again..."
	docker compose start ollama
fi

echo "Local models imported successfully."
echo "You can verify with: docker exec my_ollama ollama list"
