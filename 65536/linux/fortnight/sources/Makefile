CFLAGS = -g -O1 -fforce-mem -fforce-addr -fomit-frame-pointer -fstrength-reduce -fno-expensive-optimizations -fschedule-insns2 -Wall -Wno-parentheses -ffast-math `sdl-config --cflags` `libmikmod-config --cflags`



run: demo
	./demo

clean: 
	rm *.o *.bak demo.bz2 demo intro || :;

demo.bz2: demo
	bzip2 <demo >demo.bz2

ldr.o: ldr.asm demo.bz2
	nasm -f elf -dfilus=\"demo.bz2\" ldr.asm

intro: ldr.o 
	gcc ldr.o -o intro -nostdlib -lbz2
	objcopy -R .note -R .comment -R .note.ABI-tag -R .sbss -R .gnu_version -x -g -S --strip-unneeded intro


demo: main.o datat.o
	gcc main.o datat.o -o demo `sdl-config --libs` `libmikmod-config --libs`
	objcopy -R .note -R .comment -R .note.ABI-tag -R .sbss -R .gnu_version -x -g -S --strip-unneeded demo

datat.o: datat.asm
	nasm -f elf datat.asm

main.o: *.c Makefile
	gcc-3.0 -mcpu=k6 -frename-registers -fregmove -fmove-all-movables $(CFLAGS) -c main.c
