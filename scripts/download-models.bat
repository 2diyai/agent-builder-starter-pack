@echo off
setlocal

set ROOT_DIR=%~dp0..
cd /d "%ROOT_DIR%"

set MODEL_LIST=list-of-models.txt

if not exist "%MODEL_LIST%" (
  echo Missing %MODEL_LIST%
  exit /b 1
)

docker compose ps --status running ollama >nul 2>&1
if errorlevel 1 (
  echo Warning: ollama service is not running. Start it first with scripts\start.bat
  exit /b 1
)

for /f "usebackq tokens=* delims=" %%M in ("%MODEL_LIST%") do (
  set "LINE=%%M"
  if not "%%M"=="" (
    echo %%M | findstr /r /c:"^#" >nul
    if errorlevel 1 (
      echo Pulling model: %%M
      docker compose exec -T ollama ollama pull %%M
    )
  )
)

echo Model download complete.
endlocal