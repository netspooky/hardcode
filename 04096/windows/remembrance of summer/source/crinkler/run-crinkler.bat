set PSDKDIR=C:\Program Files\Microsoft Platform SDK
set VCDIR=C:\Program Files\Microsoft Visual Studio 8\VC
echo.>cmd.txt
echo /CRINKLER>>cmd.txt
echo /VERBOSE:FUNCTIONS>>cmd.txt
echo /VERBOSE:LABELS>>cmd.txt
echo /VERBOSE:IMPORTS>>cmd.txt
echo /OUT:%1>>cmd.txt
echo /COMPMODE:FAST>>cmd.txt
echo /LIBPATH:"%VCDIR%\lib">> cmd.txt
echo /LIBPATH:"%PSDKDIR%\lib">> cmd.txt
echo /SUBSYSTEM:WINDOWS>> cmd.txt
echo /RANGE:opengl32>> cmd.txt
echo /RANGE:glu32>> cmd.txt
echo kernel32.lib user32.lib gdi32.lib opengl32.lib glu32.lib winmm.lib ole32.lib imm32.lib>> cmd.txt
for %%F IN (*.obj) DO echo %%F>> cmd.txt
..\crinkler\crinkler.exe @cmd.txt
del cmd.txt
