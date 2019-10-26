# ------------------------------------------------------------------------

exe        = test.exe

# ryg's gfx/base stuff
objs       = base.obj     psphere.obj  font.obj     data.obj &
#            sprite.obj &
# ryg's workbench stuff
             workbnch.obj render.obj   cfont.obj    csprite.obj &
# kb's sound stuff
             synth.obj    reverb.obj   mxmplay.obj &
# torus 3d stuff
             ficken3d.obj intro.obj    util.obj     matrix.obj &
             lineaa.obj

libs       = ddraw.lib    kernel32.lib gdi32.lib    user32.lib &
             dsound.lib

# ------------------------------------------------------------------------

.extensions: .tas

ccopts     = -s -6r -fp6 -fpi87 -oisanhmr -bt=nt -zm -zq

.c.obj
  wcc386 $(ccopts) $?

.asm.obj
  nasmw -f win32 $?

.tas.obj
  tasm -m4 -t $?

.before del $(exe)

$(exe) :$(objs) makefile
  @%write temp.lnk NAME     $@
  @%write temp.lnk system   nt_win
  @%write temp.lnk FILE     {$(objs)}
  @%write temp.lnk OPTION   eliminate
  @%write temp.lnk OPTION   quiet
  @%write temp.lnk OPTION   nod
  @%write temp.lnk OPTION   nor
  @%write temp.lnk OPTION   start=entrypnt
  @%write temp.lnk OPTION   stack=65536
  @%write temp.lnk library  {$(libs)}
  wlink @temp.lnk
#  upx72 -9 --strip-relocs $(exe)
  @del temp.lnk

clean : .symbolic
  del *.obj *.bak *.lst *.map *.exe *.err *.tr *.smp

