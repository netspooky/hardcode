@echo off
cls
tasm intro  /M3
tlink intro /t

post intro.com
rem encoder intro.com

del *.map
del *.obj

echo.
echo.
echo Done... INTRO.COM created..
echo.
echo.
