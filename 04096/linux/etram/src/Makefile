etram: main.c player.h particles.h defines.h dl_init.h
	gcc -march=i686 -std=c99 -nostdlib -nostartfiles -Os -fno-strict-aliasing -fomit-frame-pointer -ffast-math -Wall -frerun-cse-after-loop -o main main.c `sdl-config --cflags` -ldl 
	./pack.sh main etram

debug: main.c player.h particles.h defines.h dl_init.h
	gcc -march=i686 -mcpu=athlon-xp -std=c99 -nostdlib -nostartfiles -g -fno-strict-aliasing -ffast-math -Wall -frerun-cse-after-loop -o debug main.c `sdl-config --cflags` -ldl -DDEBUG 

unpacked: main.c player.h particles.h defines.h dl_init.c dl_init.h
	gcc -march=i686 -mcpu=athlon-xp -std=c99 -nostdlib -nostartfiles -Os -fno-strict-aliasing -fomit-frame-pointer -ffast-math -Wall -frerun-cse-after-loop -o main main.c `sdl-config --cflags` -ldl 



clean:
	rm -f etram main 

.PHONY: clean
