@Echo off
tasm /m3 /l %1.asm
tlink /t %1
del %1.map
del %1.obj
WWPACK %1.com
%1.exe

