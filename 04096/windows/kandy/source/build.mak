#
# Makefile for the 4K intro framework.
#
# Build with:
#   nmake /f build.mak debug|fast|release|clean
#
# Author:
#   s_tec
#

out = kandy.exe
LIBS = dsound.lib gdi32.lib glu32.lib kernel32.lib opengl32.lib user32.lib
AS = nasmw
AFLAGS = -Xvc -fwin32 -dwin32

#-----------------------------------------------------------------------------
# Debug build
# Debugger-friendly build using C startup code and no compression
#-----------------------------------------------------------------------------
debug: debug/$(out)

debug/$(out): debug/debug.obj debug/main.obj debug/demo.obj debug/synth.obj debug/math.obj
	link /entry:main /subsystem:windows /incremental:no /debug /nologo /out:$@ $** $(LIBS)

debug/debug.obj: debug.c
	$(CC) /c /O1 /Zi /FAs /Fadebug\ /nologo /Fo$@ debug.c
debug/main.obj:  main.asm  math.inc win32n.inc nasmgl.inc dsound.inc
	$(AS) $(AFLAGS) -ddebug -o$@ main.asm
debug/demo.obj:  demo.asm  math.inc nasmgl.inc nasmglu.inc
	$(AS) $(AFLAGS) -ddebug -o$@ demo.asm
debug/synth.obj: synth.asm math.inc music.inc
	$(AS) $(AFLAGS) -ddebug -o$@ synth.asm
debug/math.obj:  math.asm  math.inc
	$(AS) $(AFLAGS) -ddebug -o$@ math.asm

#-----------------------------------------------------------------------------
# Release build
# Compo build using pure assembly language and full compression
#-----------------------------------------------------------------------------
release: release/$(out)

release/$(out): release/main.obj release/demo.obj release/synth.obj release/math.obj
	crinkler /entry:main /subsystem:windows /compmode:slow /progressgui /range:opengl32.lib /out:$@ $** $(LIBS)

release/main.obj:  main.asm  math.inc win32n.inc nasmgl.inc dsound.inc
	$(AS) $(AFLAGS) -o$@ main.asm
release/demo.obj:  demo.asm  math.inc nasmgl.inc nasmglu.inc
	$(AS) $(AFLAGS) -o$@ demo.asm
release/synth.obj: synth.asm math.inc music.inc
	$(AS) $(AFLAGS) -o$@ synth.asm
release/math.obj:  math.asm  math.inc
	$(AS) $(AFLAGS) -o$@ math.asm

#-----------------------------------------------------------------------------
# Fast build
# Like release build, but with faster compression
#-----------------------------------------------------------------------------
fast: fast/$(out)

fast/$(out): release/main.obj release/demo.obj release/synth.obj release/math.obj
	crinkler /entry:main /subsystem:windows /out:$@ $** $(LIBS)

#-------------------------------------------------------------------------------
# Cleanup actions
#-------------------------------------------------------------------------------
clean:
	del /Q debug\*.*
	del /Q fast\*.*
	del /Q release\*.*
