	org 100h
	; assume: CX = 0x00FF

	mov al, 0x13
	int 0x10

	mov dx, 968
	xor ax, ax
	out dx, al
	inc dx
P1:	out dx, al
	out dx, al
	out dx, al
	inc ax
	loop P1 				 ; standart gray palette, haha

	push 0x8000
	pop es				       ; texture buffer
	xor cx, cx
TGen:	mul cx
	inc ax
	aad 129
	and al, 0x3F
	stosb
	loop TGen

	; blur
	mov cl, 4
TGen3:	push cx
	xor cx, cx
TGen2:	mov al, [es:di-1]
	add al, [es:di+1]
	add al, [es:di+320]
	add al, [es:di-320]
	shr ax, 2
	stosb
	loop TGen2
	pop cx
	loop TGen3

	; setup segments
	push es
	pop fs
	push 0xa000
	pop es
	push es
	pop ds

	; low plane
render: mov di, 320*100
	mov si, 99*320 - 320			; middle screen line position
	mov bl, 1
c4:	mov cx, -160
c3:	mov al, 63
	cbw
	idiv bl 				; 63 - 63/y
	xor al, 0x3F
	push ax
	 mov ax, cx
	 shl ax, 4
	 cwd
	 idiv bx			 ; x/y
	 shr ax, 1
	 push ax
	  mov ax, 5000
	  cwd
	  idiv bx
	  add ax, bp			 ; 128/y + bp
	 pop dx
	 shr ax, 2
	 xor ax, dx
	 and al, 8			 ; 1? this not plane
	pop ax				 ; pop color (white facet)
	je px2
	xor ax, ax			 ; no color (black facet)

px2:	xchg ax, dx			 ; save AL in DL
	lodsb
	mov al, dl
	;add al, dl
	add al, [fs:di]
	shr al, 1
	stosb
	inc cx
	cmp cx, 160
	jne c3

	sub si, 640
	inc bl
	cmp bl, 100
	jne c4

	inc bp
	in al, 0x60
	dec al
	jne render
	ret