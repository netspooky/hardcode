
;/*
; * GUS baseport setter for Scant 2
; * by Nap/Dilemma         (c) 1999
; */

		.286
code		segment
		assume	cs:code,ds:code
		org	100h

start:		
		mov	ax,3d02h
		lea	dx,f
		int	21h
		jnc	openisok
		mov	ah,9
		lea	dx,error
		int	21h
		mov	ah,4ch
		int	21h
openisok:	mov	bx,ax
		mov	ax,4200h
		xor	cx,cx
		mov	dx,302h
		int	21h
		mov	ax,3f00h
		mov	cx,1
		lea	dx,b
		int	21h
		mov	al,b
		sub	al,3
		shr	al,4
		add	al,'0'
		mov	oldbase[25],al
		pusha
		lea	dx,oldbase
		mov	ah,9
		int	21h
		lea	dx,newbase
		mov	ah,9
		int	21h
		xor	ah,ah
		int	16h
		sub	al,'0'
		shl	al,4
		add	al,3
		mov	b,al
		popa
		mov	ax,4200h
		xor	cx,cx
		mov	dx,302h
		int	21h
		mov	ax,4000h
		mov	cx,1
		lea	dx,b
		int	21h
		mov	ah,4ch
		int	21h

error		db	'Unable to open ''scant2.com''$'
oldbase		db	'GUS baseport in Scant2: 2x0h',13,10,'$'
newbase		db	'Give me the baseport of your GUS (2x0):$'
f		db	'scant2.com', 0
b		db	?

code		ends
		end	start
