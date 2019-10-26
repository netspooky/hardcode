@echo off
tasm /m /ml /t /w2 /z rot2d1.asm
tlink /3 /c /t /x rot2d1.obj
tasm /m /ml /t /w2 /z rot2d2.asm
tlink /3 /c /t /x rot2d2.obj
tasm /m /ml /t /w2 /z rot2d3.asm
tlink /3 /c /t /x rot2d3.obj
tasm /m /ml /t /w2 /z rot2d4.asm
tlink /3 /c /t /x rot2d4.obj
tasm /m /ml /t /w2 /z rot2d5.asm
tlink /3 /c /t /x rot2d5.obj
tasm /m /ml /t /w2 /z rot2d6.asm
tlink /3 /c /t /x rot2d6.obj
del *.obj