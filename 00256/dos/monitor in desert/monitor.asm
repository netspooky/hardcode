
	org 100h

	mov ax, 0x4F02
	mov bx, 0x101
	int 0x10

	xor cx, cx				; gray palette
	mov dx, 969
P1:	out dx, al
	out dx, al
	out dx, al
	inc ax
	loop P1

	mov ax, 0x1130
	mov bh, 0x3
	int 0x10
	push es
	pop gs
	push 0xa000
	pop es

c3:	mov di, 0xFFFF				; offset in bank, -1 for first change to bank 0
	mov si, di				; bank No
c2:	mov bx, 480
c1:	mov cx, 640
c:	mov ax, 0x3f
	cwd
	push bx
	 sub bx, 240
	 or bl, 1
	 idiv bx
	pop bx
	and al, 0x3F
	xor al, 0x3F				; make 2 infinite plane (up, down)

	cmp bx, 60
	jb M
	cmp bx, 380
	jnb M
	cmp cx, 50
	jb M
	cmp cx, 500
	jnb M					; out screen area
	; ----------------------------------------------

	mov ax, bx
	shr ax, 3				; gradient border
	cmp bx, 80
	jb M
	cmp bx, 360
	jnb M
	cmp cx, 60
	jb M
	cmp cx, 490
	jnb M					; inner 1 area

		push si
		 mov si, bx
		 xor si, [cs:0x400]		; cross-bytes
		 xor si, cx			; switch
		 and si, 0x03C0 		; limits for bytes
		 push bx
		 push cx
		  shr bx, 2
		  and bx, 0x7
		  xor bl, 0x7
		  shr cx, 1
		  and cl, 0x7			; offsets
		  mov al, 1
		  shl al, cl
		  add bx, bp
		  test [gs:bx+si], al
		  mov al, 0			 ; no pixel
		  je L
		  mov al, 0x10			 ; yes pixel
L:		 pop cx
		 pop bx
		 mov si, 0x300
		 mov [si+6], ax 		 ; pixel font
		 mov ah, 0x03
		 mul cx 			 ; blik
		 push dx
		  mov ax, [si]
		  imul word [0x116]
		  shr ax, 1
		  add ax, [si+4]
		  dec word [si+4]
		  mov [si], ax			 ; monitor noise generator
		 pop dx
		 shr ax, 12
		 mov ah, [es:di]		 ; prev. image
		 add al, ah			 ; + prev. (blur)
		 add al, dl			 ; + blick
		 add al, [si+6] 		 ; + font
		 shr al, 1			 ; average [0...Target...1]
		pop si

M:	stosb
	and di, di
	jne d
	 push bx
	 mov ax, 0x4F05
	 xor bx, bx
	 inc si
	 mov dx, si
	 int 0x10
	 pop bx
d:	dec cx
	jne c
	dec bx
	jne c1
	inc word [cs:0x400]

sk:	mov dx, 0x3da				; syncronize
snc:	in ax, dx
	test al, 0x8
	jne snc

	in al, 0x60
	dec al
	jne c3					; exit, if ESC pressed
	ret