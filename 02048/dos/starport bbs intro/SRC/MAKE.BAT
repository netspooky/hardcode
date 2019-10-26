@echo off
tasm /m9 /ml sp2.asm
if ERRORLEVEL 1 goto end
tlink /t /x sp2.obj
:end
