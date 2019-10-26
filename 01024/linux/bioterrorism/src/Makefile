AOBJ=load.o synth.o
COBJ=
OBJ=$(AOBJ) $(COBJ)
#OBJ=$(AOBJ)
#CFLAGS=-Wall -m32 -Os -fomit-frame-pointer -flto -ffast-math
CFLAGS=-Wall -m32 -O1 -fomit-frame-pointer -ffast-math
WIDTH=1280
HEIGHT=720
FULLSCREEN=0
#FULLSCREEN=0x80000000

all: packed

intro: intro.asm t.frag.small
	nasm -f bin $< -o $@ -dWIDTH=$(WIDTH) -dHEIGHT=$(HEIGHT) -dFULLSCREEN=$(FULLSCREEN)
	chmod +x $@
	du -b $@

packed: intro unpack.header
	cp $< t
#	gzip -n --best -f -c $< > $<.gz
	7z a -tGZip -mx=9 $<.gz t
	cat unpack.header $<.gz > $@
	rm t $<.gz
	chmod a+rx $@
	du -b $@

#t.frag.small: t.frag cshader
t.frag.small: march.frag cshader
	./cshader WIDTH $(WIDTH) HEIGHT $(HEIGHT) < $< > $@

cshader: %: %.cpp
	g++ $< -o $@ -Wall -O2

clean:
	rm -f packed t.frag.small cshader
