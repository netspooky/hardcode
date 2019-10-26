dump_value dw 0
dump_target dw 0
dump_nums db "0123456789ABCDEF"

dump_template:
	db "AX=.... "
	db "BX=.... "
	db "CX=.... "
	db "DX=....",10
	db "SI=.... "
	db "DI=.... "
	db "BP=.... "
	db "SP=.... "
	db 13,10,"$"

dump_regmap:
	dw 14,8,12,10,2,0,4,6

dump_nibble:
	and al,0fH
	lea bx,[dump_nums]
	xlat [bx]
	stosb
	ret

dump_byte:
	mov ah,al
	shr al,4
	call dump_nibble
	mov al,ah
	call dump_nibble
	ret

dump_word:
	pusha

	mov di,[dump_target]
	mov al,byte [1 + dump_value]
	call dump_byte
	mov al,byte [dump_value]
	call dump_byte	

	popa
	ret

dump:
	
	push es
	pusha

	push cs
	pop es

	mov cx,8
	lea si,[dump_regmap]
	lea bx,[3 + dump_template]

dump_xreg:
	mov bp,sp
	add bp,[si]
	mov ax,[bp]
	mov [dump_value],ax
	mov [dump_target],bx
	call dump_word

	add bx,8
	add si,2
	loop dump_xreg

dump_qreg:
	lea dx,[dump_template]
	mov ah,9
	int 21H

	popa
	pop es
	ret