	page	240, 132
;XmasPong.asm	07-JAN-2002	Boreal/6502
;Rolling ball demo for the 2001 256b X-Mas Compo
;loren_blaney@idcomm.com
;
;Greetz to shr/Mnemonic, insomniac, and all 256b coders!
; ...and yes, I did steal from loveC's Galileo. Thanx!
;
;Assemble with:
; tasm /m xmaspong
; tlink /t xmaspong

debug	equ	0			;required for Turbo Debugger etc.
radius	equ	50			;radius of ball (in horizontal pixels)
Image	equ	3DAh			;64000-byte buffer for copy of screen
					; = I/O address of VGA status register
	.model	tiny
	.code
	.486
	org	100h

start:	loop	bb00			;skip variables accessable via [si]
Vx	dw	2			;X-direction velocity
R1	dw	radius/2		;horz radius (= double rotation speed)
R2	db	320-2*radius-10		;horizontal limit(s) (adj paddle posn.)

Vy	dw	-1			;Y-direction velocity
R3	dw	radius*5/6		;radius (in horizontal pixels)
R4	db	200-2*(radius*5/6)	;vertical limit(s)

aspect	dd	1.2	;6.0 / 5.0	;correction factor for aspect ratio
	org	$-4			;overwrite LSBs aspect to save space
rRadius2 dw	radius*radius -38	;radius squared (tweaked for highlight)
	org	$+2
bb00:

	if	debug			;initialize registers like DOS loader
	xor	ax, ax
	xor	bx, bx
	mov	cx, 00FEh	;00FFh
	mov	dx, cs
	mov	si, 0100h
	mov	di, -2
	mov	bp, 095Ah
	cld
	endif
;ax=0, bx=0, cx=00FEh, dx=cs, si=0100h, di=-2, bp=09xxh, sp=-2,
;df=0, [FFFEh]=0, [0]=CDh [1]=20h

;(ah=0)
	mov	al,13h			;call BIOS to set graphic mode 13h
	int	10h			; 320x200 with 256 colors

;Set up color registers with red, green and blue gradients
; blue	00h-1Dh
; varies 1Eh
; white	1Fh
; red	20h-3Fh and 40h-7Fh
; green	80h-BFh and C0h-FFh

	mov	al, 20h			;start right after bright white (=1Fh)
	mov	dx, 3C8h
	out	dx, al
	inc	dx

;(ax=10h, bx=0, cx=00FEh)
bb10:	out	dx, al			;red
	xchg	ax, bx			;get a zero
	out	dx, al			;green
	out	dx, al			;blue
	xchg	ax, bx
	inc	ax
	and	al, 7Fh			;switch from red to green at al=80h
	jne	bb15			;switch from green to blue second time
	 out	dx, al			;third time gives some blue up to 1Eh
bb15:	loop	bb10			;loop 254 times; cx--


;Coordinates of center of ball
; bx = X
; bp = Y
;(bh=0)
	mov	bl, 200-radius		;start it in the middle somewhere
	mov	bp, bx

	fninit				;initialize math coprocessor (FPU)
	fldz				;reference point used for stripe
	fld1				;unit vector straight back into screen
	fldz				;Px=0, Pz=1, Py=0

; - - - - - - - - - - - - - - - - Main Loop - - - - - - - - - - - - - - - - - - 

mainL:	mov	di, offset Image	;setup for Image buffer
	push	di			;save Image address for later
	push	ds
	pop	es

;Draw ball with background
; for cx:= 200 downto 1 do
;  Qy:= Float(cx-bp) * Aspect;
;(cx=0, si=0100h)
	mov	cl, 200
drw20:	mov	[si], cx		;Px, Pz, Py
	sub	[si], bp
	fild	word ptr [si]
	fmul	dword ptr [si+aspect-start] ;Px, Pz, Py, Qy
	fld	st
	fmul	st, st			;Px, Pz, Py, Qy, Qy^2

;  for dx:= 320 downto 1 do
;   Qx:= Float(dx-bx);
	mov	dx, 320
drw30:	mov	[si], dx		;Px, Pz, Py, Qy, Qy^2
	sub	[si], bx

	fild	word ptr [si]		;Px, Pz, Py, Qy, Qy^2, Qx
	fld	st
	fmul	st, st			;Px, Pz, Py, Qy, Qy^2, Qx, Qx^2

;   T:= Radius2 - (Qx*Qx + Qy*Qy);
	fadd	st, st(2)
	fisubr	word ptr [si+rRadius2-start]	;Px, Pz, Py, Qy, Qy^2, Qx, T

;Draw paddle when abs(cx-bp) <= radius
	lea	ax, [bp+radius]
	sub	ax, cx
	cmp	al, 2*radius
	mov	ax, dx
	ja	drw40

; and when dx >= 320 - (bx - (268-radius)); when dx >= 588-radius - bx
	add	ax, bx
	cmp	ax, 588-radius-20	;(fudge factor empirically derived)
	jb	drw42
	db	0D6h			;undocumented salc instruction; al:= 0
	jmp	drw50
drw40	equ	$-1

;Horizontal scrolling plaid
	add	ax, bx			;X
	org	$-2
	db	0C3h			;squeeze out a byte
