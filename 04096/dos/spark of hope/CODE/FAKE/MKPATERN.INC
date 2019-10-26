;+00000h	- ball blob pattern
;+10000h	- blured chessboard
;+20000h	- fractal plasma
;+30000h	- blured pixel mess
;+40000h	- tiny zigzag
;+50000h	- texts part I

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MakePatterns	PROC
	call	PrepTexture		;Make light map
	mov	ebx,ds:[TabPtr]
	lea	edx,[ebx+Patterns+600]
	add	ebx,LightMap
;----------------------- Ball blobs pattern generation -------------------------
	mov	ah,2
	mov	cx,201
	mov	si,1
	call	MkPattern
	mov	cl,201
	dec	si
	mov	ah,4
	call	MkPattern

	xor	dx,dx		;Blur generated pattern
	mov	bp,7
	mov	ebx,edx
	call	Blur256
;------------------- Blured Chessboard pattern generation ----------------------
	add	edx,10000h
Szach:
	xor	cx,cx
	mov	ax,dx
	and	ax,31+31*256
	cmp	al,25
	ja	NoSzach
	cmp	ah,25
	ja	NoSzach
	dec	cx
NoSzach:
	mov	[edx],cl
	inc	dx
	jnz	Szach

	mov	bp,13		;Blur generated pattern
	mov	ebx,edx
	call	Blur256
;----------------------- Fractal plasma pattern  generation---------------------
	lea	ebx,[edx+10000h]
	call	Plasma
;------------------------- Blured random mess pattern --------------------------
	xor	bx,bx
	add	ebx,10000h
	xor	dx,dx
RandPat:
	mov	[ebx],dl
	add	dx,9248h
	ror	dx,3
	xor	dx,bx
	inc	bx
	jnz	RandPat

	mov	bp,5		;Blur generated pattern
	call	Blur256
;--------------------- Tiny zigzag patterns ( blob + mess ) --------------------
	add	ebx,10000h
TinyZigzag:
	lea	edx,[ebx-40000h]
	inc	dl
	push	bx
	add	bl,[edx]
	sub	dl,2
	sub	bl,[edx]
	inc	dl
	inc	dh
	add	bh,[edx]
	sub	dh,2
	sub	bh,[edx]
	dec	dh
	mov	al,[ebx-10000h]
	pop	bx	
	sub	al,50
	mov	[ebx],al
	inc	bx
	jnz	TinyZigzag
;---------------------------- Prepare all texts --------------------------------
	mov 	edi,Patterns+50000h+4
        mov 	si,offset teksty
	call	MkText
	lea	ebx,[edi-2]
	mov	bp,3		;Blur generated pattern
	call	Blur256

	mov 	edi,Patterns+60000h+4
        mov 	si,offset tekst2
	call	MkText
	lea	ebx,[edi-2]
	mov	bp,3		;Blur generated pattern
	call	Blur256
	ret
MakePatterns	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MkPattern	PROC
	xor	bp,bp
MkPattern1:
	add	dx,9248h
	ror	dx,3
	xor	dx,bp
	push	dx
MkPattern2:
	push	dx
MkPattern2a:
	mov	al,[ebx]
	or	si,si
	jnz	MkPatternA
	sub	[edx],al
	jnc	MkPattern3
	mov	byte ptr [edx],0
	jmp	MkPattern3
MkPatternA:
	add	[edx],al
	jnc	MkPattern3
	mov	byte ptr [edx],255
MkPattern3:
	inc	dx
	add	bl,ah
	jnz	MkPattern2a
	pop	dx
	inc	dh
	add	bh,ah
	jnz	MkPattern2
	pop	dx
	inc	bp
	loop	MkPattern1
	ret
MkPattern	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t128	dw -128

PrepTexture	PROC
	push	cs
	pop	ds
	mov	ebx,ds:[TabPtr]
	fld1
	fild	ds:t128	
PrepYL:
	fild	ds:t128
PrepXL:
	fld	st(1)
	fmul	st,st
	fld	st(1)
	fmul	st,st
	faddp	st(1),st
	fsqrt
	fistp	word ptr ds:[PrepT1+1]
PrepT1:	mov	ax,1234h
	fadd	st,st(2)
	sub	al,127
	jb	No
	xor	al,al
No:
	neg	al
	shr	al,1
	mov	[ebx+LightMap],al
	inc	bl
	jnz	PrepXL
	fstp	st
	fadd	st,st(1)
	inc	bh
	jnz	PrepYL
	fcompp
	ret
PrepTexture	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Blur256	PROC
Blur256A:
	push	edx
	mov	edx,ebx
	inc	dh
	xor	ch,ch
	xor	ah,ah
Blur256L:
	mov	al,[ebx]		;[x,y]
	inc	bl
	mov	cl,[edx]
	inc	dl
	add	ax,cx
	mov	cl,[ebx]
	dec	bl
	add	ax,cx
	mov	cl,[edx]
	dec	dl
	add	ax,cx
	inc	dx
	shr	ax,2
	mov	[ebx],al
	inc	bx
	jnz	Blur256L
	pop	edx
	dec	bp
	jnz	Blur256A
	ret
Blur256	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
teksty db 'mine forever',0,'here elsewhere',0
       db 'can you feel it',0,'i am helpless',0
       db 'deep inside me',0,'pain and her',0
       db 'spark of hope',0,'inactivity',0
tekst2 db 'floating time',0,'and absent me',0
       db 'greetz to all',0,'tube27 1998',0
       db 0,0,0,0

MkText	PROC
	add 	edi,ds:[TabPtr]
        mov 	gs,ds:[FontSeg]
@bez:
        push 	di
@napis:
        lodsb
        and 	ax,0FFh
        jz  	@endnapis
        shl 	ax,4
        add 	ax,ds:[FontOfs]
        mov 	bx,ax
        mov 	cx,16
@pion:
        mov 	dl,gs:[bx]
        inc 	bx
        mov 	bp,8
@linia:
        xor 	ax,ax
        shl 	dl,1
        jnc 	@mfont1
        dec 	ax
@mfont1:
        mov 	[edi+256],ax
        lstosw
        dec 	bp
        jnz 	@linia
        add 	di,256-16+256
        loop 	@pion
        add 	di,-256*32+16
        jmp 	@napis
@endnapis:
        pop 	di
        add 	di,32*256
        jnc 	@bez
	ret
MkText	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
