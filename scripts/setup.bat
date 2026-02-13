@echo off
setlocal

set ROOT_DIR=%~dp0..
cd /d "%ROOT_DIR%"

docker info >nul 2>&1
if errorlevel 1 (
  echo Docker is not running or not available.
  exit /b 1
)

docker volume create n8n_data >nul
docker volume create ollama_data >nul

docker compose pull
docker compose build

echo Setup complete.
endlocal