IFDEF debug   ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TexMakeTab:	
	db 6
	
	db 0
	dw 0
	db 200,90,20
	db 0
	dw 5+5*128		;20+20*256
	db 20,92,128
	db 0
	dw 30+30*128		;120+120*256
	db 64,128,192
	db 0
	dw 45+10*128		;180+40*256
	db 128,128,128
	db 0
	dw 20+20*128		;80+80*256
	db 32,84,128
	db 1
	dw 21+50*128		;84+200*256
	db 62,64,20
TexMakeTab2:
	db 7

	db 0
	dw 0
	db 60,90,128
	db 0
	dw 35+35*128	;140+140*256
	db 0,64,64
	db 0
	dw 50+45*128	;200+190*256
	db 0,64,128
	db 1
	dw 32000/4
	db 128,64,64
	db 0
	dw 20+15*128	;80+60*256
	db 0,64,64
	db 0
	dw 55+55*128	;220+220*256
	db 0,128,128
	db 0
	dw 32+32*128	;128+128*256
	db 0,64,128
TexMakeTab3:
	db 5

	db (1 shl 1)
	dw 0
	db 120,102,90
	db (1 shl 1)
	dw 1+128		;5+5*256
	db 0,40,50
	db (2 shl 1)
	dw 0
	db 40,80,160
	db (0 shl 1)+1
	dw 0
	db 140,180,100
	db (0 shl 1)
	dw 30+30*128	;120+120*256
	db 120,70,70
TexMakeTab4:
	db 5

	db (2 shl 1)
	dw 0
	db 60,120,192
	db (2 shl 1)
	dw 12+12*128	;50+50*256
	db 160,90,92
	db (2 shl 1)
	dw 25+25*128	;100+100*256
	db 0,40,40
	db (0 shl 1)+1
	dw 0
	db 180,180,180
	db (0 shl 1)
	dw 37+37*128	;150+150*256
	db 60,80,0
TexMakeTab5:
	db 6

	db 0
	dw 0
	db 60,90,128
	db 0
	dw 0
	db 64,192,192
	db 0
	dw 10+10*128	;40+40*256
	db 0,64,128
	db 0
	dw 20+15*128	;80+60*256
	db 128,64,0
	db 0
	dw -10-10*128	;-40-40*256
	db 66,64,128
	db (4 shl 1)+1
	dw 0
	db 128,128,85
TexMakeTab6:
	db 3
	
	db (5 shl 1)
	dw 0
	db 255,255,255
	db (4 shl 1)+1
	dw 0
	db 0,255,120
	db 1
	dw 20000/4
	db 0,0,155
TexMakeTab7:
	db 3
	
	db (6 shl 1)
	dw 0
	db 255,255,255
	db (4 shl 1)+1
	dw 0
	db 0,255,120
	db 1
	dw 20000/4
	db 0,0,155
ENDIF               ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TexMakeTab8:
	db 5	
	db (2 shl 1)
	dw 0
	db 155,175,215
	db (0 shl 1)
	dw 0
	db 155,100,85
	db (1 shl 1)+1
	dw 0
	db 100,100,100
	db (1 shl 1)
	dw 0;32+32*128
	db 100,100,100
	db (2 shl 1)+1
	dw 0
	db 120, 0,200

TexMakeTab9:
	db 4;6
	db (0 shl 1)
	dw 0
	db 200,155,55	
	db (3 shl 1)+1
	dw 0
	db 200,155,55	
	db (3 shl 1)
	dw 64+64*128
	db 255,055,155	
	db (2 shl 1)
	dw 0
	db 155,175,155	

TexMakeTab10:
	db 4
	db (2 shl 1)
	dw 0
	db 200,235,185	; white squres whith green between	
	db (2 shl 1)+1
	dw 0
	db  80,155,175	
	db (0 shl 1)
	dw 12+12*128
	db 155,155,100	
	db (3 shl 1)+1
	dw 12+12*128
	db 155,255,255	
	
TexMakeTab11:
	db 4

	db (2 shl 1)
	dw 32
	db 250,160,120	; white squres whith green between	
	db (0 shl 1)
	dw 54+124*128
	db 140,250,90	
	db (0 shl 1)
	dw 154+24*128
	db 140,200,255	

