all:	sesamstr

INCS=data.inc font.inc gfx.inc zero_data.inc code.inc
font:	font.c

ggi:	ggi.o
	ld -g -o ggi ggi.o -lggi -dynamic-linker /lib/ld-linux.so.2 
ggi.o:	ggi.s $(INCS)
	as -g -o ggi.o ggi.s

sesamstr: sesamstr.o Makefile
	ld -o _ sesamstr.o --oformat binary
	@rm -f _.gz
	@gzip -9 _
	@rm -f sesamstr
	@echo -n "X=___HACK;tail -c " > sesamstr
	@cat _.gz | wc -c | tr -d "\ \n" >> sesamstr
	@echo " \$$0|zcat>\$$X;chmod +x \$$X;./___HACK;rm -f \$$X;exit " >> sesamstr
	@cat _.gz >> sesamstr
	@rm -f _.gz
	@chmod +x sesamstr
	@ls -l sesamstr
sesamstr.o: sesamstr.s $(INCS)
	as -o sesamstr.o sesamstr.s

clean:
	rm -f sesamstr.o sesamstr