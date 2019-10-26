@echo off

call	setenv.bat

%MASM_PATH%\bin\ml /I%MASM_PATH%\include /nologo /c /Cp /Fl%SOURCE_NAME%.asl /Sc /Sn %SOURCE_NAME%.asm
%MASM_PATH%\bin\link /NOLOGO /MAP /SUBSYSTEM:WINDOWS /LIBPATH:%MASM_PATH%\lib %SOURCE_NAME%.obj kernel32.lib gdi32.lib user32.lib winmm.lib dsound.lib glu32.lib opengl32.lib /OUT:%MAKE_NAME%.exe
