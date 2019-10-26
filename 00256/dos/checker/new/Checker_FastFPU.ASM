; Coded by Frederic Condolo
; fcondolo@yahoo.com
;
; Compiled with nasmw (nasmw Checker.asm -s -t -O0 -oChecker.com)

[org 100h]
[segment .text]

SCREEN_X_CENTER	equ	160
FX_HEIGHT		equ	160
SCREEN_ADRS		equ	204h
YSTART			equ	30	

				
START
									; Initialize video mode (1 byte per pixel, palletized)
	mov				al,13h
	int				10h

											; Transfer video memory segment to es register
	push	word	0A000h
	pop				es

	mov				si, START
	finit									; init FPU


	xor				al,al
	mov				cx,256					; 256 colors
PALETTE_LOOP								; For each color
	mov				dx,3C8h					; Palette register
	out				dx,al					; Color index
	inc				dx
	push			ax	

	shr				al,2
	out				dx,al					; Set red
	out				dx,al					; Set green
	out				dx,al					; Set blue
		
	pop				ax
	
	inc				al	
	loop			PALETTE_LOOP


	mov		word	[si+12], 400
	mov		word	[si+14], 160
	
	fild	word	[si+12]					; st0 = SCALE
	fild	word	[si+14]					; st0 = z (FOCALE), st1 = SCALE
	fmul			st0,st0					; st0 = z*z, st1 = SCALE
	
	
MAIN_LOOP	
	mov				si, SCREEN_ADRS
	mov				di, si

	mov				ch,(320*200)/(256*4)
BLUR
	shr				dword [di],1
	and				dword [di],0x7f7f7f7f
	add				di,4
	loop			BLUR

	mov				di, SCREEN_ADRS + 15*320

	mov				si, START

	add		word	[si+8], 2			; HORIZONTAL SPEED
	add		word	[si+16], 2			; VERTICAL SPEED

	; EYE calculation (eye height) + XOFS + ZOFS
	fild	word	[si+16]				; st0 = eye, st1 = z*z, st2 = SCALE
	fdiv			st0, st2			; st0 = eye/scale, st1 = z*z, st2 = SCALE
	fsincos								; st0 = cos(eye/scale), st1 = sin(eye/scale), st2 = z*z, st3 = SCALE
	fmul			st0, st3			; st0 = SCALE*eye/scale = EYE, st1 = z*z, st2 = SCALE
	fistp	word	[si+6]
	fmul			st0, st2			; st0 = SCALE*eye/scale = EYE, st1 = z*z, st2 = SCALE
	fistp	word	[si+10]
	
	fild	word	[si+8]				; st0 = eye, st1 = z*z, st2 = SCALE
	fdiv			st0, st2			; st0 = eye/scale, st1 = z*z, st2 = SCALE
	fsin								; st0 = cos(eye/scale), st1 = sin(eye/scale), st2 = z*z, st3 = SCALE
	fmul			st0, st2			; st0 = SCALE*eye/scale = EYE, st1 = z*z, st2 = SCALE
	mov				cx, YSTART			; init for Y loop

Y_LOOP
	mov				bx, -160			; clear start x
	mov		word	[si], cx			; y
	fild	word	[si]				; st0 = y, st1 = EYE, st2 = z*z, st3 = SCALE

	fmul			st0, st0			; st0 = y*y, st1 = EYE, st2 = z*z, st3 = SCALE
	

