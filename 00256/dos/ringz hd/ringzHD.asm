org 100h
push 0xa000
pop es
mov ax,0x4F02
mov bx,0x103
int 0x10


X
mov dx,599
T:
mov cx,799
L:
xor bx,bx
push dx
	mov ax,800
	mul dx
	add ax,cx
	adc dx,bx
	push ax
		mov ax,cx
		cmp dx,si
		je bss
			mov si,dx
			mov ax,0x4F05
			int 0x10
		bss:
	; pop bx
	pop di
pop dx

push cx
push dx
	sub dx,300
	jnz G
	inc dx
	G:
	
	sub cx,400
	; add cx,bp
	pusha
		fild 	word	[bx-12]		; x
		fild 	word	[bx-10]		; y x
		fmul	dword	[val5]		; y' x
		fpatan						; arc
		fst 	st1					; arc arc
		fsin						; cos(arc) arc
		fimul	word	[val2]		; l*cos(arc) arc
		fidiv	word	[bx-12]		; l*cos(arc)/x arc
		fld		dword	[val4]		; s l*cos(arc)/x arc
		fimul	word	[bx-18]		; ss l*cos(arc)/x arc
		faddp	st1,	st0			; ss+l*cos(arc)/x arc
		fistp	dword	[bx-10]		; arc		-> DX
		fmul 	dword 	[val3]		; scarc
		fist	dword	[bx-14]		; scarc 	-> BX
		fld		dword	[val4]		; s scarc
		fimul	word	[bx-18]		; ss scarc
		faddp	st1,	st0			; ss+scarc
		fistp	word	[bx-8]		; -			-> AX
	popa

	add ax,cx
	mov dx,ax
	
	test cl,16
	jnz H
	backH:
	mov ax,bx
	and al,31
	test al,16
	jnz K
	xor al,31
	K:
	jmp short F
	H:
	
	test cl,12
	jz backH
	
	shr ax,2
	cwd
	mov bx,24
	div bx
	; xor bx,bx
	xchg dx,ax

	xchg cx,ax
	shr ax,2
	aam 4
	; cmp al,3
	; jnz FF
	; mov al,2
	; FF:
	imul ax,byte 72

	add al,cl
	add al,32-72;+144

	F:
	stosb

pop dx
pop cx

sub cx,3
jz FFFF
jnc L
add cx,799
jmp L
FFFF:

; dec cx
; jnz L

; dec dx
; jnz T

sub dx,3
jz FFFFFFFF
jnc T
add dx,599
jmp T

FFFFFFFF:

inc bp
in al,0x60
dec al
jnz X
mov ax,3
int 0x10
ret
;val: dw 151
val2: dw 10000		; fish eye
val3: dd 0x42749603 ; pi/2 * 24*4
val4: dd 0x3e800000	; 0.25  smooth
val5: dd 0x3fa8f5c3 ; 1.32  aspect ratio
;val5: dd 0x3f800000 ; 1.00  aspect ratio


