;pcm32
;32 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;17-01-12

;Inspired by viznut works.
;Now pcm sound is possible under MS-DOS in 32 bytes!
;You need covox emulation to listen it.
;Enjoy!


org 100h

L:	in al, 40h
	in al, 40h		;al <- 4.7 kHz
	cmp al, bl
	mov bl, al
	je L
	mov cl, [fs:46ch]	;cl <- 18 Hz
	and al, cl
	mul cl
	ror al, cl
	shr cl, 4
	or al, cl
	mov dx, 378h
	out dx, al
	jmp L
