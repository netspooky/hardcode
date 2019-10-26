; Coded by Frederic Condolo
; fcondolo@yahoo.com
;
; Compiled with nasmw (nasmw Vinyl.asm -s -t -O0 -oVinyl.com)

[org 100h]
[segment .text]
SCREEN_ADRS		equ	204h


; CIRCLE CENTER STRUCTURE
OFFSET			equ 0						; angle input for cosinus & sinus
X_SCREEN		equ 2						; computed screen x coordinate
Y_SCREEN		equ 4						; computed screen y coordinate
STRUCT_SIZE		equ 6						; size of circle center structure

CIRCLE_COUNT		equ 4					; circles count in scene



START
	mov				al,13h
	int				10h						; initialize video mode

	push	word	0A000h					; copy video segment to es
	pop				es


	fild	word	[TRIGO]					; st0 = scale to convert sinc / cos into screen space

	
MAIN_LOOP	

	; STEP 1: UPDATE CIRCLES POSITION
	mov				si, DATA
	mov				cl, CIRCLE_COUNT
	
UPD_CIRCLES_LOOP

	
	fild	word	[si + OFFSET]		; st0 = ofs, st1=SCALE
	fsqrt								; kind of degree to radian conversion
	fsincos								; st0 = sin(ofs), st1 = cos(ofs), st2=SCALE

	fmul			st0,st2				; scaling to screen coord
	fadd			st0,st2				; avoid negative coord
	fistp	word	[si + Y_SCREEN]		; store Y. st0 = cos(ofs), st1 = SCALE
	
	fmul			st0,st1				; scaling to screen coord
	fadd			st0,st1				; avoid negative coord
	fistp	word	[si + X_SCREEN]		; store X. st0=SCRX, st1 = SCALE


	add		word	[si + OFFSET], cx	; increment angle input for next frame
	add				si, STRUCT_SIZE		; go to next circle
	
	loop			UPD_CIRCLES_LOOP


	; STEP 2: RENDERING LOOP
	mov				di, SCREEN_ADRS


	mov				ebx,200 * 65536		; ebx is split into MSB = Y & LSB = X. Here, we set Y to 200

Y_LOOP
	mov				bx, 320				; Set X to 320
	
X_LOOP

	mov				cx, CIRCLE_COUNT
	mov				si, DATA

SCAN_CIRCLES_LOOP
	add				si, 2				; skip offset data (only used to calculate screen coords)
	lodsw								; retrieve screen X
	sub				ax, bx				; compute delta X
	mul				ax					; square delta x
	mov				edx, ebx			; retrieve pixel counter
	push			ax					; save delta X on stack
	shr				edx,16				; Isolate Y	

	lodsw								; retrieve screen Y
	sub				ax, dx				; compute delta Y
	mul				ax					; square delta Y
	
	pop				dx					; Get back delta X
	add				ax, dx				; edx = delta X * delta X + delta Y * delta Y = distance from current pixel to the center of the current circle
	shr				ax,7				; set the influence of the distance (big or small circles, you can play with this value)
	xor				ch, al				; combine with the results from the other cirlces at the same pixel

	dec				cl					; go to next circle
	jnz				SCAN_CIRCLES_LOOP
	
	mov		byte	[di], ch			; draw resulting pixel on screen

	inc				di					; go to next pixel

	dec				bx					; X loop counter
	jnz				X_LOOP
	
	sub				ebx, 65536   		; Y loop counter
	jnz				Y_LOOP

	; STEP 3: TRANSFR VIDEO MEMORY TO SCREEN
	mov				si, SCREEN_ADRS
	xor				di, di
	mov				cx,64000/2
	rep				movsw

	jmp				MAIN_LOOP
	
TRIGO
	dw				100 / CIRCLE_COUNT		; Deg to rad
DATA

