@echo off
set asmname=keygen

if exist rsrc.obj goto :nores

rc.exe rsrc.rc
if exist rsrc.res goto :rcok
pause
goto :quit
:rcok
cvtres.exe /nologo /machine:ix86 rsrc.res
if exist rsrc.obj goto :resok
pause
del rsrc.res
goto :quit
:resok
del rsrc.res

:nores
ml.exe /nologo /c /coff %asmname%.asm
if not exist %asmname%.obj pause
link.exe /nologo /SUBSYSTEM:WINDOWS /merge:.text=.code %asmname%.obj rsrc.obj
del %asmname%.obj
upx.exe --best %asmname%.exe
:quit
set asmname=