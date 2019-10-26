# Makefile for TinyPTC/x11

PROG     = test
FLAGS    = -s -O3 -Wall
CC       = gcc $(FLAGS)
STRIP	 = strip
INCLUDES = -I/usr/X11R6/include -I/usr/include -I/usr/local/include
LIB      = -L/usr/X11R6/lib -L/usr/lib -L/usr/local/lib -lX11 -lXext \
			-lXxf86dga -lXxf86vm
OBJ      = test.o x11_8bit.o convert_8bit.o

$(PROG):	$(OBJ)
		$(CC) $(INCLUDES) $(OBJ) $(LIB) -o $(PROG)
		$(STRIP) --strip-all $(PROG)
		$(STRIP) --remove-section=".comment" $(PROG)
		$(STRIP) --remove-section=".note" $(PROG)

x11_8bit.o:		x11_8bit.c convert_8bit.c tinyptc.h
convert_8bit.o:  convert_8bit.c
test.o:		test.c

clean:		
			rm -f $(PROG)
			rm -f $(OBJ)
# DO NOT DELETE
