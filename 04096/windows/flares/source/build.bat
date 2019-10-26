@echo off
set asmname=flares

ml.exe /nologo /c /coff %asmname%.asm
if not exist %asmname%.obj pause
link.exe /nologo /SUBSYSTEM:WINDOWS /ignore:4078 /merge:.text=.rdata /merge:.text=comrade %asmname%.obj
del %asmname%.obj
:quit
set asmname=