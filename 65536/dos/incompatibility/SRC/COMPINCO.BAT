@echo off
cls
echo.
echo              þ Compiling INCOMPATIBILITY þ
echo.
echo This may take a while, eg. more than 1 min. on a 386SX25...
echo.
echo Press CTRL-C to Cancel, other key to continue...
pause >nul
echo.
tasm incompa.asm /m9
tlink incompa.obj s3mshort.obj /3
del incompa.map
cls
echo.
echo Ready.
echo.