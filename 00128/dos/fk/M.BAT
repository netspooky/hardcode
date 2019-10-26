@echo off
tasm /m2 /q /t /zn fk
if ERRORLEVEL 1 goto end
tlink /x /tc fk
del fk.obj
:end
