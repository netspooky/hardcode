;zmey
;128 byte intro
;for Outline 2013
;by fsqrt
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;09-05-2013

;It's six-hours-prod, ugly, very far from optimal, sorry.

org 100h
	mov al, 0x13
	les bp, [si]
	lds dx, [bx]
	int 0x10
	
	;sin+pal
	mov si, 256
S:	movsx ax, ch
	stosw
	add cx, si
	mov ax, 40
	imul cx
	sub si, dx
	
	mov dx, 0x3c9
	imul ax, bx, -1
	out dx, al
	shr al, 1
	out dx, al
	out dx, al
	
	dec bx
	jnz S

L0:	;_snake()
	;ax=tmp,bx=x,bp=y,dx=ang,di=time
	push si
	inc di
	inc di
	test di, 128+512
	jz E4
	jnp E3
	add dx, [es:di]
E3:	add dx, [es:di]
E4:	mov si, dx
	sar si, 5
	add si, si
	add bx, [es:si]
	add bp, [es:si+64]
	pusha
	sar bx, 6
	sar bp, 6
	imul di, bp, 320
E6:	mov [di+bx], byte 127
	inc di
	jp E6
	popa
	pop si
	mov ch, 80
L:	;_blur()
	imul si, 53
	lodsb
	sub al, 1
	jnc E5
E1:	lodsb
	add al, [si-3]
	add al, [si+318]
	add al, [si-322]
	shr al, 1
	and al, 63
	dec si
E5:	mov [si-1], al
E2:	loop L
	
	in al, 0x60
	dec ax
	jnz L0
	ret
	
	
	