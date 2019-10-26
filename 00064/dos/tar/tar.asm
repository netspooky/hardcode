;tar
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;13-02-2013

;Just to not forget x86 asm.

org 100h
	mov al, 13h
	int 10h
	les bp, [bx]
L:	mov ax, 0cccdh
	mul di
	push dx
	mov al, dh
	sub ax, bp
	imul al
	xchg ax, dx
	imul bx, ax, 2
	xor bx, ax
	add bx, bp
	add bl, bh
	add al, [si]
	imul al
	add ax, dx
	pop dx
	mul dx
	xor ax, ax
	test dh, dh
	jz A
R:	adc al, 0
	shr bl, 1
	jnz R
A:	add al, 16
	stosb
	loop L
	inc bp
	sub [si-1], dx
	in al, 60h
	dec ax
	jnz L
	ret
	
	