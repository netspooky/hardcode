CC = gcc -O2

all: peluce

############################

ELEVOBJS= main.o planes.o font.o sprites.o musa.o landscroll.o ../pwplib.a

musa.o: musa.c musa.h

font.c: font.h

font.h: font-gen.pl
	./font-gen.pl > font.h

peluce: $(ELEVOBJS)
	$(CC) -static $(ELEVOBJS) ../pwplib.a -s -o peluce -lm

sprites.o: sprites.c sprites.h
	$(CC) $(@:.o=.c) -c -o $@

%.o: %.c
	$(CC) $(@:.o=.c) -c -o $@

sprites.h: spritegen
	./spritegen > sprites.h-vittu

spritegen: spritegen.c
	$(CC) spritegen.c -o spritegen

clean:
	rm -f *.o *~
