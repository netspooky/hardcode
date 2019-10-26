.386

ASSUME CS:CODE,DS:CODE

CODE	SEGMENT USE16
	org	100h
Start:
	mov	al,13h
	int	10h
;---------------------------
	push	0a000h
	pop	es
;---------------------------
	db 0DBh,0E3h		; finit
	fldz
	mov	bx,300h

	mov	si,offset Du+2
MkSine:
	fld	st
	fsin
	fimul	word ptr ds:[si]
	fiadd	word ptr ds:[si]
	fistp	word ptr ds:[bx]
	fadd	dword ptr ds:[si+offset tpi128-offset Du-2]
	inc	bl
	jnz	MkSine
	

	mov	dx,3c8h
	xor	ax,ax
	out	dx,al
	inc	dx
Pal:
	mov	al,ah
	add	al,al
	cmp	al,63
	jbe	Pal1
	mov	al,63
Pal1:	
	out	dx,al
	mov	al,ah
	out	dx,al
	xor	al,al
	out	dx,al
	inc	ah
	jnz	Pal
;------------------------------------------------------------------------------
MainLoop:
	mov	dx,3dah
Vert:
	in	al,dx
	and	al,8
	jz	Vert

	mov	bp,200
	xor	di,di
YLoop:
	mov	si,offset v
	mov	word ptr ds:[si],bp
	fld	st
	fsub	dword ptr ds:[si+offset rite-offset v]
	fsincos	
	fld	st(2)
	fadd	dword ptr ds:[si+offset rite-offset v]
	fsincos	
	
	fild	word ptr ds:[MainLoop+1]	;960
	cmp	bp,100
	jl	Sky
	fchs			;ground
Sky:
	fld	st(2)
	fimul	word ptr ds:[si+offset t660-offset v]
	fsubp	st(1),st

	fild	word ptr ds:[si]
	fisub	word ptr ds:[si+offset t100-offset v]
	fdivp	st(1),st
	fist	word ptr ds:[si+offset col+1-offset v]
	fimul	word ptr ds:[si+offset t2000-offset v]
	
	fmul	st(1),st
	fmul	st(2),st
	fmul	st(3),st
	fmulp	st(4),st

	fsub	st,st(2)
	fidiv	word ptr ds:[si+offset t320+1-offset v]
	fistp	word ptr ds:[si+offset dv+2-offset v]
	fsub	st,st(2)
	fidiv	word ptr ds:[si+offset t320+1-offset v]
	fistp	word ptr ds:[si+offset du+2-offset v]
	fistp	dword ptr ds:[si]
	mov	dx,word ptr ds:[si]
	fistp	dword ptr ds:[si]
	push	cx
	add	cx,word ptr ds:[si]
t320:	mov	si,320
XLoop:
;	cmp	si,97
;	jae	DoIt
;	mov	al,0fh		;--0fh
;	test	bp,ax
;	jz	okk1
;	test	si,ax
;	jz	okk1
DoIt:
	mov	bl,dh
	sub	bl,[bx]
	sub	bl,ch
	mov	al,[bx]
	mov	bl,ch
	sub	bl,[bx]
	add	bl,dh
	add	bl,[bx]
	add	bl,al
	mov	al,[bx]

	shr	al,2
Col:	add	ax,1234h
	jge	okk1
	xor	ax,ax
okk1:
	cmp	si,10+80
	jae	NoFrame
	cmp	si,10
	jb	NoFrame
	shr	al,2
NoFrame:
	stosb
Du:	db 81h,0C1h,7Fh,00h		;add cx,07Fh
Dv:	add	dx,1234h
	dec	si
	jnz	XLoop
	pop	cx
	dec	bp
	jnz	YLoop
	fadd	ds:[dk]

	inc	ch			;move texture
	in	al,60h
	cmp	al,1
	jnz	MainLoop

;	das
;	jc	MainLoop

	
	ret
;------------
tpi128	dd 0.024543693
dk	dd 0.009
rite	dd 0.8
t660	dw 660
t100	dw 100
t2000	dw 1670
v	dd ?

sine	db 512 dup (?)

CODE 	ENDS

END	Start
