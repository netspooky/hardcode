@echo off
tasm fire.asm /m2 /q /t
tlink fire.obj /t /yx /x
del *.obj
