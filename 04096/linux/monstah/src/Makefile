CC = gcc
CFLAGS = -Wall -Winline -std=gnu99 -Os \
	 -fomit-frame-pointer \
         -ffast-math \
         -fmerge-all-constants -mno-ieee-fp -march=pentiumpro \
	 -fno-guess-branch-probability \
	 -fno-schedule-insns \
	 -fno-schedule-insns2 \
	 -fsingle-precision-constant \
	 -fmerge-all-constants \
	 -fverbose-asm \
	 -fno-loop-optimize \
         -fno-strict-aliasing \
         `sdl-config --cflags`
#	 -fshort-double \

# TODO: -nostdlib taitaa pitää sisällään -nostartfiles :in ?
LDFLAGS = -nodefaultlibs -nostdlib -nostartfiles -ldl

OBJS = oeoe.o

all: oeoe

oeoe: boot.sh oeoe.s.exec.gz
	cat boot.sh > oeoe
	cat oeoe.s.exec.gz >> oeoe
	chmod +x oeoe
	cat boot_nosound.sh > oeoe.nosound
	cat oeoe.s.exec.gz >> oeoe.nosound
	chmod +x oeoe.nosound
	ls -l oeoe.s.exec oeoe

oeoe.s.exec.gz: oeoe.s.exec
	gzip -9 --no-name -c < oeoe.s.exec > oeoe.s.exec.gz
	bzip2 -9 -c < oeoe.s.exec > oeoe.s.exec.bz2

oeoe.s.exec: oeoe.exec
	cp oeoe.exec oeoe.s.exec
	#objcopy -R .data oeoe.s.exec
	sstrip $@

oeoe.exec: oeoe.s
	$(CC) $(CFLAGS) -c oeoe.s
	$(CC) $(CFLAGS) -o $@ oeoe.s $(LDFLAGS)

oeoe.s: *.c *.h Makefile
	$(CC) $(CFLAGS) -S -o $@ oeoe.c
#	sed -i.orig 's/rodata/data/g' oeoe.s
	sed -i.orig 's/rodata/data/g; s/\.align .*//' oeoe.s
#	sed -i.orig 's/rodata/text/g; s/data/text/g; s/\.align .*//' oeoe.s

clean:
	rm -f oeoe.s

oeoe.debug: *.c *.h Makefile
	$(CC) -Wall -g -std=gnu99 -DDEBUG -o oeoe.debug oeoe.c `sdl-config --cflags --static-libs` -lm -lGL -lGLU -lglut

dist:
	rm -fr monstah-1.0/
	mkdir monstah-1.0/
	mkdir monstah-1.0/src/
	cp oeoe monstah-1.0/monstah
#	cp oeoe.nosound monstah-1.0/monstah.nosound
#	cp oeoe.sdlsound monstah-1.0/monstah.sdlsound
	cp README monstah-1.0/
	cp oeoe.png monstah-1.0/
	cp Makefile *.c *.h *.txt *.sh monstah-1.0/src/
	tar cvfz monstah-1.0.tar.gz monstah-1.0/
	rm -fr monstah-1.0/
