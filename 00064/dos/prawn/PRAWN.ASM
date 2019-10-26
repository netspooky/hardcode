;
; PRAWN - The first 38 byte plasma
; by Justin Walemark (Insomniac/Matrix)
; insomniac@goplay.com
;
; Brief history of the demo: 44b,43b,42b,40b,39b,38b
;
; NOTE.
; For further byte saving, I changed the routines reading the keyboard, going
; back to textmode and DOS. Instead of exiting with ESC, you exit with the '2'
; key. (Look bottom to understand).
;
	MODEL TINY				; we're making it tiny as &!%&
	CODESEG
	.386
	IDEAL					; who uses masm?

ORG	100h

XSize	=	25				; the box's width
YSize	=	25				; and height

Start:	mov	al,13h				; I want VGA!
	int	10h

	push	0a000h				; with this segment
	pop	ds				; -using DS makes it smaller!

Main:	in	al,40h				; nice&compact random generator
	sbb	di,ax				; WARNING: May hang computer!

	mov	cl,YSize			; the width...
Vert:	push	cx				; save Y-coordinate
	mov	cl,XSize
Horiz:  inc     byte ptr ds:[di]                ; next color
	inc	di				; next position
	loop	Horiz
	add	di,320-XSize			; next row
	pop	cx
	loop	Vert				; whole height

	in	al,60h				; check keyboard
        cmp     al,3                            ; for the '2'-key
	jne	Main				; if not then repeat
	int	10h				; else: go back to textmode

	ret					; and return to DOS

END	Start                       
