@echo off

rem c:\asm16\tasm d:\plasma32\kernel\kernel /m /p /q

c:\asm16\tasm d:\plasma32\plasma32 /m /p /q
c:\asm16\tlink d:\plasma32\plasma32 kernel\kernel,plasma32.exe /3 /x

del *.obj
