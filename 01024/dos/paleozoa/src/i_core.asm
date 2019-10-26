	

CORE:
	sub bx, 160
	push cx
	mov ax, bx
	cwd
	mov ah, bl
	idiv cx
	xchg bx, ax

	xor ax, ax
	cwd		;dx <- 0
	dec ax		;ax <- FFFFh
	div cx
	mov cx, ax
			;x -> bx, y -> cx

	call di
	neg bx
	pop cx
			;height scaling
	push cx
	sub cx, 40
	imul bx, cx
	sar bx, 7
	pop cx
			;perspective scaling
	add bx, cx
	sar bx, 1
	add bx, 78
	cmp bx, 200
	jae CORE_Z
	cmp di, F_SKY
	jne CORE_LOW
	imul di, bx, -320
	sub di, 1536
	jmp CORE_0
CORE_LOW:
	imul di, bx, 320
CORE_0:
	push cx
	mov cx, 5
CORE_R:	mov [fs:di+bp], al
	add di, 320
	loop CORE_R
	pop cx
CORE_Z:	mov bx, bp
	ret
