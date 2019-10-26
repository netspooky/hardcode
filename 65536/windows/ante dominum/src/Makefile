#Ante Dominum by Traction
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

FULLSCREEN = FALSE
WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480

#compiler we're using
CC = gcc
CPP = g++

OBJ = changer.o filter.o hermitecurve.o lista.o matrix.o path.o stuff.o texture.o win32.o complex.o floater.o liikkuva.o main.o molekyylidata.o primitives.o sync.o timer.o config.o font.o line.o matikka.o object3d.o sound.o tausta.o vector.o alku.o curves.o field.o newton.o rossler.o cell.o dla.o iterator.o platon.o runko.o converge.o fibotree.o lorentz.o pot2d.o

TARGET = ante_dominum
LDFLAGS = -lm
INCLUDES =
CFLAGS = -DWINDOW_WIDTH=$(WINDOW_WIDTH) -DWINDOW_HEIGHT=$(WINDOW_HEIGHT) -O2 $(INCLUDES)
CPPCFLAGS = -fno-exceptions -fno-rtti
CCFLAGS =
RELEASES = 

ifeq ($(FULLSCREEN),TRUE)
CFLAGS += -DFULLSCREEN
endif

ifeq ($(PLATFORM), LINUX)
LDFLAGS += -I/usr/X11R6/include/GL/ -L/usr/lib/ -L/usr/X11R6/lib/ -L../lib/linux/ -I./ -lGL -lGLU `sdl-config --libs` ./libfmodex.so.4.00.37
CFLAGS += `sdl-config --cflags`
endif

ifeq ($(PLATFORM), WIN32)
TARGET = ssri.exe
CFLAGS += -Dmain=SDL_main
LDFLAGS += -L"lib" -lmingw32 -liberty -lglu32 -lopengl32 -lgdi32 -lSDLmain -lSDL -mwindows ./libfmodex.a
endif

ifeq ($(PLATFORM),OS_X)
ENDIAN = $(shell uname -m)
ifeq ($(ENDIAN),Power Macintosh)
CFLAGS += -DBIGENDIAN
endif
CFLAGS += -DOS_X `sdl-config --cflags` -I/System/Library/Frameworks/AGL.framework/Headers
LDFLAGS += `sdl-config --static-libs` ./libfmodex.dylib
CPP = g++-3.3
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
	$(CC) $(EXTRACFLAGS) $(CFLAGS) $(CCFLAGS) -c $<

%.o: %.cpp $(HEADERS)
	$(CPP) $(EXTRACFLAGS) $(CFLAGS) $(CPPFLAGS) -c $<

%.o: ./Effects/%.cpp $(HEADERS)
	$(CPP) $(EXTRACFLAGS) $(CFLAGS) $(CPPFLAGS) -c $<

$(TARGET): $(OBJ)
	$(CPP) -o $@ $(OBJ) $(LDFLAGS)
