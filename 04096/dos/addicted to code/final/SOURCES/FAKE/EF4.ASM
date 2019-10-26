
;t3		dw 3
;t200		dw 200
;t3600		dw 3600
;t10		dw 10
;t1div3600	dd 0.0002777777

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;
;%%%%%%%% => st(0) = YS , st(1) = XS
;%%%%%%%% <= returns Field Value for (XS,YS) in st(0) (stack = Val,YS,XS)

MetaVal	PROC
	mov	si,offset Temp
	fldz
	mov	cx,4
MetaVal1:
	fld	st(2)			;XS
	fsub	dword ptr [si]		;XS - posX
	fmul	st,st			;(XS - posX)^2
	add	si,4
	fld	st(2)			;YS
	fsub	dword ptr [si]		;YS - posY
	fmul	st,st			;(YS - posY)^2
	add	si,4
	faddp	st(1),st
	ficom	word ptr [bx+o t3600-a]
	fnstsw	ax
	sahf
	jb	MetaVal2
	fsub	st,st
	jmp	MetaVal3
MetaVal2:				
	fmul	dword ptr [bx+o t1div3600-a]
	fld1
	fsubrp	st(1),st
	fmul	st,st
	fimul	word ptr [bx+o t200-a]
MetaVal3:
	faddp	st(1),st
	loop	MetaVal1
	ret
MetaVal	ENDP

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;

MetaData:
	dw	10,60
	dw	-7,40
	dw	17,50
	dw	-13,50
Colline:
	dw 0000h,28E4h,3948h,418Ah,418Ah,3948h,28E4h,14A2h

;-----------------------------------------------------------------------------;
Effect4	PROC
	mov	bx,offset TempWord

	mov	di,offset Temp
	mov	si,offset MetaData
	mov	ax,3
MkMetaPos:	
	fild	ds:[FrameCount]
	fidiv	word ptr [bx+o t256-a]

	fimul	word ptr [si]
	fidiv	word ptr [bx+o t10-a]
	
	fld	st
	fadd	st,st
	test	al,2
	jz	NoSwapMetaPos
	fxch	st(1)
NoSwapMetaPos:
	fcos
	fimul	word ptr [si+2]
	fiadd	word ptr [bx+o t160-a]
	fstp	dword ptr [di]
	add	di,4
	fsin
	fimul	word ptr [si+2]
	fiadd	word ptr [bx+o t84-a]
	fstp	dword ptr [di]
	add	di,4

	add	si,4

	dec	ax
	jns	MkMetaPos
;.............................................................................;
	mov	di,offset TraceTab
	xor	bp,bp
BlobY:
	xor	dx,dx
BlobX:
	mov	[bx],dx
	fild	word ptr [bx]
	mov	[bx],bp
	fild	word ptr [bx]
	call	MetaVal
	fxch	st(2)
	fxch	st(1)
	fld1
	faddp	st(2),st
	call	MetaVal
	fxch	st(2)
	fxch	st(1)
	fld1
	fsub	st(2),st
	faddp	st(1),st
	call	MetaVal

	fsub	st,st(4)
	fimul	word ptr [bx+o t3-a]
	faddp	st(1),st
	fxch	st(2)
	fsub	st,st(3)
	fimul	word ptr [bx+o t3-a]
	faddp	st(1),st

	fimul	word ptr [bx+o t256-a]
	fistp	dword ptr [di]
	add	di,4
	fimul	word ptr [bx+o t256-a]
	fistp	dword ptr [di]
	add	di,4
	fimul	word ptr [bx+o t200-a]
	fistp	dword ptr [di]
	mov	ax,word ptr [di+1]
	cmp	ax,5	
	jae	Blob1a
	mov	ax,5
Blob1a:
	or	ah,ah
	jz	Blob1b
	mov	ax,255
Blob1b:
	mov	word ptr [di+1],ax
	add	di,4

	add	dx,8
	cmp	dx,(41*8)
	jnz	BlobX
	add	bp,8
	cmp	bp,(26-4)*8
	jnz	BlobY
;.............................................................................;
	call	ColorTunelInt1
;.............................................................................;
	mov	edi,ds:[TabPtr]
	lea	esi,[edi+ColBuffers]
	lea	ecx,[edi+Patterns+Pattern4]
	shr	edi,1
	mov	ebx,edi
	
	xor	dx,dx
BlobTexY:
	xor	dl,dl
	mov	bp,320
BlobTexX:
	mov	al,[esi]

	mov	bx,[edi+edi+TunelBuffer]
	cmp	al,48
	jae	BlobA
	mov	cx,ds:[FrameCount]
	shr	cx,3
	mov	ch,cl
	add	cl,dl
	add	ch,dh
	mov	cl,[ecx]
	shr	cl,1
	xor	cl,127

	sub	al,32
	jb	BlobA0
	and	ax,7
	mov	bx,ax
	add	bx,bx
	mov	bx,[bx+offset Colline]
	jmp	BlobC
BlobA0:
	mov	bx,[ebx+ebx+Texture9+Textures]
	jmp	BlobC
BlobA:
	mov	cx,bx
	mov	bx,[ebx+ebx+Texture6+Textures]
	sub	cl,dl
	not	bx
	sub	ch,dh
	sub	ax,48+16
	jle	BlobA1
	xor	ax,ax
BlobA1:
	shl	ax,2
	sub	ax,50-128
	mov	cl,[ecx]
	shr	cl,1
	add	cl,al
BlobC:
	mov	[esi],cl
	inc	si
	mov	[edi+edi],bx
	inc	di
	inc	dl
	dec	bp
	jnz	BlobTexX

	inc	dh
	cmp	di,320*(200-32)
	jnz	BlobTexY
;.............................................................................;
;	mov	eax,ColBuffers
	xor	edx,edx
	call	Fade_tab0
	ret
Effect4	ENDP