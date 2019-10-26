;---------------- generated patterns
pattern7 equ 000000h	;- simple light pattern (circles 0-127)
pattern1 equ 010000h	;- ball blob pattern
pattern2 equ 020000h	;- blured pixel mess 0 (blured 40)
pattern3 equ 030000h	;- blured pixel mess 1 (blured 7)
pattern4 equ 040000h	;- tiny zigzag
pattern5 equ 050000h	;- sine-plasma 2
pattern6 equ 060000h	;- grid 3 (honey pattern )
pattern8 equ 070000h	;- grid4 (black dots on white background) (blured 7 times)
pattern9 equ 080000h	;- chessboard (8x8 255 : 64) (blured 1 time)
patternA equ 090000h	;-\
		;A0000h	;- bump from honey pattern
patternB equ 0B0000h	;-\
		;C0000h	;- bump from grid4 pattern

;---------------- generated textures
texture4 equ 00000h	;- sine (blured 3) braz
texture6 equ 020000h	;- sine (blured ?) niebieski
texture1 equ 40000h	;- szachownica 1 (czarno - biala)
texture2 equ 60000h	;- szachownica 2 (+braz+zolty)
texture5 equ 80000h	;- honey (hexagon) niebieski
texture7 equ 0A0000h	;- honey (hexagon) zolty
texture8 equ 0C0000h	;- honey !bump!!!
texture9 equ 0E0000h	;- grid !bump!!!

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MakeTextures	PROC
;---------------------------- make light pattern ------------------------------
	mov	ebx,ds:[TabPtr]
	add	ebx,Patterns+Pattern7
	mov	si,offset TempWord
@lightmap0:
	mov	al,bl
	sub	al,128
	imul	al
	mov	cx,ax
	mov	al,bh
	sub	al,128
	imul	al
	add	ax,cx
	mov	[si],ax
	fild	word ptr [si]
	fsqrt
	fistp	word ptr [si]
	mov	ax,127
	sub	ax,[si]
	jae	@lightmap1
	xor	ax,ax
@lightmap1:
	mov	[ebx],al
	inc	bx
	jnz	@lightmap0
;----------------------- Ball blobs pattern generation ------------------------
	mov	edx,ebx
	add	ebx,600+(Pattern1-Pattern7)

	mov	ah,2
	mov	cx,201
	call	MkPattern
	mov	cx,201+256
	mov	ah,4
	call	MkPattern

	mov	bp,7
	call	Blur256			;blur and set ptr to next pattern
;---------------------- Blured random mess 0 pattern --------------------------
	xor	ax,ax
RandPat0:
	mov	[ebx],al
	add	ax,9248h
	ror	ax,3
	xor	ax,bx
	inc	bx
	jnz	RandPat0
	mov	bp,40		;Blur generated pattern
	call	Blur256			;blur and set ptr to next pattern
;----------------------- Blured random mess 1 pattern -------------------------
	xor	ax,ax
RandPat:
	mov	[ebx],al
	add	ax,9248h
	ror	ax,3
	xor	ax,bx
	inc	bx
	jnz	RandPat
	mov	bp,7		;Blur generated pattern
	call	Blur256			;blur and set ptr to next pattern
;--------------------- Tiny zigzag patterns ( blob + mess ) --------------------
TinyZigzag:
	lea	edx,[ebx+(Pattern1-Pattern4)]
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
	mov	al,[ebx+(Pattern3-Pattern4)]
	pop	bx	
	sub	al,100
	jnc	NopeZigZag1
	mov	al,0
NopeZigZag1:
	add	al,[edx]
	jnc	NopeZigZag
	mov	al,255
NopeZigZag:
	mov	[ebx],al
	inc	bx
	jnz	TinyZigzag
;-------------------- prepare sinus plasma patterns ---------------------------
	lea	edx,[ebx+10000h]

	mov	bx,(offset SineTab+256)
	xor	bl,bl
	fldz
MkSine1:
	fld	st
	fcos
	fimul	word ptr ds:[t128]
	fiadd	word ptr ds:[t64]
	fistp	word ptr ds:[bx]
	fadd	dword ptr ds:[Tpi128]
	inc	bl
	jnz	MkSine1
	fstp	st	
