
PATH=%PATH%;%HOMEDRIVE%\windows\system32
call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"

crinkler.exe /OUT:bnz2c1k.exe /SUBSYSTEM:WINDOWS /ENTRY:entrypoint /RANGE:opengl32  /COMPMODE:SLOW /ORDERTRIES:1000 /PRINT:IMPORTS /PRINT:LABELS kernel32.lib user32.lib gdi32.lib opengl32.lib glu32.lib winmm.lib ..\Release\main.obj

pause
