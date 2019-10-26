all:	sierp2.com set80x25.com

sierp2.com:	sierp2.asm vga.inc
	nasm sierp2.asm -o sierp2.com

set80x25.com:	set80x25.asm vga.inc
	nasm set80x25.asm -o set80x25.com

clean:
	rm -f *~
	rm -f *.com
