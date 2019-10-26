CXXFLAGS=`sdl-config --cflags` -O1 -Wall -Wextra -Wshadow -ffast-math
LDFLAGS=`sdl-config --libs` -lGL

TARGET=slsim

#CXXFLAGS+= -DDEBUG=1
#LD=g++
	
LD=bold -c -a 

all: $(TARGET)
	@wc -c $(TARGET).payload
	gzip -c $(TARGET).payload > $(TARGET).gz
	@wc -c $(TARGET).gz
	cat unpack.header $(TARGET).gz > $(TARGET)
	rm $(TARGET).gz
	chmod +x $(TARGET)
	@wc -c $(TARGET)

# (window_w window_h framebuffer_w framebuffer_h)
$(TARGET): settings $(TARGET).cpp
	echo 960 600 960 600 | ./settings > settings.h
	g++ $(CXXFLAGS) -c $(TARGET).cpp
	$(LD) $(LDFLAGS) $(TARGET).o -o $(TARGET).payload

settings:

clean: 
	rm -f $(TARGET) *.o settings
