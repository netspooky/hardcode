	org 100h
	use16
		mov	al, 13h
		int	10h
		mov	ax, cs
		add	ah, 10h
		mov	fs, ax

loc_1010B:				; CODE XREF: start+10j
		mov	bx, cx
		mov	[fs:bx], ch
		loop	loc_1010B

loc_10112:				; CODE XREF: start+2Ej
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

loc_10130:				; CODE XREF: start+3Fj
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
		push	bx
		call	sub_1018A
;               call    sub_10211;unhandled interrupt
;               call    sub_10352
		call	sub_10173;copy memory to screen
		pop	bx
		add	bh, 1
		mov	dx, 3DAh

loc_10159:				; CODE XREF: start+5Cj
		in	al, dx		; Video status bits:
					; 0: retrace.  1=display is in vert or horiz retrace.
					; 1: 1=light pen is triggered; 0=armed
					; 2: 1=light pen switch is open; 0=closed
					; 3: 1=vertical sync pulse is occurring.
		test	al, 8
		jz	short loc_10159
		in	al, 60h 	; AT Keyboard controller 8042.
		dec	al
		jnz	loc_10145
		mov	ax, 3
		int	10h		; - VIDEO - SET VIDEO MODE
					; AL = mode
		mov	ah, 9
		mov	dx, 5CCh
		int	21h		; DOS - PRINT STRING
					; DS:DX -> string terminated by "$"
;;              retn
word_1032A	dw 3
byte_10455	db 28h
byte_103C9	db 18h
; =============== S U B R O U T I N E =======================================
sub_10173:
		push	es
		push	0A000h
		pop	es
		mov	si, 1938h
		mov	di, 0
		mov	ch, 73h
		rep movsw
		mov	ch, 0Ah
		xor	ax, ax
		rep stosw
		pop	es
		retn
;flt_10602      dd 2.381091e-2
L05FE  db   78h,00,18h,00,19h,0Fh,0C3h,3Ch
l606 db 0,0,0,0,0,0,0
l602=l606-4
sub_1018A:
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
		retn
l023C	 db 0C3h,041h,04,0Eh,16h,0Bh,1Ah,00,41h,05,0Ch,1Ah,07,1Ch,00

;sub_10211:
;		mov	di, 0AF4Ch
;		mov	dx, 10h
;		mov	bx, l023C
;loc_1021A:
;		push	di
;loc_1021B:
;		inc	bx
;		mov	cl, [cs:bx]
;		test	cl, cl
;		jz	short loc_10234
;		add	di, cx
;		inc	bx
;		mov	cl, [cs:bx]
;loc_10227:
;		mov	byte [di], 0FAh;?????????????????
;		mov	byte [di+141h], 0
;		inc	di
;		loop	loc_10227
;		jmp	short loc_1021B
;loc_10234:
;		pop	di
;		add	di, 280h
;		dec	dx
;		jnz	short loc_1021A
;		retn
; ---------------------------------------------------------------------------
;               db 41h, 4, 0Eh, 16h, 0Bh, 1Ah, 0, 41h, 5, 0Ch, 1Ah, 7
;               db 1Ch, 0, 1Ah, 3, 23h, 6, 11h, 8, 6, 9, 5, 6, 4, 8, 4
;               db 6, 0, 1Ah, 3, 22h, 8, 10h, 3 dup(8), 4, 2 dup(5), 8
;               db 6, 4, 0, 19h, 4, 21h, 0Ah, 0Fh, 3 dup(8), 2 dup(4)
;               db 6, 8, 7, 3, 0, 7, 3, 0Dh, 6, 20h, 0Ch, 0Eh, 3 dup(8)
;               db 4, 3, 7, 8, 7, 3, 0, 3, 0Eh, 3, 0Fh, 1Ah, 3, 2, 8, 0Dh
;               db 8, 7, 8, 6, 1, 3 dup(8), 2, 0, 1, 4, 7, 2 dup(5), 7
;               db 1Fh, 3, 4, 8, 0Ch, 15h, 11h, 8, 0, 1, 5, 8, 3, 5, 7
;               db 1Eh, 3, 6, 7, 0Ch, 12h, 14h, 8, 0, 1, 0Dh, 8, 7, 1Dh
;               db 3, 7, 8, 0Bh, 8, 5, 7, 12h, 8, 0, 1, 0FAh, 0, 4, 0Eh
;               db 4, 7, 1Bh, 4, 0Ah, 8, 9, 8, 6, 8, 10h, 8, 0, 1, 2, 8
;               db 7, 4, 7, 4, 2, 14h, 4, 0Ch, 3 dup(8), 6, 8, 2 dup(3)
;               db 0Ah, 8, 0, 1, 4, 8, 4, 5, 7, 2 dup(3), 13h, 5, 0Ch
;               db 9, 7, 8, 6, 9, 2, 3, 0Ah, 8, 0, 1, 7, 3, 5, 7, 0Bh
;               db 11h, 0Ch, 6, 1Eh, 3, 0Ch, 7, 10h, 0, 2 dup(1), 3, 8
;               db 0Ch, 7, 13h, 0Bh, 7, 1Dh, 7, 6, 0Ah, 10h, 0, 0E0h, 0E8h
;               db 0F5h, 0FFh, 0DCh, 0D4h, 0C8h
;word_1032A     dw 3
; =============== S U B R O U T I N E =======================================

