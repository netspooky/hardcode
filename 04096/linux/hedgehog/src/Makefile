CC = gcc
CFLAGS = -Wall -W -pedantic `sdl-config --cflags` -Os
CLIBS = -L/usr/X11R6/lib -lGL `sdl-config --libs` -lm

hedgehog: hedgehog.o
	$(CC) $(CFLAGS) $(CLIBS) *.o -o binary
	strip -s -R .gnu.version -R .comment binary
	gzip --best binary
	cat header.sh binary.gz >hedgehog
	rm -f binary.gz
	chmod +x hedgehog
	mv hedgehog ../
hedgehog.o: hedgehog.c
	$(CC) $(CFLAGS) hedgehog.c -c

clean:
	@echo Cleaning up...
	rm -f *.o *~ core* binary.gz
	@echo Done.