;	db (2 shl 1)
;	dw 0
;	db 160,135,145	; white squres whith green between	
;	db (2 shl 1)
;	dw 54+124*128
;	db 110,130,170	
;	db (2 shl 1)
;	dw 154+24*128
;	db 70,90,40	

	db (3 shl 1)
	dw 0
	db 244,244,244	
	
	db (3 shl 1)+1
	dw 32+64*128
	db 155,0,200	
	
;*****************************************************************************
MkTextures	proc
			xor	di,di
			mov	fs,bufferSeg_b		;patterns 0: 16k: 32: 48k:
			mov	es,bufferSeg_g		;textures
			mov	si,texturePtr;offset TexMakeTab11
MkTex0:		push	di
			xor	di,di
			xor	ax,ax
			mov	cx,0ffffh
			rep	stosb
			pop	di			
			lodsb				;6(nummber of patterns):
			xor	ch,ch
			mov	cl,al
MkTex1:		push	cx
			lodsb				;0:0
			shr	al,1
			jnc	short TAdd1			;add:
			;call	TexSub
;------------- tex sub ---------------------
			xor	ah,ah
			shl	eax,14
			mov	bx,ax
			lodsw
			add	bx,ax
			mov	dx,bx
			and	dx,1100000000000000b
			push	di
			mov	cx,3
TexSub0:		push	di
			mov	bp,128*128
TexSub1:		and	bx,0011111111111111b
			or	bx,dx			
			mov	al,fs:[bx]
			inc	bx
			mul	byte ptr [si]
			mov	al,es:[di]
			sub	al,ah
			jnc	short NoneTexSub
			xor	al,al
NoneTexSub:	mov	es:[di],al
			add	edi,3
			dec	bp
			jnz	short TexSub1
			pop	di
			inc	di
			inc	si
			loop	TexSub0
			pop	di
			jmp	short TSub1
TAdd1:		;call	TexAdd
;------------- tex add ---------------------
			xor	ah,ah
			shl	eax,14
			mov	bx,ax				;bx = pointer to pattern
			lodsw					;0 (offset into pattern): 20+20*256
			add	bx,ax			
			mov	dx,bx
			and	dx,1100000000000000b			
			push	di
			mov	cx,3					;for r&g&b
TexAdd0:		push	di
			mov	bp,128*128
TexAdd1:		and	bx,0011111111111111b
			or	bx,dx			
			mov	al,fs:[bx]
			inc	bx
			mul	byte ptr [si]			;200r: 90g: 20b:
			add	ah,es:[di]			;ah set by mul
			jnc	short NoneTexAdd
			mov	ah,255
NoneTexAdd:	mov	es:[di],ah
			add	di,3
			dec	bp
			jnz	short TexAdd1
			pop	di
			inc	di
			sub	bx,128*128
			inc	si
			loop	short TexAdd0
			pop	di
TSub1:		pop	cx
			dec	cx
			jnz	MkTex1
			ret
MkTextures	endp
;*****************************************************************************
; resizes 256*256 texture in es and converts it to 128*128 into bufferSeg_b
; with offset in di
;
resize256To128	proc
			push	fs
			mov	fs,bufferSeg_b
			xor	si,si
			mov	dx,128
resizeY:		mov	cx,128
resizeX:		movzx ax,byte ptr es:[si]
			movzx bx,byte ptr es:[si+1]
			add	ax,bx
			movzx bx,byte ptr es:[si+256]
			add	ax,bx
			movzx bx,byte ptr es:[si+256+1]
			add	ax,bx
			shr	ax,2
			mov	fs:[di],al
			add	si,2
			inc	di
			loop	resizeX
			add	si,256
			dec	dx
			jnz	short resizeY
			pop	fs
			ret
resize256To128	endp
;*****************************************************************************
generateTexture	proc
			call	prepTexture
			mov	es,textureSeg1
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
			
			xor	di,di
			call	resize256To128
			
;------------------- Blured Chessboard pattern generation ----------------------
;			xor	di,di
;			xor	bx,bx
;			xor	dx,dx
;RandPat:		mov	es:[bx],dl
;			add	dx,9248h
;			ror	dx,3
;			xor	dx,bx
;			inc	bx
;			jnz	short RandPat		
;			mov	bp,15		;Blur generated pattern
;			call	Blur256

