@echo off
setlocal EnableExtensions
title Traccar One-Click Setup
REM ============================================================
REM  TRACCAR PERSONAL TRACKER - ONE-CLICK SETUP (2026-10-31)
REM  What this does, in order:
REM    1. Downloads the official Traccar server v6.16.0 (free,
REM       open source, Apache-2.0) and installs it as a Windows
REM       service that auto-starts with your PC.
REM    2. Installs Tailscale (private network - sign in with
REM       GitHub, NOT Google) so your phone can reach this PC
REM       from anywhere, even on mobile data.
REM    3. Opens the dashboard and the Tailscale login page.
REM  Nothing here sends data to anyone except YOUR OWN server.
REM ============================================================

echo.
echo ============================================
echo   STEP 1 of 3 : TRACCAR SERVER
echo ============================================

sc query traccar >nul 2>&1
if %errorlevel%==0 (
    echo [OK] Traccar is already installed. Skipping download.
    goto tails
)

set TZFILE=traccar-windows-64-6.16.0.zip
set TZURL=https://github.com/traccar/traccar/releases/download/v6.16.0/traccar-windows-64-6.16.0.zip

echo Downloading Traccar v6.16.0 (about 100 MB, please wait)...
curl -L --progress-bar -o "%TEMP%\%TZFILE%" "%TZURL%"
if errorlevel 1 (
    echo [ERROR] Download failed. Check internet and run this file again.
    pause
    exit /b 1
)

echo Extracting...
powershell -NoProfile -Command "Expand-Archive -Force '%TEMP%\%TZFILE%' '%TEMP%\traccar-setup'"
if exist "%TEMP%\traccar-setup\traccar-setup.exe" (
    set "TZEXE=%TEMP%\traccar-setup\traccar-setup.exe"
) else (
    for /r "%TEMP%\traccar-setup" %%f in (traccar-setup*.exe) do set "TZEXE=%%f"
)

if not defined TZEXE (
    echo [ERROR] Installer not found inside the zip.
    pause
    exit /b 1
)

echo Installing Traccar as a Windows service...
"%TZEXE%" /VERYSILENT /NORESTART /SUPPRESSMSGBOXES
timeout /t 10 /nobreak >nul
sc query traccar >nul 2>&1
if not %errorlevel%==0 (
    echo [NOTE] Silent install did not finish. Opening the normal
    echo        installer instead - just click Next, Next, Finish.
    start "" "%TZEXE%"
    echo        When it finishes, run this file once more.
    pause
    exit /b 0
)
echo [OK] Traccar service installed.

:tails
echo.
echo ============================================
echo   STEP 2 of 3 : TAILSCALE (private network)
echo ============================================

where tailscale >nul 2>&1
if %errorlevel%==0 (
    echo [OK] Tailscale already installed.
    goto startsvc
)

where winget >nul 2>&1
if %errorlevel%==0 (
    echo Installing Tailscale via winget...
    winget install --id tailscale.tailscale -e -h --accept-package-agreements --accept-source-agreements
) else (
    echo winget not found - downloading Tailscale installer directly...
    curl -L --progress-bar -o "%TEMP%\tailscale-setup.exe" https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe
    if errorlevel 1 (
        echo [ERROR] Download failed. Check internet and run this file again.
        pause
        exit /b 1
    )
    "%TEMP%\tailscale-setup.exe" /quiet /norestart
)
timeout /t 5 /nobreak >nul

:startsvc
echo.
echo ============================================
echo   STEP 3 of 3 : START EVERYTHING
echo ============================================

net start traccar 2>nul

set "TSCMD=tailscale"
if exist "%ProgramFiles%\Tailscale\tailscale.exe" set "TSCMD=%ProgramFiles%\Tailscale\tailscale.exe"

echo Installing Simple View (the clean personal viewer)...
set "TZWEB=%ProgramFiles%\Traccar\web"
if not exist "%TZWEB%" set "TZWEB=%ProgramFiles(x86)%\Traccar\web"
if exist "%TZWEB%" (
    if exist "%~dp0simple-view.html" (
        copy /y "%~dp0simple-view.html" "%TZWEB%\simple-view.html" >nul
        echo [OK] Simple View installed.
    )
) else (
    echo [NOTE] Traccar web folder not found - Simple View not copied.
)

echo Starting Tailscale login. A browser window will open.
echo SIGN IN WITH GITHUB (not Google). This is one time only.
%TSCMD% up

start http://localhost:8082
echo.
echo ============================================
echo   SETUP DONE. Last three things:
echo   1. In the dashboard, login with admin / admin,
echo      then CHANGE the password.
echo   2. Run SHOW-PHONE-ADDRESS.bat to get the
echo      address to type into the phone app.
echo   3. Your clean viewer lives at:
echo      http://localhost:8082/simple-view.html
echo ============================================
pause
