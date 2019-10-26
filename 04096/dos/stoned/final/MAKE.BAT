@echo off
REM ***** Makefile for 'Stoned' / Copyright (C) 1994, 1995 by Markus Stein

REM ***** Assemble (needs Turbo Assembler and Turbo Link)
tasm /z stoned
if exist stoned.com del stoned.com >nul
tlink /x /t stoned >nul
if exist stoned.obj del stoned.obj >nul

REM ***** Postprocess to cut off zeros at the end of the file
echo Postprocessing...
postproc stoned.com >nul

REM ***** Pack with PKLite (makes it about 10% smaller)
echo Packing with PKLite...
pklite stoned.com >nul

REM ***** Append the Copyright Message to the end of the file
echo Appending Copyright Message...
copy /b stoned.com+stoned.end stoned.com >nul