MkSine2:
	mov	bl,dl
	mov	bl,[bx]
	sub	bl,dh
	mov	al,[bx]
	mov	bl,dh
	mov	bl,[bx]
	sub	bl,dl
	mov	bl,[bx]
	add	bl,al
	add	bl,dl
	mov	bl,[bx]
	add	bl,dh
	add	bl,al
	mov	bl,[bx]
	mov	[edx],bl
	inc	dx
	jnz	MkSine2
;------------------------------- honey pattern --------------------------------
	lea	ebx,[edx+10000h]
@honey00:
	dec	byte ptr [ebx]			; byte = 255
	inc	bx
	jnz	@honey00	

;	mov	dx,1
	inc	dx
@honey10:
	mov	al,16
@honey11:
	inc	byte ptr [ebx]
	inc	bl
	inc	byte ptr [ebx]
	inc	bh
	inc	byte ptr [ebx]
	dec	bl
	inc	byte ptr [ebx]
	add	bl,dh
	test	al,1
	jz	@honey12
	dec	bh
@honey12:
	dec	al
	jnz	@honey11
	xor	dh,dl
	or	bh,bh
	jnz	@honey10
	add	bl,32
	jnz	@honey10
	neg	dl
	js	@honey10

	mov	bp,7		;Blur generated pattern
	call	Blur256			;blur and set ptr to next pattern
;---------------------------- Grid4 - black dots ------------------------------
MKGrid4:
	mov	al,bl
	and	al,bh
	and	al,4
	mov	al,0
	jnz	MkGrid4a
	dec	al
MkGrid4a:
	mov	[ebx],al
	inc	bx
	jnz	MkGrid4

	mov	bp,7
	call	Blur256
;---------------------------- Chessboard 8x8 blured ---------------------------
MkChessBoard1:
	mov	al,bl
	xor	al,bh
	and	al,8
	mov	al,255
	jnz	MkChessBoard1a
	mov	al,64
MkChessBoard1a:
	mov	[ebx],al
	inc	bx
	jnz	MkChessBoard1

	mov	bp,1
	call	Blur256
;---------------------------- Prepare all texts -------------------------------
	mov	edx,ds:[TabPtr]
	add	edx,Patterns+Pattern6
	call	Bump0
	add	edx,(Pattern8-Pattern6)
	call	Bump0
;---------------------------- Prepare all texts -------------------------------
  	

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;^^^^^^^^^^^^ Make textures ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;^^^^^^^^^^^^ Make textures ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	mov	edi,ds:[TabPtr]
	add	edi,Textures
	mov	si,offset TexMakeTab
MkTex0:
	push	edi
	mov	edi,ds:[TabPtr]
	push	edi		;Clear memory for texture
	mov	cx,(10000h/4)*3
	xor	eax,eax
	rep	lstosd
	pop	edi
	lodsb
	xor	ch,ch
	mov	cl,al
MkTex1:
	push	cx
	lodsb
	shr	al,1
	jnc	TAdd1
	call	TexSub
	jmp	TSub1
TAdd1:
	call	TexAdd
TSub1:
	pop	cx
	loop	MkTex1	
;--------- blur some textures--------
	cmp	si,offset TexMakeTab7			;!!!
	ja	NoBlurTexture				;!!!
BlurTexture:
	pushad
	mov	ebx,ds:[TabPtr]
	mov	bp,3
	call	Blur256
	mov	bp,3
	call	Blur256
	mov	bp,3
	call	Blur256
	popad
NoBlurTexture:
;--- Convert texture to 15 bit color ----------
	pop	edi
	mov	ebx,ds:[TabPtr]
C24to15:
	mov	al,[ebx]
	mov	ah,[ebx+10000h]
	shr	ah,3
	shr	ax,3
	mov	dl,[ebx+20000h]
	and	dl,11111000b
	shl	dx,2+5
	or	ax,dx
	lstosw
	inc	bx
	jnz	C24to15
	call	OutTimeText
	cmp	si,offset TexMakeTabEnd
	jnz	MkTex0
	ret
MakeTextures	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Bump0	PROC
@bump0:
	mov	al,[edx]
	inc	dl
	sub	al,[edx]
	dec	dl
	xor	ah,ah
	add	al,al
	jns	@bump1
	neg	al
	xchg	ah,al
