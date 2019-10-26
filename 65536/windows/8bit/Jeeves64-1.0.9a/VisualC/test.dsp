# Microsoft Developer Studio Project File - Name="test" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 5.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=test - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "test.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "test.mak" CFG="test - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "test - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "test - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "test - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "test___Win32_Release"
# PROP BASE Intermediate_Dir "test___Win32_Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "release"
# PROP Intermediate_Dir "release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O1 /Ob0 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /FD /Zm1000 /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0xc09 /d "NDEBUG"
# ADD RSC /l 0xc09 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 MSVCRT.LIB winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /map /machine:I386 /nodefaultlib
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "test - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "test___W"
# PROP BASE Intermediate_Dir "test___W"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "debug"
# PROP Intermediate_Dir "debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /W3 /GX /O1 /Ob0 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /FD /Zm1000 /c
# ADD CPP /nologo /MD /W3 /GX /Zi /O1 /Ob0 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /FD /Zm1000 /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0xc09 /d "NDEBUG"
# ADD RSC /l 0xc09 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 MSVCRT.LIB winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /map /machine:I386 /nodefaultlib
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 MSVCRT.LIB winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /map /debug /machine:I386 /nodefaultlib
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "test - Win32 Release"
# Name "test - Win32 Debug"
# Begin Group "intro files"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\src\blob.h
# End Source File
# Begin Source File

SOURCE=..\src\plasma.h
# End Source File
# Begin Source File

SOURCE=..\src\polar.h
# End Source File
# Begin Source File

SOURCE=..\src\tiles.h
# End Source File
# Begin Source File

SOURCE=..\src\transition.h
# End Source File
# Begin Source File

SOURCE=..\src\zoem.h
# End Source File
# End Group
# Begin Group "tinyptc files"

# PROP Default_Filter ""
# Begin Source File

SOURCE="..\src\tinyptc-win_8bit\convert.h"
# End Source File
# Begin Source File

SOURCE="..\src\tinyptc-win_8bit\convert_8bit.c"
# End Source File
# Begin Source File

SOURCE="..\src\tinyptc-win_8bit\ddraw_8bit.c"
# End Source File
# Begin Source File

SOURCE="..\src\tinyptc-win_8bit\tinyptc.c"
# End Source File
# Begin Source File

SOURCE="..\src\tinyptc-win_8bit\tinyptc.h"
# End Source File
# End Group
# Begin Group "fxmp files"

# PROP Default_Filter ""
# Begin Source File

SOURCE=..\src\fxmp\config.h
# End Source File
# Begin Source File

SOURCE=..\src\fxmp\decode_xm.c
# End Source File
# Begin Source File

SOURCE=..\src\fxmp\drv_dsp.c
# End Source File
# Begin Source File

SOURCE=..\src\fxmp\drv_dsp.h
# End Source File
# Begin Source File

SOURCE=..\src\fxmp\fxmp.c
# End Source File
# Begin Source File

SOURCE=..\src\fxmp\fxmp.h
# End Source File
# Begin Source File

SOURCE=..\src\fxmp\types.h
# End Source File
# End Group
# Begin Group "jeeves64 files"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Icon.rc

!IF  "$(CFG)" == "test - Win32 Release"

!ELSEIF  "$(CFG)" == "test - Win32 Debug"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=..\src\jeeves64.h
# End Source File
# Begin Source File

SOURCE=..\src\test.cpp
# End Source File
# Begin Source File

SOURCE=..\src\typeface64.h
# End Source File
# End Group
# Begin Source File

SOURCE=..\data\64k.ico
# End Source File
# End Target
# End Project
