@echo off
setlocal EnableExtensions
title Stop Traccar Server
REM Stops the portable Traccar server (kills whatever listens on 8082).

set FOUND=0
for /f "tokens=5" %%p in ('netstat -ano ^| findstr ":8082" ^| findstr LISTENING') do (
    echo Stopping PID %%p ...
    taskkill /PID %%p /F >nul 2>&1
    set FOUND=1
)
if %FOUND%==0 (
    echo [OK] Server is not running.
) else (
    echo [OK] Server stopped. History is saved in server\data\database.mv.db
)
pause
