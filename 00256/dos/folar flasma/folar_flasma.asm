SCREEN_VRAM EQU 0A000h

org 100h
	mov al,13h
	int 10h

; ----------- Palgen ---------------


	MOV	BH,16
	MOV	BL,BH
	
	MOV	DX,3C8h
	OUT	DX,AL
	INC	DX


loop0:

;        XOR     AL,AL
;        OUT     DX,AL

	MOV	AL,16
	SUB	AL,BH
	SHL	AL,2
;        ADD     AL,31
	OUT	DX,AL
		OUT	DX,AL
	MOV	AL,16
	SUB	AL,BL
	SHL	AL,1
	ADD	AL,31
	OUT	DX,AL

	DEC	BL
	JNZ	loop0

	MOV	BL,16
	DEC	BH
	JNZ	loop0

	mov si,variables
main:
	push word SCREEN_VRAM
	pop es

	xor di,di
	mov dx,200
yloop:
	mov cx,320
xloop:
	fild word [si+20]
	fidiv word [si+18]
	fsin
	fld st0
	fimul word [si]
	fidiv word [si+16]

	push dx
	fild word [esp] ; y
	fisub word [si+8]	; center y
	fadd st0,st1
	fld st0 	; y, y
	fmul st0,st0	; y^2, y
	pop dx

	push cx
	fild word [esp] ; x , y^2, y
	fisub word [si+6]	; center x
;        fadd st0,st2
	fxch st1	 ; y^2, x, y
	fld st1 	; x, y^2, x, y
	fmul st0,st0	; x^2, y^2, x, y
	pop cx

	faddp st1,st0	; x^2 + y^2, x, y
	fsqrt		; sqrt(x^2 + y^2), x, y

	fistp word [si] ; x, y

	fpatan			; atan(y/x)
	fimul word [si+10]	; leafs * atan(y/x)
	fld st0 		; leafs * atan(y/x), leafs * atan(y/x)
	fadd st0,st2
	fsin			; sin(leafs * atan(y/x)), leafs * atan(y/x)
	fimul word [si+12]	; modulate * sin(leafs * atan(y/x)), leafs * atan(y/x)
	fistp word [si+2]	; leafs * atan(y/x)

	fimul word [si+16]
	fsin			; sin(leafs * atan(y/x))
	fimul word [si+14]	; modulate * sin(leafs * atan(y/x))
	fistp word [si+4]

;        finit
	fistp word [si+64]	; just pop
	fistp word [si+64]	; just pop

	mov ax,[si]
	add ax,[si+2]
	add ax,[si+4]
	cmp al,63
	jc test123
	mov al,0
test123:
	and al,15
	shl al,4

	mov bx,[si+2]
	and bl,15
	shr bl,2
	or al,bl

	mov [es:di],al
	inc di

	dec cx
	jnz xloop

	dec dx
	jnz yloop

	inc word [si+20]

;6,8,10,12,14,16
	mov al,[si+21]
	cmp al,5
	jnz nof1
	mov byte [si+10],3
	mov byte [si+12],16
	mov byte [si+14],24
nof1:
	cmp al,10
	jnz nof2
	mov byte [si+16],8
nof2:

	MOV DX,3DAh
Vsync1:
	IN	AL,DX
	AND	AL,8
	JZ	Vsync1

	in al,60h
	dec al
	jnz main

	mov ax,03h
	int 10h
ret

variables:
dw 0, 0, 0	; result1, result2, result3
dw 160,100	; centerX, centerY
dw 7		; leafs

dw 24, 6	; sinemul1, sinemul2
dw 3, 150	  ; inermul, timediv
dw 0		; timer


