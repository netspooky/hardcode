@ECHO OFF
cls
echo.
echo Building TPP1.ASM
echo.
if '%1'=='DEBUG' goto DebugMode
tasm /m3 tpp1
tlink /e /x tpp1,tpp1.exe
lzexe tpp1
goto Ended

:DebugMode
tasm /m3 /zi tpp1
tlink /e /x /v tpp1,tpp1.exe

:Ended
cls

del tpp1.old
del tpp1.obj
