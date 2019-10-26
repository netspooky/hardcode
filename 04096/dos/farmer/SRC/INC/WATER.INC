



CalculateWater:
	mov ax,Segment2
	mov es,ax

	inc nPage
	mov ax,nPage
	and ax,1
	or ax,ax
	jz chess1
	mov di,32768
	xor si,si
	jmp Chess2
chess1:
	xor di,di
	mov si,32768
chess2:
	add si,129*2
	add di,129*2

	mov bp,126	;yCount
loop1:
	mov cx,126	;xCount
loop2:
	mov ax,es:[di+128*2]
	add ax,es:[di-128*2]
	add ax,es:[di+1*2]
	add ax,es:[di-1*2]
	sar ax,1
	sub ax,es:[si]
	mov dx,ax
	sar dx,4+1
	sub ax,dx
	mov es:[si],ax
	add si,2
	add di,2
	dec cx
	jnz loop2
	add si,4
	add di,4
	dec bp
	jnz loop1

	ret

	nPage	dw 1

DrawWater:
	mov ax,Segment2
	mov ds,ax

	xor bx,bx
	lea bp,obrazek
	mov ax,Segment1
	mov es,ax
	xor di,di
	test nPage,1
	jz vamp1
	mov si,32768
	jmp draf
vamp1:	xor si,si
draf:
	mov cx,128
	mov WaterY,0
loop00:
	push cx
	mov cx,128
	mov WaterX,0
loop11:
	push cx

	mov ax,ds:[si]
	mov dx,ax
	sub ax,ds:[si+128*2]
	sub dx,ds:[si+2]

	mov bx,ax
	mov cx,ax
	mov ax,128
	sub ax,cx
	mov innerWater,al
	sar bx,3
	sar dx,3
	add bx,WaterY
	add dx,WaterX
	mov ax,bx
	shl ax,7
	add ax,dx
	mov bx,ax
	mov al,obrazek[bx]

	mov ah,innerWater
	mul ah
	cmp ah,64
	jb rys
	mov ah,63
 rys:
	add ah,64*3
	mov es:[di],ah

	inc di
	add si,2
	inc WaterX

	pop cx
	dec cx
	jnz loop11

	inc WaterY

	pop cx
	dec cx
	jnz loop00

	ret

innerWater db 0




