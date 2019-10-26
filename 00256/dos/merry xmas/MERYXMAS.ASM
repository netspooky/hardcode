	page	240, 132
;MERYXMAS.ASM	09-JAN-2002	Boreal/6502
;A Christmas Card for the 2001 256b X-Mas Compo
;loren_blaney@idcomm.com
;
;Seasonz Greetz!
;
;Assemble with:
; tasm /m meryxmas
; tlink /t meryxmas

	.model	tiny
	.code
	.486

;Other registers are assumed to be initialized by the loader, for instance ah
; must be 0. This program will not run under a debugger such as CodeView that
; zeros these registers. It also will not run under FreeDOS which also zeros
; these registers. Standard DOS loaders initialize these registers as follows:
;  ax = 0000
;  bx = 0000
;  cx = 00ff
;  dx = cseg
;  si = 0100
;  di = fffe
;  bp = varies (091c 0912)
;  sp = fffe
;
;The direction flag (d) is clear (incrementing).

	org	100h			;this is a COM file so skip the PSP
xms00:	mov	al, 13h			;call BIOS to set graphic mode 13h
	int	10h			; 320x200 with 256 colors (ah = 0)

	in	al, 61h			;enable speaker and 8254 timer
	push	ax			;save initial state to restore things
	or	al, 03h			; at exit
	out	61h, al			;the beeper is going, shut it off soon

;Windoze (unlike DOS) doesn't bother to set up the speaker port so we do it here
; This also shuts off the beeper (unnecessary because music starts immediately)
	mov	al, 0B6h		;set 8254 control register for counter 2
	out	43h, al			; for mode 3, write low byte high byte

	mov	bp, offset random	;dedicate bp to call Random subroutine

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;Make a forest of triangular trees. The lower left corner of a tree is X0, Y0.
;(ah=0, ch=0, dx=0)
	mov	cl, 15			;number of trees
xmas10:	mov	al, 30			;size:= Ran(30); = 1/2 width, 1/3 height
	pusha				;save ah=0, bx=0, cx, si=100h, di=-2
	call	bp			;random
	xchg	dx, ax			;dx:= size

	mov	ax, 320			;X0:= Ran(Width)
	call	bp			;random
	xchg	bx, ax			;bx:= X0; (bh was 0 thus ah:=0)

	mov	al, 40			;Y0:= Ran(40)+120-40;
	call	bp			;random
	add	al, 120-40		;ax:= Y0; (ah=0)

;Create a table of 3 coordinate pairs (at 100h), for a total of 12 bytes
;	      Y1,X1
;               +
;
;	Y0,X0 +   + Y2,X2
;
xmas15:	mov	[si], ax		;store Y coordinate into table
	cmpsw				;si++; (di++)
	mov	[si], bx		;store X coordinate into table
	add	bx, dx			;X:= X + size
	add	di, dx			;accumulate 3 sizes (+4)
	inc	si
	inc	si			;loop a total of 3 times
	jnp	xmas15			;(only low 8 bits set parity: 0, 1, 2)

	sub	[si-8], di		;fix up coordinate; Y1:= Y1 - (size*3+4)

;Make a tree using the Chaos Game
; bx = X2+size
; ch = 0
; dx = size, used for initial point in tree (close enough to Y0)
	push	0A000h + (40*320/16)	;point to 40th scan line in video ram
	pop	es

	imul	ax, dx, 32		;for Iter:= 1, Ran(Size*32) do...
	call	bp			;random
	xchg	cx, ax			;set loop counter; (ah:=0)

