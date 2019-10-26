.PHONY: all
all: player player.packxz
	@true

4klang.o: 4klang.asm 4klang.inc
	nasm -f elf32 4klang.asm 

player: 4klang.o player.c 4klang.inh shader.h shadermini.h
	gcc -m32 4klang.o player.c -O1 -o player /usr/lib/i386-linux-gnu/libSDL-1.2.so.0 -lGL -lpthread

player.pack: player stub.sh
	cp player player.pack
	~/src/ELFkickers-3.0a/bin/sstrip player.pack
	gzip -n --best player.pack
	advdef -z -4 player.pack.gz 
	cat stub.sh player.pack.gz > player.pack
	chmod +x player.pack
	rm player.pack.gz
	ls -l player.pack

player.packxz: player stubxz.sh
	cp player player.pack
	~/src/ELFkickers-3.0a/bin/sstrip player.pack
	xz -9e --block-size=65536 player.pack
	cat stubxz.sh player.pack.xz > player.packxz
	chmod +x player.packxz
	rm player.pack.xz
	ls -l player.packxz

hackers-electro_magnetic-2016.tar.xz: player player.packxz
	cp player electro-release/
	cp player.packxz electro-release/
	git archive --format=tar -o electro-release/src.tar HEAD
	tar -cvJf hackers-electro_magnetic-2016.tar.xz electro-release