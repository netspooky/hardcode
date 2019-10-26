컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; WAVINESS - a 128 bytes demo
; by Insomniac/Matrix
; insomniac@goplay.com
;
; Full source code.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
code	SEGMENT
	ASSUME	cs:code, ds:code
	p386

ORG	100h

Start:	mov	al,13h			; yes, gimme graphics!
	int	10h

컴컴컴컴컴컴컴컴컴컴
; SET THE PALETTE - by Io/Matrix
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
     	mov	dx,3c9h
	mov	cl,128
plc2:	mov	al,bl
	shr	al,1
	out	dx,al
	out	dx,al
	out	dx,al
	inc	bx
	loop	plc2

	mov	cl,128
plc3:	dec	bx
	mov	al,bl
	shr	al,1
	out	dx,al
	out	dx,al
	out	dx,al
	loop	plc3

	push	0a000h			; the VGA segment
	pop	es

컴컴컴컴컴컴컴컴컴컴
; GENERATE CIRCLES - The pattern to use
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;	xor	cx,cx
@y:	xor	bx,bx
@x:	mov	ax,cx			; get Y
	mul	cx			; make it Y^2
	mov	dx,bx			; get X
	imul	dx,dx			; make it X^2
	add	ax,dx			; Color = (X^2+Y^2)

	mov	di,cx			; calculate postition
	imul	di,320
	add	di,bx
	stosb

	inc	bx			; do the vertical
	cmp	bx,320
	jbe	@x

	inc	cx			; and the horizontal
	cmp	cl,200
	jbe	@y
	
컴컴컴컴컴컴컴컴컴컴
; SAVE THE PALETTE
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	push	ds			; we only need the data-segment
	pop	es

SavePal:
	lea	di,Pal			; save the whole palette
	mov	cx,256*3		; 256 R,G,B values
	xor	ax,ax			; start with color 0
	mov	dx,3c9h
	rep	insb			; get the all

컴컴컴컴컴컴컴컴컴컴
; ROTATE THE PALETTE
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;	mov	col,0	
Ploop:	mov	al,bl	;col
	mov	dx,3c8h
	out	dx,al
	inc	dx
	lea	si,Pal
	mov	cx,256*3
	rep	outsb			; set the whole palette
	
	inc	bx			; move the colors one step

컴컴컴컴컴컴컴컴컴컴
; WAIT FOR VERTICAL RETRACE - Update screen
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	mov	dx,3dah
@v1:	in	al,dx
	test	al,8
	jz	@v1
@v2:	in	al,dx
	test	al,8
	jnz	@v2

	in	al,60h			; check the keyboard for ESC-press
	dec	ax
	jnz	Ploop			; if not ESC, the repeat

	mov	al,3			; back to textmode
	int	10h

	ret				; and return to DOS

db	'MTX!'				; The magic label!

컴컴컴컴컴컴컴컴컴컴
; VARIABLES - 0 bytes
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Pal	db 256*3 dup (?)

code	ENDS
	END	Start