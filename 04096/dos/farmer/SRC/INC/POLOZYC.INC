
polozyc:
	;---perspektywa polozenie :)
	mov ax,segment0
	mov es,ax
	mov di,10
	lea bp,LeftP
	mov ax,Segment1
	mov ds,ax
	mov cx,200
 perY:	push cx
	xor ax,ax
	xor si,si
	add si,cs:[bp]
	mov dx,cs:[bp][2]
	xor bx,bx
	mov cx,256
 perX:	mov bl,ds:[si][bx]
	mov es:[di],bl
	inc di
	add ax,dx
	mov bl,ah
	loop perX
	pop cx
	add bp,4
	add di,320-256
	loop perY
	ret


