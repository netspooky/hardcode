;kaleid64
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;27-12-2011

;Enjoy!

org 100h
	mov al, 13h
	int 10h
	les dx, [bx]
	mov dx, 3d4h
	mov ah, 20h
	out dx, ax
L:	mov al, dl
R:	neg al
	jl R
	mov bx, di
	mul bl
	add bh, ah
	and bx, 7f7fh
	mov al, bl
	add al, bh
	add al, al
	salc
	push dx
	xor dl, al
	cmp bl, bh
	adc al, 0
	jnz A
	xchg bl, bh
A:	xchg ax, bx
	add al, dl
	pop dx
	xor al, ah
	stosb
	loop L
	inc dx
	in al, 60h
	dec al
	jnz L
	ret
