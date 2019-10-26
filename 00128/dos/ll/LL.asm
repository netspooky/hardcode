;LL
;128 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;22-03-2012

;Another boring xor poles...
;But with reflecting floor!


org 100h
	mov al, 13h
	int 10h
c1:	push 0a000h
	pop es
	mov dx, 3c9h
PAL:	shr al, 1
	out dx, al
	shrd ax, cx, 18
	out dx, al
	out dx, al
	loop PAL

L:	mov cx, 319
LX:	mov ax, 64
LR:	inc al
	jz R

	mov bx, cx
	imul bx, ax
	mov bl, bh
	add bx, si
	mov bp, bx
	xor bp, ax
	and bl, al
	or bl, 11010111b
	inc bl
	jnz LR

R:	mov dl, 200
LY:	push bp
	push ax
	push dx

	imul dx, ax
	mov dl, dh
	add dl, dl
	jo FLOOR
	xor bp, dx
	and bp, 31
	neg al
	jnz Z

FLOOR:
	pop di
	push di
	push ax
	mov ax, 4000h
	cwd
	div di
	push ax
	cwd
	shrd ax, cx, 10
	div di
	pop dx
	add ax, si
	xor ax, dx
	and al, 31
	pop bp

Z:	sub ax, bp
	add al, 32
	pop dx
	imul di, dx, 320
	add di, cx
	stosb
	pop ax
	pop bp
	dec dx
	jnz LY
	loop LX
	inc si
	in al, 60h
	dec ax
	jnz L
	ret



