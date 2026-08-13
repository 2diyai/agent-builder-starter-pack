@echo off
setlocal

set ROOT_DIR=%~dp0..
cd /d "%ROOT_DIR%"

docker compose -f docker-compose-ollama.yml up -d

echo Services started.
endlocal