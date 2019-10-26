@echo off
set asmname=1kb
tasm32.exe %asmname%.asm
tlink.exe /3 /x /TDc %asmname%.obj

rename %asmname%.com %asmname%.com

del *.obj