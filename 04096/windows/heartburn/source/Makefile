
ifdef DEBUG
CFLAGS = -m32 -O0 -g
else
CFLAGS = -m32 -O1 -ffast-math -fomit-frame-pointer -mpush-args -mfpmath=387
endif


ifdef FROM_ASM
heartburn:	heartburn.ld heartburn.o music.o heartburn_footer.o
	ld -Theartburn.ld -o heartburn \
		heartburn.o music.o heartburn_footer.o

heartburn.o:	heartburn.S
	gcc -m32 -c -o heartburn.o heartburn.S

heartburn_footer.o:	heartburn_footer.S
	as --32 -o heartburn_footer.o heartburn_footer.S
else
heartburn:	heartburn.o music.o
	gcc -m32 -lSDL -lGL -lm -o heartburn heartburn.o music.o

heartburn.o:	heartburn.c shaders.h
	gcc $(CFLAGS) -g -DS_WIDTH=1680 -DS_HEIGHT=1050 \
		-c -o heartburn.o heartburn.c

heartburn.S:	heartburn.c
	gcc $(CFLAGS) -DS_WIDTH=800 -DS_HEIGHT=600 \
		-S -o heartburn.S heartburn.c
endif


music.o:	clinkster-linux.asm music-linux.asm
	nasm -o music.o -f elf32 clinkster-linux.asm


clean:
	rm -f heartburn *.o

.PHONY: clean
