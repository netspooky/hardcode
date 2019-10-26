@echo off
tasm32.exe snow.asm
tlink.exe /3 /x /TDc snow.obj

rename snow.com snow.com

del *.obj