CC=gcc-4.0
CFLAGS=-Os -fno-inline -fshort-double -fexpensive-optimizations -fpeephole2 -fforce-mem -ffast-math -Wall -march=pentium4 -mtune=pentium4 -DX86_ASM  \
	$(shell sdl-config --cflags) -frerun-cse-after-loop
LDFLAGS=-nostdlib -nostartfiles -ldl 

CFLAGS_DEBUG=-g -ffast-math -Wall -DX86_ASM $(shell sdl-config --cflags) -DDEBUG
	
LDFLAGS_DEBUG=-ldl -lpthread -lm


all: intro gzintro 
	ls -l $^

run: gzintro
	./gzintro
	
stripintro: intro 
	cp intro $@
	sstrip $@

gzintro: stripintro gz-loader 
	cp gz-loader $@
	gzip -cn9 stripintro >> $@
	chmod +x $@

intro: synth.o dl_init.o main.o play.o
	$(CC) $(LDFLAGS) -o $@ synth.o dl_init.o main.o play.o

main.o: dl_init.h synth.h
synth.o: synth.h dl_init.h
play.o: dl_init.h synth.h play.h song.h
#dl_init.o: dl_init.asm dl_init.h 
#	nasm -f elf -O3 -o dl_init.o dl_init.asm

dl_init.o: dl_init.h

debug:
	rm *.o
	make CFLAGS='$(CFLAGS_DEBUG)' LDFLAGS='$(LDFLAGS_DEBUG)' intro
	mv intro debug
	rm *.o


clean:
	rm -f *.o intro stripintro gzintro debug sstrip *~ .*.swp

.PHONY: clean all

