@echo off
del chicken.com
tasm chicken.asm
tlink /t chicken.obj
rem exe2bin chicken.exe
rem copy chicken.exe chicken.com
rem del chicken.exe
dir chicken.com
pause
chicken.com
