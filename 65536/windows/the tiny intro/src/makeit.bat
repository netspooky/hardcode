@echo off
cls

echo {---------------------------------}
echo {---------------------------------}
echo {-----------HxC2001 Intro---------}
echo {------www.powerofasm.fr.st-------}
echo {--jeanfrancoisdelnero@libero.it--}
echo {---------------------------------}
echo {---------------------------------}


if not exist rsrc/rsrc.rc goto over1
e:\MASM32\BIN\Rc.exe /v rsrc/rsrc.rc 
move rsrc\rsrc.res build\rsrc.res
e:\MASM32\BIN\Cvtres.exe /machine:ix86 build/rsrc.res

:over1

if exist build\%1.obj del HxC2001.obj
if exist build\%1.exe del HxC2001.exe

e:\MASM32\BIN\Ml.exe /c /coff /Fobuild\Hxc2001.obj main\HxC2001.asm

if errorlevel 1 goto errasm


if not exist build\rsrc.obj goto nores
e:\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS build\HxC2001.obj build\rsrc.obj 
if errorlevel 1 goto errlink

goto TheEnd

:nores
e:\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS build\HxC2001.obj 
if errorlevel 1 goto errlink
goto TheEnd

:errlink
echo _
echo Link error
goto TheEnd

:errasm
echo _
echo Assembly Error
goto TheEnd

:TheEnd
dir *.exe

del build\*.obj
del build\*.res

echo {---------------------------------}
echo {---------------------------------}
echo {-----------HxC2001 Intro---------}
echo {------www.powerofasm.fr.st-------}
echo {--jeanfrancoisdelnero@libero.it--}
echo {---------------------------------}
echo {---------------------------------}


pause

