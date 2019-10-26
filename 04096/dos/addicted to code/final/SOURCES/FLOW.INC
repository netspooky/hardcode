

FlowPos		dw 0
FlowFrame	dw 0

fla		equ (offset Flshr1)+2
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;
Flow2:
	mov	bx,fla
	mov	byte ptr [bx],2
	mov	byte ptr [bx+o Flshr2+2-fla],2
	mov	byte ptr [bx+o Flsub1+2-fla],32
	mov	byte ptr [bx+o Flsub2+2-fla],32
	mov	byte ptr [bx+o Flneg1+2-fla],0
	mov	byte ptr [bx+o Fladd1+1-fla],13
	mov	byte ptr [bx+o Fladd2+1-fla],13
	mov	byte ptr [bx+o Fladd3+1-fla],13
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;
Flow:

	mov	edi,ds:[TabPtr]
	lea	esi,[edi+Patterns+Pattern1]
	lea	ebx,[edi+Textures+Texture5]
	shr	ebx,1
	add	edi,FlowBuffer

	mov	ax,ds:[FrameCount]
	mov	cx,ds:[FlowFrame]
	sub	cx,ax
	neg	cx
	cmp	cx,5
	jle	NoFlow
	mov	ds:[FlowFrame],ax	


	mov	ecx,edi
	mov	bp,[FlowPos]
flow1Loop:
	mov	si,di
	add	si,bp
;	lea	si,[di+bp]
	mov	ch,[esi]
	mov	si,di
	sub	si,bp
	mov	cl,[esi]

Flshr1:	shr	ch,3
	mov	bx,bp
Flshr2:	shr	cl,3
	xor	bh,bh
Flsub1:	sub	cl,16
	sub	bh,bl
Flsub2:	sub	ch,16
	add	bx,di
	add	cx,di
;---------------------------------;
	mov	dx,[ebx+ebx]
Flneg1:	xor	dx,-1

	mov	al,[ecx]
	mov	bx,dx
	shr	bx,10
	xor	ah,ah
	and	bx,31
Fladd1:	sub	ax,18
	add	ax,bx
	jge	@no1a
	xor	ax,ax
@no1a:
	or  	ah,ah
	jz  	@no2a
	mov  	al,255
@no2a:
	add	al,[edi]
	rcr	al,1
	mov	[edi],al
;---------------------------------;
	mov	al,[ecx+10000h]
	mov	bx,dx
	shr	bx,5
	xor	ah,ah
	and	bx,31
Fladd2:	sub	ax,18
	add	ax,bx
	jge	@no1b
	xor	ax,ax
@no1b:
	or	ah,ah
	jz  	@no2b
	mov  	al,255
@no2b:
	add	al,[edi+10000h]
	rcr	al,1
	mov	[edi+10000h],al
;---------------------------------;
	mov	al,[ecx+20000h]
	mov	bx,dx
	xor	ah,ah
	and	bx,31
Fladd3:	sub	ax,18
	add	ax,bx
	jge	@no1c
	xor	ax,ax
@no1c:
	or	ah,ah
	jz  	@no2c
	mov  	al,255
@no2c:
	add	al,[edi+20000h]
	rcr	al,1
	mov	[edi+20000h],al
flowdone:
	inc	di
	jnz	flow1Loop

	add	bp,257
	mov	[FlowPos],bp


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;
NoFlow:
	mov	ebx,edi
	mov	edi,ds:[TabPtr]
	shr	edi,1
DrawFlowY:
	mov	bp,320
	xor	bl,bl
DrawFlowX:
	mov	ah,[ebx]
	xor	ch,ch
	mov	cl,[ebx+10000h]
	mov	al,[ebx+20000h]
	inc	bl
	shr	al,3
	shr	cl,3
	shr	ah,3
	shl	ah,2
	shl	cx,5
	or	ax,cx
	mov	[edi+edi],ax
	inc	di
	dec	bp
	jnz	DrawFlowX	
	inc	bh
	cmp	di,320*(200-32)
	jb	DrawFlowY
;NoFlow:
	ret
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;