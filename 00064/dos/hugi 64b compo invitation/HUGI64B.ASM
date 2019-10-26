	page	240, 132
;Hugi64b.asm	23-Oct-2006	Boreal		loren_blaney@idcomm.com
;Hugi 64b Compo Invitation. Run in 80-column mode. Runs as infinite loop
; (i.e: hit Alt+Enter under Windows, or hit Ctrl+Alt+Del under pure DOS.)
;Assemble with: tasm /m; tlink /t

	.486
cseg	segment dword public use16 'code'
	assume	cs:cseg, ds:cseg, es:cseg, ss:cseg

	org	100h
start:
@@00:	mov	ax, 1130h	;get font table location
	mov	bh, 03h		;8x8 font
	int	10h		;es:bp:= seg:off of font table

;Register usage:
; ax = character to display, and scratch
; bx = index into font table
; cx = scan lines per character counter
; dl = dots per byte counter (8)
; dh = font byte (8 horizontal dots of font data)
; si = pointer to next character in string
; di = screen pointer
; bp = pointer to font table (FontOff)
; es = seg addr of font table (FontSeg), and screen segment (B800h)
; ds = seg addr of string

;(ch=0)
	mov	cl, 8		;for 8 scan lines in font; for J:= 0, FontHeight
@@10:	mov	si, offset string ;point to string
@@20:	lodsb			;fetch character from string; al:= ds:[si++]

;Byte:= Peek(FontSeg,  FontOff + Ch*FontHeight + J);
	mov	dl, 8		;for 8 dots of font width...
	mul	dl		;character*8; ax:= al*dl
	add	ax, bp		; + offset to font table (+ J)
	xchg	bx, ax		;set up index register
	mov	dh, es:[bx]	;get font byte from table (es = FontSeg)

	push	es		;save FontSeg
	push	0B800h		;point to screen instead
	pop	es

	mov	ah, 4Ah		;color attribute: bright green on red (Xmas)
@@30:	shl	dh, 1		;test font bit by moving it into carry flag
	db	0D6h		;salc: al:= 00 or FF depending on carry
	and	al, 08h		;set character, either 08 or 00
	stosw			;write it to screen; es:[di++]:= ax
	dec	dx		;(dh=0 when dl=0)
	jne	@@30		;loop for 8 dots of font width

	pop	es		;restore FontSeg

	cmp	bx, bp		;zero-byte string terminator reached?
	jne	@@20		;loop if not

	inc	bp		;next scan line down
	loop	@@10		;loop for 8 scan lines

	add	di, 180		;magic number to scroll screen
	jmp	@@00		;loop forever...
	nop			;future expansion

string	db	' Hugi 64b', 0	;banner string (must be 9 chars + 0)

cseg	ends
	end	start
