@echo off
tasm intro.asm /m2 /ml /zi /z
tlink /x intro.obj
del intro.obj
