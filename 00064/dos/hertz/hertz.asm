;hertz
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;02-11-2011

org 100h
	mov al, 13h
	int 10h
	les bx, [bx]

L:	mov si, 320
	mov ax, di
	xor dx, dx
	div si
	shr si, 1
	sub dx, si
	jc A
	neg dx
A:	sub ax, dx
	sub ax, si
	imul ax, ax
	imul dx, dx
	add ax, dx
	sub bp, ax
	salc
	xor al, 4
	stosb
	and bp, bx
	loop L
	mov bh, [fs:46ch]
	and bh, 8
	or bh, 7
	in al, 60h
	dec al
	jnz L
	ret





