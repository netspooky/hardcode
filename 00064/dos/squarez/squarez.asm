;squarez
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;24-10-2011

org 100h
	mov al, 13h
	int 10h
	push 0a000h
	pop es
	mov si, 320

L:	push cx
	push bx
	mov cl, 8
A:	mov ax, di
	xor dx, dx
	div si
	add ax, bx
	shr bx, 1
	test cl, 0aah
	jz C1
	neg bx
C1:	sub dx, bx
	xor al, dl		
	and al, cl
	jz C2
	mov bp, ax
C2:	add cl, cl
	jns A
	pop bx
	pop cx
	xchg ax, bp
	xor al, ah
	stosb
	loop L
	inc bx
	in al, 60h
	dec al
	jnz L
	ret




