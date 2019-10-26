@echo off
tasm analride.asm /m9 /x
tlink analride.obj /t /x
process analride.com
del analride.obj

