;walk
;128 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;15-12-2011

;Dynamically distorted Sierpinski pyramids in pseudo-voxels.
;NASM compatible.
;Enjoy!


org 100h
	mov al, 13h
	int 10h
	
	push 0a000h
	pop es			;Screen area.
	push 09000h
	pop ds			;Sin lookup table.
	push 08000h
	pop fs			;Buffer.

SINPAL:	mov [bx], ch		;Make sine table
	shrd ax, bx, 18		;and black-red-white palette.
	out dx, al
	mul bl
	mov al, ah
	out dx, al
	out dx, al
	add cx, si
	mov ax, 40
	imul cx
	sub si, dx
	mov dx, 3c9h
	dec bx
	jnz SINPAL

L0:	xor dx, dx
LP:	mov bx, 319
LX:	push bx
	mov ax, dx
	add al, al
	add bx, si
	add al, [bx+si]		;Plasma-like movement.
	mov bp, ax
	add bl, [ds:bp+si]
	pop bp

	xor al, bl		;al is the height and color.
	add al, 128
	movzx bx, al

	imul bx, dx		;Scale height to distance.
	movzx bx, bh
	add bx, dx
	cmp bx, 200		;Cut points with "y" > 199.
	jge Z
	imul di, bx, 320
	mov cl, 5
R:	mov [fs:di+bp], al	;Put point to the buffer
	add di, 320		;In fact we need several
	loop R			;ponins to make solid bodies.
Z:	mov bx, bp
	dec bx
	jns LX
	inc dl
	jnz LP

COPY:	xor ax, ax		;Clear and copy buffer.
	xchg al, [fs:di]
	stosb
	loop COPY

	dec si
	in al, 60h
	dec ax
	jnz L0
	ret




