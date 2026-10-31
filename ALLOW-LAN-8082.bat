@echo off
setlocal EnableExtensions
title Allow phone on Wi-Fi (port 8082)
REM Run this ONCE as Administrator (right-click > Run as administrator).
REM Lets devices on your own Wi-Fi reach the tracker server on port 8082.
REM (Only the local network - nothing on the public internet.)

net session >nul 2>&1
if not %errorlevel%==0 (
    echo Requesting Administrator rights - one UAC prompt...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

netsh advfirewall firewall delete rule name="Traccar 8082 LAN allow" >nul 2>&1
netsh advfirewall firewall add rule name="Traccar 8082 LAN allow" dir=in action=allow protocol=TCP localport=8082 remoteip=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16
echo.
echo [OK] Done. Your phone can now reach http://YOUR-PC-IP:8082 on the same Wi-Fi.
echo      (This PC's address: run "ipconfig" and look for IPv4.)
pause
