;
; 256 byte
; --------
;
; 256 byte intro for ragest'98 by nap/dilemma
; 4th place
;
; copyright (c) 1998, peter nagy, all rights reserved
;
; e-mail: nap@dilemma.hu, http://www.dilemma.hu
;
;
; use tasm to compile
;

		.386p
code		segment	use16
		assume	cs:code,ds:code
		org	100h

start:
		mov	al,13h
		int	10h

		mov	ah,9
		mov	dx,offset nap
		int	21h
		mov	cl,32
l:		hlt
		loop	l

		mov	dx,3c8h
		xor	al,al

		mov	ah,70h
		mov	fs,ax
		mov	ah,80h
		mov	gs,ax

		out	dx,al
		inc	dx
		mov	cl,64*3
pg_l1:		mov	al,bh
		out	dx,al
		add	bx,45*4/3
		loop	pg_l1
		mov	cl,64*3
pg_l2:		mov	al,bh
		out	dx,al
		add	bx,-(45*4/3)
		loop	pg_l2

		lea	di,datas
		lea	si,tabla
		mov	ch,1
		push	cx
sg_loop:	fldpi
		fimul	word ptr [di+4]
		fidiv	word ptr [di]
		fsin
		fimul	word ptr [di+2]
		fistp	word ptr [si]
		inc	si
		inc	word ptr [di+4]
		loop	sg_loop

		push	6000h
		pop	es
		pop	cx
		push	es

texturegenerator:
		sub	si,cx
		push	cx
tg_l1:		add	al,5
		add	ah,6
		mov	bx,ax
		xor	bh,bh
		mov	dl,byte ptr [si+bx]
		mov	bl,ah
		add	dl,byte ptr [si+bx]
		mov	bl,cl
		mov	byte ptr texture[bx],dl
		loop	tg_l1

		pop	bp
		sub	si,bp
tg_l2:		mov	dl,[si+bp-1]
		mov	bh,1
tg_l3:		mov	al,[si+bx-1]
		add	ax,dx
		shr	al,1
		stosb
		dec	bx
		jnz	tg_l3
		dec	bp
		jnz	tg_l2

		push	0a000h
		pop	es

		xor	di,di
		lea	si,datas
		mov	cx,-100
c&l2_1:		mov	bx,-160
c&l2_2:
		mov	[si],bx				;linegenerator
		fild	word ptr [si]
		mov	[si],cx
		fild	word ptr [si]
		fpatan
		mov	word ptr [si],128*2
		fimul	word ptr [si]
		fldpi
		fdivp	st(1),st
		fistp	word ptr fs:[di]
;		mov	word ptr [si],8192		;circlegenerator
		fild	word ptr [si+1]
		mov	[si],bx
		fild	word ptr [si]
		fmul	st,st(0)
		mov	[si],cx
		fild	word ptr [si]
		fmul	st,st(0)
		faddp	st(1),st
		fsqrt
;		mov	word ptr [si],8
;		fiadd	word ptr [si]
		fdivp	st(1),st
		fistp	word ptr gs:[di]
		inc	di

		inc	bx
		cmp	bx,160
		jne	c&l2_2
		inc	cx
		cmp	cx,100
		jne	c&l2_1

		pop	ds
tunnel1_loop:	mov	ah,fs:[di]
		mov	al,gs:[di]
		mov	si,ax
		add	si,dx
		movsb
		loop	tunnel1_loop

		inc	dx
		cmp	dh,8
		je	q

		in	al,60h
		cmp	al,1
		jne	tunnel1_loop

q:		mov	al,3
		int	10h
		ret

nap		db	'by nap/dma$'
datas		dw	128,32

texture		db	256 dup (?)
tabla		db	256 dup (?)

code		ends
		end	start
