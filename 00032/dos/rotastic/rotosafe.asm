org 100h
	push 0xa000
	pop es
	mov al,0x13
	int 0x10
X:	db 0x0f
	mov al,dl
	mul byte [bx]

	mov al,dh

	sub dh,ah
	
	mul byte [bx]
	add dl,ah
	
	xor dl,dh
	xchg dx,ax
	stosb
	mov ax,0xcccd
	mul di
jmp short X-1
