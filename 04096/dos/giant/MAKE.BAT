@Echo off
tasm /m9 /ml /q GIANT.ASM
if ERRORLEVEL 1 goto end
tlink /t /x GIANT.OBJ
:end
