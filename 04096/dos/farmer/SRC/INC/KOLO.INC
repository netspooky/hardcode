
make_Bump:
	push cs
	pop es
	lea di,kolo
	mov cx,128
 KoloY:	mov _y,cx
	mov dx,128
 KoloX:	mov _x,dx
	fild [_x]
	fimul [_x] ;st(0)=x^2
	fild [_y]
	fimul [_y] ;st(0)=x^2
	fadd st(0),st(1)
	fsqrt
	fistp wyn 
	fstp st
	mov ax,wyn
	cmp ax,128
	jl bzz
	mov al,0
	jmp bze	
 bzz:	sar ax,1
	neg al
	and al,63
 bze:	mov es:[di],al
	inc di
	dec dx
	jnz KoloX
	dec cx
	jnz KoloY
	mov [kolo+128*128-1],63
	ret









