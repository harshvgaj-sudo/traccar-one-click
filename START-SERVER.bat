@echo off
setlocal EnableExtensions
title Traccar Server (portable)
REM Starts the portable Traccar server with its bundled Java 21 runtime.
REM Dashboard: http://localhost:8082  -  Simple View: http://localhost:8082/simple-view.html

if not exist "%~dp0server\tracker-server.jar" (
    echo [ERROR] server folder not found next to this script.
    pause
    exit /b 1
)
if not exist "%~dp0jre21\bin\java.exe" (
    echo [ERROR] jre21 folder not found next to this script.
    pause
    exit /b 1
)

netstat -ano | findstr ":8082" | findstr LISTENING >nul 2>&1
if not errorlevel 1 (
    echo [OK] Server already running.
    start http://localhost:8082
    exit /b 0
)

echo Starting Traccar server...
cd /d "%~dp0server"
start "Traccar Server" /min "%~dp0jre21\bin\java.exe" -jar tracker-server.jar conf/traccar.xml
timeout /t 8 /nobreak >nul
start http://localhost:8082
echo [OK] Server starting. Keep the minimized "Traccar Server" window open.
echo      To stop it later, run STOP-SERVER.bat.
pause
