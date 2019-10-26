all:
	gcc sstrip.c -o sstrip
	nasm fossfor.asm -felf -o fossfor.o
	ld script.ld -dynamic-linker /lib/ld-linux.so.2 /usr/lib/libSDL.so fossfor.o -o fossfor.bin
	strip --strip-all -R .comment -R .gnu.version -R .note.ABI-tag -R .note.gnu.build-i -R .eh_frame -R .eh_frame_hdr -R .gnu.hash -R .got -R .ptl -R .fini -R .shstrtab -R .hash ./fossfor.bin
	./sstrip fossfor.bin
	gzip -cn9 fossfor.bin > fossfor.zip
	cat fossfor.header fossfor.zip > fossfor
	rm fossfor.zip fossfor.o fossfor.bin
	chmod +x fossfor
