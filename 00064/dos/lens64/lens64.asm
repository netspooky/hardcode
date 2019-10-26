;lens64
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;17-10-2011

org 100h
	mov al, 13h
	int 10h
	les bx, [bx]
	mov si, 320

L:	mov ax, di
	xor dx, dx
	div si
	call pr
	xchg ax, dx
	call pr
	xor ax, dx
	and al, 12
	stosb
	loop L
	inc bp
	in al, 60h
	dec ax
	jnz L
	ret

pr:	sub ax, 100
	push ax
	imul ax, ax
	mov [si], ax
	add bx, ax
	pop ax
	cmp bh, 10h
	jge A
	imul ax, bx
	sar ax, 12
A:	add ax, bp
	mov bx, [si]
	ret