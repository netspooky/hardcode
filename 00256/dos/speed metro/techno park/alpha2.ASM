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
	loop P1 			 ; standart gray palette, haha

	push 0x8000
	pop es				 ; texture buffer
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

	; plane render
	mov bp, 1024			; initialize COS0 = 1024
					; for sinus generator
render:
	xor di, di
	mov bl, 100
c6:	mov cx, 320
c5:	mov ax, cx
	push bp
	 sar bp, 3
	 sub ax, bp
	pop bp
	cwde
	imul eax
	push eax
	 mov ax, bx
	 push si
	  sar si, 5
	  add si, 80
	  sub ax, si
	 pop si
	 cwde
	 imul eax
	pop edx
	add edx, eax			  ; r^2 = (x-x0)^2 + (y-y0)^2
	cmp edx, 3000
	mov al, 0
	jnb px3
	 shr dx, 5
	 xchg ax, dx
	 add al, 0x20
	 test al, 0x40
	 jne px4
	 mov al, 0
px4:	 xor al, 0x3F
px3:	stosb
	loop c5
	dec bx
	jne c6

	; low plane
	mov bl, 4
c4:	mov cx, -160
c3:	mov al, 63
	cbw
	idiv bl 			 ; 63 - 63/y
	xor al, 0x3F			 ; white facet color
	push bx
	push ax
	 mov ax, cx
	 shl ax, 7
	 cwd
	 idiv bx			 ; x/y
	 push ax
	  mov ax, 16000
	  cwd
	  idiv bx
	  add ax, bp			 ; 16000/y + bp
	  mov bl, al			 ; y texture (plane)
	 pop dx
	 add dx, si
	 mov bh, dl			 ; x texture (plane)
	 shr dx, 2
	 shr ax, 2
	 xor ax, dx
	 and al, 64;+8                    ; 1? this is black facet
	pop ax				 ; pop color white facet
	je px2
	xor ax, ax			 ; no color (black facet)
px2:	add al, [fs:bx] 		 ; + texture
	pop bx
	shr al, 1
	stosb
	inc cx
	cmp cx, 160
	jne c3
	inc bl
	cmp bl, 100
	jne c4

	; sinus generator (14 bytes)
	mov ax, bp
	sar ax, 7
	sub si, ax			; cosx[si] -= k*sinx[bp,bx]
	mov ax, si
	sar ax, 7
	add bp, ax			; sinx[bp] += k*cosx[si,bx]

	mov dx, 0x3da
f:	in al, dx
	test al, 8
	jne f

	in al, 0x60
	dec al
	jne render
	ret