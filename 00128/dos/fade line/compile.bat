@ECHO OFF
cls
tasm     fadlin.asm /m
tlink    fadlin.obj
chophead fadlin.exe 512
del      fadlin.obj
del      fadlin.map
move     fadlin.exe fadlin.com
pause
