org 100h
	mov al,13h
	int 10h

	mov dx,3C8h
	xor ax,ax
	mov cl,1
	out dx,al
	inc dx
col64:
	mov al,ah
	cmp al,128
	jc trig3
	and al,127
	mov cl,8
trig3:
	cmp al,64
	jc trig1
	xor al,63
trig1:
	and al,63
	out dx,al

	push ax
	shr al,cl
	out dx,al
	pop ax

	cmp al,32
	jc trig2
	xor al,31
trig2:
	and al,31
	out dx,al

	inc ah
	jnz col64


; ----------- Sinegen ------------


	XOR	DI,DI
	xor cx,cx
	push word 09000h
	pop ds

Singen:
	MOV	[DI],CH
	ADD	CX,SI
	MOV	AX,56
	IMUL	CX
	SUB	SI,DX
	INC	DI
	JNZ	Singen

	push word 0a000h
	pop es
	push word 08000h
	pop fs

main:
	push bp
	add di,2
	xor si,si
	mov bl,200
yloop:
	mov cx,320
xloop:

	push si
	push di
	mov si,2
	xor bp,bp
nblobs:
	mov al,bl
	sub al,100
	sub al,[di]
	imul al
	mov dx,ax

	mov al,cl
	sub al,160
	shr di,1
	sub al,[di+64]
	imul al
	add ax,dx

	push bp
	xor dx,dx
	mov bp,64
	idiv bp
	pop bp

	add bp,ax
	add bp,ax
;        add bp,ax

	dec si
	jnz nblobs

	mov ax,bp

	or ah,ah
	jz below256
	mov al,255
below256:
;        xor ax,255
	pop di
	pop si
;        xor al,127
	mov [fs:si],al

	inc si
	dec cx
	jnz xloop

	dec bl
	jnz yloop

	pop bp
	push di
	push si
	call plasma
	pop si
	pop di
	call avsync

	in al,60h
	dec al
	jnz main

	mov al,03h
	int 10h
ret


; ----------------------------------


plasma:
	inc bp
	xor di,di
	mov bl,200
ayloop:
	mov cx,320
axloop:
	mov ax,[bx]
	mov si,cx
	shl si,2
	add si,cx
	add ax,[si+bx]
	mov si,bp
	add si,cx
	shl si,1
	add si,bx
	add ax,[si+bx]
	mov si,bp
	add si,cx
	shr si,1
	add si,bx
	shl si,1
	add ax,[si+bx]

	and al,127

	add al,[fs:di]
	add al,[fs:di]


	stosb
	loop axloop
	dec bx
	jnz ayloop
ret

avsync:

	MOV	DX,3DAh
Vsync:
	IN	AL,DX
	AND	AL,8
	JZ	Vsync

ret