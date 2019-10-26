;knead
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;20-01-2012


org 100h
	mov al, 13h
	int 10h
	push 0a000h
	pop es
	mov si, 320

L:	mov bl, 100
B:	mov ax, di
	xor dx, dx
	div si
	sub ax, bp
	sub dx, bx
	imul al
	imul dx, dx
	add ax, dx
	shr ax, 3
	push ax
	neg bp
	add bl, 120
	jnc B

	pop ax
	pop dx
	add ax, bp
	add dx, bp
	or ax, dx
	shr ax, 4
	stosb
	loop L
	dec bp
	in al, 60h
	dec al
	jnz L
	ret

