@echo off
tasm /m /ml /t /w2 /z rot2d5.asm
tlink /3 /c /t /x rot2d5.obj
tasm /m /ml /t /w2 /z rot2d6.asm
tlink /3 /c /t /x rot2d6.obj
del *.obj
