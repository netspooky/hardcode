#CC=/home/slack/temp/gcc4/bin/gcc
CFLAGS=-Os -std=c99 -fomit-frame-pointer -fno-strict-aliasing -ffast-math -Wall -fforce-mem -fpeephole2 -fexpensive-optimizations -DX86_ASM  \
	$(shell sdl-config --cflags) -frerun-cse-after-loop #-DDEBUG

CFLAGS_DEBUG=-std=c99 -g -fno-strict-aliasing -ffast-math -Wall -march=i686 -mcpu=athlon-xp -DX86_ASM \
	$(shell sdl-config --cflags) -frerun-cse-after-loop -DDEBUG
	
LDFLAGS=-nostdlib -nostartfiles -ldl -lpthread 

LDFLAGS_DEBUG=-ldl -lpthread -lm


all: main 
	./pack.sh main
	./bzpack.sh main

debug: maind
	
main: main.o synth.o dl_init.o 
	$(CC) $(LDFLAGS) -o $@ $^
	ls -l main 

synth.o: synth.c synth.h 
	$(CC) $(CFLAGS) -c -o $@ $<

main.o: main.c play.c
	$(CC) $(CFLAGS) -c -o $@ $<

dl_init.o: dl_init.c dl_init.h 
	$(CC) $(CFLAGS) -c -o $@ $<
	#nasm -O9 -f elf -o $@ $<
	
maind: maind.o synthd.o dl_initd.o
	$(CC) $(LDFLAGS_DEBUG) -o $@ $^

maind.o: main.c
	$(CC) $(CFLAGS_DEBUG) -c -o $@ $<


synthd.o: synth.c synth.h 
	$(CC) $(CFLAGS_DEBUG) -c -o $@ $<

playd.o: play.c play.h song.h
	$(CC) $(CFLAGS_DEBUG) -c -o $@ $<

dl_initd.o: dl_init.c dl_init.h 
	$(CC) $(CFLAGS_DEBUG) -c -o $@ $<

sstrip: sstrip.c
	$(CC) -o $@ $<
	
clean:
	rm -f *.o main gzplay bzplay main.gz main.bz2 maind *~

.PHONY: clean

