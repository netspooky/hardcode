
kuraZ:
	mov _cos,0
	mov ax,Segment1
	mov es,ax
	xor di,di
	add kat,4
	mov bx,kat
	and bx,1023
	shl bx,1
	mov ax,[cos][bx]
	shl ax,1
	mov si,ax
	mov _sin,si
	mov bx,_sin
	shl bx,7
	add si,bx
	sub ax,bx
	mov bx,_sin
	shl bx,7
	sub ax,bx
	mov cx,200
 roq2:	sub si,_sin
	add ax,_cos
	push si ax
	mov bp,256
 roq1:	mov bx,si
	mov bl,ah
	mov dl,fs:[bx]
	add ax,_sin
	add si,_cos
	mov es:[di],dl
	inc di
	dec bp
	jnz roq1
	pop ax si
;	add di,320-256
	dec cx
	jnz roq2
	ret