drw42:	xor	al, cl
drw50:
	and	al, 11011100b		;darken background, eliminate white line

;   if T >= 0.0 then ... Qx,Qy is inside circle
	fist	word ptr [si]		;(negative overflow is stored as 8000h)
	dec	word ptr [si]
	jl	drw70			;jump if T <= 0.0; (js won't work)

;    Qz:= Sqrt(T);	\Qz = height of point Qx,Qy above screen
	fsqrt				;Px, Pz, Py, Qy, Qy^2, Qx, Qz

;    Color:= Fix(Qz) + 14+64;
	mov	al, 1Fh			;assume bright white highlight
	fist	word ptr [si]
	cmp	byte ptr [si], radius	;compare Qz to radius
	jge	drw60			;jump if highlight

;    Dot-product formula gives projection of Q vector along P vector
;    if abs(Px*Qx + Py*Qy + Pz*Qz) < 16.0 then C:= C + 48;    \stripe
	fmul	st, st(5)		;Px, Pz, Py, Qy, Qy^2, Qx, Qz*Pz
	mov	al, [si]		;get Qz
	fld	st(3)			;Px, Pz, Py, Qy, Qy^2, Qx, Qz*Pz, Qy
	fmul	st, st(5)		;Px, Pz, Py, Qy, Qy^2, Qx, Qz*Pz, Qy*Py
	add	al, 14+64		;add adjustment for color intensity
	fadd				;Px, Pz, Py, Qy, Qy^2, Qx, Qz*Pz+Qy*Py
	fld	st(1)			;Px, Pz, Py, Qy, Qy^2, Qx, Qz*Pz+Qy*Py, Qx
	fmul	st, st(7)		;Px, Pz, Py, Qy, Qy^2, Qx, Qz*Pz+Qy*Py, Qx*Px
	fadd				;Px, Pz, Py, Qy, Qy^2, Qx, Qz*Pz+Qy*Py+Qx*Px
	fabs

	fist	word ptr [si]		;get abs(Qz*Pz+Qy*Py+Qx*Px)
	cmp	word ptr [si], 16	;compare it to stripe width
	jge	drw60
	 add	al, 48+64		;make stripe a green gradient
drw60:
;    Screen(cx, dx):= Color;
drw70:	stosb				;es:[di++]:= al

	fcompp				;Px, Pz, Py, Qy, Qy^2; drop two items
	dec	dx
	jne	drw30

	fcompp				;Px, Pz, Py; drop two items
	loop	drw20

;Move ball (centered at bx=X, bp=Y)
;(cx=0)
	pop	dx			;get Image address (= 3DAh, used later)
	push	si
	lodsw				;si:= 102h
mov10:	fild	word ptr [si]		;Px, Pz, Py, Vx

	mov	di, bx			;X
	lodsw				;Vx
	add	di, ax			;X+Vx
	fidiv	word ptr [si]		;Px, Pz, Py, Vx/R
	lodsw				;ax=R; (ah=0!)
	sub	di, ax
	lodsb				;al=320-2*R
	cmp	di, ax
	jb	mov20
	 neg	word ptr [si-5]		;Vx:= -Vx
mov20:	add	bx, [si-5]		;X:= X+Vx
;Rotate vector P using rotation formula (difference equations accumulate error)
	fsincos				;Px, Pz, Py, sin, cos
	fld	st(1)			;Px, Pz, Py, sin, cos, sin
	fmul	st, st(4)		;Px, Pz, Py, sin, cos, Pz*sin
	fld	st(1)			;Px, Pz, Py, sin, cos, Pz*sin, cos
	fmul	st, st(6)		;Px, Pz, Py, sin, cos, Pz*sin, Px*cos
	fadd				;Px, Pz, Py, sin, cos, Pz*sin+Px*cos
	fxch	st(5)			;Px*cos+Pz*sin, Pz, Py, sin, cos, Px

	fmulp	st(2), st		;Px, Pz, Py, Px*sin, cos
	fmulp	st(3), st		;Px, Pz*cos, Py, Px*sin
	fsubp	st(2), st		;Px, Pz*cos-Px*sin, Py

	fxch	st(2)			;Py, Pz, Px
	xchg	bx, bp			;exchange X and Y axes
	dec	cx
	jp	mov10			;jump if parity of cl is even (loop 2x)
					;Px, Pz, Py
;Wait for vertical blank--to regulate speed
;(dx=3DAh)
wait1:	in	al, dx
	test	al, 08h			;test sync bit and also clear ah
	je	wait1

;Copy Image to video screen (takes about 5ms--outruns video beam--no glitches!)
	mov	ch, 64000/2/256		;cl = don't care
	mov	si, dx			;si:= offset Image
	xor	di, di
	push	0A000h			;point es to video ram
	pop	es
	rep movsw			;es:[di++]:= ds:[si++]; cx--
	pop	si
;(si=100h)

;Exit program if Esc key is down
;(ah=0)
	in	al, 60h			;read scan code from keyboard controller
	dec	ax			;Esc scan code = 01h when held down
	jne	mainL
;(ax=0)
	mov	al, 03h			;restore normal text display
	int	10h
	ret

	end	start
