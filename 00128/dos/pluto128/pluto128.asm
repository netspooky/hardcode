;pluto128
;by Rudi
org 100h
	mov al, 13h
	int 10h
	mov ah, 80h
	mov es, ax
	mov ds, ax
	xor cx, cx
L:	add al, ch
	stosb
	loop L
	inc cx
	rol ecx, 19
B:	lodsw
	dec si
	add ax, [si+0ffh]
	add al, ah
	shr al, 2
	inc ax
	stosb
	dec ecx
	jnz B
	aaa
	mov fs, ax
	push 0a000h
	pop es
DRAW:	dec bh
	mov si, 319
XLOOP:	xor sp, sp
	mov bp, 200
TLOOP:	push si
	sub si, sp
	imul si, sp
	shr si, 8
	mov ax, sp
	sub al, bh
	shl ax, 8
	add si, ax
	lodsb	
	pop si
	xor ah, ah
	mov bl, al
	shl ax, 6
	inc sp
	cwd
	div sp
	cmp ax, bp
	jae Y_LD
	mov cx, bp
	sub cx, ax
DR_V:	push bp
	sub bp, cx
	imul bp, 320
	mov [fs:bp+si], bl
	pop bp
	loop DR_V
	xchg bp, ax
Y_LD:	cmp sp, 127
	jnz TLOOP
	dec si
	jnz XLOOP
CP:	xor al, al
	xchg al, [fs:di]
	stosb
	loop CP
jmp DRAW