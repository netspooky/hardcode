;##########################################################################
; roto256 for asmcompo #7 (http://asmcompo.dimebar.net/)
; 31.05.2003
; coded by comrade <comrade2k@hotmail.com>
; IRC: #asm, #coders, #win32asm on EFnet
; Web: http://comrade64.cjb.net/
;      http://comrade.win32asm.com/
;##########################################################################
org 100h
use16
;##########################################################################
OFFSET equ
;##########################################################################
;##########################################################################
start:	; switch to graphics mode
	mov	ax,13h
	int	10h
	; set font
	mov	ax,1124h
	int	10h
	; draw text
	mov	ah,09h
	mov	dx,OFFSET text
	int	21h
	; copy to bitmap
	push	0A000h
	pop	ds
	xor	si,si
	mov	di,OFFSET textbmp
	mov	cx,(320*16) shr 1
	rep	movsw
.main:	; set segments
	push	cs
	pop	ds
	push	0A000h
	pop	es
	; draw
	fld	[angle]
	fadd	[anglei]
	fst	[angle]
	fsincos
	fstp	[cos]
	fstp	[sin]
	xor	di,di
	mov	[y],200
.dy:	mov	[x],320
	.dx:	fild	[x]
		fmul	[cos]
		fild	[y]
		fmul	[sin]
		fsubp	st1,st0
		fdiv	[scale]
		fabs
		fistp	[u]

		fild	[x]
		fmul	[sin]
		fild	[y]
		fmul	[cos]
		faddp	st1,st0
		fdiv	[scale]
		fistp	[v]

		mov	ax,[u]
		cwd
		div	[xwidth]
		mov	si,dx
		mov	ax,[v]
		and	ax,0Fh
		imul	[scanln]
		add	si,ax
		add	si,OFFSET textbmp
		lodsb
		cmp	al,0
		je	@F
		mov	ax,bp
		shr	ax,2
		and	ax,255
	@@:	stosb
		dec	[x]
		jg	.dx
	dec	[y]
	jg	.dy
	fld	[scale]
	fadd	[scalei]
	fstp	[scale]
	test	bp,63
	jnz	@F
	fld	[scalei]
	fmul	[opp]
	fstp	[scalei]
@@:	inc	bp
	; check keypress
	mov	ah,01h
	int	16h
	jz	.main
	; quit
	ret
;##########################################################################
;##########################################################################
	text	db	" comrade $"
	textlen =	($ - text - 1)
	anglei	dd	0.01
	scalei	dd	0.01
	scale	dd	1.00
	opp	dd	-1.0
	xwidth	dw	(textlen*8)
	scanln	dw	320
	times 7 db 0
;##########################################################################
	textbmp rb	(8*16*320)
	x	rw	01h
	y	rw	01h
	u	rw	01h
	v	rw	01h
	angle	rd	01h
	sin	rd	01h
	cos	rd	01h
;##########################################################################
;##########################################################################