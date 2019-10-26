# Makefile for Nean der taler, gmake syntax
# Shouldn't be too hard to change for your platform
#
# -Marq 2001

# Platform (LINUX/IRIX)
PLATFORM = LINUX
# YES for sound, NO or whatever for no sound
SOUND = YES
# YES for a crappy old version, something else for >=3.7
OLDGLUT = NO

# General defines
CC = g++
COPT = -O2 -ffast-math -fomit-frame-pointer
DEF = 
GL = -lglut -lGL -lGLU
LIBS = -lm

# Linux (or XFree) specific
ifeq ($(PLATFORM),LINUX)
X = -L/usr/X11R6/lib -lX11 -lXext -lXmu -lXi
LIBS += -ldl
DEF += -DBSDENV
endif

# SGI specific
ifeq ($(PLATFORM),IRIX)
X = -L/usr/lib32 -lX11 -lXext -lXmu -lXi
endif

# If sound enabled
ifeq ($(SOUND),YES)
DEF += -DSOUND
LIBS += -lmikmod
endif

# If old GLUT version
ifeq ($(OLDGLUT),YES)
DEF += -DOLDGLUT
endif

neandertaler: neandertaler_mainloop.o main.cc
	$(CC) $(COPT) main.cc neandertaler_mainloop.o -o neandertaler \
	$(DEF) $(GL) $(X) $(LIBS)
	strip neandertaler

neandertaler_mainloop.o: neandertaler_mainloop.cc
	$(CC) $(COPT) -c neandertaler_mainloop.cc $(DEF)

clean: 
	rm neandertaler *.o *~
