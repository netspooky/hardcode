all: main
main:
	gcc -Os -ffast-math -fshort-double -fpeephole2 -fomit-frame-pointer -c main.c
	ld -dynamic-linker /lib/ld-linux.so.2 main.o /usr/lib/libSDL.so -o main
	strip -s -R .comment -R .gnu.version main
	~/documents/bin/sstrip main
	7z a -tGZip -mx=9 main.gz main
	cat unpack.header main.gz > main
	chmod a+x main
	rm main.gz main.o
	wc -c main

