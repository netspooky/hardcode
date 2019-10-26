#It's Full Of Stars by Traction
#WIN32, LINUX, OS_X
PLATFORM = $(shell uname)
ifeq ($(PLATFORM),Linux)
PLATFORM = LINUX
endif
ifeq ($(PLATFORM),Darwin)
PLATFORM = OS_X
endif
ifeq ($(PLATFORM),)
PLATFORM = WIN32
endif

FULLSCREEN = TRUE
WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 768

#compiler we're using
CC = gcc
CXX = g++

#sourcefiles in use
OBJ = changer.o complex.o filter.o floater.o font.o hermitecurve.o liikkuva.o line.o lista.o main.o matikka.o matrix.o object3d.o path.o primitives.o sound.o stuff.o sync.o tausta.o texture.o timer.o vector.o win32.o alku.o dla.o hila.o kasvi.o kaupunki.o lento.o loppu.o maailma.o runko.o synty.o tunneli.o universumi.o valo.o

TARGET = stars
LDFLAGS = -lm
CFLAGS = -O2 -DWINDOW_WIDTH=$(WINDOW_WIDTH) -DWINDOW_HEIGHT=$(WINDOW_HEIGHT)

ifeq ($(FULLSCREEN),TRUE)
CFLAGS += -DFULLSCREEN
endif

#linux Makefile setup
ifeq ($(PLATFORM), LINUX)
LDFLAGS += -I/usr/X11R6/include/GL/ -L/usr/lib/ -L/usr/X11R6/lib/ -L../lib/linux/ -I./ -lGL -lGLU `sdl-config --libs` ./libfmodex.so.4.00.37
CFLAGS += `sdl-config --cflags`
endif

#windows Makefile setup
ifeq ($(PLATFORM), WIN32)
TARGET = stars.exe
CFLAGS += -Dmain=SDL_main
LDFLAGS += -L"lib" -lmingw32 -liberty -lglu32 -lopengl32 -lgdi32 -lSDLmain -lSDL -mwindows ./libfmodex.a
endif

#OS X Makefile setup
ifeq ($(PLATFORM),OS_X)
ENDIAN = $(shell uname -m)
ifeq ($(ENDIAN),Power Macintosh)
CFLAGS += -DBIGENDIAN
endif
CFLAGS += -DOS_X `sdl-config --cflags` -I/System/Library/Frameworks/AGL.framework/Headers
LDFLAGS += `sdl-config --static-libs` ./libfmodex.dylib
CXX = g++-3.3
CC = gcc-3.3
endif

.PHONY: all all-before all-after clean clean-custom
all: all-before $(TARGET) all-after
#define some system utilities
RM = rm -f
CP = cp -R
MKDIR = mkdir

clean:
	 $(RM) $(OBJ) $(TARGET)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $<

%.o: %.cpp $(HEADERS)
	$(CXX) $(CFLAGS) -c $<

%.o: ./Effects/%.cpp $(HEADERS)
	$(CXX) $(CFLAGS) -c $<

$(TARGET): $(OBJ)
	$(CXX) -o $@ $(OBJ) $(LDFLAGS)
