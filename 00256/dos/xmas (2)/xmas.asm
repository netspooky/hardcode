; A quick entry for the Xmas compo 2001-2002, by Bonz
; I wanted to stuff more than this, but the wormie
; was bigger than I hoped it to be... and I was in a hurry
; as well.  Well, at least it was fun...
;
; Gee, I don't have any hope to compete with the 3D
; they showed at Demobit... who cares... :-)
;
; assemble with nasm

%define var(x)	[byte bp+x-$$]

	org	100h

	add	dh, 10h		; Setup a data area
	mov	ds, dx		; after the stack (DX=CS)
	mov	es, dx

	mov	al, 13h		; Set 320x200x256
	int	10h

	push	si		; Save 100h
	mov	al, 10h
	mov	dx, 03c8h	; Set DAC address register to 0
	out	dx, al
	inc	dx

palette:			; AH = counter, AL = 0
	out	dx, al		; Output 0 red
	out	dx, al		; and 0 green
	push	ax
	shr	ax, 10		; Set AL = 0..31
	out	dx, al		; And output blue
	pop	ax
	add	ah, 2		; Do 256/2=128 iterations
	jnc	palette		; until we overflow AH

	mov	bh, 0fah	; Point BX to off-screen area
	mov	di, bx		; And DI too
	mov	ch, 2		; CX = 767

sine:				; Construct a 767-entries sine table
	mov	ax, di		; AX = sign extended (-128..127) value
	cbw

	mov	si, ax
	imul	si, si		; SI = x^2

	mov	bp, 16341	; BP = 16341 - x^2
	sub	bp, si
	shr	si, 1
	add	si, 10291	; SI = 10291 + x^2/2
	imul	bp		; DX:AX = x (16341 - x^2)
	idiv	si		; divide -- sine (-63..63) in AX
	add	al, 63+10h	; Turn the range to 16..142
	stosb			; Store AL
	loop	sine
	
	pop	bp		; Get back BP=100h
	
frame:
	xor	di, di		; Start from top of VRAM

line:
	mov	si, ax		; Save AX
	xlatb			; Compute sin(AL) = sin (y + 2t)
	mov	ah, bh		; Add base of sine table
	xchg	si, ax		; Put it in SI, get back old AX
	inc	ax		; Adjust for next line

	mov	cl, 160
	rep	movsw		; Draw sin (x + sin (y + 2t))
	cmp	di, bx		; Done 200 lines?
	jb	line		; No, go on

	add	al, 1-200	; Adjust AL for next frame

	pusha		; Save registers for wormie
	mov	bl, 80h

	push	dword var(worm1x)
	push	dword var(worm2x)
	mov	cl, 80
	
wormie:
	mov	dl, [byte bx+0]
worm2x	equ	$-1
	mov	al, [byte bx+27]
worm2y	equ	$-1
	shr	dl, 2
	shr	al, 1
	cbw
	add	dl, [byte bx+34]
worm1x	equ	$-1
	add	al, [byte bx+58]
worm1y	equ	$-1

	imul	di, ax, 320
	mov	dh, 0
	add	di, dx
	add	di, dx
	
	sub	di, 5801
	mov	si, bitmap
	mov	dl, 5
noplot:
	inc	di
pixel:
	ss lodsb
	dec	al
	js	newline
	jz	noplot
	stosb
	jmp	short pixel
newline:
	add	di, 314
	dec	dx
	jnz	pixel
	
	call	update
	loop wormie

	pop	dword var(worm2x)	; CS = SS!
	pop	dword var(worm1x)
	call	update
	
	push	es		; Copy to screen
	mov	ch, 0a0h	; Set ES=VRAM
	mov	es, cx
	xor	si, si
	xor	di, di
	rep	movsw	; Blit 40960 words (too many)
	pop	es		; Restore old ES

	mov	ah, 1		; Key pressed?
	int	16h
	mov	ah, 11		; (wait for vertical retrace!)
	int	10h
	popa			; Get back registers for sine
	jz	near frame		; No, next frame

	mov	ax, 3		; Back to text mode
	int	10h

	; Using ADC makes the wormie much more interesting
	
update:
	add	byte var(worm1x), 2	; CS=SS!
	adc	byte var(worm1y), 3
	adc	byte var(worm2x), 14
	adc	byte var(worm2y), 3
	ret

bitmap:
	db	1, 5, 5, 5, 5,1,0
	db	13,13,13,13,13,16,0
	db	13,13,13,13,13,16,0
	db	13,13,13,13,13,16,0
	db	1,16,16,16,16,1,0
