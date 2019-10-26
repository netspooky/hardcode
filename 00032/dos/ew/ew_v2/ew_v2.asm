	org 0x100

;        in al,0x61
;        or al,3
	mov al,3
	out 0x61,al

	;les bp,[bx]
	push 0xA000
	pop es
	mov al,0x13
	int 0x10
;        mov al,0xB6
;        out 0x43,al
here:	mov ax,cx
	xor al,ch
	and al,00111000b
	stosb
	loop here
	mov ax,di
	and al,00001111b
	out 0x42,al
	add di,0x3F
	jmp here