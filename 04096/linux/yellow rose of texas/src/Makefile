CC = gcc-3.3
COPT = -O1 -ffast-math -fno-inline -fmove-all-movables \
       -fno-loop-optimize -fexpensive-optimizations -fpeephole2 -fshort-double -S
SOPT = -R .comment -R .note -R .note.ABI-tag -R .fini -R .gnu.version
OBJ = syna_tiny.o tinymain.o osa.o minigl.o

# FULL = FULLSCREEN for fullscreen mode, something else for window
FULL = FULLSCREEN

intro: $(OBJ)
	$(CC) -o intro -nostdlib $(OBJ) -lSDL -lpthread -lm
	strip $(SOPT) intro

final: intro
	gzip --best -f intro
	cat unpack.header intro.gz > yellow_rose
	rm intro.gz
	chmod a+rx yellow_rose
	ls -l yellow_rose

syna_tiny.o: syna_tiny.asm
	nasm -f elf syna_tiny.asm

minigl.o: minigl.asm
	nasm -f elf minigl.asm

tinymain.o: tinymain.asm
	nasm -f elf -D$(FULL) tinymain.asm

osa.o: osa.s
	$(CC) -c $<

%.o: %.c
	$(CC) $(COPT) -c $<
       
clean:
	rm *.o intro yellow_rose *~

