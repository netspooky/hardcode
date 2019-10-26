	org 100h
	; assume: CX = 0x00FF

	xor ebp, ebp
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

	; setup segments
	push 0xa000
	pop es
	push cs
	pop ds
	mov bx, ds
	mov word [bx], 320

	; low plane
render: xor di, di
	mov bx, -100
c4:	mov cx, -160
c3:	mov al, 63
	cmp bx, 1
	jl px3					; no calculation plane

	cbw
	idiv bl 				; 63 - 63/y
	xor al, 0x3F
	push ax
	 mov ax, cx
	 shl ax, 4
	 cwd
	 idiv bx				; x/y
	 sub ax, bp
	 shr ax, 1
	 push ax
	  mov ax, 5000
	  cwd
	  idiv bx
	  add ax, bp				; 128/y + bp
	 pop dx
	 shr ax, 2
	 xor ax, dx
	 and al, 8				; 1? this not plane
	pop ax					; pop color (white facet)
	je px2
px3:	xor ax, ax				; no color (black facet)
px2:	push bp
	push di
	push ax

	 mov di, ds				; random position, not actually
	 mov ax, 80
	 mov si, [di]
	 sal si, 1
	 mov bp, 7000
	 call cbr				; glare 2
	 push ax

	  mov ax, 40
	  mov si, [di]
	  mov bp, 3000
	  call cbr				; glare 1

	  push ax
	   mov ax, -60
	   mov si, [di]
	   neg si
	   mov bp, 8000
	   call cbr2
	  pop dx
	  add al, dl			       ; g1 + sun
	 pop dx
	 add al, dl			       ; +g2
	pop dx
	add al, dl			       ; +prev.img
	pop di
	pop bp
	cmp al, 0x40
	jb px4
	mov al, 0x3f
px4:
	stosb
	inc cx
	cmp cx, 160
	jne c3
	inc bx
	cmp bx, 100
	jne c4
	inc bp

	push bx
	 mov bx, ds
	 mov ax, [bx]
	 cmp ax, -320
	 jnl nl1
	 mov ax, 320
nl1:	 dec ax
	 mov [bx], ax			  ; x position sun
	pop bx

	in al, 0x60
	dec al
	jne render
	ret

; ----------------------------------------------------------------
; calculation brightness [blicks]

cbr:	call subpx
	jb pxl
	shr ax, 8
pxl:	ret

; ---------- sun ---------------
cbr2:	call subpx
	jb pxl				; out of center
	shr ax, 7			; smooth
	xor al, 0x3F			; revert
	add al, 0x8			; sun center
	ret

; ------
subpx:	sub ax, bx
	cwde
	imul eax			 ;  (x - x0)^2
	push eax
	 sub si, cx
	 xchg ax, si
	 cwde
	 imul eax
	pop edx
	add eax, edx			  ; (y-y0)^2 + (x-x0)^2
	cmp ebp, eax
	mov al, 0
	ret