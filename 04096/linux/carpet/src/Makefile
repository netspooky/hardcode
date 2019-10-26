CC = gcc
CFLAGS = -Wall -W -pedantic `sdl-config --cflags` -march=i386 -Os
CLIBS = -L/usr/X11R6/lib -lGL `sdl-config --libs` -lm -lasound

intro: main.o
	$(CC) $(CFLAGS) $(CLIBS) *.o -o binary
	strip -s -R .gnu.version -R .comment binary
	gzip --best binary
	cat header.sh binary.gz >carpet
	rm -f binary.gz
	chmod a+x carpet
	mv carpet ../
main.o: main.c
	$(CC) $(CFLAGS) main.c -c

clean:
	@echo Cleaning up...
	rm -f *.o *~ core* binary*
	@echo Done.
