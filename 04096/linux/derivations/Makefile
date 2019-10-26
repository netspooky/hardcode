# Derivations by zipola
# Compiles and links the executable.
CC = gcc
# Try -Os -O1 -O2 -O3
CFLAGS = -nostdlib -ffast-math -fomit-frame-pointer -fshort-double -fno-inline -fno-strict-aliasing -fpeephole2 -fexpensive-optimizations -Os
LINKER = ld
LDFLAGS = -dynamic-linker /lib/ld-linux.so.2
LDLIBS = /usr/lib/libSDL.so /usr/lib/libGL.so
TARGET = derivations

all: $(TARGET)

derivations: derivations.o gfx.o snd.o seq.o letters.o

	$(LINKER) $(LDFLAGS) $^ $(LDLIBS) -o $@
	./size.sh
	strip -s -R .comment -R .gnu.version $(TARGET)
	sstrip $(TARGET)
	#mv $(TARGET) $(TARGET)_big
	#upx --best --crp-ms=999999 --all-methods --all-filters --ultra-brute -o $(TARGET) $(TARGET)_big
	7z a -tgzip -mx=9 $(TARGET).gz $(TARGET)
	cat unpack.header $(TARGET).gz > $(TARGET)
	chmod a+x $(TARGET)
	rm $(TARGET).gz $(TARGET).o
	./size.sh

derivations.o: derivations.c
	$(CC) $(CFLAGS) -c $<

gfx.o: gfx.c
	$(CC) $(CFLAGS) -c $<

seq.o: seq.c
	$(CC) $(CFLAGS) -c $<

snd.o: snd.c
	$(CC) $(CFLAGS) -c $<

letters.o: letters.c
	$(CC) $(CFLAGS) -c $<

run:
	./$(TARGET)

distclean: clean
	$(RM) $(TARGET)

clean:
	$(RM) *.o *~
