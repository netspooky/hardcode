# Microsoft Developer Studio Project File - Name="Durantro" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=Durantro - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Durantro.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Durantro.mak" CFG="Durantro - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Durantro - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "Durantro - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE "Durantro - Win32 Final" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/desa/Durantro", DKAAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Durantro - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /Zi /O1 /I "minifmod140" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0xc0a /d "NDEBUG"
# ADD RSC /l 0xc0a /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib d3d8.lib /nologo /subsystem:windows /map /debug /machine:I386 /opt:ref /opt:nowin98
# SUBTRACT LINK32 /pdb:none
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Desc=UPXando
PostBuild_Cmds=upx -9 Release\Durantro.exe
# End Special Build Tool

!ELSEIF  "$(CFG)" == "Durantro - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /Zi /Od /I "minifmod140" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0xc0a /d "_DEBUG"
# ADD RSC /l 0xc0a /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib d3d8.lib /nologo /subsystem:windows /map /debug /machine:I386 /pdbtype:sept

!ELSEIF  "$(CFG)" == "Durantro - Win32 Final"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Durantro___Win32_Final"
# PROP BASE Intermediate_Dir "Durantro___Win32_Final"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Final"
# PROP Intermediate_Dir "Final"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /W3 /GX /Zi /O1 /I "minifmod140" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /O1 /I "minifmod140" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "VERSIONFINAL" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0xc0a /d "NDEBUG"
# ADD RSC /l 0xc0a /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib d3d8.lib /nologo /subsystem:windows /map /machine:I386 /opt:ref /opt:nowin98
# SUBTRACT BASE LINK32 /pdb:none
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib d3d8.lib /nologo /subsystem:windows /map /machine:I386 /opt:ref /opt:nowin98
# SUBTRACT LINK32 /pdb:none
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Desc=UPXando
PostBuild_Cmds=upx -9 Final\Durantro.exe
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "Durantro - Win32 Release"
# Name "Durantro - Win32 Debug"
# Name "Durantro - Win32 Final"
# Begin Group "minifmod"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\minifmod140\allxmeffects.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\Fmusic.c
# End Source File
# Begin Source File

SOURCE=.\minifmod140\Fsound.c
# End Source File
# Begin Source File

SOURCE=.\minifmod140\minifmod.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\Mixer.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\mixer_clipcopy.c
# End Source File
# Begin Source File

SOURCE=.\minifmod140\mixer_clipcopy.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\mixer_fpu_ramp.c
# End Source File
# Begin Source File

SOURCE=.\minifmod140\mixer_fpu_ramp.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\Music.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\music_formatxm.c
# End Source File
# Begin Source File

SOURCE=.\minifmod140\music_formatxm.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\Sound.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\system_file.c
# End Source File
# Begin Source File

SOURCE=.\minifmod140\system_file.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\system_memory.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\xmeffects.h
# End Source File
# Begin Source File

SOURCE=.\minifmod140\Winmm.lib
# End Source File
# End Group
# Begin Group "Motor"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\DisplayDevice.cpp
# End Source File
# Begin Source File

SOURCE=.\DisplayDevice.h
# End Source File
# Begin Source File

SOURCE=.\DisplayVertex.cpp
# End Source File
# Begin Source File

SOURCE=.\DisplayVertex.h
# End Source File
# Begin Source File

SOURCE=.\DXNames.h
# End Source File
# Begin Source File

SOURCE=.\ProjectionViewport.cpp
# End Source File
# Begin Source File

SOURCE=.\ProjectionViewport.h
# End Source File
# Begin Source File

SOURCE=.\RenderContext.cpp
# End Source File
# Begin Source File

SOURCE=.\RenderContext.h
# End Source File
# Begin Source File

SOURCE=.\StdDisplayMaterials.cpp
# End Source File
# Begin Source File

SOURCE=.\StdDisplayMaterials.h
# End Source File
# End Group
# Begin Group "Data"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\IntroXM.h
# End Source File
# End Group
# Begin Group "Effects"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\DECirculos.cpp
# End Source File
# Begin Source File

SOURCE=.\DECirculos.h
# End Source File
# Begin Source File

SOURCE=.\DECubiculos.cpp
# End Source File
# Begin Source File

SOURCE=.\DECubiculos.h
# End Source File
# Begin Source File

SOURCE=.\DemoEffect.cpp
# End Source File
# Begin Source File

SOURCE=.\DemoEffect.h
# End Source File
# Begin Source File

SOURCE=.\DERayas.cpp
# End Source File
# Begin Source File

SOURCE=.\DERayas.h
# End Source File
# Begin Source File

SOURCE=.\DETextWriter.cpp
# End Source File
# Begin Source File

SOURCE=.\DETextWriter.h
# End Source File
# End Group
# Begin Group "Utils"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Base.cpp
# End Source File
# Begin Source File

SOURCE=.\Base.h
# End Source File
# Begin Source File

SOURCE=.\LinkedList.h
# End Source File
# Begin Source File

SOURCE=.\vectors.h
# End Source File
# Begin Source File

SOURCE=.\WinWindow.cpp
# End Source File
# Begin Source File

SOURCE=.\WinWindow.h
# End Source File
# End Group
# Begin Group "Misc"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\BasicMesh.cpp
# End Source File
# Begin Source File

SOURCE=.\BasicMesh.h
# End Source File
# Begin Source File

SOURCE=.\TextTexture.cpp
# End Source File
# Begin Source File

SOURCE=.\TextTexture.h
# End Source File
# End Group
# Begin Source File

SOURCE=.\Durantro.cpp
# End Source File
# Begin Source File

SOURCE=.\IntroMain.cpp
# End Source File
# Begin Source File

SOURCE=.\IntroMain.h
# End Source File
# End Target
# End Project
