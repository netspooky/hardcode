;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;rad_X		dd 320 dup (?)
;rad_Y		dd 320 dup (?)
;t50		dw 50
;t40		dw 40
;Rad_Ypos	dw ?
;Rad_V		dw ?
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
RadialBlur	PROC
	mov	bx,a
	fild	ds:[FrameCount]
	fidiv	word ptr [bx+o t160-a]
	fsincos
	fimul	word ptr [bx+o t50-a]
	fiadd	word ptr [bx+o t160-a]
	fist	word ptr [bx+o Temp-a]
	fxch	st(1)
	fimul	word ptr [bx+o t50-a]
	fiadd	word ptr [bx+o t84-a]
	fist	word ptr [bx+o Temp+2-a]
	fxch	st(1)
		
	mov	cx,2
	mov	di,offset Rad_X
MkRadialTable0:
	mov	dx,320
	fldz
MkRadialTable:
	fld	st
	fsub	st,st(2)
	fidiv	word ptr [bx+o t40-a]
	fsubr	st,st(1)
	fimul	word ptr [bx+o t256-a]
	fimul	word ptr [bx+o t256-a]
	fistp	dword ptr [di]
	fld1
	faddp	st(1),st
	shr	word ptr [di],8
	add	di,4
	dec	dx
	jnz	MkRadialTable
	fcompp
	loop	MkRadialTable0

;----------------- make tables ----------------;
	mov	edi,ds:[TabPtr]
	add	edi,ColBuffers
	mov	esi,edi

	mov	bx,word ptr [bx+o Temp+2-a]
	push	bx
RadY1:
	call	RadialLine
	dec	bx
	jge	RadY1
EndRadY1:
	pop	bx
RadY2:
	inc	bx
	call	RadialLine
;	cmp	bx,(200-32)
	cmp	bl,200-32
	jb	RadY2
EndRadY2:
;/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/;
	mov	edi,ds:[TabPtr]
	shr	edi,1
@AddRadial:
	mov	bl,[esi]
	inc	si
	mov	ax,[edi+edi]
	mov	cl,bl
	shr	bl,3
	mov	dx,ax
	shl	cx,3
	and	ax,31775
	and	dx,992
	add	al,bl
	shl	bx,10
	and	cx,992+1024
	add	ax,bx
	add	cx,dx

	test	al,32
	jz	OkiB
	mov	al,31
OkiB:
	test	ax,32768
	jz	OkiR
	mov	ah,124
OkiR:
	test	cx,1024+2048
	jz	OkiG
	mov	cx,992
OkiG:
	or	ax,cx
	mov	[edi+edi],ax
	inc	di
	cmp	di,320*(200-32)
	jb	@AddRadial

	ret
RadialBlur	ENDP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;   => ax - ypos of line

RadialLine	PROC
	pusha	
	mov	bp,word ptr ds:[Temp]
	mov	di,bx
	imul	di,320
	add	di,bp
	shl	bp,2
	add	bp,offset Rad_X

	shl	bx,2
	mov	ax,[bx+2+offset Rad_Y]
	mov	cx,[bx+offset Rad_Y]
	mov	ds:[Rad_V],cx
	imul	ax,320
	mov	ds:[Rad_Ypos],ax

	push	di
	push	bp
;---------------------------;
RadX1:
;	cmp	bp,offset Rad_X
;	jb	EndRadX1
	mov	si,[bp+2]
	add	si,ds:[Rad_ypos]
	
	mov	al,[esi+1]
	xor	bh,bh
	mov	bl,[esi]
	xor	ah,ah
	xor	ch,ch
	sub	ax,bx

	imul	word ptr [bp]

	mov	cl,[esi+320]
	add	bl,ah
	adc	bh,dl
	xor	ah,ah

	mov	al,[esi+321]
	sub	ax,cx
	imul	word ptr [bp]
	mov	al,ah
	mov	ah,dl
	add	ax,cx

	sub	ax,bx
	imul	word ptr ds:[Rad_V]

	mov	cl,[edi]
	add	bl,ah
	adc	bh,dl

	mov	ax,bx
	sub	bx,cx
	shl	ax,5
	sub	ax,bx
	shr	ax,5

	or	ah,ah
	jz	NoRadial1
	mov	al,255
NoRadial1:
	mov	[edi],al
	dec	di
	sub	bp,4
;	jmp	RadX1
	cmp	bp,offset Rad_X
	jae	RadX1
EndRadX1:
;---------------------------;
	pop	bp
	pop	di
RadX2:
	add	bp,4
	inc	di
;	cmp	bp,offset Rad_X+320*4
;	jae	EndRadX2
	mov	si,[bp+2]
	add	si,ds:[Rad_ypos]
	
	mov	al,[esi+1]
	xor	bh,bh
	mov	bl,[esi]
	xor	ah,ah
	xor	ch,ch
	sub	ax,bx

	imul	word ptr [bp]

	mov	cl,[esi+320]
	add	bl,ah
	adc	bh,dl
	xor	ah,ah

	mov	al,[esi+321]
	sub	ax,cx
	imul	word ptr [bp]
	mov	al,ah
	mov	ah,dl
	add	ax,cx

	sub	ax,bx
	imul	word ptr ds:[Rad_V]

	mov	cl,[edi]
	add	bl,ah
	adc	bh,dl

	mov	ax,bx
	sub	bx,cx
	shl	ax,5
	sub	ax,bx
	shr	ax,5

	or	ah,ah
	jz	NoRadial2
	mov	al,255
NoRadial2:
	mov	[edi],al
;	jmp	RadX2
	cmp	bp,offset Rad_X+320*4
	jb	RadX2

EndRadX2:
;---------------------------;
	popa
	ret
RadialLine	ENDP
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;