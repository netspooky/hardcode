	org 	100h
	mov 	al, 0x13
	les 	bp, [byte si+M-3]
L:	int 	0x10
	mov 	ax, 0x1010
	inc 	cx
	dec 	bx
	jnz 	L
X:	push 	di
	fild 	word [bx-4]
	fidivr 	dword [si]
M:	stosb
	fstp 	dword [bx-5]
	pop 	ax		
	sub 	ax, bp
	loop 	X
	inc 	bp
	jmp 	short X