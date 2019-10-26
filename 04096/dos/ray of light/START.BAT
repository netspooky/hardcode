@echo off
echo This intro has gmidi sound support...
echo MEGAEM will now be loaded to switch the gus in GM-compatibility mode.
echo The GMIDI-Port should be at 330h!
echo UNIVBE will be loaded for VESA Support!
echo.
echo Press any key...
pause >nul
call megaem
call univbe
mag-ray.com
