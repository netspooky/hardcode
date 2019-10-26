@echo off
tasm fire256r.asm /m9 /zn
tlink fire256r.obj /x
wwpack o fire256r.exe
del fire256r.obj