X_LOOP
	; Get vector length
	mov		word	[si], bx			; x
	fild	word	[si]				; st0 = x, st1 = y*y, st2 = EYE, st3 = z*z, st4 = SCALE
	fmul			st0, st0			; st0 = x*x, st1 = y*y, st2 = EYE, st3 = z*z, st4 = SCALE
	fadd			st0, st1			; st0 = x*x + y*y, st1 = y*y, st2 = EYE, st3 = z*z, st4 = SCALE
	fadd			st0, st3			; st0 = x*x + y*y + z*z, st1 = y*y, st2 = EYE, st3 = z*z, st4 = SCALE
	fsqrt								; st0 = vector len, st1 = y*y, st2 = EYE, st3 = z*z, st4 = SCALE

	; Normalize x
	fild	word	[si]				; st0 = x, st1 = vector len, st2 = y*y, st3 = EYE, st4 = z*z, st5 = SCALE
	fdiv			st0, st1			; st0 = normalized x, st1 = vector len, st2 = y*y, st3 = EYE, st4 = z*z, st5 = SCALE
	
	; Normalize y
	mov		word	[si], cx			; y
	fild	word	[si]				; st0 = y, st1 = normalized x, st2 = vector len, st3 = y*y, st4 = EYE, st5 = z*z, st6 = SCALE
	fdiv			st0, st2			; st0 = normalized y, st1 = normalized x, st2 = vector len, st3 = y*y, st4 = EYE, st5 = z*z, st6 = SCALE

	; Determine distance to plane (k) = ray-length to plane
	fld				st4					; st0 = EYE, st1 = normalized y, st2 = normalized x, st3 = vector len, st4 = y*y, st5 = EYE, st6 = z*z, st7 = SCALE
	fsub			st0, st3			; THIS is the instruction that generates the deformation: Modulate ray length with dist to plane
	fdiv			st0, st1			; st0 = k, st1 = normalized y, st2 = normalized x, st3 = vector len, st4 = y*y, st5 = EYE, st6 = z*z, st7 = SCALE
	fxch			st0, st1			; st0 = normalized y, st1 = k, st2 = normalized x, st3 = vector len, st4 = y*y, st5 = EYE, st6 = z*z, st7 = SCALE
	; Migth be a better way to get rid of st0 than the below instruction...
	fstp	dword	[si]				; st0 = k, st1 = normalized x, st2 = vector len, st3 = y*y, st4 = EYE, st5 = z*z, st6 = SCALE
	
	
	; Normalize Z
	fild	word	[si+14]				; st0 = z, st1 = k, st2 = normalized x, st3 = vector len, st4 = y*y, st5 = EYE, st6 = z*z, st7 = SCALE
	fdiv			st0, st3			; st0 = normalized z, st1 = k, st2 = normalized x, st3 = vector len, st4 = y*y, st5 = EYE, st6 = z*z, st7 = SCALE

	; Calculate x at plane intersection
	fxch			st0, st2			; st0 = normalized x, st1 = k, st2 = normalized z, st3 = vector len, st4 = y*y, st5 = EYE, st6 = z*z, st7 = SCALE
	fmul			st0, st1			; st0 = k*normalized x, st1 = k, st2 = normalized z, st3 = vector len, st4 = y*y, st5 = EYE, st6 = z*z, st7 = SCALE
	fistp	word	[si+2]				; st0 = k, st1 = normalized z, st2 = vector len, st3 = y*y, st4 = EYE, st5 = z*z, st6 = SCALE
	
	; Calculate z at plane intersection
	fxch			st0, st1			; st0 = normalized z, st1 = k, st2 = vector len, st3 = y*y, st4 = EYE, st5 = z*z, st6 = SCALE
	fmul			st0, st1			; st0 = k*normalized z, st1 = k, st2 = vector len, st3 = y*y, st4 = EYE, st5 = z*z, st6 = SCALE
	fistp	word	[si+4]				; st0 = k, st1 = vector len, st2 = y*y, st3 = EYE, st4 = z*z, st5 = SCALE


	mov		word	dx, [si+2]			; Projected X	
	add		word	dx, [si+10]			; X SCROLLING
	mov		word	ax, dx
	mov		word	dx, [si+4]			; Projected Z
	shr				al,1
	sub		word	dx, [si+6]			; Z SCROLLING
	shr				dl,1
	xor				al, dl				; Xor pattern (texture generation)
	add		byte	[di],al

	inc				bx						; X loop
	inc				di

	; get rid of st0, st1
	fstp	dword	[si]				; st0 = vector len, st1 = y*y, st2 = EYE, st3 = z*z, st4 = SCALE
	fstp	dword	[si]				; st0 = y*y, st1 = EYE, st2 = z*z, st3 = SCALE

	cmp				bx, 160
	jl				X_LOOP

	; get rid of st0
	fstp	dword	[si]				; st1 = EYE, st2 = z*z, st3 = SCALE

	inc				cx					; Y loop
	cmp				cx,200
	jl				Y_LOOP

	mov				si, SCREEN_ADRS
	xor				di, di
	mov				cx,64000/4
	rep				movsd

	
	fistp	word	[si]				; st0 = SCALE

	
	xor ah, ah											; Test ESC key	
	in	al,60h
	dec	ax
	jnz	 MAIN_LOOP
		
	ret

	

