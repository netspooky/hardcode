DEFS = /D__PMODE /D__DPMI__ /D__32BIT__

.before
   @mkdir mesha
   
mesha.com : mesha\pack.exe mesha\mesha.exe mesha\unpack.com
   @cd mesha
   @pack
   @if exist mesha.com copy mesha.com .. >NUL
   @cd ..

mesha\unpack.com : mesha\unpack.obj
   @tlink /t /3 /k /m mesha\unpack,mesha\unpack,mesha\unpack

mesha\pack.exe : mesha\pack.obj
   @wlink system dos4g file mesha\pack.obj name mesha\pack

mesha\unpack.obj: unpack.asm
   @tasm /ml /m9 /t $<, $*

mesha\pack.obj: pack.cpp
   @wpp386 $< -mf -zq -fomesha\$^& -oxtr

mesha\mesha.exe : mesha\mesha.obj mesha\pmode4k.obj
   @tlink /m /k /3 mesha\pmode4k mesha\mesha,mesha\mesha,mesha\mesha

mesha\mesha.obj : mesha.asm static.inc scene.inc 3d.inc pmode4k.inc
   @tasm $(DEFS) /ml /m9 /t mesha.asm , $*

mesha\pmode4k.obj : pmode4k.asm
   @tasm $(DEFS) /ml /m9 /t $< , $*

clean: .symbolic
   @echo y | del mesha\*.* >NUL
   @rmdir mesha >NUL
