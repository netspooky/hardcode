;      €ﬂﬂﬂﬂﬂ  €   €ﬂﬂﬂﬂ€   €ﬂﬂﬂﬂﬂ
;      €‹‹‹‹   €   €‹‹‹‹€   €‹‹‹‹
;      €       €   € ﬂ‹     €
; nice €       €   €   ﬂ‹   €‹‹‹‹‹
;
; written 1997 by Ziron/ALPiNE aka Christoph Groth
;
; e-mail: groth@kulmbach.baynet.de

	IDEAL
	P386
	ASSUME	CS:Code,DS:Code

O	EQU	OFFSET	;quite a cool trick, what?
B	EQU	BYTE
W	EQU	WORD
D	EQU	DWORD

SEGMENT Code	PUBLIC
	ORG	100h	;COM-Programs begin at offset 256

;€€€€€€€€ fill bottom of buffer with random values and smooth the flames
MACRO	Fire
LOCAL	@@1,@@2,@@3
	mov	cx,320
	mov	di,O Buffer+34560-320	;beginning of the bottom line
	mov	ax,[Seed]
	mov	bl,ah
@@1:	mul	si			;generate "random" number
	inc	ax
	cmp	al,32;64
	jnb	@@2
	mov	bl,ah
@@2:	mov	[di],bl
	mov	[di-320],bl
	inc	di
	loop	@@1
	mov	[Seed],ax

	mov	di,O Buffer
	xor	ax,ax
	xor	dx,dx
	mov	cx,34560
;in this loop, the colors are smoothed and moved one pixel up
@@3:	mov	al,[di+640]
	mov	dl,[di]
	add	ax,dx
	mov	dl,[di+1+320]
	add	ax,dx
	mov	dl,[di-1+320]
	add	ax,dx
	shr	ax,2
	jz	@@4
	dec	ax	;the flames must be darker at the top
@@4:	mov	[di],al
	inc	di
	loop	@@3
ENDM

;€€€€€€€€ compute the VGA-palette
MACRO	InitPal
;The Idea for this routine was taken from Gaffer's FLAME.ASM. Thanx!
;But now it's even 2 bytes shorter! :)
	mov	al,63
	mov	ch,3		;cx will be always bigger than
	mov	di,64*3
	rep	stosb

	mov	si,2+63*3
	xor	ax,ax
	call	PaletteGen
	inc	bx
	call	PaletteGen                                 

	mov	si,1+63*3
	call	PaletteGen
	
	xor	si,si
	call	PaletteGen
;and set it
	mov	ax,1012h
	mov	cl,255
	xor	dx,dx
	int	10h
ENDM

;€€€€€€€€ main loop
start:	mov	ax,13h
	int	10h
	mov	dx,3d4h
	mov	ax,0309h
	out	dx,ax		;set resolution 320*100

	push	0a000h		;the VGA-segment
	pop	es
	InitPal

@@main:	xor	di,di
	mov	si,O Buffer
	mov	cx,16000
	rep	movsw		;copy the buffer to screen
	Fire
	mov	ah,1		;check if a key is pressed
	int	16h
	jz	@@main		;if not, jump to @@main
	mov	ax,3h
	int	10h		;set textmode 80*25
	ret			;the shortest way to return to DOS from a COM

;€€€€€€€€ generate a piece of palette
PROC	PaletteGen
	mov	cl,64
	xor	ax,ax
@@1:	mov	[es:si],al
	add	al,bl
	add	si,3
	loop	@@1
	ret
ENDP

Seed	DW	?		;seed for the random-generator
Buffer	DB	34560 DUP(?)
ENDS

END     start