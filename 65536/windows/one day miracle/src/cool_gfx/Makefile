# Select platform (i386linux/anylinux/solaris/irix/hpsux/dos/w32/sdl)
TARGET=sdl

# Usual parameters for x86-GCC
ASM=nasm
COPT=-O2 -ffast-math
AR=ar
OWNOBJ=blit32a.o

# i386 Linux specific
ifeq ($(TARGET),i386linux)
# Select graphics target (x11/svga)
GTARGET=x11
ifeq ($(GTARGET),x11)
CDEF=-DLINUX -DX11
OWNOBJ+= gfx_x.o
KOE=-L/usr/X11R6/lib -lX11 
# Uncomment for Shm
CDEF+=-DX_SHM
KOE+=-lXext
# Uncomment for DGA
CDEF+=-DX_DGA
KOE+=-lXxf86vm -lXxf86dga -lXext
else
CDEF=-DLINUX -DSVGA
OWNOBJ+= gfx_svga.o
KOE=-lvga
endif
ASMOPT=-f elf
RM=rm
endif

# Generic Linux specific
ifeq ($(TARGET),anylinux)
ASM=
CDEF=-DLINUX -DX11
OWNOBJ=gfx_x.o blit32c.o
KOE=-L/usr/X11R6/lib -lX11
# Uncomment for Shm
CDEF+=-DX_SHM
KOE+=-lXext
# Uncomment for DGA
# CDEF+=-DX_DGA
# KOE+=-lXxf86vm -lXxf86dga -lXext
endif

# Solaris specific
ifeq ($(TARGET),solaris)
ASM=
CDEF=-DLINUX -DX11 -I/usr/openwin/include
OWNOBJ=gfx_x.o blit32c.o
KOE=-L/usr/openwin/lib -lX11
# Uncomment for Shm
CDEF+=-DX_SHM
KOE+=-lXext
endif

# IRIX specific
ifeq ($(TARGET),irix)
ASM=
CDEF=-DLINUX -DX11
OWNOBJ=gfx_x.o blit32c.o
KOE=-L/usr/lib/X11 -lX11
# Uncomment for Shm
CDEF+=-DX_SHM
KOE+=-lXext
endif

# HP-SUX specific
ifeq ($(TARGET),hpsux)
ASM=
CDEF=-DLINUX -DX11 -I/usr/include/X11R6
OWNOBJ=gfx_x.o blit32c.o
KOE=-L/usr/lib/X11 -lX11
# Uncomment for Shm
CDEF+=-DX_SHM
KOE+=-lXext
endif

# DJGPP specific
ifeq ($(TARGET),dos)
CDEF=-DDOS
OWNOBJ+= gfx_dos.o vesa.o tweak.o
KOE=
ASMOPT=-f coff -dUNDERSCORE -dSELECTOR
RM=del
endif

# SDL specific
ifeq ($(TARGET),sdl)
ASM=
CDEF=-DSDL
OWNOBJ= gfx_sdl.o blit32c.o
KOE=-lSDL -lpthread
ASMOPT=-f coff -dUNDERSCORE -dSELECTOR
RM=rm
endif

# W32 specific
ifeq ($(TARGET),w32)
CDEF=-DW32
ASMOPT=-f win32 -dUNDERSCORE
RM=del
endif

cool_gfx.a: blit32.o $(OWNOBJ)
	$(AR) rc cool_gfx.a blit32.o $(OWNOBJ)
	$(RANLIB) cool_gfx.a

gfx_x.o: gfx_x.c gfx_x.h
	$(CC) $(COPT) -c gfx_x.c $(CDEF)

gfx_svga.o: gfx_svga.c gfx_svga.h blit32.o
	$(CC) $(COPT) -c gfx_svga.c $(CDEF)

gfx_sdl.o: gfx_sdl.c gfx_sdl.h
	$(CC) $(COPT) -c gfx_sdl.c $(CDEF)

gfx_dos.o: vesa.o gfx_dos.c gfx_dos.h
	$(CC) $(COPT) -c gfx_dos.c $(CDEF)

tweak.o: tweak.c tweak.h
	$(CC) $(COPT) -c tweak.c $(CDEF)

vesa.o: vesa.c vesa.h
	$(CC) $(COPT) -c vesa.c $(CDEF)

blit32.o: blit32.c blit32.h
	$(CC) $(COPT) -c blit32.c $(CDEF)

blit32c.o: blit32c.c
	$(CC) $(COPT) -c blit32c.c $(CDEF)

blit32a.o: blit32a.asm
	$(ASM) $(ASMOPT) blit32a.asm

clean:
	$(RM) *.o
	$(RM) *.a
