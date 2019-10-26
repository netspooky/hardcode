FT	equ 16				; granular
pFx	equ 32767			; maximum

	org 100h
	mov al, 0x13
	int 0x10

	mov dx, 968
	xchg ax, bx
	out dx, al
	inc dx
p1:	out dx, al
	out dx, al
	out dx, al
	inc ax
	loop p1

	; rnd. texture
	les si, [si+0x40]		; es = 0x8953 segment!
	push es
	pop ds				; ds = tex.buffer
TGen:	mul cx
	inc ax
	aad 63				; more random effect
	stosb
	loop TGen

	; line blur
	mov cl, 3			; 3 blur
TGen3:	push cx
	xor cx, cx
TGen2:	lodsb
	add al, [di]
	sar ax, 2			; ax = (p(x,y) + p(x+1,y)) / 4
	stosb
	loop TGen2
	pop cx
	loop TGen3

	push 0xa000
	pop es
	xchg ax, bp			; bp < 64
c3:	push bp 			; bp assumes random small number
	push bp

	mov bx, -100
	xor di, di
c2:	mov cx, -160
c1:	push si
	shr si, 4			; speed correct (4 - normal, 5 - slower by 2,
					; 6 - slower by 4, than 3 etc.
	push bx
	push bx

	mov ax, cx
	call xMUL
	xchg ax, dx			; ax = bx^2 + cx^2
	xchg ax, bx			; bx = bx^2 + cx^2, ax = y
	and bx, bx
	je csr				 ; it's center of screen? yes -> ct

	mov ax, pFx
	cwd
	idiv bx 			; mask pos
	add ax, si			; moving

csr:	pop bx
	mov dx, bp			; load previous value

	cmp cx, bx			; x > y?
	jnl NEXT1
	test al, FT
	jz NEXT1a			; if 0, nothing

	 mov dx, cx
	 sar dx, 2			; dx = x / 4 (left side)
	 jmp NEXT1

NEXT1a: push ax
	push bx
	 mov ax, cx
	 sal ax, 4			; OPTIONAL: disable SAL
	 cwd
	 or bl, 1			; protection from "divide by zero" error
	 idiv bx
	 push ax
	  mov ax, 1000			; OPTIONAL: 63=NORMAL
	  cwd
	  idiv bx			; OPTIONAL: div bx (up plane moving back)
	 pop dx
	 xchg ax, bx			; BL = y (parallax)
	 mov bh, dl			; BH = x (parallax)
	 add dl, [bx+si]		; br.para.Y - texture [at si]
	pop bx
	pop ax				; line of horizon

NEXT1:	neg bx
	cmp cx, bx
	jl NEXT2			; condition not allowed

	test al, FT
	jnz NEXT2			; if 1, skip

	mov dx, cx
	sar dx, 1			; dx = x / 2 (right side)

NEXT2:	pop bx
	test dh, 0x80
	jz NZero
	neg dx				; if dx < 0, dx = -dx
NZero:	mov bp, dx			; save new pixel

	; --- spark --------
	mov ax, cx
	sub ax, -43			; x position of sun
	call xMUL			; dx = (x - x0)^2 + y^2
	cmp dx, 2024
	mov al, 0			; out of circle
	jnb px

	  shr dx, 5
	  mov al, dl			; calculation brightness
	  xor al, 0x3f			; revert

px:	test si, 128 shr 3
	jnz px3
	shr al, 1			; bright down
px3:	add ax, bp			; prev. + additive blending
	cmp al, 0x40
	jb px2				; pixel < 0x40?
	mov al, 0x3f			; els pixel = 0x3f
px2:	stosb
	pop si

	inc cx
	cmp cx, 160
	jne c1
	inc bx
	cmp bx, 100
	jne c2

	pop bp				; si = speed
	shr bp, 4
	add si, bp
	pop bp

	in al, 0x60			; get key state
	cmp al, 0x2A			; left shift = +1 speed
	jne keya
	inc bp
keya:	cmp al, 0x36			; right shift = -1 speed
	jne keyb
	dec bp
keyb:	dec al
	jne c3
	ret

	; standart circle equation
xMUL:	imul ax
	push ax
	 mov ax, bx
	 imul ax
	pop dx
	add dx, ax			; (x)^2 + (y)^2
	ret