;Effect 5

;t30	dw 30
;t5500	dw 5500

Ef5DataTab:
	dw 80,160
	dw 56,-228
	dw 104,94
	dw 120,200
	dw 64,-266
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
MkTunel1	PROC
	mov	bx,offset TempWord
;----------- calc tunel position (5 tunnels)---------;
	mov	si,offset Ef5DataTab
	mov	di,offset Temp
	mov	cx,5
MkTunelPos:
	fild	word ptr ds:[FrameCount]
	fidiv	word ptr [si+2]
	fsincos
	fimul	word ptr [si]
	fiadd	word ptr [bx+o t160-a]
	fstp	dword ptr [di]
	add	di,4
	fimul	word ptr [si]
	fiadd	word ptr [bx+o t84-a]
	fstp	dword ptr [di]
	add	di,4
	add	si,4
	loop	MkTunelPos
;------------------------------------------------------------------------------
;------ Calc tunel table -------;
	mov	di,offset TraceTab
	xor	bp,bp
TunY:
	xor	dx,dx
TunX:
	fldz
	fldz
	mov	si,offset Temp
	mov	cx,5
TunInnerL:
	mov	[bx],dx
	fild	word ptr [bx]
	fsub	dword ptr [si]
	mov	[bx],bp
	fild	word ptr [bx]
	fsub	dword ptr [si+4]

	fld	st(1)
	fmul	st,st
	fld	st(1)
	fmul	st,st
	faddp	st(1),st
	fsqrt
	ficom	word ptr [bx+o t30-a]
	fnstsw	ax
	sahf
	jae	TunOki
	fstp	st
	fild	word ptr [bx+o t30-a]
TunOki:

	mov	ax,1
	test	cl,1
	jnz	TunOki2
	neg	ax
TunOki2:
	mov	[bx],ax


	fidivr	word ptr [bx+o t5500-a]
	fimul	word ptr [bx]
	faddp	st(3),st

	fpatan
	fmul	dword ptr [bx+o t128pi-a]
	fimul	word ptr [bx]
	faddp	st(2),st
	add	si,8
	loop	TunInnerL

	fimul	word ptr [bx+o t256-a]
	fistp	dword ptr [di]
	add	di,4
	fimul	word ptr [bx+o t256-a]
	fistp	dword ptr [di]
	add	di,4
	add	di,4
	add	dx,8
	cmp	dx,(41*8)
	jnz	TunX

	add	bp,8
	cmp	bp,(26-4)*8
	jnz	TunY
;------------------------------------------------------------------------------
	
	call	TunelInt1
	ret
MkTunel1	ENDP
;------------------------------------------------------------------------------
;------ eax - texture
TextureTunel	PROC
	mov	edi,ds:[TabPtr]
	add	eax,edi
	shr	eax,1
	shr	edi,1
TextureTun:
	mov	ax,[edi+edi+TunelBuffer]
	mov	ax,[eax+eax]
	mov	[edi+edi],ax
	inc	di
	cmp	di,320*(200-32)
	jnz	TextureTun

;	ret
;TextureTunel	ENDP
;------------------------------------------------------------------------------
;MkFadeBlob	PROC
;	mov	ebx,ds:[TabPtr]
;	lea	edi,[ebx+ColBuffers]
;	add	ebx,Patterns

	mov	edi,ds:[TabPtr]
	lea	ebx,[edi+Patterns+Pattern1]
	mov	edx,ebx	
	add	edi,ColBuffers


	mov	bx,ds:[FrameCount]
	shr	bx,3
	mov	bh,bl
	sub	dx,bx
	add	dx,150+50*256

FBlobY:
	push	bx
	push	dx
	xor	cx,cx
	mov	bp,320
FBlobX:
	xor	ax,ax
	mov	al,[ebx]
	inc	bl
	mov	cl,[edx]
	inc	dl
	add	ax,cx
	cmp	ax,64+30
	jl	FBlobA
	cmp	ax,127+30
	jg	FBlobB
	sub	ax,64+30
	add	ax,ax
	jmp	FBlobC
FBlobA:	
	xor	ax,ax
	jmp	FBlobC
FBlobB:	
	mov	ax,127
FBlobC:	
	mov	[edi],al
	inc	di
	dec	bp
	jnz	FBlobX
	
	pop	dx
	pop	bx
	inc	dh
	inc	bh
	cmp	di,320*(200-32)
	jnz	FBlobY
	
	ret
;MkFadeBlob	ENDP
TextureTunel	ENDP
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
Effect5	PROC
	mov	edi,ds:[TabPtr]
	lea	ebx,[edi+Patterns+Pattern2]
	mov	edx,ebx
	lea	eax,[edi+Textures+Texture7]
	add	edi,20000h
	shr	edi,1
	shr	eax,1
	
	mov	bx,ds:[FrameCount]
	shr	bx,3
	mov	bh,bl
	mov	dx,bx
	not	dx

	xor	cx,cx
Effect5GlassY:
	push	bx
	push	dx
	xor	cl,cl
	mov	si,320
Effect5GlassX:
	mov	al,[ebx]
	inc	bl
	add	al,[edx]
	inc	dl
	rcr	al,1
	mov	ah,al
	add	ax,cx
	mov	ax,[eax+eax]
	inc	cl
	mov	[edi+edi],ax
	inc	di
	dec	si
	jnz	Effect5GlassX
	
	pop	dx
	pop	bx
	inc	dh
	inc	bh
	inc	ch
	cmp	ch,200-32
	jnz	Effect5GlassY

	ret
Effect5	ENDP