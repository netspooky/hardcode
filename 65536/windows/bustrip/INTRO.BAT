@echo off
echo "Starting demo"
call Bustrip.exe

if errorlevel == 0 echo everything is fine
if errorlevel == -3 echo tinyptc initialisation error
if errorlevel == -1 echo fmod initialisation error
if errorlevel == -2 echo fmod playing error

echo "Press any key..."
pause