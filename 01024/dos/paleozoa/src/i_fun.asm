;Height functions
;Take bx -> x, cx -> y, si -> t
;Return h[0..256] -> bx, col[0..256] -> al

F_WATER:
	push bx
	mov al, [bx+si]
	mov bx, cx
	add al, [bx+si]
	mov bl, al
	movsx ax, [bx+si]
	sar ax, 1
	pop bx
	push ax
	
	shr bx, 2
	add bx, si
	shr cx, 2
	add cx, si
	mov bh, cl
	movzx bx, [gs:bx]
	sub bx, 64

	pop ax
	add bx, bx
	add bx, ax
	sar bx, 2
	lea ax, [bx+127]	;bl + 127 -> al
	ret


F_SKY:
	shr bx, 2
	shr cx, 2
	add cx, si
	mov bh, cl
	movsx bx, [gs:bx+si]
	shl bx, 3
	movsx ax, byte [bx+si]
	sar ax, 3
	mov bx, ax
	sar bx, 1
	add al, 128+8
	ret


F_ISLAND:
	push bx
	add bx, si
	mov dx, bx
	sar bx, 1
	mov al, [bx]
	mov bx, cx
	add bx, si
	xor dx, bx
	sar bx, 1
	add al, [bx]
	sar al, 1
	pop bx
	add cx, si
	mov bh, cl
	add al, [gs:bx+si]
	movzx bx, al
	shr bx, 1
	sub bx, 20

	push bp
	mov bp, si
	shr bp, 4
	neg bp
	add bp, 80
	cmp bx, bp
	jg F_ISLAND_Z
	sar bx, 2
	mov al, 150
	add al, bl
	mov bx, bp
	jmp F_ISLAND_EXIT
F_ISLAND_Z:
	shr al, 2
F_ISLAND_EXIT:
	lea bp, [si-1024]
	sar bp, 3
	cmp bx, bp
	jg F_ISLAND_NG
	and dx, 7
	add al, 64+14
	add bx, dx
F_ISLAND_NG:
	pop bp
	ret


F_STARFLD:
	pusha
	mov bx, 200
	F_SF:
	movsx di, [bx]
	imul di, si
	sar di, 5
	add di, [cs:F_WATER+bx]
	lea ax, [si+bx]
	mov [fs:di], al
	dec bx
	jnz F_SF
	popa
	ret


F_PLANET:
	pusha
	call F_STARFLD
	mov cx, 256
F_PLANET_L:
	xor dx, dx
F_PLANET_L2:
	mov bx, dx
	add bx, si
	mov bh, cl
	mov al, [gs:bx]
	push ax
	mov bx, dx
	movsx bx, [bx+64]
	mov di, cx
	shr di, 1
	movsx ax, [di]
	imul ax, bx
	sar ax, 7
	movsx bx, [di+64]
	sar bx, 1
	imul bx, 320
	add bx, ax
	pop ax
PL_COL:	add al, 63-12
	push si
	neg si
	sar si, 3
	mov [fs:bx+320*100+280+si], al
	pop si
	inc dl
	jnz F_PLANET_L2	
	loop F_PLANET_L
	popa 
	ret


F_SUN:
	pusha
	mov bx, 130
F_SUN_L1:
	imul bp, bx, 32
	movsx cx, [ds:bp+si]
	movsx bp, [si]
	add cx, bp
	sar cx, 3
	add cx, 80
F_SUN_L2:
	push cx
	mov al, [bx+185]
	imul cl
	shr ax, 6
	imul di, ax, 320
	
	movsx dx, [bx+185+64]
	pop cx
	imul dx, cx
	sar dx, 6
	add di, dx
	mov al, [si]
	add al, 60
	imul cl
	add ah, 192
	mov al, ah
	mov [fs:di+320*99], ax
	mov [fs:di+320*100], ax
	loop F_SUN_L2
	dec bx
	jnz F_SUN_L1
	popa 
	ret

F_BUSH:
	sar cx, 1
	sar bx, 1
	mov bh, cl
	mov al, [gs:bx+si]
	movzx bx, al
	shr bx, 1
	shr al, 2
	add al, 64
	ret

F_FISH:
	pusha
	xor bx, bx
F_F04:	mov al, bh
	shr al, 2
	add al, 128
	mov [fs:bx], al
	inc bx
	jnz F_F04

	mov bx, 10
F_F02:	push bx
	movsx bp, [bx]
	sar bp, 2
	imul bp, si
	sar bp, 3
	add bp, [cs:F_STARFLD+bx]
	movsx ax, [ds:bp+si]
	sar ax, 2
	imul ax, 320
	add bp, ax
	mov bx, 150
F_F01:	mov al, bl
	push bx
	movsx dx, [bx]
	sub bx, bp
	add bx, 320*100+160
	mov cl, 30
F_F03:	mov di, dx
	imul di, cx
	sar di, 7
	imul di, 320
	push cx
	or cl, al
	shr cl, 1
	mov [fs:di+bx], cl
	neg di
	mov [fs:di+bx], cl
	pop cx
	loop F_F03

	pop bx
	dec bx
	jns F_F01
	pop bx
	dec bx
	jnz F_F02
	popa
	ret