@bump1:
	mov	[ebx],al
	mov	[ebx+10000h],ah
	inc	dx
	inc	bx
	jnz	@bump0
	add	ebx,10000h
	add	ebx,10000h
	ret
Bump0	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MkPattern	PROC
	xor	bp,bp
MkPattern1:
	add	bx,9248
	ror	bx,3
	xor	bx,bp
	push	bx
MkPattern2:
	push	bx
MkPattern2a:
	mov	al,[edx]
	shr	al,1
	or	ch,ch
	jnz	MkPatternA
	add	[ebx],al
	jnc	MkPattern3
	mov	byte ptr [ebx],255
	jmp	MkPattern3
MkPatternA:
	sub	[ebx],al
	jnc	MkPattern3
	mov	byte ptr [ebx],0
MkPattern3:
	inc	bx
	add	dl,ah
	jnz	MkPattern2a
	pop	bx
	inc	bh
	add	dh,ah
	jnz	MkPattern2
	pop	bx
	inc	bp
	dec	cl
	jnz	MkPattern1
	ret
MkPattern	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Blur256	PROC
Blur256A:
	xor	bx,bx
	xor	cx,cx
	xor	ax,ax
Blur256L:
	mov	al,[ebx]		;[x,y]
	inc	bl
	mov	cl,[ebx]
	inc	bh
	add	ax,cx
	mov	cl,[ebx]
	dec	bl
	add	ax,cx
	mov	cl,[ebx]
	dec	bh
	add	ax,cx
	shr	ax,2
	mov	[ebx],al
	inc	bx
	jnz	Blur256L
	dec	bp
	jnz	Blur256A
	add	ebx,10000h		;Set ptr to next pattern
	ret
Blur256	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TexAdd	PROC
	xor	ah,ah
	shl	eax,16
	mov	ebx,ds:[TabPtr]
	lea	ebx,[ebx+eax+Patterns]
	lodsw
	mov	bx,ax
	push	edi
	mov	cx,3
TexAdd0:
	xor	bp,bp
TexAdd1:
	mov	al,[ebx]
	inc	bx
	mul	byte ptr [si]
	add	ah,[edi]
	jnc	NoneTexAdd
	mov	ah,255
NoneTexAdd:
	mov	[edi],ah
	inc	edi
	inc	bp
	jnz	TexAdd1
	inc	si
	loop	TexAdd0
	pop	edi
	ret
TexAdd	ENDP
;------------------------------------------------------------------------------
TexSub	PROC
	xor	ah,ah
	shl	eax,16
	mov	ebx,ds:[TabPtr]
	lea	ebx,[ebx+eax+Patterns]
	lodsw
	mov	bx,ax
	push	edi
	mov	cx,3
TexSub0:
	xor	bp,bp
TexSub1:
	mov	al,[ebx]
	inc	bx
	mul	byte ptr [si]
	mov	al,[edi]
	sub	al,ah
	jnc	NoneTexSub
	xor	al,al
NoneTexSub:
	mov	[edi],al
	inc	edi
	inc	bp
	jnz	TexSub1
	inc	si
	loop	TexSub0
	pop	edi
	ret
TexSub	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mkpatern_text	db 'þ$'

OutTimeText	PROC
	pusha
	mov	dx,offset mkpatern_text
	mov	ah,9
	int	21h
	popa
	ret
OutTimeText	ENDP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TexMakeTab:
	db 6
	
	db ((Pattern5 shr 16) shl 1)
	dw 0
	db 60,120,192

	db ((Pattern5 shr 16) shl 1)
	dw 50+50*256
	db 100,90,92

	db ((Pattern5 shr 16) shl 1)
	dw 100+100*256
	db 40,40,40

	db ((Pattern1 shr 16) shl 1)+1
	dw 0
	db 180,180,180
	
	db ((Pattern1 shr 16) shl 1)
	dw 150+150*256
	db 60,80,60

	db ((Pattern1 shr 16) shl 1)+1
	dw 60+60*256
	db 180,180,180
