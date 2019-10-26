gcc -std=c99 -g -o swamp_fly src/SDLMain.m src/swamp_fly.c src/record.c -DUSE_GNU_LD -framework OpenGL -framework GLUT -framework SDL -framework Cocoa \
 -L/usr/X11/lib/ -lpng12 -lz
