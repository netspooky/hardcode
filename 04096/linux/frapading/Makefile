CC=gcc
CFLAGS=-O2 -Wall
NASM=nasm
ASFLAGS=-f bin

PROGS=tinlink frapading wav2bit

all : frapading

wav2bit : wav2bit.o wav.o
	$(CC) $(CFLAGS) -o $@ $^

tinlink : tinlink.o
	$(CC) $(CFLAGS) -o $@ $<

frapading.1b : frapading.wav wav2bit
	wav2bit

frapading : frapading.1b tinlink frapading.o
	tinlink -o $@ -c frapading.o -m 65536

%.o : %.asm
	$(NASM) $(ASFLAGS) -o $@ $<

distclean :
	rm -f $(PROGS) *.o *~ core *.1b

clean :
	rm -f *.o *~ core tinlink frapading.1b wav2bit

.PHONY : all clean distclean