sub_1032C:;
		mov	bp, 7

loc_1032F:				; CODE XREF: sub_1032C+23j
		push	di
		mov	al, [bp+322h]

loc_10334:				; CODE XREF: sub_1032C+1Bj
		mov	cl, [bx]
		inc	bx
		test	cl, cl
		jz	short loc_10349
		push	cx
		shr	cx, 4
		add	di, cx
		pop	cx
		and	cl, 0Fh
		rep stosb
		jmp	short loc_10334
; ---------------------------------------------------------------------------

loc_10349:				; CODE XREF: sub_1032C+Dj
		pop	di
		add	di, 140h
		dec	bp
		jg	short loc_1032F
		retn

sub_10352:
;		mov	di, 1938h
;		mov	ch, 0Ah
;		xor	ax, ax
;		rep stosw
;		mov	di, 2478h
;		mov	si, l3C9h;таблица
;		add	di, [cs:word_1032A]
;loc_10365:
;		movzx	bx, byte [cs:si]
;		cmp	bx, 28h
;		jz	short loc_10377
;		mov	bx, [bx+5A4h]
;		push	di
;		call	sub_1032C
;		pop	di
;loc_10377:
;		inc	si
;		add	di, 10h
;		cmp	si, 3DDh
;		jl	short loc_10365
;		mov	di, 2468h
;		xor	ax, ax
;		mov	bx, 8
;loc_1038A:
;		push	di
;		mov	cx, 20h
;		rep stosb
;		pop	di
;		add	di, 140h
;		dec	bx
;		jg	short loc_1038A
;		mov	cx, 0C8h
;		test	byte [cs:word_1032A], 0Bh
;		jnz	short loc_103A5
;		mov	cx, 0D8h
;loc_103A5:
;		mov	di, 2D38h
;		rep stosb
;		dec	byte [cs:word_1032A]
;		jge	short locret_103C8
;		mov	byte [cs:word_1032A], 0Fh
;		mov	bl, [cs:byte_103C9]
;		mov	cx, 8Ch
;		mov	di, l3C9h
;		lea	si, [cs:di+1]
;		rep movsb
;		mov	[cs:byte_10455], bl
;locret_103C8:
;		retn
;l3C9h:
; ;file 'st3c9.BIN'
; ---------------------------------------------------------------------------
;byte_103C9     db 18h                  ; DATA XREF: sub_10352+63r
;               db 1Ah, 0, 16h, 1Ah, 28h, 14h, 0, 16h, 1Ah, 20h, 6 dup(28h)
;               db 0Eh, 0Ah, 2 dup(0Eh), 4, 9 dup(28h), 24h, 26h, 28h
;               db 0Ch, 0, 10h, 1Ch, 0, 16h, 20h, 28h, 24h, 2 dup(22h)
;               db 26h, 5 dup(28h), 0Eh, 4, 28h, 6, 16h, 4, 18h, 10h, 12h
;               db 20h, 4 dup(28h), 4, 10h, 1Ah, 16h
;               db 0
;               db 10h, 2, 4, 28h, 24h, 22h, 28h, 4, 1Ch, 16h, 12h, 18h
;               db 7 dup(28h), 18h, 2, 4, 10h, 4, 28h, 18h, 14h, 0Ah, 16h
;               db 0Ah, 1Ah, 28h, 1Eh, 0Ah, 1Ah, 8, 28h, 6, 16h, 4, 10h
;               db 2, 8, 28h, 1Ah, 12h, 1Ch, 2, 8, 28h, 0, 18h, 28h, 1Ch
;               db 18h, 1Ch, 0, 0Eh, 4 dup(28h), 2, 28h, 20h, 0, 4 dup(28h)
;byte_10455     db 28h                  ; DATA XREF: sub_10352+72w
;               db 64h, 0, 48h, 0, 24h, 44h, 0, 2Ch, 0, 24h, 44h, 0, 24h
;               db 44h, 0, 24h, 44h, 0, 48h, 0, 24h, 44h, 0, 24h, 0, 24h
;               db 0, 24h, 0, 24h, 44h, 0, 48h, 0, 2Ch, 0, 24h, 0, 24h
;               db 0, 28h, 0, 24h, 0, 24h, 0, 2Ch, 0, 2Ch, 0, 24h, 0, 24h
;               db 0, 28h, 0, 24h, 0, 24h, 0, 24h, 0, 24h, 44h, 0, 24h
;               db 44h, 0, 24h, 44h, 0, 2Ch, 0, 24h, 44h, 0, 24h, 44h
;               db 0, 24h, 44h, 0, 48h, 0, 64h, 0, 64h, 0, 64h, 0, 64h
;               db 0, 64h, 0, 48h, 0, 68h, 0, 84h, 0, 84h, 0, 84h, 0, 84h
;               db 0, 2 dup(24h), 0, 46h, 0, 24h, 0, 24h, 0, 24h, 0, 24h
;               db 0, 24h, 0, 24h, 0, 2Ch, 0, 24h, 44h, 0, 26h, 24h, 0
;               db 2Ch, 0, 2Ch, 0, 24h, 26h, 0, 24h, 44h, 0, 24h, 44h
;               db 0, 48h, 0, 24h, 44h, 0, 24h, 44h, 0, 24h, 44h, 0, 24h
;               db 44h, 0, 24h, 44h, 0, 48h, 0, 2Ah, 0, 24h, 44h, 0, 24h
;               db 44h, 0, 2Ah, 0, 24h, 0, 24h, 0, 24h, 0, 2Ah, 0, 24h
;               db 44h, 0, 24h, 44h, 0, 2Ah, 0, 28h, 0, 2 dup(24h), 0
;               db 24h, 44h, 0, 48h, 0, 24h, 44h, 0, 24h, 0, 48h, 0, 0A4h
;               db 0, 24h, 44h, 0, 48h, 0, 2Ch, 0, 64h, 0, 64h, 0, 64h
;               db 0, 64h, 0, 64h, 0, 64h, 0, 24h, 44h, 0, 24h, 44h, 0
;               db 24h, 44h, 0, 24h, 44h, 0, 24h, 44h, 0, 24h, 44h, 0
;               db 48h, 0, 24h, 64h, 0, 24h, 64h, 0, 24h, 64h, 0, 24h
;               db 22h, 24h, 0, 2Eh, 0, 2 dup(26h), 0, 24h, 64h, 0, 24h
;               db 44h, 0, 24h, 44h, 0, 24h, 44h, 0, 48h, 0, 64h, 0, 64h
;               db 0, 64h, 0, 48h, 0, 24h, 44h, 0, 24h, 26h, 0, 26h, 24h
;               db 0, 24h, 44h, 0, 24h, 44h, 0, 48h, 0, 48h, 0, 24h, 44h
;               db 0, 0A4h, 0, 84h, 0, 44h, 0, 24h, 0, 2Ch, 0, 0A4h, 0
;               db 86h, 0, 68h, 0, 24h, 44h, 0, 2Eh, 0, 0A4h, 0, 0A4h
;               db 0, 56h, 4, 68h, 4, 78h, 4, 86h, 4, 94h, 4, 0A8h, 4
;               db 0B6h, 4, 0C5h, 4, 0D3h, 4, 0E6h, 4, 0F9h, 4, 9, 5, 1Bh
;               db 5, 2Bh, 5, 39h, 5, 4Dh, 5, 62h, 5, 73h, 5, 86h, 5, 95h
;               db 5
;aCodeSkalBomb_S db 'Code: Skal / BomB!. See you at SOTA^H^H^H^HstART.$x',0
;               db 18h, 0
;flt_10602      dd 2.381091e-2          ; DATA XREF: sub_1018A+3r
;seg000         ends
;               end start
