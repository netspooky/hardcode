; Amiga, isn't it? -- by Bonz
;
; This is a bouncing sphere with an animated texture map, resembling the
; original Amiga effect that stunned everybody at the time. Ahem, let's
; put things straight, this is not a real sphere -- the formula is that
; of the lens effect.  Though I like the result, I wrote this just to do
; a 256b intro in 16 color modes before anyone forgets how to program
; them :-)
;
; Everything is done in hardware: the animation is flicker-free thanks to
; bitplane animation (you toggle which planes are visible with register
; 12h@3c0h, and draw only on the opposite ones with register 2@3c4h), the
; scrolling uses the start offset (0ch@3d4h and 0dh@3d4h) and pixel panning
; (13h@3c0h) registers.  I use Write Mode 2, which is set with register
; 5@3ceh: the color comes from the written data, while the bitmask register
; 8@3d4h decides which pixels are affected.  Tnx to Boreal who taught me
; the Color Plane Enable register and bitplane animation!
;
; The only program ever (I think) to use all of JPE, SALC and XADD (which
; BTW makes it require a 486).  Does exactly 12994 square roots per frame.


	org	100h

	mov	al, 12h
	mov	dx, 1306h		;9830h>>3 (9830h is close enough to VRAM)
color:	int	10h
	mov	bl, dl			;color index
	mov	bh, 63			;white
	mov	ax, 1000h		;set EGA palette function
	shl	dx, 1			;set color indices 0110 and 1100
	jns	color

	mov	ds, dx			;point DS to (just before) VRAM

	push	byte -100		;create data area on the stack: origin
	push	byte -120
	push	byte 2			;and direction
	push	byte -2
	
	mov	bl, 6			;BX = mask for Color Plane Enable
;	xor	cx, cx			;don't care about a little flicker on the
;	xor	si, si			;first frame (I got bored optimizing ;-)
frame:

	mov	dx, 03DAh
 	in      al,dx			;also clear flip flop
	test	al,01h			;test display disable
	jnz	frame

	mov	dl, 0C0h		;select Attribute Controller
	mov	al, 33h			;13h + Palette Address Source (PAS) bit
	out	dx, al
	xchg	ax, si			;write the horizontal panning
	and	al, 7
	out	dx, al
	mov	al, 32h			;12h + Palette Address Source (PAS) bit
	out	dx, al
	xchg	ax, bx			;now write the mask
	out	dx, al

	xor	al, 6^12		;complemented mask
	mov	bx, ax			;put it back in BX
	mov	dl, 0C4h		;Sequencer Map Mask register
	mov	ah, al
	mov	al, 2			;enable the invisible planes for writing
	out	dx, ax

	mov	dl, 0D4h		;CRT controller
	mov	al, 13
	mov	ah, cl
	out	dx, ax			;start address low
	dec	ax
	mov	ah, ch
	out	dx, ax			;start address high

	mov	dl, 0CEh		;Mode register
	mov	ax, 0205h
	out	dx, ax			;select "write mode 2"

	inc	di			;increment frame number
	push	di			;and push it on the stack

	mov	di, 8+(0a0000h-98300h)	;set up top-left corner of the screen
	mov	si, -63			;sphere Y
	mov	ax, 127			;initial X^2 = 4096 - Y^2
	mov	dx, 125			;initial delta between squares
	
line:
	push	ax			;update AX and compute square root in CX
	call	update
	pop	cx			;square root is leftmost x value
	jcxz	done			;end if no pixels to be drawn

	pusha
	mov	ax, 4096		;initial Z^2 = 8192 - x^2 - (4096-x^2)

	mov	dx, cx 
	add	dx, dx			;draw from -CX to CX-1 (2*CX pixels)
	push	dx			;save no. of pixels to draw
	dec	dx			;the first delta for Z values is 2*CX-1
	mov	bx, 8008h		;prepare bitmask register
	rol	bh, cl
	dec	cx
	shr	cx, 3			;and compute offset into DI too
	sub	di, cx
	pop	cx			;no. of pixels to draw in CX

pixel:
	push	ax			;update AX and compute square root in SI
	call	update
	pop	si

	;; STACK LAYOUT
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;
	;;  ORIGIN X	   BP+28	FFFC
	;;  ORIGIN Y	   BP+26	FFFA
	;;  DX		   BP+24	FFF8
	;;  DY		   BP+22	FFF6
	;;  FRAME NUMBER   BP+20	FFF4
	;;  AX		   BP+18
	;;  CX		   BP+16
	;;  DX		   BP+14
	;;  BX		   BP+12
	;;  SP		   BP+10
	;;  BP		   BP+8
	;;  SI		   BP+6
	;;  DI		   BP+4
	;;  (parameter)    BP+2		<--- these two could be overwritten
	;;  (stack return) BP+0		<--- by now (who cares)

	pusha
	xchg	ax, bx			;Set bitmask register
	mov	dx, 3ceh
	out	dx, ax

	mov	ax, [bp+16]		;sphere X is in old CX
	shl	ax, 6
	cwd
	idiv	si			;texture X = 64*X/Z in BX
	add	ax, [bp+20]		;add frame number
	xchg	bx, ax			;frame number in AX

	mov	ax, [bp+6]		;sphere Y is from old SI
	shl	ax, 6
	cwd
	idiv	si			;texture Y = 64*Y/Z in AX
	add	ax, [bp+20]		;add frame number

	xor	ax, bx			;compute checker pattern
	shr	al, 5			;from (x^y) & 32
	salc				;write with colors 4-15, but the Map Mask
	or	al, 4			;register changes them to 4-6 or 4-12!

	xchg	al, [di]		;read to latch other bits, write new bit
	popa
	dec	word [bp+16]		;modify sphere X
	ror	bh, 1			;update bitmask
	adc	di, byte 0		;and pass to next byte if necessary
	loop	pixel

	popa
	add	di, byte 80		;next screen line
	inc	si			;update sphere Y
	jmp	short line		;and go on

done:
	mov	cx, -348		;maximum allowable Y value
bounce:
	xchg	si, ax			;second time, save Y value in SI
	mov	ax, [bp+8]
	cwd				;if delta>0, limit coordinate to 0
	and	cx, dx			;else to the value in CX
	xadd	[bp+12], ax		;old Y in AX, new in [bp+12]
	cmp	ax, cx			;limit reached?
	jne	short ok
	neg	word [bp+8]		;yes, invert movement
ok:
	mov	cx, -498		;second time, do the X
	dec	bp
	dec	bp
	jpe	bounce			;loop twice

	push	ax			;push top X (for smooth scroll)
	imul	cx, si, byte 80		;top address in CX
	sar	ax, 3
	add	cx, ax
	pop	si			;pop top X into SI
	
	pop	di			;get back frame number
	
	mov	ah, 1			;key pressed?
	int	16h
	jz	near frame		;if not, another frame
	mov	ax, 3			;else back to text mode
	int	10h
	int	20h
	
update:
	add	ax, dx			;compute next square
	dec	dx			;decrement delta to next odd number
	dec	dx
	mov	bp, sp
	fild	word [bp+2]
	fsqrt
	fistp	word [bp+2]
	ret
