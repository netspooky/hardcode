

TEX01:	;texture generator
	;cx <- filter itaration number
	;ax <- initial value, < 1000h
	cwd
	xor bx, bx
RND:	add ax, bx
	xor al, ah
	mov [gs:bx], al
	inc bx
	jnz RND
FIL:	mov dl, [gs:bx]
	add ax, dx
	mov dl, [gs:bx+1]
	add ax, dx
	mov dl, [gs:bx+256]
	add ax, dx
	shr ax, 2
	mov [gs:bx], al
	inc bx
	jnz FIL
	loop FIL
	ret

TEX_ZZ:
	xor bx, bx
TEX_Z:
	mov byte [gs:bx], 0
	inc bx
	jnz TEX_Z
	inc byte [gs:bx]
	ret

TEX_BUSH:
	mov bx, [cs:SETCOL_00]
	imul bx, 153
	ror bx, 1
	mov [cs:SETCOL_00], bx
	test byte [gs:bx-1], 0ffh
	jnz TEX_BUSH_Z
	mov al, [gs:bx]
	or al, [gs:bx-2]
	or al, [gs:bx-257]
	or al, [gs:bx+255]
	jz TEX_BUSH_Z
	mov ax, si
	shr al, 1
	mov [gs:bx-1], al
TEX_BUSH_Z:
	ret



	




