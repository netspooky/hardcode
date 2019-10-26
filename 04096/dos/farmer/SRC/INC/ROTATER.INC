
SegAdd	dw 0
Pik	dw 0








rotater:
	mov pik,0
	mov ax,Segment1
	mov es,ax
	xor di,di
	cmp SegAdd,1
	jne dddw
	mov pik,1
dddw:

	mov bx,kat
	and bx,1023
	shl bx,1
	mov ax,[cos][bx]
shl ax,1
	mov _cos,ax
	shr bx,1
	sub bx,256
	and bx,1023
	shl bx,1
	mov si,[cos][bx]
	mov _sin,si

	mov bx,_cos
	shl bx,7
	sub si,bx
	mov bx,_sin
	shl bx,7
	add si,bx
	sub ax,bx
	mov bx,_cos
	shl bx,7
	sub ax,bx
	
	sub ax,8000h
	sub si,8000h

	mov cx,256
 rot2:
	sub si,_sin
	add ax,_cos
	push si ax
	mov bp,128 ;256
 rot1:
	mov bx,si
	mov bl,ah
	mov dl,fs:[bx]

	add ax,_sin
	add si,_cos
	add ax,_sin
	add si,_cos
	cmp SegAdd,0
	jne ysss
;	sub dl,64
	jmp oddd
 ysss:
 	add dl,64
 oddd:
	mov bx,pik
	and bx,1
	mov es:[di+bx],dl
	inc di
	inc di
	dec bp
	jnz rot1

	pop ax si
	inc pik

	dec cx
	jnz rot2

	ret









rotater2:
	mov ax,Segment1
	mov es,ax
	xor di,di

	mov bx,kat
	and bx,1023
	shl bx,1
	mov ax,[cos][bx]
	shl ax,1
	mov _cos,ax
	shr bx,1
	sub bx,256
	and bx,1023
	shl bx,1
	mov si,[cos][bx]
	mov _sin,si

	mov bx,_cos
	shl bx,7
	sub si,bx
	mov bx,_sin
	shl bx,7
	add si,bx
	sub ax,bx
	mov bx,_cos
	shl bx,7
	sub ax,bx
	
	sub ax,8000h
	sub si,8000h

	mov cx,256
 rot211:
	sub si,_sin
	add ax,_cos
	push si ax
	mov bp,256
 rot111:
	mov bx,si
	mov bl,ah
	mov dl,fs:[bx]

	add ax,_sin
	add si,_cos

	mov es:[di],dl
	inc di
	dec bp
	jnz rot111

	pop ax si

	dec cx
	jnz rot211

	ret

