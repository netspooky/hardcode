@echo off
if not "%1" == "" goto %1
echo Usage: %0 tasm/nasm/ml
goto end

:ml
ml /AT firework.asm
del *.obj
goto end

:tasm
tasm firework.asm /m2
if not errorlevel 1 tlink /t firework.obj
del *.obj 
del *.map
goto end

:nasm
nasm -o firework.com firework.a

:end