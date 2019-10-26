;vox128
;128 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;31-12-2011

;Pseudo-voxel landscape.
;NASM compatible.
;Happy new year!


org 100h
	mov al, 13h
	int 10h
	
	push 0a000h
	pop es
	push 09000h
	pop ds
	push 08000h
	pop fs


RND:	add ax, bx
	xor al, ah
	mov [bx], al
	inc bx
	jnz RND

	mov cl, 32
TEX:	mov dl, [bx]
	add ax, dx
	mov dl, [bx+1]
	add ax, dx
	mov dl, [bx+si]
	add ax, dx
	shr ax, 2
	mov [bx], al
	inc bx
	jnz TEX
	loop TEX

L0:	mov cl, 60
LP:	mov bx, 319
LX:	push bx
	
	xchg ax, bx
	sub ax, 160
	cwd
	shl ax, 7
	idiv cx
	sub ax, si
	mov bh, al
	
	mov ah, 07fh
	cwd
	div cx
	mov bl, al

	mov al, [bx+si]
	push ax
	mul cl
	shr ax, 7
	add ax, cx
	shr ax, 1
	imul di, ax, 320
	cmp ax, 225
	pop ax
	pop bx
	jge Z
	mov [fs:di+bx-320*25], al
Z:	dec bx
	jns LX
	inc cl
	jnz LP

COPY:	xor ax, ax
	xchg al, [fs:di]
	stosb
	loop COPY

	inc si
	in al, 60h
	dec ax
	jnz L0
	ret

