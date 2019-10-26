; nasm -f bin -o kanditro.com kanditro.asm
; basecode by las
; intro by cce
;
; paljon onnea atomille

org 100h
temp equ 0x7E00 
section .text
_start:
	mov ax, 0x13 ; is mov al, 0x13 a better idea here?
	int 0x10

	; http://webpages.charter.net/danrollins/techhelp/0166.HTM
	;mov ax, 0x1130
	;mov bl, 0x00
	;mov bh, 0x03 ; get addr of ROM 8x8 font
	;int 0x10
	;; cx = height (scan-lines) / bytes per char (from 0040:0085)
	;; DL    screen rows (from 0040:0084)
    ;; ES:BP address of requested font-definition table
	;mov cx, 100

	mov dx, msg
	mov ah, 9 ; print string
	int 0x21


	xor di, di
	mov cx, 320*64
_copyloop:
	push word temp
	push 0xa000
	pop es
	mov ax, [es:di]
	pop es
	stosb ; store ax to es:di
	loop _copyloop	

	push word 0xa000 
	pop es

; debug pixel
xor di, di
mov byte [es:di], 2


_mainloop:
	xor di, di
	mov	cx, 320*200
_drawloop:
	;mov [esp], cx
	xor dx, dx ; we divide DX:AX by BX, make sure DX has no garbage
	mov ax, di
	mov bx, 320
	div bx
	; ax = y
	; dx = x

	mov [ypos], ax
	mov [xpos], dx

	;finit

	fild word [xpos]

	fild word [xpos]
	;fidiv word [divisor]
	;fild word [frame]
	;faddp st1, st0
	;fcos
	;faddp st1, st0
	fidiv word [size]

	fist word [xpos]
	mov dx, [xpos]

	fild word [xpos]
	mov [xpos], ax
	fidiv word [divisor]
	fild word [frame]
	faddp st1, st0
	fsin
	fild word [xpos]

	;fild word [frame]
	;fsin
	;fld1
	;faddp st1, st0
	;fdiv st1
	;fidiv word [size]
	fild word [frame]
	fidiv word [divisor]
	fcos
	fldpi
	faddp st1, st0
	fdiv

	faddp st1, st0
	fist word [xpos]
	mov ax, [xpos]

	push es
	push temp
	pop es
	push di
	push dx
	sub ax, 15
	mov bx, 320
	mul bx 
	pop dx

	add ax, dx
	mov di, ax ; final pixel offset

	mov ax, [es:di]
	shr ax, 11
	;add ax, 32
	mov bx, [xpos]
	inc bx
	;and bx, 0x0F
	add bx, 32
	mul bx
	;shl bx, 1
	;add ax, bx
	;add bx, 0

	pop di
	pop es

	stosb 

loop _drawloop
	mov ax, [frame]
	inc ax
	mov [frame], ax

	xor ax, ax ; maybe this can be removed later - given ah could be zeroed by accident somewhere else
	; ESC check
	in al, 0x60
	dec ax 
	jnz _mainloop


	mov al, 0x3 ; ah is 0 already due to mainloop exit condition
	int 0x10
ret

    msg  db '   MATERIAALIPISTE-',13,10,'      MENETELM',0x8E,13,10,'      2014-2015', '$'   
	xpos dw 0
	ypos dw 0
	divisor dw 8
	size dw 2
	frame dw 0
