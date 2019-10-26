CC=gcc-3.0
EXECUTABLE=flause
OBJECTS=jpeg.o opengl.o module.o minifmod.o demo.o main.o scenes.o effects.o gakk.o kykkeli.o
DATA=module.c module.h gakk.c kykkeli.c gakk.h kykkeli.h
LIBS=lib/libminifmod.a
LDFLAGS=-lglut -ljpeg -lm
CFLAGS=-g3 -Wall -Os  -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Woverloaded-virtual -Wunreachable-code -DCHEAP #-Werror #-DCHEAP #-pedantic-error #-Wconversion -Wid-clash-8



all: $(EXECUTABLE)

scenes.o: tekst.h scenes.c gakk.c kykkeli.c

module.c: module.h data/WEIRD2.XM util/bin2h
	util/bin2h data/WEIRD2.XM MODULE c > module.c

module.h: data/WEIRD2.XM util/bin2h
	util/bin2h data/WEIRD2.XM MODULE h > module.h

gakk.c: gakk.h data/gakk.jpg util/bin2h
	util/bin2h data/gakk.jpg gakk c > gakk.c

gakk.h: data/gakk.jpg util/bin2h
	util/bin2h data/gakk.jpg gakk h > gakk.h

kykkeli.c: kykkeli.h data/kykkeli.jpg util/bin2h
	util/bin2h data/kykkeli.jpg kykkeli c > kykkeli.c

kykkeli.h: data/kykkeli.jpg util/bin2h
	util/bin2h data/kykkeli.jpg kykkeli h > kykkeli.h

lib/libminifmod.a: minifmod/fmusic.c minifmod/fsound.c minifmod/genasminc.c minifmod/minifmod.h minifmod/mixer.h minifmod/mixer_clipcopy.c minifmod/mixer_clipcopy.h minifmod/mixer_fpu_ramp.c minifmod/mixer_fpu_ramp.h minifmod/music.h minifmod/music_formatxm.c minifmod/music_formatxm.h minifmod/sound.h minifmod/system_file.c minifmod/system_file.h minifmod/system_memory.h minifmod/xmeffects.h 
	make -C minifmod/ -f makefile.linux

util/bin2h: util/bin2h.c
	make -C util/

$(EXECUTABLE): $(DATA) $(OBJECTS) $(LIBS)
	$(CC) -o $(EXECUTABLE) $(CFLAGS) $(LDFLAGS) $(OBJECTS) $(LIBS)

clean:
	rm -f $(OBJECTS) $(EXECUTABLE) $(DATA) $(LIBS)
	make -C util/ clean
	make -C minifmod/ -f makefile.linux clean
