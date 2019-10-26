all:
	nasm -f bin tides.asm -o tides.bin
	zopfli --i1000 tides.bin
	mv tides.bin.gz tides.img
clean:
	rm -f *.bin
