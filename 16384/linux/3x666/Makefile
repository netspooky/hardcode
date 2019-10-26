# mAKEFiLE fOR 3x666 bY oCSA

# Choose either vga or X11
VIDEO = X11

# 1 = /dev/dsp a.k.a OpenSoundSystem; 0 = nosound
AUDIO = 1

# Ok, next check out config.h!

## ## ## ##

CC = gcc

COPT = -O9 -funroll-loops -fomit-frame-pointer

# If you prefer size to speed, use one of the below COPTs:
# i386 size
#COPT = -O2 -m386 -fomit-frame-pointer -malign-functions=0 -malign-loops=0 -malign-jumps=0
# generic size
#COPT = -O2

CFLAGS = -g -Wall -DVIDEO=$(VIDEO) -DAUDIO=$(AUDIO) 
LIBS   = -l$(VIDEO) -lm

# You may want to check out if these dirs are right.
INCDIR = 
LIBDIR = -L/usr/X11R6/lib

# These are for sun etc.
#INCDIR = -I/usr/openwin/include
#LIBDIR = -L/usr/openwin/lib

3x666: 3x666.o oxl.o
	$(CC) 3x666.o oxl.o -s -o 3x666 $(LIBDIR) $(LIBS)

oxl.o: oxl.c config.h
	$(CC) oxl.c -c -o oxl.o $(COPT) $(CFLAGS) $(INCDIR)

3x666.o: 3x666.c oxl.h config.h 3xfont.h
	$(CC) 3x666.c -c -o 3x666.o $(COPT) $(CFLAGS) $(INCDIR)
