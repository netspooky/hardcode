TARGET_NAME=DasSanseffortseur

EXTRA_INCLUDE=
#LIBS= -L. -lsfml-graphics -lsfml-window -lsfml-system -lrtaudio_static -lpulse -lpulse-simple -lpthread -lGL `pkg-config --libs gtk+-2.0`
LIBS= -L. -lX11 -lrtaudio_static -lpulse -lpulse-simple -lpthread -lGL `pkg-config --libs gtk+-2.0` -lGLU
DEFINES= -DeRELEASE -DePLAYER -DeGTK


CXXFLAGS= $(DEFINES) $(EXTRA_INCLUDE) -W -Wall -s -Os -std=c++11 `pkg-config --cflags gtk+-2.0`

OBJ= cameras.o \
	frameworks.o \
	main.o \
	music.o \
	scenes.o \
	sequences.o \
	tf4.o \
	tf4fx.o \
	array.o \
	random.o \
	runtime.o \
	simd.o  \
	vec3.o  \
	window.o  \
	fbo.o  \
	texture.o  \
	datastream.o

FILECPP= main.cpp \
	cameras.cpp \
	frameworks.cpp \
	music.cpp  \
	scenes.cpp \
	sequences.cpp\
	tf4.cpp \
	tf4fx.cpp \
	array.cpp \
	random.cpp \
	runtime.cpp \
	simd.cpp \
  vec3.cpp  \
  window.cpp  \
	fbo.cpp  \
	texture.cpp  \
	datastream.cpp


HEADER= cameras.hpp \
	frameworks.hpp \
	music.hpp  \
	scenes.hpp \
	sequences.hpp\
	tf4.hpp \
	tf4fx.hpp \
	array.hpp \
	random.hpp \
	runtime.hpp \
	simd.hpp \
  system.hpp \
  types.hpp \
  vec3.cpp  \
  window.cpp  \
	fbo.hpp  \
	texture.hpp  \
	datastream.hpp

all: $(OBJ) $(FILECPP) $(FILEC) $(HEADER)
	g++ -o $(TARGET_NAME) $(OBJ) $(LIBS) 
	strip -s -x -X -v $(TARGET_NAME)
	upx --ultra-brute $(TARGET_NAME)

%.o: %.cpp $(HEADER)
	@echo Compile C++ $< to $@
	g++  -c $< -o $@ $(CXXFLAGS)

clean:
	rm *.o
	rm *~

