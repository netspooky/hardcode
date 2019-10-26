	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;								;
	;			 G A L I L E O				;
	;								;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

; (C) 2001, loveC			e-mail: lovec@cauldron.sk
; Big thanx for baze and Spektra Soft & Hardware

; Samozrejme moja vdaka patri aj Galileovi, ktory uz davno vedel ze:
; 			"A predsa sa toci!"


%define PIXMAP (512+32)
%define RED_LEAD 4
%define R_BASE 40
%define POS_X 127
%define POS_Y 120
%define D_ALPHA (44*2)

[segment .text]
[org	100h]

BEGIN	mov	ax,13h
	int	10h
	mov	cl,0
PALETE	mov	ax,cx
	mov	dx,3C8h
	out	dx,al		; color number
	inc	dx
	shr	ax,2
	add	al,RED_LEAD
	out	dx,al		; RED
	sub	al,RED_LEAD
	out	dx,al		; GREEN
	cmp	cl,63
	cmc
	salc
	or	al,cl
	out	dx,al
	loop	PALETE
	fninit
	fldz			; alpha
	mov	dl,0DAh
	mov	bx,TEMP


MAIN	in	al,dx
	test	al,8
	jz	short MAIN
	push	si

DRAW	push	word 0A000h
	pop	es
	mov	si,dx		; frame buffer -> screen
	xor	di,di
	mov	ch,32000/256
	rep movsw

	mov	cl,200
	mov	di,dx
	pop	si

	push	ds
	pop	es

	inc	si
	fiadd	word [byte bx+D_ALPHA_ADD-TEMP]	; alpha += D_ALPHA

FOR_Y	mov	ax,si			; for(cx=200;cx>0;cx--)
	cbw
	xor	al,ah
	shr	al,1
	add	al,R_BASE
	cbw			; compute R
	
	mov	[bx],ax
	fild	word [bx]	; alpha, r
	fld	st0
	fmul	st0,st0		; alpha, r, r2
	
	fld	st2		; alpha,r,r2,alpha
	fsincos			; alpha,r,r2,sin(alpha),cos(alpha)

	fmul	st3		; alpha,r,r2,sin(alpha),r.cos(alpha)
	fistp	word [byte bx+CENTERX-TEMP]	; alpha,r,r2,sin(alpha)
	fmul	st2		; alpha,r,r2,r.sin(alpha)
	
	mov	[bx],cx
	sub	word [bx],POS_Y
	fiadd	word [bx]	; alpha,r,r2,y
	fld	st0		; alpha,r,r2,y,y
	fmul	st0,st0		; alpha,r,r2,y,y2
	fsubp	st2		; alpha,r,r2-y2,y

	fld	st3		; alpha,r,r2-y2,y,alpha
	fadd	st0,st0		; alpha,r,r2-y2,y,2.alpha
	fsincos			; alpha,r,r2-y2,y,sin 2.alpha,cos 2.alpha
	fmulp	st2,st0		; alpha,r,r2-y2,y.sy,sx
	mov	bp,320
FOR_X				; for(bp=320; bp>0 ;bp--)
	mov	ax,POS_X
CENTERX	equ	$-2
	lea	ax,[eax+ebp-POS_X]
	mov	[bx],ax

	fild	word [bx]	; alpha,r,r2-y2,y.sy,sx,x
	fmul	st1
	fild	word [bx]	; alpha,r,r2-y2,y.sy,sx,sx.x,x
	fld	st0		; alpha,r,r2-y2,y.sy,sx,sx.x,x,x
	fmul	st0,st0		; alpha,r,r2-y2,y.sy,sx,sx.x,x,x2
	fsubr	st5		; alpha,r,r2-y2,y.sy,sx,sx.x,x,r2-x2-y2

	fist	word [bx]
	or	[bx],cx
	jns	short SPHERE
TEXTURE
	fcompp			; FPU: alpha,r,r2-y2,y.sy,sx,sx.x,x,r2-x2-y2
	fistp	word [bx]
	mov	ax,[bx]
	shr	ax,3
	add	ax,cx
	xor	ax,bp
	and	al,31
NEXT	stosb
	dec	bp
	jnz	short FOR_X     ; FPU: alpha,r,r2-y2,y.sy,sx
	fcompp
	fcompp
	loop	FOR_Y	
	
	mov	ah,1
	int	16h
	jz	near MAIN
	mov	ax,3
	int	10h
	ret


SPHERE	fsqrt			; alpha,r,r2-y2,y.sy,sx,sx.x,x,z	;FPU is full
	lea	ax,[ecx+4*esi]
	fadd	st2,st0
	fpatan			; alpha,r,r2-y2,y.sy,sx,sx.x,arctg(z/x)
	fimul	word [bx+XXX-TEMP]
	fistp	word [bx]	; alpha,r,r2-y2,y.sy,sx,sx.x

	add	ax,[bx]

	shl	al,2
	fadd	st0,st1
	cbw
    	xor	al,ah	
	fistp	word [di]	
	shr	al,2
	shr	ah,6
	add	al,ah

	or	[di+1],ch
	js	short NEXT
	add	al,[di]
	jmp	short NEXT	

D_ALPHA_ADD	dw	44

XXX		equ	DRAW
align	4
TEMP		equ	512-8

