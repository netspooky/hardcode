@tasm /m3 tron.asm, tron.obj
@if errorlevel == 1 goto nooo
@tlink /t /x /3 tron.obj, tron.com
@del tron.obj
rem @comopt tron.com
:nooo
