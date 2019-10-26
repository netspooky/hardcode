@echo off
tasm outlaw.asm
if errorlevel 1 then goto end:
tlink outlaw.obj
outlaw.exe

:end
del *.bak
del *.obj
del *.map
