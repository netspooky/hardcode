REM thread.bat by luis           

@echo off
set /a "x=%RANDOM%%%2"
if %x%==0 (<nul set /p=\) ELSE <nul set /p=/
thread.bat