; Voxelscape in 192b
; by Rudi / yaphan~darklite

org 100h
	mov al, 13h
	int 10h
	mov ax, 0b000h
	mov es, ax
	mov ds, ax
	mov cx, 256*256-1
L:	add ax, di	;texture
	xor al, ch
	stosb
	loop L
	mov cx, 6;7	;blur
BC:	xor ax, ax
	push cx
	mov cx, 65535
B:	xor bx, bx
	add ax, bx
	mov bl, [di+256]
	add ax, bx
	mov bl, [di-1]
	add ax, bx
	mov bl, [di+1]
	add ax, bx
	shr ax, 2
	stosb
	loop B
	pop cx
	loop BC

	mov cx, 255	;pal
PAL:	mov al, cl
	mov dx,	3c8h
	out dx, al
	mov dx,	3c9h
	shr al, 2
	out dx, al
	out dx, al
	out dx, al
	loop PAL

	push 0a000h
	pop es	
DRAW:	xor di, di
	dec si
	mov cx, 320
	XLOOP:	mov bl, 200
		mov word [t+1], 0
		push cx
		mov cx, 160		;tracer
		TLOOP:	mov [t+3], cl	;illum
			push di
			;sub di, 160	;original
			;add di, cx	;move dir
			sub di, cx
			;xor di, cx
			imul di, word [t+1]
			shr di, 8	;((di-160)*t)>>8
			mov bp, si
			sub bp, [t+1]
			shl bp, 8	;(si-t)<<8
			xor ah, ah
			mov al, [ds:bp+di]
			pop di
			mov [t], al
			shl ax, 6
			inc byte [t+1]
			cwd
			idiv word [t+1]	;persp
			mov dl, al
			cmp ax, bx
			jae Y_LD
			push cx
			mov cl, bl
			sub cl, dl
			DR_V:	mov bp, bx
				sub bp, cx
				imul bp, 320
				mov al, 160	;ambient
				sub al, [t]
				add al, [t+3]	;global lighting
				mov byte [es:di+bp], al
			loop DR_V
			pop cx
			mov bl, dl
			Y_LD:
		loop TLOOP
		pop cx
		inc di
	loop XLOOP
	jmp DRAW
t db 0