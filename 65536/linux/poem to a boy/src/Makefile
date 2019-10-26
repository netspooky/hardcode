CPP = g++
OBJECTS = ktex.o htex.o gl.o demo.o window.o module.o minifmod.o texture.o jpeg.o scroller.o heart.o light.o text.o font.o
CFLAGS = -ggdb -DDEBUG
LIBS = -lSDL -lGLU -lGL -L/usr/X11R6/lib -lpthread -ljpeg
#CFLAGS = -march=pentium4 -mmmx -msse -msse2 -O4 -fomit-frame-pointer -ffast-math
CFLAGS = -march=i686 -O2 -fomit-frame-pointer
#CFLAGS = -march=i686 -O4 -fomit-frame-pointer -ffast-math
STATIC_LIBS = libminifmod.a /usr/X11R6/lib/libXxf86vm.a

all: 	poem

.cpp.o: 
	$(CPP) $(CFLAGS) -c $<

module.c: module.h data/modul.xm util/bin2h
	util/bin2h data/modul.xm MODULE c > module.c

module.h: data/modul.xm util/bin2h
	util/bin2h data/modul.xm MODULE h > module.h

libminifmod.a: minifmod.c
	cd minifmod; make -f makefile.linux

htex.c: htex.h data/hjerte.jpg util/bin2h
	util/bin2h data/hjerte.jpg HTEX c > htex.c

htex.h: data/hjerte.jpg util/bin2h
	util/bin2h data/hjerte.jpg HTEX h > htex.h

ktex.c: ktex.h data/kake.jpg util/bin2h
	util/bin2h data/kake.jpg KTEX c > ktex.c

ktex.h: data/kake.jpg util/bin2h
	util/bin2h data/kake.jpg KTEX h > ktex.h


poem:	main.o $(OBJECTS) $(STATIC_LIBS)
	$(CPP) $(LIBS) -o poem main.o $(OBJECTS) $(STATIC_LIBS)
	strip poem
	upx -9 poem
	cp poem ../

clean:
	rm  *o minifmod/*.o libminifmod.a
