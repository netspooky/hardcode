
ileTlo dw 1500

Make_tlo:
	xor di,di
	mov cx,32000
	xor ax,ax
	rep stosw
	xor di,di
	XSize=26
	YSize=26
	xor bx,bx
	mov bp,ileTlo ;1500
 l3:	mov ax,0a000h
	Seed1=$-2
	mov bx,1
	Seed2=$-2
	add bx,ax
	mov w cs:[SEED1],bx
	mov w cs:[SEED2],ax
	xchg bl,ah
	xor di,di
	mov ch,Ysize
 l2:	mov cl,XSize
 l1:	add b es:[di][bx],2
	inc di
	dec cl
	jnz l1
	add edi,320-XSize
	dec ch
	jnz l2
	dec bp
	jnz l3
	ret	
