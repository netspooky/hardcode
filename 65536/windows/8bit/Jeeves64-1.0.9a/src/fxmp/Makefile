
SYSTEM = LINUX

CFLAGS = -Wall -pedantic -ansi -O6 -mpentium -s
# -fprofile-arcs -ftest-coverage
CC = gcc -D$(SYSTEM)
# LIBS = -lpthread

FXMPOBJS = fxmp.o load_xm.o drv_dsp.o drv_seq.o

player: main.o fxmp.a fxmp.h
	$(CC) $(CFLAGS) main.o fxmp.a -o player $(LIBS)
	strip player

fxmp.a: $(FXMPOBJS)
	ar rcv fxmp.a fxmp.o load_xm.o drv_dsp.o drv_seq.o
	ranlib fxmp.a

clean:
	rm -f *.o
	rm -f fxmp.a
	rm -f core
	rm -f player

pack:
	rm -f fxmp.tar.bz2
	tar vfcI fxmp.tar.bz2 *
