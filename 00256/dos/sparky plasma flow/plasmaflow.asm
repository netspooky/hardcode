org 100h
	mov al,13h
	int 10h

; ----------- Sinegen ------------

	xor di,di
	xor cx,cx
	push word 09000h
	pop ds


Singen:
	MOV	[DI],CH
	ADD	CX,SI
	MOV	AX,56*2
	IMUL	CX
	SUB	SI,DX
	INC	DI
	JNZ	Singen


; ----------- Palgen ------------


	mov dx,3C8h
	xor ax,ax
	out dx,al
	inc dx
col64:
	mov al,ah
	cmp al,128
	jc trig3
	and al,127
trig3:
	cmp al,64
	jc trig1
	xor al,63
trig1:
	and al,63
	out dx,al

	push ax
	shr al,1
	out dx,al
	pop ax

	cmp al,32
	jc trig2
	xor al,31
trig2:
	and al,31
	shl al,1
	out dx,al

	inc ah
	jnz col64

call pepper


main:

plasma:
	push word 09000h	; sines
	pop ds
	push word 08000h	; plasma
	pop es

	inc bp
	xor di,di
	mov bx,200
ayloop:
	mov cx,320
axloop:
	mov ax,[bx]
	mov si,bp
	add si,cx
	add ax,[si+bx]
	mov si,bp
	add si,cx
	add ax,[si+bx]
	mov si,bp
	add si,bx
	add ax,[si+bx]

	cmp al,128
	jc nopingpong
	mov dx,255
	sub dx,ax
	mov ax,dx
nopingpong:

	stosb
	loop axloop
	dec bx
	jnz ayloop
;jp render
flow:
	push word 08000h	; plasma
	pop ds
	push word 07000h	; flow
	pop es

	mov di,1*320 + 1
	mov si,di
	mov cx,64000-2*320-6
flowi:
	mov bl,[si+1]
	sub bl,[si-1]	; bl = DiffX
	mov al,[si-320]
	sub al,[si+320] ; al = DiffY

	cbw
	imul ax,320
	push ax
	mov al,bl
	cbw
	pop bx
	add bx,ax

	xor ah,ah
	mov al,[es:di]
	add al,[es:di+bx]
	shr al,1

	inc al

	mov[es:di+bx],al

	inc di
	inc si
	loop flowi

render:
	push word 07000h	; flow
	pop ds
	push word 0A000h	; screen
	pop es

	xor di,di
	xor si,si
	mov cx,64000
	rep movsb


	MOV	DX,3DAh
Vsync:
	IN	AL,DX
	AND	AL,8
	JZ	Vsync

	in al,60h
	dec al
	jnz main

	mov ax,03h
	int 10h
ret

pepper:
	push word 07000h	; flow
	pop es
	mov cx,64000
pepperloop:
	mov ax,cx
	stosb
	loop pepperloop
ret