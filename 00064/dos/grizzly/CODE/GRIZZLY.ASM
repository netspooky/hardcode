컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; GRIZZLY - a 64 byte demo
; by Justin Walemark (Insomniac/Matrix)
; insomniac@goplay.com
;
; Full source code.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
code	SEGMENT
	ASSUME	cs:code, ds:code
	.386
	LOCALS

ORG	100h

XSize	=	25			; the box width
YSize	=	25			; and height

Start:	mov	al,13h			; i want VGA!
	int	10h

	lea	dx,Text			; write the 3D-text
	mov	ah,9
	int	21h

컴컴컴컴컴컴컴컴컴컴
; SET THE PALETTE (4 grey scales)
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Setpal:	mov	dx,3c9h			; the phong palette
	xor	ax,ax
	
@pal:	out	dx,al
	out	dx,al
	out	dx,al
	inc	ax
	loop	@pal

	push	0a000h			; with this segment
	pop	ds			; using DS makes it smaller!

컴컴컴컴컴컴컴컴컴컴
; MAIN PROCEDURE (plottes randomized bricks)
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Main:	imul	di,dx			; nice and compact
	inc	di			; random generator

	mov	cl,YSize
Vert:	push	cx			; save Y-coordinate
	mov	cl,XSize
Horiz:	inc	byte ptr ds:[di]	; next color
	inc	di			; next position
	loop	Horiz
	add	di,320-XSize		; next row
	pop	cx
	loop	Vert			; whole height

	in	al,60h			; check the keyboard for '2'-press
	cmp	al,3			; scancode for ASCII '2' is 3
	jne	Main

	int	10h			; switch back to textmode

	ret				; and return to DOS

Text	db	'GRIZZLY','$'		; and that's the whole 64-byte demo!

code	ENDS
	END	Start                    