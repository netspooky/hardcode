# A very pathetic makefile...

CFLAGS += -funsigned-char -O2 -ffast-math -I/usr/local/include

lib: obj
	ar rc cool_mzx.a pt*.o cool*.o sd*.o
	ranlib cool_mzx.a

obj:
	$(CC) $(CFLAGS) -c *.c

clean:
	rm *.o *.a
