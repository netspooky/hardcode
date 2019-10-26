org 100h
	mov al,13h
	int 10h

; ----------- Sinegen ------------


	XOR	DI,DI
	xor cx,cx
	push word 09000h
	pop fs

Singen:
	MOV	[fS:DI],CH
	ADD	CX,SI
	MOV	AX,56
	IMUL	CX
	SUB	SI,DX
	INC	DI
	JNZ	Singen


	push word 08000h
	pop es


	xor di,di
patterns:
	mov bl,0
syloop:
	mov cl,0
sxloop:

	mov bh,bl
	and bh,7
jz test4
	mov ch,cl
	and ch,7
jz test4

	cmp ch,5
	jc nomirror
	mov al,4
	sub al,ch
	add al,al
	mov ah,255
	mov bp,ax

	mov al,[es:di+bp]

	jmp test3
nomirror:
;3,2,1
;5,6,7

	xor si,ax
	imul si,cx
	imul si,bx
	and si,255
	mov al,[cs:si]

	cmp al,1
	jnc test2
test4:
	xor al,al
	jmp test3
test2:
	mov al,cl
	and al,11111000b
	mov ah,bl
	and ah,11111000b
	add al,ah
	add al,ah
	add al,32
test3:


	stosb

	inc cl
	jnz sxloop
	inc bl
	jnz syloop


	push word 08000h
	pop ds
	push word 0a000h
	pop es
	xor bh,bh
main:
	xor di,di
	mov bl,200
ayloop:
	mov cx,320
axloop:
	mov ah,bl
	xor al,al

	push bx
	add ax,[fs:bp]
mov dx,bp
and dh,4
jz nodistort
	mov bx,cx
	shr bx,1
	add ax,[fs:bx]
nodistort:


	mov bx,cx
	push cx
	mov cx,bp
	shr cx,2
	shr cl,6
	inc cl
	shr ah,cl
	mov dx,bx
	shr dx,cl
	add dx,ax
	pop cx


	mov bx,dx
	mov al,[bx]
	pop bx

	stosb
	loop axloop
	dec bx
	jnz ayloop

	MOV	DX,3DAh
Vsync:
	IN	AL,DX
	AND	AL,8
	JZ	Vsync

	inc bp

	in al,60h
	dec al
	jnz main

	mov ax,03h
	int 10h
ret
