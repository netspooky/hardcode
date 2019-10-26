CXXFLAGS=`sdl-config --cflags` -Os -Wall -Wextra -Wshadow -ffast-math
LDFLAGS=`sdl-config --libs` -lGL

TARGET=main

#CXXFLAGS+= -DDEBUG=1
#LD=g++
	
LD=bold -c -a 

all: $(TARGET)
	@wc -c $(TARGET).payload
	lzma -c $(TARGET).payload > $(TARGET).lzma
	@wc -c $(TARGET).lzma
	cat unpack.header $(TARGET).lzma > $(TARGET)
	rm $(TARGET).lzma
	chmod +x $(TARGET)
	@wc -c $(TARGET)

# (window_w window_h framebuffer_w framebuffer_h)
$(TARGET): settings letters formatter $(TARGET).cpp
	echo 1920 1200 960 600 | ./settings > settings.h
	./formatter > shaders.h
	g++ $(CXXFLAGS) -c $(TARGET).cpp
	$(LD) $(LDFLAGS) $(TARGET).o -o $(TARGET).payload

settings:

formatter:

CXXFLAGS+= -std=c++0x
letters:

clean: 
	rm -f $(TARGET) *.o settings