TexMakeTab5:
	db 5
	
	db ((Pattern5 shr 16) shl 1)
	dw 0
	db 60,120,192

	db ((Pattern5 shr 16) shl 1)
	dw 50+50*256
	db 160,90,92

	db ((Pattern5 shr 16) shl 1)
	dw 100+100*256
	db 0,40,40

	db ((Pattern1 shr 16) shl 1)+1
	dw 0
	db 180,180,180

	db ((Pattern1 shr 16) shl 1)
	dw 150+150*256
	db 60,80,0
TexMakeTab7:


	db 6
	
	db ((Pattern9 shr 16) shl 1)
	dw 0
	db 255,255,255

	db ((Pattern1 shr 16) shl 1)
	dw 120+120*256
	db 50,80,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 200+200*256
	db 160,140,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 60+60*256
	db 150,150,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 0
	db 180,160,120

	db ((Pattern4 shr 16) shl 1)+1
	dw 0
	db 100,100,100
TexMakeTab2:
	db 9
	
	db ((Pattern9 shr 16) shl 1)
	dw 0
	db 255,255,255

	db ((Pattern1 shr 16) shl 1)
	dw 120+120*256
	db 50,80,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 200+200*256
	db 160,140,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 60+60*256
	db 150,150,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 0
	db 180,160,120

	db ((Pattern4 shr 16) shl 1)+1
	dw 0
	db 100,100,100

	db ((Pattern1 shr 16) shl 1)+1
	dw 60+10*256
	db 80,40,0

	db ((Pattern1 shr 16) shl 1)+1
	dw 116+216*256
	db 255,255,255

	db ((Pattern1 shr 16) shl 1)+1
	dw 216+116*256
	db 255,255,255
TexMakeTab4:
	db 5
	
	db ((Pattern6 shr 16) shl 1)
	dw 0
	db 120+120,120+80,60+120

	db ((Pattern1 shr 16) shl 1)
	dw 120+120*256
	db 60,120,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 200+200*256
	db 100,80,80

	db ((Pattern1 shr 16) shl 1)+1
	dw 60+60*256
	db 180,180,180

	db ((Pattern1 shr 16) shl 1)+1
	dw 0
	db 180,120,80
TexMakeTab6:
	db 5
	
	db ((Pattern6 shr 16) shl 1)
	dw 0
	db 180,200,240

	db ((Pattern1 shr 16) shl 1)
	dw 120+120*256
	db 60,120,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 200+200*256
	db 100,80,80

	db ((Pattern1 shr 16) shl 1)+1
	dw 60+60*256
	db 180,180,180

	db ((Pattern1 shr 16) shl 1)+1
	dw 0
	db 180,120,80
TexMakeTab8:
	db 10
	
	db ((Pattern6 shr 16) shl 1)
	dw 0
	db 120+60,120+80,120+120

	db ((Pattern1 shr 16) shl 1)
	dw 120+120*256
	db 60,80,160

	db ((Pattern1 shr 16) shl 1)+1
	dw 200+200*256
	db 100,80,80

	db ((Pattern1 shr 16) shl 1)+1
	dw 60+60*256
	db 180,180,180

	db ((Pattern1 shr 16) shl 1)+1
	dw 0
	db 180,120,80

	db ((Pattern1 shr 16) shl 1)+1
	dw 0
	db 120,120,80

	db ((Pattern1 shr 16) shl 1)+1
	dw 180+180*256
	db 60,20,0

	db ((Pattern1 shr 16) shl 1)+1			;!!!!!!!
	dw 150+150*256
	db 160,160,160

	db ((PatternA shr 16) shl 1)
	dw 0
	db 255,255,255

	db (((PatternA+10000h) shr 16) shl 1)+1
	dw 0
	db 255,255,255
TexMakeTab9:
	db 8
	
	db ((Pattern8 shr 16) shl 1)
	dw 0
	db 120+60,120+80,120+120

	db ((Pattern1 shr 16) shl 1)
	dw 120+120*256
	db 50,80,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 200+200*256
	db 160,140,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 60+60*256
	db 150,150,120

	db ((Pattern1 shr 16) shl 1)+1
	dw 0
	db 180,160,120

	db ((Pattern4 shr 16) shl 1)+1
	dw 0
	db 100,100,100

	db ((PatternB shr 16) shl 1)
	dw 0
	db 255,255,255

	db (((PatternB+10000h) shr 16) shl 1)+1
	dw 0
	db 255,255,255
TexMakeTabEnd:
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%