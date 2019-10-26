# Microsoft Developer Studio Project File - Name="bob" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=bob - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "bob.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "bob.mak" CFG="bob - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "bob - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "bob - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "bob - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "../bob.bin"
# PROP Intermediate_Dir "../bob.tmp"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /G6 /MD /W3 /O1 /I "d:\prog\dx7sdk\include" /D "NDEBUG" /D "WIN32" /FR /YX /FD /c
# ADD BASE RSC /l 0x413 /d "NDEBUG"
# ADD RSC /l 0x413 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib ddraw.lib dinput.lib winmm.lib MSVCRT.LIB /nologo /map /machine:I386 /nodefaultlib
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "bob - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "../bob.bin"
# PROP Intermediate_Dir "../bob.tmp"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /G6 /MDd /W3 /Gm /Zi /Od /I "d:\prog\dx7sdk\include" /D "_DEBUG" /D "WIN32" /FR /YX /FD /GZ /c
# ADD BASE RSC /l 0x413 /d "_DEBUG"
# ADD RSC /l 0x413 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib ddraw.lib dinput.lib winmm.lib MSVCRT.LIB /nologo /map /debug /machine:I386 /nodefaultlib /pdbtype:sept
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "bob - Win32 Release"
# Name "bob - Win32 Debug"
# Begin Group "src"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\bob.src\gettime.c
# End Source File
# Begin Source File

SOURCE=..\bob.src\gettime.h
# End Source File
# Begin Source File

SOURCE=..\bob.src\typeface.c
# End Source File
# Begin Source File

SOURCE=..\bob.src\typeface.h
# End Source File
# End Group
# Begin Group "fxmp.src"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\fxmp.src\config.h
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\drv_win.c
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\drv_win.h
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\freq.c
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\freq.h
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\fxmp.c
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\fxmp.h
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\load_xm.c
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\load_xm.h
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\ticker.c
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\ticker.h
# End Source File
# Begin Source File

SOURCE=..\fxmp.src\types.h
# End Source File
# End Group
# Begin Group "dx7.src"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\bob.src\bob_dx7.c
# End Source File
# Begin Source File

SOURCE=..\bob.src\bob_dx7.h
# End Source File
# Begin Source File

SOURCE=..\bob.src\convert.h
# End Source File
# Begin Source File

SOURCE=..\bob.src\convert_8bit.c
# End Source File
# Begin Source File

SOURCE=..\bob.src\win32cfg.h
# End Source File
# End Group
# Begin Group "bob.src"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\bob.src\bob_data.c
# End Source File
# Begin Source File

SOURCE=..\bob.src\bob_data.h
# End Source File
# Begin Source File

SOURCE=..\bob.src\bob_game.c
# End Source File
# Begin Source File

SOURCE=..\bob.src\bob_game.h
# End Source File
# Begin Source File

SOURCE=..\bob.src\bob_text.c
# End Source File
# Begin Source File

SOURCE=..\bob.src\bob_text.h
# End Source File
# Begin Source File

SOURCE=..\bob.src\main.c
# End Source File
# End Group
# Begin Group "doc"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\doc\changelog.txt
# End Source File
# Begin Source File

SOURCE=..\..\readme.html
# End Source File
# Begin Source File

SOURCE=..\doc\todo.txt
# End Source File
# End Group
# Begin Group "data"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\data.tmp\drbob2.pal.h
# End Source File
# Begin Source File

SOURCE=..\data.tmp\drbob20.jrs.h
# End Source File
# Begin Source File

SOURCE=..\data.tmp\drbob20.jtf.h
# End Source File
# Begin Source File

SOURCE=..\data.tmp\drbob21.jrs.h
# End Source File
# Begin Source File

SOURCE=..\data.tmp\drbob21.jtf.h
# End Source File
# Begin Source File

SOURCE=..\data.tmp\game.xm.h
# End Source File
# Begin Source File

SOURCE=..\data.tmp\menu.xm.h
# End Source File
# End Group
# End Target
# End Project
