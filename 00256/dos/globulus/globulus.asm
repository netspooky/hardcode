org 100h
	mov al,13h
	int 10h

	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx

times256:
	mov al,32
	out dx,al
	mov al,bl
	shr al,3
	shl al,1
	out dx,al
	shl al,2
	out dx,al
	inc bx
	jnz times256
nopal:
; ----------- Sinegen ------------

	XOR	DI,DI
	push word 09000h
	pop ds
	push word 08000h
	pop es
	push word 0a000h
	pop fs

Singen:
	MOV	[DI],CH
	ADD	CX,SI
	MOV	AX,40
	IMUL	CX
	SUB	SI,DX
	INC	DI
	JNZ	Singen

main:
	;call cls
;                xor eax,eax
	add eax,ebx
	mov cx,16000
	xor di,di
	rep stosd


	mov bp,32
sineI:
	mov di,bp

	shl di,3
	add di,[counter]

	mov bx,160
	mov al,[di + bx]
	add bl,al
	add bl,al

	mov cx,100
	add di,[counter]
	mov al,[di+bx]
	add cl,al
	add cl,al

	mov dx,20
	add di,[counter]
	mov al,[di]
	add dl,al
	add dl,32

	call drawSprite

	dec bp
jnz sineI

	MOV	DX,3DAh
Vsync:
	IN	AL,DX
	AND	AL,8
	JZ	Vsync

	mov cx,16000
	xor si,si
copyloop:
	mov eax,[es:si]
	mov [fs:si],eax
	add si,4
	dec cx
	jnz copyloop

	inc byte [counter]

	xor ax,ax
	in al,60h
	dec ax
	jnz main

	mov al,03h
	int 10h
ret

drawSprite:
; dx = size
; bx = xpos
; cx = ypos

shr dx,1

sub bx,dx
sub cx,dx

mov ax,cx
shl ax,6
mov ch,cl
xor cl,cl
add ax,cx
mov di,ax
add di,bx

xor ax,ax
sub ax,dx
    mov cx,ax
    mov bx,ax
    inc dx

    spriteY:
    push bx
    spriteX:
	push dx
	mov ax,bx
	imul bx
	mov si,ax
	mov ax,cx
	imul cx
	add ax,si
	pop dx
	div dl
	xor ah,ah
	shl ax,5
	or ah,ah
	jz noclamp
	mov al,255
noclamp:
not al
	mov ah,[es:di]
	add al,ah
	jnc noclamp2
	mov al,255
noclamp2:
	stosb
	inc bx
	cmp bx,dx
	jnz spriteX
    pop bx

    sub di,dx
    sub di,dx
    add di,321
    inc cx
    cmp cx,dx
    jnz spriteY
ret

org 0200h
counter: