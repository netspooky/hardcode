# Microsoft Developer Studio Project File - Name="fortnight_win32" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=fortnight_win32 - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "fortnight_win32.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "fortnight_win32.mak" CFG="fortnight_win32 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "fortnight_win32 - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "fortnight_win32 - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "fortnight_win32 - Win32 Release"

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
# ADD CPP /nologo /G6 /Gd /MD /W2 /Ox /Oa /Og /Oi /Os /Op /Gf /Gy /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /FAs /FD /c
# SUBTRACT CPP /Ot /YX
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x407 /d "NDEBUG"
# ADD RSC /l 0x407 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib /nologo /subsystem:windows /machine:I386

!ELSEIF  "$(CFG)" == "fortnight_win32 - Win32 Debug"

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
# ADD CPP /nologo /G6 /MDd /W3 /Gm /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /FD /GZ /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x407 /d "_DEBUG"
# ADD RSC /l 0x407 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib minifmod.lib winmm.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "fortnight_win32 - Win32 Release"
# Name "fortnight_win32 - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\datat.asm

!IF  "$(CFG)" == "fortnight_win32 - Win32 Release"

# Begin Custom Build
InputDir=.
OutDir=.\Release
InputPath=.\datat.asm
InputName=datat

"$(OutDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	nasmw -f win32 -o $(OutDir)\$(InputName).obj $(InputDir)\$(InputName).asm

# End Custom Build

!ELSEIF  "$(CFG)" == "fortnight_win32 - Win32 Debug"

# Begin Custom Build
InputDir=.
OutDir=.\Debug
InputPath=.\datat.asm
InputName=datat

"$(OutDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	nasmw -f win32 -o $(OutDir)\$(InputName).obj $(InputDir)\$(InputName).asm

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\main.c
# End Source File
# End Group
# Begin Group "minifmod"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\Fmusic.c
# End Source File
# Begin Source File

SOURCE=.\Fsound.c
# End Source File
# Begin Source File

SOURCE=.\minifmod.h
# End Source File
# Begin Source File

SOURCE=.\Mixer.h
# End Source File
# Begin Source File

SOURCE=.\mixer_clipcopy.c
# End Source File
# Begin Source File

SOURCE=.\mixer_clipcopy.h
# End Source File
# Begin Source File

SOURCE=.\mixer_fpu_ramp.c
# End Source File
# Begin Source File

SOURCE=.\mixer_fpu_ramp.h
# End Source File
# Begin Source File

SOURCE=.\Music.h
# End Source File
# Begin Source File

SOURCE=.\music_formatxm.c
# End Source File
# Begin Source File

SOURCE=.\music_formatxm.h
# End Source File
# Begin Source File

SOURCE=.\reverb.asm

!IF  "$(CFG)" == "fortnight_win32 - Win32 Release"

# Begin Custom Build
InputDir=.
OutDir=.\Release
InputPath=.\reverb.asm
InputName=reverb

"$(OutDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	nasmw -f win32 -o $(OutDir)\$(InputName).obj $(InputDir)\$(InputName).asm

# End Custom Build

!ELSEIF  "$(CFG)" == "fortnight_win32 - Win32 Debug"

# Begin Custom Build
InputDir=.
OutDir=.\Debug
InputPath=.\reverb.asm
InputName=reverb

"$(OutDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	nasmw -f win32 -o $(OutDir)\$(InputName).obj $(InputDir)\$(InputName).asm

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\reverb.h
# End Source File
# Begin Source File

SOURCE=.\Sound.h
# End Source File
# Begin Source File

SOURCE=.\system_file.c
# End Source File
# Begin Source File

SOURCE=.\system_file.h
# End Source File
# Begin Source File

SOURCE=.\system_memory.h
# End Source File
# Begin Source File

SOURCE=.\xmeffects.h
# End Source File
# End Group
# Begin Group "tinyptc"

# PROP Default_Filter ""
# Begin Source File

SOURCE=.\convert.c
# End Source File
# Begin Source File

SOURCE=.\convert.h
# End Source File
# Begin Source File

SOURCE=.\ddraw.c
# End Source File
# Begin Source File

SOURCE=.\gdi.c
# End Source File
# Begin Source File

SOURCE=.\mmx.asm

!IF  "$(CFG)" == "fortnight_win32 - Win32 Release"

# Begin Custom Build
InputDir=.
OutDir=.\Release
InputPath=.\mmx.asm
InputName=mmx

"$(OutDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	nasmw -f win32 -o $(OutDir)\$(InputName).obj $(InputDir)\$(InputName).asm

# End Custom Build

!ELSEIF  "$(CFG)" == "fortnight_win32 - Win32 Debug"

# Begin Custom Build
InputDir=.
OutDir=.\Debug
InputPath=.\mmx.asm
InputName=mmx

"$(OutDir)\$(InputName).obj" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	nasmw -f win32 -o $(OutDir)\$(InputName).obj $(InputDir)\$(InputName).asm

# End Custom Build

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\mmx.h
# End Source File
# Begin Source File

SOURCE=.\tinyptc.c
# End Source File
# Begin Source File

SOURCE=.\tinyptc.h
# End Source File
# Begin Source File

SOURCE=.\vfw.c
# End Source File
# End Group
# Begin Group "data"

# PROP Default_Filter ""
# Begin Source File

SOURCE=".\dxn-sl2.xm"
# End Source File
# Begin Source File

SOURCE=.\video.dat
# End Source File
# End Group
# End Target
# End Project
