@echo off
tasm /m2 /q /zn cpw
if errorlevel 1 goto end
tlink /x /n cpw
del cpw.obj
:end
