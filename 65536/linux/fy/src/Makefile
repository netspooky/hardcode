OBJS = src/main.o src/sound.o

EXECUTABLE = fy  

CFLAGS = -Wall -ansi -I ./include
COMPILE =$(CC) $(CFLAGS) -c

CC = gcc
LFLAGS =`sdl-config --cflags --libs` -lm  -s -L ./lib/linux -lminifmod -lpthread

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJS)
	$(CC) -o $(EXECUTABLE) $(OBJS) $(LFLAGS)

main.o bmp.o: src/main.h

%.o: %.c
	$(COMPILE) -o $@ $<

clean:
	-rm src/$(OBJS) $(EXECUTABLE) src/*~
	-rm ./*~
	-rm src/*.o
