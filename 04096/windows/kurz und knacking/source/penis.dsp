# Microsoft Developer Studio Project File - Name="penis" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** NICHT BEARBEITEN **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=penis - Win32 Debug
!MESSAGE Dies ist kein gültiges Makefile. Zum Erstellen dieses Projekts mit NMAKE
!MESSAGE verwenden Sie den Befehl "Makefile exportieren" und führen Sie den Befehl
!MESSAGE 
!MESSAGE NMAKE /f "penis.mak".
!MESSAGE 
!MESSAGE Sie können beim Ausführen von NMAKE eine Konfiguration angeben
!MESSAGE durch Definieren des Makros CFG in der Befehlszeile. Zum Beispiel:
!MESSAGE 
!MESSAGE NMAKE /f "penis.mak" CFG="penis - Win32 Debug"
!MESSAGE 
!MESSAGE Für die Konfiguration stehen zur Auswahl:
!MESSAGE 
!MESSAGE "penis - Win32 Release" (basierend auf  "Win32 (x86) Console Application")
!MESSAGE "penis - Win32 Debug" (basierend auf  "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "penis - Win32 Release"

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
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /G5 /Gz /W3 /GX /Og /Os /Ob1 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /FAs /FR /FD /QIfist /c
# ADD BASE RSC /l 0x407 /d "NDEBUG"
# ADD RSC /l 0x407 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 opengl32.lib glu32.lib winmm.lib kernel32.lib user32.lib gdi32.lib msvcrt.lib /nologo /subsystem:console /machine:I386 /nodefaultlib /crinkler /range:opengl32 /compmode:slow /hashsize:100
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "penis - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 2
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /D "_AFXDLL" /YX /FD /GZ /c
# ADD BASE RSC /l 0x407 /d "_DEBUG"
# ADD RSC /l 0x407 /d "_DEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 winmm.lib opengl32.lib user32.lib glu32.lib gdi32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "penis - Win32 Release"
# Name "penis - Win32 Debug"
# Begin Source File

SOURCE=.\Source\audio.c
# End Source File
# Begin Source File

SOURCE=.\Source\audio.h
# End Source File
# Begin Source File

SOURCE=.\Source\face.c
# End Source File
# Begin Source File

SOURCE=.\Source\face.h
# End Source File
# Begin Source File

SOURCE=.\Source\global.c
# End Source File
# Begin Source File

SOURCE=.\Source\global.h
# End Source File
# Begin Source File

SOURCE=.\Source\glwindow.c
# End Source File
# Begin Source File

SOURCE=.\Source\glwindow.h
# End Source File
# Begin Source File

SOURCE=.\Source\main.c
# End Source File
# Begin Source File

SOURCE=.\Source\particle.c
# End Source File
# Begin Source File

SOURCE=.\Source\particle.h
# End Source File
# Begin Source File

SOURCE=.\Source\particlesystem.c
# End Source File
# Begin Source File

SOURCE=.\Source\particlesystem.h
# End Source File
# Begin Source File

SOURCE=.\Source\spring.c
# End Source File
# Begin Source File

SOURCE=.\Source\spring.h
# End Source File
# Begin Source File

SOURCE=.\Source\utility.c
# End Source File
# Begin Source File

SOURCE=.\Source\utility.h
# End Source File
# Begin Source File

SOURCE=.\Source\vec.c
# End Source File
# Begin Source File

SOURCE=.\Source\vec.h
# End Source File
# End Target
# End Project
