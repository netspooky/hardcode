all: pwplib.a
	cd oldchsool; make

./configure:
	$(CC) configure.c -o configure

pwplib/Makefile: ./configure
	./configure
	exit 123

pwplib.a: pwplib/Makefile
	cd pwplib; make

clean:
	rm -f *~ ./configure ./configure.exe
	cd pwplib; make clean; rm -f Makefile
	cd oldchsool; make clean; rm -f Makefile

linux: ./configure
	./configure linux
	make all

unix: ./configure
	./configure unix
	make all

hpux: ./configure
	./configure hpux
	make all

cygwin: ./configure
	./configure cygwin
	make all

win32: ./configure
	./configure win32
	make all

