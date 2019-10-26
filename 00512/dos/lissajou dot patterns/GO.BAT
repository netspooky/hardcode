tasm /m3 /z lissajou.asm
if errorlevel == 1 goto in_the_ass
tlink /i /x /t /3 lissajou.obj, lissajou.com
:in_the_ass