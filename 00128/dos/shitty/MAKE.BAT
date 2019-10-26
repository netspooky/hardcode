@ECHO OFF
tasm /t plot.asm
tlink /t plot.obj
del *.map
del *.obj
