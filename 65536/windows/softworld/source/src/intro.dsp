# Microsoft Developer Studio Project File - Name="intro" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=intro - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "intro.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "intro.mak" CFG="intro - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "intro - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "intro - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "intro - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "intro___Win32_Release"
# PROP BASE Intermediate_Dir "intro___Win32_Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "intro___Win32_Release"
# PROP Intermediate_Dir "intro___Win32_Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MDd /W3 /GX /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 opengl32.lib glu32.lib glaux.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386 /nodefaultlib:"libcmt.lib" /nodefaultlib:"libcd.lib" /nodefaultlib:"libcmtd.lib" /nodefaultlib:"msvcrtd.lib"
# SUBTRACT LINK32 /incremental:yes /nodefaultlib

!ELSEIF  "$(CFG)" == "intro - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "intro___Win32_Debug"
# PROP BASE Intermediate_Dir "intro___Win32_Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "intro___Win32_Debug"
# PROP Intermediate_Dir "intro___Win32_Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 opengl32.lib glu32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "intro - Win32 Release"
# Name "intro - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Group "gif No. 1"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\gifdecoder\BitStream.cpp
# End Source File
# Begin Source File

SOURCE=.\gifdecoder\GifDecoder.cpp
# End Source File
# End Group
# Begin Source File

SOURCE=.\3d_intro.cpp
# End Source File
# Begin Source File

SOURCE=.\intro.cpp
# End Source File
# Begin Source File

SOURCE=.\metaballs\metalib.c
# End Source File
# Begin Source File

SOURCE=.\normal.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Group "Textures"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\essai\briquea.h
# End Source File
# Begin Source File

SOURCE=.\essai\chat.h
# End Source File
# Begin Source File

SOURCE=.\essai\FD1B.H
# End Source File
# Begin Source File

SOURCE=.\essai\FD2B.H
# End Source File
# Begin Source File

SOURCE=.\essai\fnt3.h
# End Source File
# Begin Source File

SOURCE=.\essai\oeuf9.h
# End Source File
# Begin Source File

SOURCE=.\essai\RUB.H
# End Source File
# Begin Source File

SOURCE=.\essai\t_carot9.h
# End Source File
# Begin Source File

SOURCE=.\essai\TETOILE.H
# End Source File
# Begin Source File

SOURCE=.\essai\TGLACE9.H
# End Source File
# End Group
# Begin Group "Obj3d"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\essai\carotte.h
# End Source File
# Begin Source File

SOURCE=.\essai\etoile.h
# End Source File
# Begin Source File

SOURCE=.\essai\glace2.h
# End Source File
# Begin Source File

SOURCE=.\essai\o_oeuf2.h
# End Source File
# Begin Source File

SOURCE=.\essai\pot2fleur4.h
# End Source File
# End Group
# Begin Group "Music"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\essai\SOFTWRLD.H
# End Source File
# End Group
# Begin Group "Metaballs"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\metaballs\metalib.h
# End Source File
# End Group
# Begin Group "gif"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\gifdecoder\BitStream.h
# End Source File
# Begin Source File

SOURCE=.\gifdecoder\GifDecoder.h
# End Source File
# End Group
# Begin Source File

SOURCE=.\3d_intro.h
# End Source File
# Begin Source File

SOURCE=.\normal.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# Begin Source File

SOURCE=.\ReadMe.txt
# End Source File
# Begin Source File

SOURCE=.\minifmod.lib
# End Source File
# Begin Source File

SOURCE=.\lib\Winmm.lib
# End Source File
# End Target
# End Project
