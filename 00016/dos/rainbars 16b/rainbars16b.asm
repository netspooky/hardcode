	mov al,0x13
L:	int 0x10
	mov ax,cx
	mov al,0xc4
	rol ax,4
	loop L
	inc dx
	jmp short L
