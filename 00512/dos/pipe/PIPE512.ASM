;-----------------------------------------------------------------------------;
;               - Dedicated for Computer Art Festival 2002 -                  ;
;                   Compo: 512 bytes intro   Name: Pipe                       ;
;                  Author: Doctor Max^Global Corporation                      ;
;                                2:6037/1.27                                  ;
;-----------------------------------------------------------------------------;

.model	tiny
.386
.387
locals

GMport	=	330h		;General Midi port

.code
	org	0100h
start:	mov	ax,13h
	int	10h

	mov	ax,cs
	add	ax,1000h
	mov	fs,ax		;pipe table segment
	mov	es,ax
	add	ax,1000h
	mov	gs,ax		;background segment

;compute palette ---------------------------------------------------------
	mov	dx,03c8h
	xor	ax,ax
	out	dx,al
	inc	dx
	call	Pal
	mov	al,0c7h
	mov	[Pal_m1+1],al	;mov	al,bh
	mov	[Pal_m2+1],al	;mov	al,bh
	call	Pal

;compute pipe table -------------------------------------------------------
	xor	di,di
	xor	bx,bx		;r
@@rlp:	mov	bl,-127		;x
@@xlp:	mov	al,bh
	imul	al
	mov	dx,ax		;cx=r^2
	mov	al,bl
	imul	al		;ax=x^2
	cmp	ax,dx
	jl	@@in
	xor	ax,ax
	jmp	@@out

@@in:
;z=sqrt (r^2 - x^2)
	sub	dx,ax
	xor	cx,cx
@@sqr:	mov	al,cl
	imul	al
	inc	cx
	cmp	ax,dx
	jb	@@sqr
	mov	es:[di+32768],cl

;(x*m)/z
	mov	al,bl
	cbw
	imul	ax,128
	cwd
	idiv	cx
	test	al,al
	jnz	@@out
	inc	ax
@@out:	stosb
	inc	bl
	cmp	bl,129
	jnz	@@xlp
	inc	bh
	cmp	bh,bl
	jnz	@@rlp

;compute background -------------------------------------------------------
	push	0a000h
	pop	es
	push	es
	pop	ds
	mov	di,64256
	mov	dx,417ah
	xor	cx,cx
@@bg:	add	bl,[di-318]
	add	bl,[di-319]
	add	bl,[di-639]
	shr	bl,2
	sub	dl,dh
	ror	dx,3
	xor	dx,3a36h
	mov	ax,dx
	shr	al,6
	add	al,bl
	dec	ax
	and	al,3fh
	mov	bl,al
	mov	gs:[di],al
	stosb
	loop	@@bg

;fs - pipe
;main loop ----------------------------------------------------------------
MLoop:	mov	dx,03dah
@@vs0:	in	al,dx
	test	al,8
	jz	@@vs0
@@vs1:	in	al,dx
	test	al,8
	jnz	@@vs1

	push	cs
	pop	es
	push	cs
	pop	ds

	dec	byte ptr [muscnt]
	jnz	@@nomus

	mov	dx,GMport
	mov	al,0c9h
	out	dx,al
	mov	al,1
	out	dx,al
	mov	al,99h
	out	dx,al

	db	0beh		;mov si,offset music
musptr	dw	offset music
	lodsb
	test	al,al
	jnz	@@nlp
	mov	si,offset music
	mov	al,33h
@@nlp:	mov	[musptr],si
	out	dx,al
	mov	al,7fh
	out	dx,al
	mov	[muscnt],11

@@nomus:mov	si,offset cntx00
	mov	di,offset cntx0
	add	[si],word ptr 4
	movsw
	add	[si],word ptr 4
	movsw
	add	[si],word ptr -2
	movsw

	xor	bp,bp		;scr addr
@@mylp:	push	cs
	pop	es

	mov	si,offset cntx0
	add	[si],word ptr 3
	lodsw
	mov	bl,16
	call	Sin
	push	ax
	add	[si],word ptr -2
	lodsw
	mov	bl,48
	call	Sin
	pop	bx
	add	ax,bx
	add	ax,offset StrBuff+192
	push	ax

	dec	word ptr [si]
	lodsw
	mov	bl,48
	call	Sin
	add	ax,64+8
	shl	ax,8
	push	ax

;fill stripe buffer
	mov	ax,[cntx00]
	mov	bl,128
	call	Sin
	mov	cx,ax
	mov	ax,[cntz00]
	mov	bl,128
	call	Sin
	add	ax,cx

	push	gs
	pop	ds
	mov	si,bp
	add	si,ax
	mov	di,offset StrBuff+160
	mov	cx,320
	rep	movsb

	push	cs
	pop	ds

	pop	bx
	pop	di

@@mxlp:	movzx	ax,fs:[bx]
	test	ax,ax
	jz	@@mnx0
	sub	ax,[cntx01]
	shr	byte ptr es:[di+24],1	;shadow
	and	al,40h
	add	al,al
	add	al,fs:[bx+32768]
	mov	es:[di],al
@@mnx0:	inc	di
	inc	bl
	jnz	@@mxlp

	push	0a000h
	pop	es
	mov	si,offset StrBuff+160
	mov	di,bp
	mov	cx,320
	rep	movsb

	mov	bp,di
	cmp	bp,64000
	jnz	@@mylp

	in	al,60h
	dec	al
	jnz	MLoop

	mov	ax,3
	int	10h
	mov	dx,offset msg
	mov	ah,9
	int	21h
	ret

;ax - angle
;bl - amplitude
Sin:	mov	di,fputmp
	mov	[di],ax
	fild	word ptr [di]
	fild	[per]
	fdiv
	fldpi
	fmul
	fsin
	xor	bh,bh
	mov	[di],bx
	fild	word ptr [di]
	fmul
	fistp	word ptr [di]
	mov	ax,[di]
	ret

Pal:	xor	bx,bx
@@pal1:	mov	al,bl
	out	dx,al
Pal_m1	db	8ah,0c3h	;mov	al,bl
	out	dx,al
	mov	al,bh
	out	dx,al
	inc	bl
	cmp	bl,64
	jnz	@@pal1

@@pal2:	mov	al,63
	out	dx,al
Pal_m2	db	8ah,0c0h	;mov	al,al
	out	dx,al
	mov	al,bh
	out	dx,al
	inc	bh
	cmp	bh,64
	jnz	@@pal2
	ret

;variables block ---------------------------------------------------------
;don't remove!!!
msg	db	"Dr.Max^Global"
music	db	24h,2ch,33h,26h,33h,33h,26h,33h,24h,24h,26h
muscnt	db	1
cntx00	dw	512
cntx01	dw	128
cntz00	dw	32
per	dw	512
cntx0	dw	?
cntx1	dw	?
cntz	dw	?
fputmp	dw	?

StrBuff	db	640 dup (?)

end	start
