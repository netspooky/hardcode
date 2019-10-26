@echo off
tasm %1 /m
tlink /t %1
erase *.map
erase *.obj
%1.com
