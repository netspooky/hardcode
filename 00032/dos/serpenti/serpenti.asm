;serpenti
;32 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;04-01-2011

org 100h
	mov al, 13h	
	int 10h
	lds bp, [bx]
	mov dx, 3d4h
	mov ah, 20h
	out dx, ax

L:	add al, bh
	adc bl, 0
	sub ah, bl
	adc bh, 0
	mov [bx+si], dl
	loop L
	inc bx
	xadd si, dx
	jmp L