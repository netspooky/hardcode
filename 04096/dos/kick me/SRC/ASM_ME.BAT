: *************************************************
: This shows you the way Kick Me must be assembled!
:    By Baah in July 1995. 
: *************************************************
echo off
cls
tasm /m3 kick_me.s
if exist kick_me.obj goto cont1 
goto end
:cont1
tlink kick_me.obj
del kick_me.obj
if exist kick_me.exe goto cont2
goto end
:cont2
rincbin kick_me.exe 
del kick_me.map
:end
