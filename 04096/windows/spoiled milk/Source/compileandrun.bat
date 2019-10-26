@del 1kframework.exe
@..\Assembler\nasm.exe -f win32 1kframework.asm
@..\Assembler\nasm.exe -f win32 -w-number-overflow Sonant~1\sonant2.asm
@..\crinkler13\crinkler.exe /OUT:1kframework.exe /CRINKLER /COMPMODE:INSTANT /PRIORITY:NORMAL /SUBSYSTEM:WINDOWS /ENTRY:main /UNSAFEIMPORT /TRANSFORM:CALLS /REPORT:crklrout.htm ..\Lib\kernel32.lib ..\Lib\user32.lib ..\Lib\gdi32.lib ..\Lib\opengl32.lib ..\Lib\glu32.lib ..\Lib\winmm.lib 1kframework.obj Sonant~1\sonant2.obj
@1kframework.exe