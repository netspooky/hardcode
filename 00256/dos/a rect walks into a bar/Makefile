
all: rectbar.com backup.com

rectbar.com: rectbar.asm
	nasm -f bin -O2 rectbar.asm -o rectbar.com -dREALTHING

backup.com: rectbar.asm
	nasm -f bin -O2 rectbar.asm -o backup.com

clean:
	rm -f *.com

