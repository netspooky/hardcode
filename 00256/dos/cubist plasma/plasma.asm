; Cubist - a little plasma effect by Bonz
; assemble with NASM

; -------------------------------------------------------------------------
; If defined, do not assume CX=0xFFh on startup, and does not set video mode
; %define DEBUG

; If defined, don't set the palette (-39 bytes)
; %define NO_PAL

; If defined, squares don't rotate (-44 bytes)
; %define SIMPLE

; If defined, squares rotate around a vertex rather than the center (+1 byte)
; %define HEADACHE

; -------------------------------------------------------------------------

%ifdef SIMPLE
NX	equ	64			; Number of horizontal blocks
NY	equ	40			; Number of vertical blocks
BLK	equ	5			; Spacing between each block
%else
NX	equ	30			; Number of horizontal blocks
NY	equ	18			; Number of vertical blocks
BLK	equ	10			; Spacing between each block
%endif

_I	equ	-192//NX		; Vertical cosine 1 update per row
_J	equ	2			; Vertical cosine 1 update per frame
_K	equ	320//NX		; Double cosine update per column
_N	equ	128//NX		; Vertical cosine 2 update per row
_O	equ	1			; Vertical cosine 2 update per frame
_L	equ	-192//NX		; Horizontal cosine update per column
_M	equ	3			; Horizontal cosine update per frame

; A few parameters for the plasma.  The bigger they are, the more
; periods are visible on each frame, or the faster the animation is.
; Bigger NX and NY should be compensated with small values of 
; _[IKNL]

%ifdef HEADACHE
ORIGIN	equ	0			; Origin of each square
SIZE	equ	78h			; Scaling factor for the blocks
%else
ORIGIN	equ	-128			; Origin of each square
SIZE	equ	40h			; Scaling factor for the blocks
%endif

INCR	equ	700h / SIZE		; Delta between two points (empiric)

; Initial coordinates and increment between two rows
X0	equ	(320-NX*BLK)/2 + BLK/2
Y0	equ	(200-NY*BLK)/2 + BLK/2
ADV	equ	320*BLK-NX*BLK

; -------------------------------------------------------------------------
; Macro to update the cosine values, exploiting a few constant values
; of the registers

%macro cos_set 2
	mov	byte	[si+%1-vcos1], %2
%endm

%macro cos_upd 2
%if ((%2) & 255) = 2
	add	byte	[si+%1-vcos1], bh
%elif ((%2) & 255) = 3
	add	byte	[si+%1-vcos1], dh
%elif ((-%2) & 255) = 2
	sub	byte	[si+%1-vcos1], bh
%elif ((-%2) & 255) = 3
	sub	byte	[si+%1-vcos1], dh
%else
	add	byte	[si+%1-vcos1], (%2) & 255
%endif
%endm

; Macro to set the individual bytes in a word

%define MAKEWORD(a, b)		((a) * 256) | ((b) & 255)

; set video mode (4 bytes) -------------------------------------------------

	org	100h

%ifdef DEBUG
	mov	cx, 0ffh
%else
	mov	al, 13h
	int	10h
%endif

; compute sine table (31 bytes) --------------------------------------------

	mov	di, sine		; Point DI to beginning of data area
	inc	cx			; CX = 256

sineloop:				; Construct a 256-entries -sine table
	mov	ax, di			; AX = sign extended (-128..127) value
	cbw
	mov	si, ax
	imul	si, si			; SI = x^2
	lea	bp, [si-16341]		; BP = x ^ 2 - 16341
	shr	si, 1			; SI = 10291 + x^2/2
	add	si, 10291
	imul	bp			; DX:AX = x (x^2 - 16341)
	idiv	si			; divide -- negated sine in AX
	sar	al, 1			; Turn range to -31..31
	stosb				; Store AL (CS=ES)
	loop	sineloop		; Until the sine table is full

; set palette (39 bytes) --------------------------------------------------

%ifndef NO_PAL
        mov	dx,3c8h			; DAC address register
	xor	eax, eax
        out	dx, al
	dec	ax			; eax = BGRM (M=marker, R is red-1)
        inc	dx			; DAC data register

	; Meaning of the bytes in EAX:
	;   00h-3fh	Output this
	;   7fh		Output this -- it has already reached 3fh
	;   FFh		Increment the next byte
	;
	; At start, BBGGRRMM = 0000FFFFh; note that only AL acts as a marker
	; because AH -- red -- is incremented to 00h when the LSB is rotated).
	;
	; When we reach MMBBGGRR = FF00003Fh, we XOR the magic value 8000FFC0h
	; and turn it to RRBBGGMM = 7F00FFFFh.  Again, AH -- green -- becomes
	; 00h so it is not a marker.
	;
	; Analogously, MMRRBBGG = FF7F003Fh is turned to GGRRBBMM = 7F7FFFFFh
	; (where again AH -- blue -- becomes 00h).
	;
	; Finally when we reach MMGGRRBB = FF7F7F3Fh, XORing the same value as
	; before gives BBGGRRMM = 7F7F80FFh which we recognize easily because
	; AH is not turned to FFh.
	
setpal:
	ror	eax, 8			; Advance EAX, set carry if marker
	adc	al, 0			; Increment if the marker was there
	js	setpal			; Don't output AL if it is a marker
	out	dx, al
        cmp	al, 63
        jne	setpal
	xor	eax, 08000ffc0h		; See above
	sahf				; Stop when 7fh (red) becomes 80h
        jc	setpal

	mov	al, 3fh			; AX = 803fh
pal3:					; set 64 entries to white -> black
	out	dx, al			; Output 63-0
	out	dx, al
	out	dx, al
	dec	ax
	js	pal3			; Until AX = 7fffh
%endif

