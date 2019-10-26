DEFS = /D__DEBUG /D__DPMI__ /D__PMODEW /D__32BIT__

.before
   @mkdir viewer >NUL

viewer.exe : viewer\viewer.obj viewer\mesha.obj viewer\scenes.obj viewer\_i86.obj
   @wlink debug all system dos4g file { viewer\viewer.obj viewer\mesha.obj viewer\scenes.obj viewer\_i86.obj } name viewer

viewer\viewer.obj: viewer.cpp
   @wpp386 /d2 $< -mf -zq -foviewer\$^&

viewer\scenes.obj: scenes.cpp
   @wpp386 $< -mf -zq -foviewer\$^&

viewer\mesha.obj : mesha.asm static.inc scene.inc 3d.inc pmode4k.inc
   @tasm $(DEFS) /ml /m9 /zi /t mesha.asm , $*

viewer\_i86.obj : _i86.asm _i86.inc
   @tasm $(DEFS) /ml /m9 /t _i86.asm , $*

clean: .symbolic
   @echo y | del viewer\*.* >NUL
   @rmdir viewer >NUL
