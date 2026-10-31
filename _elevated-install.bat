@echo off
REM Elevated helper: Traccar silent install + Simple View copy + firewall hardening.
REM Run elevated only. Writes progress to _install-done.txt next to this script.

setlocal EnableExtensions
set "KIT=%~dp0"

echo [1/4] Installing Traccar server silently...
"%KIT%traccar-setup.exe" /VERYSILENT /NORESTART /SUPPRESSMSGBOXES /LOG="%TEMP%\traccar-install.log"
if errorlevel 1 echo [WARN] Installer returned errorlevel %errorlevel%

echo [2/4] Copying Simple View into the web folder...
set "TZWEB=%ProgramFiles%\Traccar\web"
if not exist "%TZWEB%" set "TZWEB=%ProgramFiles(x86)%\Traccar\web"
if exist "%TZWEB%\." (
    copy /y "%KIT%simple-view.html" "%TZWEB%\simple-view.html" >nul
    echo [OK] Simple View copied to %TZWEB%
) else (
    echo [WARN] Traccar web folder not found: %TZWEB%
)

echo [3/4] Starting the traccar service...
net start traccar 2>&1

echo [4/4] Firewall: block LAN ranges from reaching port 8082...
netsh advfirewall firewall delete rule name="Traccar 8082 LAN block v4" >nul 2>&1
netsh advfirewall firewall add rule name="Traccar 8082 LAN block v4" dir=in action=block protocol=TCP localport=8082 remoteip=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16
netsh advfirewall firewall delete rule name="Traccar 8082 LAN block v6" >nul 2>&1
netsh advfirewall firewall add rule name="Traccar 8082 LAN block v6" dir=in action=block protocol=TCP localport=8082 remoteip=fe80::/10,fc00::/7

echo DONE > "%KIT%_install-done.txt"
echo ALL STEPS COMPLETE
