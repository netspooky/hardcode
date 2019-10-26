org 100h
	mov al, 13h
	int 10h
	push 0a000h
	pop es
	mov si, 320

L:	mov ax, di
	xor dx, dx
	div si

	
	sub ax, bx
	imul ax, ax
	not bl
	sub dx, bx
	imul dx, dx
	add ax, dx
	shr ax, 8
	push ax
	neg bp
	js L
	
	pop dx
	pop dx
	imul dx 
	shr ax, 8

	stosb
	loop L
	inc bl
	in al, 60h
	dec ax
	jnz L
	ret

