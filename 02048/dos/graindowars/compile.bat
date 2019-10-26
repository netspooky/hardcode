nasm -o graindowars.com graindowars.asm
if errorlevel 1 goto failed
graindowars.com

:failed
pause