;128b intro
;Svga 640x400x256!
;Try 640x480,800x600,1024x768,1280x1024 e.t.c. (only 256 colors !!!)
;     101h     103h    105h      107h
;Modify "!!!!!!" lines
;Compile on MASM 6.0
;Coded by Mr.Dsteuz/Proxium

.model tiny
.code
.386
.startup

	cli
	mov ax,4f02h  
	mov bx,100h   ;!!!!!!
	int 10h
	mov dx,3c8h
	xor cx,cx
	xor al,al
	out dx,al
	inc dx
l6:	out dx,al
	loop l6
	push 0a000h
	pop es
	xor si,si
	xor di,di
	mov cx,480    ;!!!!!!
l1:	mov bx,640    ;!!!!!!
l2:	mov ax,cx
	mul ax
	xchg ax,bp
	mov ax,bx
	sub ax,cx
	mul ax
	sub ax,bp
	mov al,ah
	shr ax,1
	stosb
	and di,di
	jnz l5
	push bx
	inc si
	mov dx,si
	xor bx,bx
	mov ax,4f05h
	int 10h
	pop bx
l5:	dec bx
	jnz l2
	loop l1
new:	mov dx,3dah
l4:	in al,dx
	test al,8
	jz l4
	inc ch
	mov dx,3c0h
	mov al,49
	out dx,al
	mov al,bl
	out dx,al
	mov dl,0c8h
	out dx,al
	inc dx
l3:	mov al,cl
	add al,cl
	out dx,al
	add al,cl
	out dx,al
	shr al,1
	out dx,al
	loop l3
	inc bl
	in al,60h
	dec al
	jnz new
	mov ax,3
	int 10h
	ret

	db "PrM!"
end