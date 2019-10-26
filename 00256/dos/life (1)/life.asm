; Roto-life (rotozooming game of life, with blur -- in 256 bytes!)
; Game of life algorithms by INT-E
; Decyphering and adaptation of game of life, and everything else by Bonz

	org	100h

; The first two lines of the matrix are filled with crap because of the
; algorithm, so we skip them when plotting the cells

NX	equ	512 / 8
NY	equ	272
EXTRA	equ	128 / 8 + NX * 8	; So many bytes are not displayed
CELLS	equ	NX * NY			; Also the origin of cells table

; Constants for the rotozooming table

table		equ	01000h		; Pointer to base of table
tabentries	equ	200h		; Number of entries in the table
tabsize		equ	tabentries * 4	; Size in bytes of table
tabmask	equ	table | (tabsize - 1)	; Mask for addresses in the table

; Macro for referencing FPU constants

work		equ	200h		; Base of work area

%define var(x) word [byte si+x-work]

; Setup video mode and palette -----------------------------------------

	fninit
	mov	al,13h
	int	10h

	; The palette is set to a blue...white gradient with this setup:
	; each bit represents whether the pixel was set 0..7 generations
	; ago: bit 7 is set if a pixel appeared in the most recent generation
	; and decreases the red and green components represents by 8,
	; while bit 0 is set if a pixel appeared 7 generations ago and
	; decreases the components by 1.
	; This allows one to plot a pixel with a simple BT+RCR pair
	; (BT on the game of life matrix, RCR on VRAM)

	mov	dx,03c8h
	xor	ax,ax
	out	dx,al
	inc	dx
setpal:
	mov	al, 63
	jns	setpal2			; SF has sign of AH
	mov	al, 40			; If cell alive, draw it more blue
setpal2:
	mov	cl, 8
bit:
	rol	ah, 1			; extract a bit into carry
	jnc	nodec
	sub	al, cl			; and accumulate the weight
nodec:
	loop	bit
	out	dx, al			; Output red/green
	out	dx, al
	mov	al, 255			; Setting AL=255...
	out	dx, al			; ...is the same as 63 (full blue)...
	inc	ax			; ...but INC AX increments AH!
	jnz	setpal			; Do next color

; Compute sines and cosines ------------------------------------------

	mov	ch, tabentries >> 8	; 256 entries in the table
	mov	di, table		; Pointer to base of table
%if tabentries == work
	mov	si, cx			; Pointer to base of data
%else
	mov	si, work
%endif

calctab:	
	mov	word [si], cx
	fild	word [si]		; ang
	fldpi				; pi ang
	fmulp	st1			; ang*pi
	fidiv	var(shift)		; ang*pi/128
	fsincos				; sin cos
	fld	st0			; sin cos cos
	call	calc			; sin cos
	call	calc			; sin
	fstp	st0
	loop	calctab

; Main cycle ---------------------------------------------------------

	push	word 0a000h
	pop	fs

frame:
	pusha				; Save CX=0, DI=angle
	mov	bp, CELLS		; number of bytes in the cells matrix
	mov	di, bp			; di=cells matrix
	lea	si, [bp+di]		; si=workspace (at 2*CELLS)

life:
	push	bp			; save count of remaining bytes
	mov	bp,NX * 2		; start with the line below
	mov	al,byte [di+bp]		; Copy screen to buffer for
	mov	byte [si+bp],al		; next line

