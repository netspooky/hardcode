org 100h
	aas
	les		di,		[byte bp+si-0x6C]
	les 	bp,		[byte si+M-3]
	mov 	al,		0x13
	cwd
L:	int		0x10
	mov 	ax,		0x1010
	inc 	cx
	dec 	bx
	jnz 	L
X:	push 	di
	fninit
	fild 	word	[bx-4]
	fidivr 	dword	[si]
M: 	stosb
	fst 	dword	[bx-5]
	pop 	ax
	add 	ax,		bp
	test 	al,		0x40
	jz 		F
	not 	al
F:
	loop 	X
	inc 	bp
	mov 	dx,		0x331
	push 	si
	outsb
	dec 	dx
	outsb
	outsb
	outsb
	pop 	si
	imul 	ax,		bp,	byte 51
	aam 	50
	out 	dx,		al
	shl 	al,		1
	out 	dx,		al
	jmp 	short 	X
