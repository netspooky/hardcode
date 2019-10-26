# Microsoft Developer Studio Project File - Name="Assy" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 60000
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=Assy - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Assy.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Assy.mak" CFG="Assy - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Assy - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "Assy - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Assy - Win32 Release"

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
# ADD CPP /nologo /W3 /GX /O2 /Ob2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD BASE RSC /l 0x40b /d "NDEBUG"
# ADD RSC /l 0x40b /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib ddraw.lib libc.lib /nologo /subsystem:console /machine:I386 /nodefaultlib

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

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
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /GZ /c
# ADD BASE RSC /l 0x40b /d "_DEBUG"
# ADD RSC /l 0x40b /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 comdlg32.lib kernel32.lib user32.lib gdi32.lib winspool.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib ddraw.lib libc.lib /nologo /subsystem:console /debug /machine:I386 /nodefaultlib /pdbtype:sept

!ENDIF 

# Begin Target

# Name "Assy - Win32 Release"
# Name "Assy - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\Bitmap.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\BMFont.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

# ADD CPP /O2

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Camera.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

# ADD CPP /O2

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Clouds.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Cone.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Cylinder.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Dd.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\DrawQuad.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Error.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Frustum.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\ISList.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\KeyFramer.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Light.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\LineFont.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\LineLetter.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Main.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Matrix.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Music.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Object.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Plane.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Primitive.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Ptrlist.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\RayTracer.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\SafeAlloc.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Sphere.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\TextManager.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

# ADD CPP /O2

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Timer.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

# ADD CPP /O2

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\Trace.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\World.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\WorldLoadSave.cpp

!IF  "$(CFG)" == "Assy - Win32 Release"

# ADD CPP /O2

!ELSEIF  "$(CFG)" == "Assy - Win32 Debug"

# ADD CPP /Od

!ENDIF 

# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\Bitmap.h
# End Source File
# Begin Source File

SOURCE=.\BMFont.h
# End Source File
# Begin Source File

SOURCE=.\Camera.h
# End Source File
# Begin Source File

SOURCE=.\Clouds.h
# End Source File
# Begin Source File

SOURCE=.\Cone.h
# End Source File
# Begin Source File

SOURCE=.\Cylinder.h
# End Source File
# Begin Source File

SOURCE=.\Dd.h
# End Source File
# Begin Source File

SOURCE=.\Error.h
# End Source File
# Begin Source File

SOURCE=.\Frustum.h
# End Source File
# Begin Source File

SOURCE=.\ISList.h
# End Source File
# Begin Source File

SOURCE=.\KeyFramer.h
# End Source File
# Begin Source File

SOURCE=.\Light.h
# End Source File
# Begin Source File

SOURCE=.\LineFont.h
# End Source File
# Begin Source File

SOURCE=.\Material.h
# End Source File
# Begin Source File

SOURCE=.\Matrix.h
# End Source File
# Begin Source File

SOURCE=.\Music.h
# End Source File
# Begin Source File

SOURCE=.\Object.h
# End Source File
# Begin Source File

SOURCE=.\Plane.h
# End Source File
# Begin Source File

SOURCE=.\Primitive.h
# End Source File
# Begin Source File

SOURCE=.\Ptrlist.h
# End Source File
# Begin Source File

SOURCE=.\RayTracer.h
# End Source File
# Begin Source File

SOURCE=.\SafeAlloc.h
# End Source File
# Begin Source File

SOURCE=.\Sphere.h
# End Source File
# Begin Source File

SOURCE=.\TextManager.h
# End Source File
# Begin Source File

SOURCE=.\Timer.h
# End Source File
# Begin Source File

SOURCE=.\Vector.h
# End Source File
# Begin Source File

SOURCE=.\Video.h
# End Source File
# Begin Source File

SOURCE=.\World.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# Begin Source File

SOURCE=..\muu\minifmod\minifmod.lib
# End Source File
# Begin Source File

SOURCE=..\muu\minifmod\lib\Winmm.lib
# End Source File
# End Target
# End Project
