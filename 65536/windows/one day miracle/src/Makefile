# Possible platforms: linux/irix/osx/win32
PLATFORM = linux
# Endianness: LITTLE/BIG (x86,Alpha/MIPS,PPC,SPARC etc.)
ENDIAN = LITTLE

MAKE = make
RANLIB = ranlib
EXE = miracle

ifeq ($(PLATFORM),osx)
INC = -I./vecsys -I/usr/local/include/SDL
SDL = `/usr/local/bin/sdl-config --libs`
CC = cc
endif

ifeq ($(PLATFORM),win32)
INC = -I./vecsys -I/usr/include/SDL
SDL = -lSDL
CC = gcc
EXE = miracle.exe
endif

ifeq ($(PLATFORM),linux)
INC = -I./vecsys -I/usr/include/SDL
SDL = `sdl-config --libs`
CC = gcc
endif

ifeq ($(PLATFORM),irix)
INC = -I./vecsys -I/usr/local/include/SDL
SDL = `sdl-config --libs`
CC = gcc
MAKE = gmake
RANLIB = echo
endif

LIB = -lm
OPT = -O2 -ffast-math -D$(ENDIAN)
COOL = cool_mzx/cool_mzx.a cool_gfx/cool_gfx.a
OBJ = main.o venkula.o data.o maf.o feidi.o panorama.o suumi.o halftone.o \
      flarex.o ranta.o

export CC
export RANLIB

miracle: $(OBJ) vecsys/vecsys.a $(COOL)
	$(CC) -o $@ $(OBJ) vecsys/vecsys.a $(COOL) $(SDL) $(LIB)

vecsys/vecsys.a:
	cd vecsys && $(MAKE)

cool_mzx/cool_mzx.a:
	cd cool_mzx && $(MAKE)

cool_gfx/cool_gfx.a:
	cd cool_gfx && $(MAKE)

%.o: %.c
	$(CC) $(OPT) $(INC) -c $<

clean:
	rm *.o $(EXE)
	cd vecsys && $(MAKE) clean
	cd cool_mzx && $(MAKE) clean
	cd cool_gfx && $(MAKE) clean
