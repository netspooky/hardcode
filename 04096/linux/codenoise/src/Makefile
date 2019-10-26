CFLAGS=-Os -ffast-math -Wall -march=i686 -mcpu=athlon-xp -DX86_ASM \
	$(shell sdl-config --cflags) -frerun-cse-after-loop

LDFLAGS=-nostdlib -nostartfiles -ldl -lpthread 

all: play
	./pack.sh play

play: play.o synth.o dl_init.o
	$(CC) $(LDFLAGS) -o $@ $^

synth.o: synth.c synth.h
	$(CC) $(CFLAGS) -c -o $@ $<

play.o: play.c play.h song.h
	$(CC) $(CFLAGS) -c -o $@ $<

dl_init.o: dl_init.c dl_init.h
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o play gzplay play.gz *~

.PHONY: clean

