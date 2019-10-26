; Attempting to make a 3D starfield in 100 bytes.
;
; Rex Deathstar, March 1995
;
; 0x30 March 1995 : 162, 159, 153, 147
; 0x31 March 1995 : 145, 143, 137, 130, 125
; 0x4  March 1995 : 123

; Okay, seems like I failed this time, 123 bytes is what I can get now...
;
; Releasing this source is my effort to help people interested in assembly
; and 3D graphics. This may not be a great looking demo, but it does show
; what assembly is capable of, small/sweet routines, that is.
;
; Any comments/suggestions/enquiries, mail to Rex Jordan in
; Meteoroid BBS and Andromeda BBS or email <deathstr@singnet.com.sg>

; Usage:
; Use TASM /M2 TINYSTAR, TLINK /Tdc TINYSTAR to make a 123 byte COM file

.model tiny
.386

	STARS	equ 1000 ; old starfield to be erased,256*4=1024 bytes
	STARS2	equ 2024 ; x'formed starfield array,256*4=1024 bytes
	STARS3	equ 3048 ; original starfield array,256*6=1536 bytes

	NSTARS  equ 256	 ; hard-coded, do not change!

.CODE
.STARTUP
	mov	al,13h
	int	10h		; set VGA mode 13h

	;||||||||||||||||||||||||||||
	;||| INITIALIZE STARFIELD |||
	;||||||||||||||||||||||||||||
	mov	di,STARS3
	mov	ch,3 		; x,y,z components
	init_stars:
	mov	al,147
	imul	bp
	mov	bp,ax
	shr	ax,8		; x,y,z coord hi-byte must be zero
	stosw
	loop	init_stars

;---------------------------------------------------------------------------
MainLoop:

	push	0a000h
	pop	es

	;|||||||||||||||||||||
	;||| V-SYNC TIMING |||
	;|||||||||||||||||||||
	mov	dx,3dah
	vr1:
	in	al,dx
	test	al,8
	jz	vr1

	;||||||||||||||||||||||||||||||||
	;||| CLEAR PREVIOUS STARFIELD |||
	;||||||||||||||||||||||||||||||||
	xor	ax,ax
	mov	si,STARS		; old starfield
	mov	ch,NSTARS/256
	push	cx
	clear_oldstars:
	mov	di,[si]
	stosb
	add	si,4
	loop	clear_oldstars

	; reaching here, si=STARS2


	;||||||||||||||||||||||||||
	;||| DRAW NEW STARFIELD |||
	;||||||||||||||||||||||||||
	pop	cx		; NSTARS
	push	si		; save STARS2
	push	cx		; save NSTARS

	draw_stars:
	lodsw			; get y
	add	ax,100		; y-centering
		cmp	ax,200	; clip at y=0 and y=200
		jae	clipper
	mov	dx,320
	imul	dx
	mov	di,ax
	add	di,[si]		; get x
	add	di,160		; x-centering
	mov	al,9

	mov	[si-1026],di	; di=y*320+x
	stosb

	clipper:
	lodsw			; next star
	loop	draw_stars

	; reaching here, si=STARS3


	;||||||||||||||||||||||||||||||||||||||||||
	;||| PERFORM PERSPECTIVE TRANSFORMATION |||
	;||||||||||||||||||||||||||||||||||||||||||
	pop	cx		; NSTARS
	pop	di		; STARS2
	push	ds
	pop	es
	move_stars:
	dec	byte ptr [si]   ; decrease z coord
	lodsw			; get z
	mov	bp,ax		;
	add	bp,205		; +perspective

	mov 	bl,2		; loop for y and x
	redundant:
	lodsw			; get y, then get x
	xchg	al,ah		; same as 'shl ax,8'
	cwd
	idiv	bp		; y'=y*perspective/z
	stosw
	dec	bx		; only possible if bh is zero all along
	jnz	redundant

	loop	move_stars


	;|||||||||||||||||||||||
	;||| KEY-PRESS CHECK |||
	;|||||||||||||||||||||||
	mov     ah,1
	int     16h	; key-press test
	Jz	MainLoop
;---------------------------------------------------------------------------

	mov	ax,3
	int	10h
	ret		; back to DOS
	END
