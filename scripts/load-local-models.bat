@echo off
setlocal EnableExtensions EnableDelayedExpansion

for %%I in ("%~dp0..") do set "ROOT_DIR=%%~fI"
set "SOURCE_MODELS_DIR=%ROOT_DIR%\ollama-models\models"
set "BACKUP_DIR=%ROOT_DIR%\ollama-models\backups"

set "VOLUME_NAME="
set "ASSUME_YES=0"
set "NO_BACKUP=0"

@REM Parse command-line arguments
:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="--source" (
  if "%~2"=="" goto missing_source
  set "SOURCE_MODELS_DIR=%~2"
  shift
  shift
  goto parse_args
)
if /I "%~1"=="--volume" (
  if "%~2"=="" goto missing_volume
  set "VOLUME_NAME=%~2"
  shift
  shift
  goto parse_args
)
if /I "%~1"=="--no-backup" (
  set "NO_BACKUP=1"
  shift
  goto parse_args
)
if /I "%~1"=="-y" (
  set "ASSUME_YES=1"
  shift
  goto parse_args
)
if /I "%~1"=="--yes" (
  set "ASSUME_YES=1"
  shift
  goto parse_args
)
if /I "%~1"=="-h" goto usage
if /I "%~1"=="--help" goto usage

echo Unknown option: %~1
goto usage

@REM Check required arguments
:missing_source
echo Missing value for --source
exit /b 1

:missing_volume
echo Missing value for --volume
exit /b 1

:args_done
cd /d "%ROOT_DIR%"

echo Project root: %ROOT_DIR%
echo Source models directory: %SOURCE_MODELS_DIR%

docker info >nul 2>&1
if errorlevel 1 (
  echo Docker is not running or not available.
  exit /b 1
)

if not exist "%SOURCE_MODELS_DIR%" (
  echo Source directory does not exist: %SOURCE_MODELS_DIR%
  exit /b 1
)

if not exist "%SOURCE_MODELS_DIR%\blobs" (
  echo Missing required source directory: %SOURCE_MODELS_DIR%\blobs
  exit /b 1
)

set "HAS_MANIFEST=0"
if exist "%SOURCE_MODELS_DIR%\manifests" set "HAS_MANIFEST=1"
if exist "%SOURCE_MODELS_DIR%\manifest" set "HAS_MANIFEST=1"
if "%HAS_MANIFEST%"=="0" (
  echo Missing required source manifest directory. Expected either:
  echo   %SOURCE_MODELS_DIR%\manifests
  echo   %SOURCE_MODELS_DIR%\manifest
  exit /b 1
)

if "%VOLUME_NAME%"=="" (
  for /f "delims=" %%V in ('docker inspect -f "{{ range .Mounts }}{{ if eq .Destination \"/root/.ollama\" }}{{ .Name }}{{ end }}{{ end }}" my_ollama 2^>nul') do (
    if not "%%V"=="" set "VOLUME_NAME=%%V"
  )
)

if "%VOLUME_NAME%"=="" (
  set "CANDIDATE_COUNT=0"
  for /f "delims=" %%V in ('docker volume ls --format "{{.Name}}" ^| findstr /R /C:"ollama_data$"') do (
    set /a CANDIDATE_COUNT+=1
    set "LAST_CANDIDATE=%%V"
  )

  if "!CANDIDATE_COUNT!"=="1" (
    set "VOLUME_NAME=!LAST_CANDIDATE!"
  ) else (
    echo Could not uniquely auto-detect the Ollama volume.
    echo Please provide it explicitly, for example:
    echo   scripts\add-local-models.bat --volume n8n-ollama-dev_ollama_data
    exit /b 1
  )
)

docker volume inspect "%VOLUME_NAME%" >nul 2>&1
if errorlevel 1 (
  echo Docker volume not found: %VOLUME_NAME%
  exit /b 1
)

echo Target Docker volume: %VOLUME_NAME%
echo Target path in volume: /root/.ollama/models

if "%ASSUME_YES%"=="0" (
  set /p REPLY=Proceed with importing local models into "%VOLUME_NAME%"? [y/N] 
  if /I not "%REPLY%"=="y" if /I not "%REPLY%"=="yes" (
    echo Cancelled.
    exit /b 0
  )
)

if "%NO_BACKUP%"=="0" (
  if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

  for /f "delims=" %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "TS=%%T"
  if "%TS%"=="" set "TS=backup"

  set "BACKUP_FILE=%VOLUME_NAME%_%TS%.tar.gz"
  echo Creating backup: %BACKUP_DIR%\%BACKUP_FILE%

  docker run --rm -v "%VOLUME_NAME%:/vol:ro" -v "%BACKUP_DIR%:/backup" alpine:3.20 sh -c "set -eu; cd /vol; tar -czf '/backup/%BACKUP_FILE%' ."
  if errorlevel 1 (
    echo Backup failed. Aborting import.
    exit /b 1
  )

  echo Backup complete.
) else (
  echo Backup skipped (--no-backup).
)

set "OLLAMA_WAS_RUNNING=0"
docker ps --format "{{.Names}}" | findstr /X /C:"my_ollama" >nul
if not errorlevel 1 (
  set "OLLAMA_WAS_RUNNING=1"
  echo Stopping running Ollama container for a consistent import...
  docker compose stop ollama
  if errorlevel 1 (
    echo Failed to stop ollama service.
    exit /b 1
  )
)

echo Importing model files into Docker volume...
docker run --rm -v "%VOLUME_NAME%:/target" -v "%SOURCE_MODELS_DIR%:/source:ro" alpine:3.20 sh -c "set -eu; mkdir -p /target/models; cp -a /source/blobs /target/models/; if [ -d /source/manifests ]; then cp -a /source/manifests /target/models/; fi; if [ -d /source/manifest ]; then cp -a /source/manifest /target/models/; fi"
if errorlevel 1 (
  echo Import failed.
  if "%OLLAMA_WAS_RUNNING%"=="1" docker compose start ollama >nul 2>&1
  exit /b 1
)

if "%OLLAMA_WAS_RUNNING%"=="1" (
  echo Starting Ollama container again...
  docker compose start ollama
  if errorlevel 1 (
    echo Import succeeded, but failed to start ollama service.
    exit /b 1
  )
)

echo Local models imported successfully.
echo You can verify with: docker exec my_ollama ollama list
exit /b 0

:usage
echo Usage: %~n0 [options]
echo.
echo Safely imports local Ollama model files into the Docker volume used by Ollama.
echo.
echo Options:
echo   --source ^<path^>   Source models directory ^(default: ollama-models\models^)
echo   --volume ^<name^>   Docker volume name ^(auto-detected if omitted^)
echo   --no-backup       Skip creating a backup archive before import
echo   -y, --yes         Run non-interactively ^(skip confirmation prompt^)
echo   -h, --help        Show this help message
exit /b 1