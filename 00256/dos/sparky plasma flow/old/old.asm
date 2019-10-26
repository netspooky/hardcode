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

	mov al,[es:di]
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