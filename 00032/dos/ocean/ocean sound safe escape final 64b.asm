org 100h
	aas
	les		di,		[byte bp+si-0x6C]
	mov 	al,		0x13
	les 	bp,		[byte si+M-3]
L:	int 	0x10
	mov 	ax,		0x1010
	inc 	cx
	dec 	bx
	jnz 	L
X:	push 	di
	fild 	word 	[bx-4]
	fidivr 	dword	[si]
M: 	stosb
	fstp 	dword	[bx-5]
	pop 	ax		
	add 	ax,		bp
	test 	al,		0x40
	jz 		F
	not 	al
F:	loop 	X
	dec 	bp
	mov 	dx,		0x331
	pusha
	outsb
	dec 	dx	
	outsb
	outsb
	outsb
	xchg 	bp,		ax
	shr 	al,		2
	out 	dx,		al
	out 	dx,		al
	popa
	in 		al,		0x60
	dec 	al
	jnz 	X
	jmp 	bx
