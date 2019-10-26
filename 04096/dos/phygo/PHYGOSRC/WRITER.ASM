writer:

	; ds=output

	push ds
	push es

	push es
	pop ds

	xor di,di
	mov si,nulltext
	.txtloc equ $-2

	mov ax,0x1130	; es:bp=romfont8x16
	mov bh,6	; ds=screenbuf
	int 0x10 	; es=romfont

;	cs movzx bx,byte[timer]
;	shl bl,3

.l2	cs lodsb
	cbw
	test al,al
	jz .o0
	jns .c0

	neg ax		; move cursor
	shl ax,4
	shl ah,4
	add di,ax
	jmp .l2

.c0	shl ax,4

	push si
	push di
	mov si,ax
	add si,bp
	xor dh,2

	mov dl,16

.l1	;add bl,19
;	push bx
;	shl bx,1
;	cs mov ax,[bx+sin_table]
;	sar ax,14
;	pop bx

	push di
;	add di,ax
	es lodsb

.l0	cbw
	and ah,0xbf	; cf blöh
	.txtcol equ $-1
	or [di],ah
	inc di
	or [di],ah
	inc di
	or [di],ah
	mov bl,ah
	and bl,0xaf
	mov bh,bl
	or [di+254],bx
	shl ax,1
	jne .l0

	pop di

	add di,257

	cmp dl,9	; 6: y:n ja g:n alasakarat mulahtavat
	jc .g0
		dec di
		dec di
.g0:	dec dl
	jne .l1

	pop di
	pop si
	add di,16
	jmp .l2

.o0	pop es
	pop ds