;IFDEF debug   ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			xor	di,di;mov	di,dx
Szach:		xor	cx,cx
			mov	ax,di
			and	ax,1111100011111b
			cmp	al,25			;25/32
			ja	short NoSzach
			cmp	ah,25			;25/32
			ja	short NoSzach
			dec	cx
NoSzach:		mov	es:[di],cl
			inc	di
			jnz	short Szach			
			mov	bp,13		;Blur generated pattern
			mov	ebx,edx
			call	Blur256
;ENDIF         ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

			mov	di,128*128*1
			call	resize256To128
			
;----------------------- Fractal plasma pattern  generation---------------------
			xor	bx,bx
			call	Plasma
			mov	bp,5
			call	Blur256

			mov	di,128*128*2
			call	resize256To128

;------------------------- Blured random mess pattern --------------------------
IFDEF debug   ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			xor	bx,bx
			xor	dx,dx
RandPat:		mov	es:[bx],dl
			add	dx,9248h
			ror	dx,3
			xor	dx,bx
			inc	bx
			jnz	short RandPat		
			mov	bp,5		;Blur generated pattern
			call	Blur256
ENDIF         ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			
			mov	es,ligthMap
			mov	di,128*128*3
			call	resize256To128
			
			call	mkTextures
;------------- packTexture3 ----------------
			mov	fs,bufferSeg_g
			mov	es,textureSeg1
			mov	cx,128*128
			xor	si,si
			xor	di,di
packTexture3X:	mov  ah,fs:[si]
			mov	al,fs:[si+1]
			shl	eax,8
			mov	al,fs:[si+2]
			stosd
			add	si,3
			dec	cx
			jnz	short packTexture3X
			ret
generateTexture	endp	          
;*****************************************************************************
; ebx = lightmap
; es:bx = lightmap
; lea	edx,[ebx+Patterns+600]
; fs = destination
MkPattern		proc
			mov	fs,ligthMap
			xor	bp,bp
MkPattern1:	add	dx,9248h;1001001001001000b
			ror	dx,3
			xor	dx,bp
			push	dx
MkPattern2:	push	dx
MkPattern2a:	mov	di,dx
			mov	al,fs:[bx]
			or	si,si
			jnz	short MkPatternA			
			sub	es:[di],al
			jnc	short MkPattern3
			mov	byte ptr es:[di],0
			jmp	short MkPattern3
MkPatternA:	add	es:[di],al
			jnc	short MkPattern3
			mov	byte ptr es:[di],255
MkPattern3:	inc	dx
			add	bl,ah
			jnz	short MkPattern2a
			pop	dx
			inc	dh
			add	bh,ah
			jnz	short MkPattern2
			pop	dx
			inc	bp
			loop	MkPattern1
			ret
MkPattern		endp
;*****************************************************************************
t128			dw -128
PrepTexture	PROC
			mov	fs,ligthMap
			xor	bx,bx
			xor	dx,dx
			fld1
			fild	ds:[t128]
PrepYL:		fild	ds:[t128]
PrepXL:		fld	st(1)
			fmul	st,st
			fld	st(1)
			fmul	st,st
			faddp st(1),st
			fsqrt
			fistp word ptr ds:[PrepT1+1]
PrepT1:		mov	ax,1234h
			fadd	st,st(2)
			sub	al,127
			jb	short No
			xor	ax,ax
No:			neg	al
			shr	al,1
			mov	fs:[bx],al
			inc	bx
			dec	dl
			jnz	short PrepXL
			fstp	st
			fadd	st,st(1)
			dec	dh
			jnz	short PrepYL
			fcompp
			ret
PrepTexture	ENDP
;*****************************************************************************
Blur256		PROC
Blur256A:		push	dx
			mov	dx,bx
			inc	dh
			xor	ch,ch
			xor	ah,ah
Blur256L:		mov	al,es:[bx]		;[x,y]
			inc	bl
			mov	di,dx
			mov	cl,es:[di]
			inc	di
			;inc	dl;;;;
			add	ax,cx
			mov	cl,es:[bx]
			dec	bl
			add	ax,cx
			;mov	di,dx;;;;
			mov	cl,es:[di]
			;dec	dl;;;;;
			add	ax,cx
			inc	dx
			shr	ax,2
			mov	es:[bx],al
			inc	bx
			jnz	short Blur256L
			pop	dx
			dec	bp
			jnz	short Blur256A
			ret
Blur256		ENDP
;*****************************************************************************
