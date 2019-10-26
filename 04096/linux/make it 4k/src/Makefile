CC = gcc-3.2
COPT = -O1 -ffast-math -fno-inline -fmove-all-movables -fshort-double\
	-fexpensive-optimizations -fpeephole2 -Wall -fforce-mem\
	`sdl-config --cflags`

OBJ = syna_tiny.o tinymain.o osa.o dynlib.o frustum.o faces.o

UNPACKED = intro
NAME = makeit4k

# FULL = FULLSCREEN for fullscreen mode, something else for window
FULL = FULLSCREEN

$(UNPACKED): $(OBJ)
	$(CC) -o $@ -nostdlib $(OBJ) -lpthread -ldl
	sstrip $@

final: $(UNPACKED)
	gzip -n --best -f $<
	cat unpack.header $<.gz > $(NAME)
	rm $<.gz
	chmod a+rx $(NAME)
	ls -l $(NAME)

syna_tiny.o: syna_tiny.asm
	nasm -f elf $<

dynlib.o: dynlib.asm
	nasm -f elf $<

tinymain.o: tinymain.asm
	nasm -f elf -D$(FULL) $<

%.o: %.c
	$(CC) $(COPT) -c $<

frustum.o: frustum.c
	$(CC) -O1 -ffast-math -c $<
       
clean:
	rm *.o *.s $(UNPACKED) $(NAME) core *~
