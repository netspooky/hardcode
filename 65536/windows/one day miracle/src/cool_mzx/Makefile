# A very pathetic makefile...

COPT += -funsigned-char -O2 -ffast-math
INC = -I/usr/local/include

lib: obj
	ar rc cool_mzx.a pt*.o cool*.o sd*.o
	$(RANLIB) cool_mzx.a

obj:
	$(CC) $(COPT) $(INC) -c *.c

clean:
	rm *.o *.a
