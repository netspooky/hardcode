CC = gcc
CFLAGS = -O2 -ffast-math `sdl-config --cflags`
LDFLAGS = `sdl-config --libs` -lGL -lm

# My setup for a Mac
#CFLAGS = -O2 -ffast-math `sdl-config --cflags` -I/sw/include
#LDFLAGS = `sdl-config --static-libs` -lm

all: main
	mv main emo_defect

main: main.o gl_render.o cool_mzx/cool_mzx.a dump.o

cool_mzx/cool_mzx.a:
	cd cool_mzx && make

clean:
	rm -f *.o main emo_defect *~
	cd cool_mzx && make clean
