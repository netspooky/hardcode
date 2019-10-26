;Code: Skal / BomB!. See you at SOTA^H^H^H^HstART.$x',0
; st_art04.com
	org 100h
	use16
		mov	al, 13h
		int	10h
		mov bh,0A0h
		mov es,bx
		mov	ax, cs
		add	ah,10h
		mov	fs, ax

loc_1010B:
		mov	bx, cx
		mov	[fs:bx], ch
		loop	loc_1010B

loc_10112:
		mov	bx, cx
		add	ax, cx
		rol	ax, cl
		mov	dh, al
		sar	dh, 4
		adc	dl, dh
		adc	dl, [fs:bx+0FFh]
		shr	dl, 1
		mov	[fs:bx], dl
		not	bh
		mov	[fs:bx], dl
		loop	loc_10112

loc_10130:
		mov	ax, cx
		mov	dx, 3C8h
        out     dx, al
		inc	dx
        out     dx, al
		mul	al
		sar	ax, 8
        out     dx, al
        out     dx, al
		loop	loc_10130
		fldz
		xor	bx, bx

loc_10145:
;;		push	bx
;		call	sub_1018A
;sub_1018A:
		mov	di, 2D38h;??????????next
		fadd	dword [cs:l602];fadd        [cs:flt_10602]
		mov	dx, 0FFACh
loc_10194:
		mov	bp, 0FF60h
loc_10197:
		mov	si, l606
		fild	word [cs:si-8]
		mov	[cs:si], bp
		fild	word [cs:si]
		mov	[cs:si], dx
		fild	word [cs:si]
		mov	cl, 2
loc_101A7:
		fld	st3;st(3)
		fsincos
		fld	st2;st(2)
		fmul	st,st1;st, st(1)
		fld	st4;st(4)
		fmul	st,st3;st, st(3)
		faddp	st1,st;st(1), st
		fxch	st3;st(3)
		fmulp	st2,st;st(2), st
		fmulp	st3,st;st(3), st
		fsubp	st2,st;st(2), st
		fxch	st2;st(2)
		loop	loc_101A7
		fld	st
		fmul	st, st
		fld	st2;st(2)
		fmul	st, st
		faddp	st1,st;st(1), st
		fxch	st3;st(3)
		fmul	st, st
		fadd	st,st3;st, st(3)
		fxch	st3;st(3)
		fxch	st2;st(2)
		fpatan
		fxch	st2;st(2)
		fpatan
		fimul	word [cs:si-8]
		fistp	word [cs:si]
		fimul	word [cs:si-6]
		fistp	word [cs:si+1]
		mov	si, [cs:si];?????????????
		mov	ax, si
		xor	al, ah
		test	al, 10h
		mov	al, 0
		jz	short loc_101F6
		not	si
		mov	al, 50h
loc_101F6:
		add	al, [fs:bx+si]
		mov	si, bp
		add	al, [fs:bx+si+0A0h]
		mov	[di], al
		inc	di
		inc	bp
		cmp	bp, 0A0h
		jl	short loc_10197
		inc	dx
		cmp	dx, 54h
		jl	loc_10194
;;		retn
;		call	sub_10173;copy memory to screen
;sub_10173:
;		push	es
;		push	0A000h
;		pop	es
		mov	si, 1938h
		xor di,di;mov	di, 0
		mov	ch, 73h
		rep movsw
		mov	ch, 0Ah
		xor	ax, ax
		rep stosw
;		pop	es
;		retn
;
;;		pop	bx
		inc bh;add	bh, 1
;		mov	dx, 3DAh

;loc_10159:
;		in	al, dx
;		test	al, 8
;		jz	short loc_10159
		in	al, 60h 	; AT Keyboard controller 8042.
		dec	al
		jnz	loc_10145
;		mov	ax, 3
;		int	10h
		int	20h
;word_1032A	dw 3
;byte_10455	db 28h
;byte_103C9	db 18h

L05FE  db   78h,00,18h,00,19h,0Fh,0C3h,3Ch
l606=L05FE+8; db 0,0,0,0,0,0,0
l602=l606-4
