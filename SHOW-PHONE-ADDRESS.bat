@echo off
setlocal EnableExtensions
title Traccar - Phone Address
REM ============================================================
REM  Shows the address your phone app needs. Works from ANYWHERE
REM  (including mobile data) because your phone and this PC are
REM  on the same private Tailscale network. No port forwarding,
REM  no public exposure, no Google.
REM ============================================================

set "TS=%ProgramFiles%\Tailscale\tailscale.exe"
if exist "%TS%" goto run
where tailscale >nul 2>&1
if %errorlevel%==0 (
    set "TS=tailscale"
    goto run
)
echo [ERROR] Tailscale not found. Run SETUP-TRACKER.bat first.
pause
exit /b 1

:run
echo Getting your private address...
set TSIP=
for /f "usebackq tokens=1" %%i in (`"%TS%" ip -4`) do set "TSIP=%%i"

if not defined TSIP (
    echo [ERROR] No Tailscale address found. Are you logged in?
    echo Run: "%TS%" up   then try again.
    pause
    exit /b 1
)

echo.
echo ============================================
echo  In the Traccar Client app on your phone,
echo  type EXACTLY this as the Server URL:
echo.
echo      http://%TSIP%:8082
echo.
echo  Leave Username and Password EMPTY in the
echo  app - the Device Identifier is your key.
echo ============================================
echo.
echo Dashboard on this PC  : http://localhost:8082
echo Simple View (clean UI): http://%TSIP%:8082/simple-view.html
echo Same address works on home WiFi and outside.
pause