line:					; WARNING: black magic follows
	mov	ax,[si+bp-NX]		; read 16 cells from buffer
	push	ax
	ror	ax,1			; AX=89ABCDEF 01234567
	rcl	al,1			; -> 789ABCDE 01234567
	call	subtract		; do 16 subtracts in parallel
	pop	ax			; (8 for this byte and 8 for the next)
	rol	ax,1
	mov	ah,0			; -> -------- 12345678
	call	subtract		; do 8 subtracts in parallel
	sub	bp,byte NX
	jns	line			; Work on the three neighboring lines

	; Here is the Karnaugh map for the "cell is alive" function:
	; CBA = ~count of neighbors, X=cell is alive
	;
	;   XC \ BA |  00   01  11  10
	;   ----`---+-------------------
	;    00     |   0    0   0   0
	;    01     |  _0___|1|  0   0     X' = C ~B A + X C ~B
	;    11     | |_1___|1|  0   0        = C ~B (A + X)
	;    10     |   0    0   0   0
	;
	; In the code, AL = X, CL = A, DL = B, BX = C

	lodsb				; Decide destiny of these 8 cells
	or	al, cl			; according to the above formula
	not	dl
	and	al, dl
	and	ax, bx
	stosb				; and store in the cells buffer

	mov	cl, 8			; shift sums by 8 bits
	shr	dx, cl
	shr	bx, cl
	shr	cx, cl

	pop	bp
	dec	bp
	jnz	life			; do NX * NY times
	popa
	
	and	di, tabmask		; Constrain DI in the table
	mov	si, di			; For LODS
	lodsw				; cosine in BP
	xchg	bp, ax
	lodsw				; AX=sine, SI=new angle
	xchg	si, ax			; SI=sine, AX=new angle
	xchg	di, ax			; SI=sine, DI=new angle

	; We don't need to zero out BX and DX because their
	; values are constant across frames

	pusha
	xor	di, di			; Base of VRAM
	mov	ax, 320			; Common value
	mov	cl, 200			; 200 rows
yplot:
	pusha
	xchg	cx,ax			; CX=320
xplot:

	push	bx			; Save Y index
	mov	al, dh			; AL = X index
	mov	bl, al			; Combine Y and X in BX
	and	al, 7			; Isolate bit index in AX
	shr	bl, 1			; Discard it in bx
	shr	bx, 2
	bt	[bx + CELLS+EXTRA], ax	; bx = 00YYYYYYYY0XXXXX
	rcr	byte [fs:di], 1		; Rotate cell status into VRAM
	pop	bx			; Pop Y index
	inc	di			; Next pixel
	add	bx, si			; Update for next column
	add	dx, bp
	loop	xplot			; and draw it

	popa
	add	di, ax			; Next line (AX=320)
	sub	bx, bp			; Update for next line
	add	dx, si
	loop	yplot			; and draw it

	popa
	mov	ah,1			; ESC pressed?
	int	16h
	jz	near frame		; If not, next frame please

	mov	ax,3			; Else back in text mode
	int	10h			; and use the RET from this subroutine

	mov	ah,9
	mov	dx,text
	int	21h
	
	; This routine subtracts the 16 bits in AX from sixteen 3-bit counters
	; spread across CX, DX and BX.
	;
	; First of all, notice that even though 0-9 require 4 bits,
	; we can get by with 3 because 0-1 and 8-9 neighboring cells
	; have the same behavior (i.e. die)
	;
	; The formulas for subtracting X to CBA are very nice:
	;	A' = A ^ X
	;	B' = B ^ (X & ~A)      = B ^ (X & A')
	;	C' = C ^ (X & ~A & ~B) = C ^ (X & A' & ~B) = C ^ (X & A' & B')
	;
	; (X & ~A implies X, but if X then A' = ~A; and similarly,
	; X & ~A & ~B implies X & ~A, but if X & ~A then B' = ~B)

subtract:
	xor	cx,ax			; cx: bit 0 counter
	and	ax,cx
	xor	dx,ax			; dx: bit 1 counter
	and	ax,dx
	xor	bx,ax			; bx: bit 2 counter
	ret

; Compute st1*(cos(angle)*30+50), assuming st0=cos(angle)
; Stack balance: -1

calc:
	fimul	var(scale)		; st1 cos*scale
	fiadd	var(base)		; st1 cos*scale+base
	fmul	st1			; st1 st1*(cos*scale+base)
	fistp	word [di]		; st1
	scasw
	ret

shift:
	dw	tabentries / 2		; values for the math coprocessor
scale:
	dw	30
base:
	dw	60
	
text:
	db	'LIFE!-Bonz$'
