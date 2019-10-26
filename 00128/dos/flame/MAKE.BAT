@echo off
tasm flame /m
tlink /t flame
erase *.map
erase *.obj
echo:
echo:
