# The target platform: unix/osx/win
PLATFORM = unix

CC = gcc
COPT = -Wall -O2 -ffast-math -fno-strict-aliasing
HEADERS = palikka.h volume.h gl_render.h dump.h wavefront.h dudes.h \
          hakkyra.h tunneli.h spiral.h ball.h writer.h feidit.h naamat.h \
          syna.h
OBJ = palikka.o volume.o main.o wavefront.o dump.o gl_render.o dudes.o \
      hakkyra.o tunneli.o spiral.o serfdata.o walkerdata.o ball.o fontdata.o \
      writer.o feidit.o naamatdata.o naamat.o syna.o piisi.o
LIB = `sdl-config --libs` -lm
TARGET = leeko
SPECIAL =

ifeq ($(PLATFORM),unix)
LIB += -lGL
endif

ifeq ($(PLATFORM),osx)
COPT += -DMAC `sdl-config --cflags` \
-I/System/Library/Frameworks/AGL.framework/Headers -DBLKSIZE=1024
SPECIAL = cp $(TARGET) Leeko.app/Contents/MacOS
LIB = `sdl-config --static-libs`
endif

ifeq ($(PLATFORM),win)
LIB = -lSDL -lopengl32 -lm
TARGET = leeko.exe
endif

$(TARGET): $(OBJ)
	$(CC) -o $@ $(OBJ) $(LIB)
	$(SPECIAL)

final: $(TARGET)
	strip -R .comment -R .note $(TARGET)
	upx $(TARGET)

%.o: %.c $(HEADERS)
	$(CC) $(COPT) -c $<

data2c: data2c.c
	$(CC) -o $@ $<

clean:
	-rm *.o $(TARGET) *~ *.bak data2c
