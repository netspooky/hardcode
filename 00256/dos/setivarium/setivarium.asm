org 100h
	mov al,13h
	int 10h

	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx
	xor bl,bl
times256:
	mov al,bl
	dec al
	out dx,al
	shr al,1
	out dx,al
	shr al,1
	out dx,al
	dec bx
	jnz times256
nopal:

; ----------- Sinegen ------------

	XOR	DI,DI
	push word 09000h
	pop ds
	push word 0a000h
	pop es

Singen:
	MOV	[DI],CH
	ADD	CX,SI
	MOV	AX,40
	IMUL	CX
	SUB	SI,DX
	INC	DI
	JNZ	Singen

main:
	MOV	DX,3DAh
Vsync:
	IN	AL,DX
	AND	AL,8
	JZ	Vsync

	mov dl,[counter+1]
	and dl,3
	mov [part],dl

	xor di,di
	mov cx,200
	pixelY:
		mov bx,320
		pixelX:
			mov dx,[counter]
			cmp dl,32

			mov dl,[part]
			mov si,[counter]

			jnc nonoise

			noise:
				imul ax,bx
				add ax,6128
				imul ax,cx
				mov dx,si
				imul dx,di
				add ax,dx
			jmp pixel

nonoise:
			or dl,dl
			jz texture
			dec dl
			jz plasma
			dec dl
			jz lastfx
			dec dl
			jz onemore

			plasma:
				mov al,[ds:bx]
				mov bp,cx
				add bp,si
				add al,[ds:bp]
				shl bp,1
onemore:
				add bp,bx
				add ax,si
				add ax,si
				add al,[ds:bx]
				shl bp,1
				add al,[ds:bp]

				cmp al,128
				jc loopery
				mov dl,255
				sub dl,al
				mov al,dl
			loopery:
				shl al,1
			jmp pixel

			texture:
				mov al,bl
				mov bp,cx
				add bp,si
				add al,[ds:bp]
				mov dl,al
				mov al,cl
				mov bp,bx
				add bp,si
				add bp,si
				add al,[ds:bp]
				xor al,dl
			jmp pixel

			lastfx:
				mov ax,bx
				add ax,si
				imul ax
				mov bp,ax
				mov ax,cx
				imul ax
				add ax,bp
				add ax,si
				add ax,si




pixel:
			shr al,2

			mov dl,[part]

			shl dl,6
			add al,dl
			stosb
		dec bx
		jnz pixelX
		dec cx
	jnz pixelY

	inc word [counter]

	xor ax,ax
	in al,60h
	dec ax
	jnz main

	mov al,03h
	int 10h
ret

org 0200h
counter:

org 0202h
part:
