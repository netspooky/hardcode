;disco64
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
	mov bp, sp
	fldlg2
	fldz

L:	mov ax, di
	xor dx, dx
	div si
	sub ax, bx
	neg bl
	sub dx, bx
	pusha
	fild word [bp-2]
	fild word [bp-6]
	fpatan
	fdiv st2
	fadd st1
	fistp word [bp-2]
	popa
	stosb
	loop L
	fsub st1
	inc bl
	in al, 60h
	dec al
	jnz L
	ret


