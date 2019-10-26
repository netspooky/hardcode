@echo off
tasm /m /ml /t /w2 /z sbmeta.asm
tlink /3 /c /t /x sbmeta.obj
del *.obj
