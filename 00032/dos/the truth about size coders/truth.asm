
	ORG 0x100

	mov al,0x13
	int 0x10
	push word 0xa000
	pop ds
	mov dword [31838],0x40424242
	mov word [31838+320],0x0642
loop:	in al,0x60
	dec al
	jnz loop
	ret