frame:
	xchg	cx, ax			; Zero the off-screen buffer (CX=0)
	mov	ch, 320*200/256		; about 320*200 bytes
	mov	di, buffer
	push	di
	rep	stosb

; Do the effect ------------------------------------------------------------
;
; The formula is this:
;
; cos ( cos (i y + j t) + k x ) +       cos (i y + j t) +
;       cos (l x + m t)         +       cos (n y + o t) + t

	mov	di, buffer+320*X0+Y0	; Point DI to center of first square
	mov	si, vcos1 + 2		; Use SI when modifying cosine offsets
	mov	bx, sine+80h		; Point BX to middle of data area
					; BX = 280h
	
	mov	cl, NY			; Number of vertical squares (CH=0)
vplasma:
	mov	bp, NX			; Number of horizontal squares

base:	mov	ah, 0


vcos1:	add	ah, [bx+12]		; cos (i y + j t)
		cos_set	hcos1, ah
vcos2:	add	ah, [bx+34]		; cos (n y + o t)

hplasma:
hcos1:	mov	al, [bx+56]		; cos (k x + cos (i y + j t))
hcos2:	add	al, [bx+78]		; cos (l x +            m t)
	add	al, ah			; combine with the inner cosines

	pusha				; Plot a single square in the plasma
%ifdef SIMPLE
	sub	di, 320*2+2
	mov	cx, 316
	mov	ah, al
	stosw
	stosw
	add	di, cx
	stosw
	stosw
	add	di, cx
	stosw
	stosw
	add	di, cx
	stosw
	stosw
%else
	mov	cx, ax			; Save color in CX

	mov	bl, al			; Point BX to sine
	mov	al, SIZE
	imul	byte [bx]		; size * sin(alpha)
	xchg	si, ax			; in SI
	
	mov	al, SIZE
%if SIZE=40h	
	add	bl, al			; Offset for cosine
%else
	add	bl, 40h
%endif	
	imul	byte [bx]		; size * cos(alpha)
	xchg	cx, ax			; in CX, color back in AX

	; Sine/cosine scale	 = 5 bits	(range is -31..31)
	; Coordinate (X/Y) scale = 7 bits	(range is -128..127)
	;
	; Since the transformation routine discards the bottom 16
	; bits after multiplying a sine/cosine, a coordinate, and
	; the size factor, the number of decimal bits in the size
	; factor is 16-7-5=4.
	;
	; For example, a size factor of 64 means that coordinates
	; go from -4 to 4, and hence that each square has a 
	; side of 8 pixels.
	;
	; Usage of registers:
	;	AL = color
	;	BH = increment between two coordinates
	;	BL = current coordinate value (X or Y)
	;	CX = X coefficient for transformation
	;	SI = Y coefficient for transformation
	;	DI = base offset
	;
	; The transformation matrix is	C -S
	; 				S C
	;
	; or something like that :-) What's important is that the
	; coefficients are exchanged, and one of them is negated.
	
	mov	bx, MAKEWORD(INCR, ORIGIN) ; X in BL, first coordinate in BH
vblock:
	pusha				; Save base address, X and coefficients
	call	trasf			; Combine X contribute into DI
	neg	si
	xchg	si, cx			; Change coefficients to (-sine, cosine)
	mov	bl, ORIGIN		; Y in BL
hblock:
	push	di
	call	trasf			; Combine Y contribute into DI
	stosb				; Draw two adjacent pixels
	stosb
	pop	di
	add	bl, bh			; Next value
	jno	hblock			; Until overflow
	popa				; Restore values
	add	bl, bh			; Next value
	jno	vblock			; Until overflow
%endif

	popa				; Back to plasma code
	cos_upd	hcos1, _K		; update cosines for next square
	cos_upd	hcos2, _L
	add	di, byte BLK
	dec	bp			; do next horizontal square
	jnz	hplasma

	add	di, ADV			; to next line
	
	cos_upd	vcos1, _I		; update vertical cosines for next line
	cos_upd	vcos2, _N
	cos_upd	hcos2, -(NX*_L)	; reset horizontal cosine
	loop	vplasma			; another vertical iteration

	cos_upd	vcos1, -(NY*_I)+_J	; update outer cosines for next frame
	cos_upd	vcos2, -(NY*_N)+_O
	cos_upd	hcos2, _M
	inc	byte [si+(base+1)-(vcos1+2)]

; Scaffolding (blit to VRAM and wait for key) ------------------------------

	mov	ch, 0a0h		; Set ES=VRAM
	mov	es, cx
	pop	si			; Get back origin of off-screen buffer
	xor	di, di
	rep	movsw			; blit 40960 words (a lot :-)
	push	ds			; Restore DS = ES
	pop	es

	mov	ah, 1			; Key pressed?
	int	16h
	mov	ah, 11			; (wait for vertical retrace!)
	int	10h
	jz	near frame		; No, next frame

	mov	ax, 3			; Back to text mode
	int	10h			; uses RET from the TRASF subroutine

%ifndef SIMPLE
trasf:
	push	ax
	movsx	ax, bl			; Get coordinate in AX
	push	ax
	imul	cx			; Sum coordinate*X coefficient
	add	di, dx
	pop	ax
	imul	si			; Sum coordinate*Y coefficient*320
	imul	dx, 320
	add	di, dx
	pop	ax
%endif
	ret

; memory map:
;  0000-00ff	PSP
;  0100-01ff	program
;  0200-02ff	sine table
;  0300-043f	extra line at the top of the off-screen buffer
;  0440-fe3f	off-screen buffer
;  fe40-ff7f	extra line at the end of the off-screen buffer
;  ff80-ffff	stack

sine	equ	$$ + 100h
buffer	equ	$$ + 340h