;Randomly select a corner point (selecting in sequence doesn't work)
xmas20:	mov	al, 3*4			;Pnt:= Ran(3*4); (ah=0)
	call	bp			;random
	and	al, 0FCh		;mask for 4 bytes per coordinate
	mov	ah, 1			;set up pointer to table
	xchg	si, ax

;Move halfway toward selected corner point (average the distance)
	lodsw				;ax:= ds:[si++]; (ah:=0)
	add	dx, ax			;YPos:= (YPos + Point.Y(Pnt)) /2
	shr	dx, 1
	add	bx, [si]		;XPos:= (XPos + Point.X(Pnt)) /2
	shr	bx, 1

	imul	di, dx, 320		;PlotPoint(XPos, YPos, 78h)
	mov	byte ptr es:[bx+di], 78h ;a nice shade of (even parity) green

	loop	xmas20			;loop for all pixels in the tree

	popa				;restore ah=0, bx=0, cx, si=100h, di=-2
	loop	xmas10			;loop for all the trees in the forest

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;Music and animation loop (let it snow...let it snow...let it snow...)
	mov	si, offset music	;point to the notes
	cwd				;dx:=0, used much later
;(ah=0, cx=0, dx=0)
xmas50:	not	cx			;skip snow every other pass
	jcxz	xmas79			; (it's not a blizzard)

;for di:= bottom to top...
	mov	di, 320*(160-40)-1-1	;last pixel on last line (-1 for random)
xmas70:	mov	bx, 320-1		;put handy value into bx
	cmp	di, bx			;is di pointing to top (40th) line?
	ja	xmas73			;jump if not
	 mov	al, 20			;(ah=0)
	 call	bp			;randomly generate a snow flake
	 cmp	al, 7			;is it a snow flake? (1 chance in 20)
	 jne	xmas73			;jump if not
	  stosb				;else draw it; es:[di++]:= al
	  dec	di			;undo ++ (and still save a byte)
xmas73:
	cmp	byte ptr es:[di], ah	;is there a snow flake (7) here?
	jp	xmas76			;jump if not, only flakes = even parity
	 mov	al, 3			;randomly pick 1 of 3 places to fall
	 call	bp			;bx:= Ran(3) -1 +320 +di; (ah=0)
	 add	bx, ax
	 cmp	byte ptr es:[bx+di], ah	;is it falling into an empty spot?
	 jne	xmas76			;jump if not
	  xchg	byte ptr es:[di], ah	;erase flake at old position; ah:=7
	  xchg	byte ptr es:[bx+di], ah	;draw flake at new position; ah:=0
xmas76:	dec	di			;loop for all pixels in scene
	jne	xmas70
xmas79:

; si = music (note) pointer
; cx = low / high nibble selector
; dx = timer for note duration (passes)

	dec	si			;backup and re-fetch previous note
	lodsb				;al:= ds:[si++]
	shr	al, 4			;get note from high nibble
	je	snd60			;jump if terminator--leave sound off
					; (al= 1..15, which is inaudiable)
	dec	dx			;check timer for note duration
	jg	snd60			;jump if still sustaining note
;	mov	al, 1			;pause between notes, for attack
	je	snd55			;jump if between notes
					;else get next note
	jcxz	snd51			;jump if cx=0 then use high nibble
	 lodsb				;get note; al:= ds:[si++]
snd51:					;else get note from low nibble
	mov	di, ax			;save copy of note

	and	al, 1			;set up timer for note duration
	inc	ax			;bit 0:  0  1
	shl	ax, 1			;dx:     2  4
	xchg	dx, ax

	and	di, 0Eh			;get note frequency
	mov	ax, [bp+di+pertbl-random] ;look up period (for freq) in table
snd55:	out	42h, al			;set 8254 timer
	shr	ax, 8			;al:=ah; ah:=0
	out	42h, al
snd60:
;Kill some time. (Pure DOS can get away with a single 'hlt' instruction here.)
	pusha				;preserve ah, cx, dx
	mov	ah, 86h			;BIOS Delay routine
	cwd				;delay 65535 microseconds =1/15sec
	xor	cx, cx
	int	15h
	popa

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;Exit program if Esc key is down
	in	al, 60h			;get keyboard scan code
	dec	ax			;test for 01h = Esc key (ah=0)
	jne	xmas50			;loop if Esc key is not down

	mov	al, 03h			;restore 80-column text mode (ah=0)
	int	10h

	pop	ax			;disable speaker and timer
	out	61h, al
;	ret				;return to DOS via int 20h in PSP

;-------------------------------------------------------------------------------
;Return a random number between 0 and the value in ax-1. (ax must be positive.)
;
random:	push	cx			;preserve registers
	push	dx

	cwd				;dx:=0; make dividend + for + remainder
	xchg	cx, ax			;get divisor

	imul	ax, [bp+seed-random], 121 ;seed:= (seed*121 + 1) modulo 65536
	inc	ax			;"Master Class Assembly Language" p 838
	mov	[bp+seed-random], ax

	idiv	cx			;ax:= dx:ax/cx  dx:= remainder
	xchg	ax, dx			;return remainder in ax

	pop	dx			;restore registers
	pop	cx
	ret


;Music Table: 2 notes per byte, low nibble first. The low bit of a nibble deter-
; mines the duration (quarter or eighth note); the high 3 bits select the note.
; "We Wish You a Merry Christmas"
music	db	10010011b 		;D2 G2        2 = 1/4 note; 1 = 1/8 note
	db	10101000b, 01101000b	;G1 A1  G1 F1
	db	01010101b, 10110101b	;E2 E2  E2 A2
	db	11001010b, 10001010b	;A1 B1  A1 G1
	db	00110111b, 11010011b	;F2 D2  D2 B2
	db	11101100b, 10101100b	;B1 C1  B1 A1
	db	01011001b, 00100010b	;G2 E2  D1 D1
	db	10110101b, 10010111b	;E2 A2  F2 G4 (last note should be G8)
;	db	00h			;terminator

;Period table         index/note/freq
pertbl	dw	1	;0  rest note (= very high frequency = inaudiable)
	dw	4063	;1  4D  293.66
	dw	3620	;2  4E  329.63
	dw	3225	;3  4F# 369.99
	dw	3044	;4  4G  392.00
	dw	2712	;5  4A  440.00
	dw	2416	;6  4B  493.88
	dw	2280	;7  5C  523.25

seed	dw	5252h			;(gives a nice arrangement of trees)

	end	xms00			;("xms00" is required by assembler, else
					; org 0 is assumed and .com file is 256
					; bytes larger)
