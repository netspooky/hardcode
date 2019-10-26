@echo off
echo HTA maker - uses CabArc from "Cabinet Software Development Kit"
echo Making x.cab
cabarc n x.cab x x.hta
echo Making out.bat with extraction commands. 
copy /b x.cab+post.bin out.bat
echo Resulting size of
dir out.bat
echo.
echo Warning!  Do not run out.bat from this directory if you are 
echo playing with x.hta.  When it runs, it will overwrite x.hta
echo and delete x and x.hta when finished running. 

