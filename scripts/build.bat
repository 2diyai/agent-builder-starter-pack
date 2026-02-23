@echo off
setlocal enabledelayedexpansion

REM Resolve repo root (parent of scripts)
set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT_DIR=%%~fI"

echo Rebuilding containers: %ROOT_DIR%
cd /d "%ROOT_DIR%"

REM Ensure Docker is available
docker info >nul 2>&1
if errorlevel 1 (
  echo Error: Docker is not available.
  exit /b 1
)

docker compose build
if errorlevel 1 exit /b 1

echo Build complete.
endlocal