@echo off

c:\asm16\tasm d:\naag11\naag /m /p /q
c:\asm16\tlink d:\naag11\naag kernel\kernel,naag.exe /3 /x

del *.obj

d:\upx d:\naag11\naag.exe
