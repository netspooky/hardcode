CFLAGS=-O3 -g
XLIBDIR=-L/usr/X11/lib -L/usr/X11R6/lib
GLLIBS=-lglut -lGLU -lGL
XLIBS=-lX11 -lXext -lXmu -lXt -lXi
OBJS=17Points.o

17Points:	$(OBJS)
	    cc $(CFLAGS) $(OBJS) $(XLIBDIR) $(GLLIBS) $(XLIBS) -o 17Points

17Points.o:	17Points.cpp
	    cc $(CFLAGS) -c 17Points.cpp
