;cord
;128 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;09-03-2012

;Code is pretty ugly,
;read it at your own risk!
;Due to addressing abuse don't work under WinXP,
;check cord_compat.com


org 100h
	mov al, 13h
	les di, [bx]
	int 10h
	lfs di, [si+5]
	lds di, [si]

SINPAL:	mov [bx], ch
	shrd ax, bx, 18
	out dx, al
	out dx, al
	out dx, al
	add cx, si
	mov ax, 40
	imul cx
	sub si, dx
	mov dx, 3c9h
	dec bx
	jnz SINPAL


L:	mov di, 320
LX:	mov bh, 1
LY:	mov al, [5*ebx]
	add al, [edi+esi]
	sar al, 2
	add al, 24
	mov dx, ax
	push di
	sub di, si
	imul byte [bx+di]
	xchg ax, dx
	imul byte [bx+di+64]
	pop di
	sar ax, 6
	sar dx, 6
	imul bp, si, 4
	movsx bp, [ds:bp+di]
	add ax, bp
	sar bp, 2
	add dx, bp
	imul bp, dx, 320
	add al, 80
	cmp [fs:bp+di], al
	ja A
	mov [fs:bp+di], al
	mov [fs:bp+di+320], al
A:	dec bx
	jnz LY
	dec di
	jnz LX

COPY:	xor ax, ax
	xchg al, [fs:di-320*100-15]
	stosb
	loop COPY

	dec si
	in al, 60h
	dec ax
	jnz L
	ret



