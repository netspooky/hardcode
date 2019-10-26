@ECHO OFF

tasm		%1.asm /m
tlink		%1.obj /3
del		%1.obj
del		%1.map
chophead	%1.exe 512
move		%1.exe %1.com
