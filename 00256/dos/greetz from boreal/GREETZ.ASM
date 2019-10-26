	page	240, 132
;GREETZ.ASM	13-AUG-2001
;Greetz from Boreal
; a 256-byte intro
;loren_blaney@idcomm.com
;
;Assemble with:
; tasm /m
; tlink /t
;
MsgLen	equ	36	;number of characters in scroll message (see Main)
STS	equ	2	;small tile size

	.486
cseg	segment dword public use16 'code'
	assume	cs:cseg, ds:cseg, es:cseg, ss:cseg

	org	100h			;this is a COM file so skip the PSP
start:	mov	fs, ax			;fs:= 0
;(ah=0)
	mov	al,13h			;call BIOS to set graphic mode 13h
	int	10h			; 320x200 with 256 colors (ah = 0)

;bp = MsgX = horizontal coordinate of beginning of message (pixels)
mainL:	xor	bp, bp			;initialize horizontal location of msg
frameL:
;Fill background with moving geometric pattern
; cx = X	screen coordinates (pixels)
; dx = Y
; di = Z	index for Image array
	mov	di, offset Image
	push	ds
	pop	es
	mov	ah, [di+FCtr-Image]
	dec	byte ptr [di+FCtr-Image] ;move background

	xor	dx, dx			;for Y:= 0, 200-1 do
fb10:	mov	cx, 320			;for X:= 0, 320-1 do
fb20:	mov	al, 64			;(320 - cx) & FFh
	sub	al, cl			;Image(0, Z):= X+FCtr ! Y+FCtr | FCtr

	add	al, ah			;jumpin' Sierpinskis!
	mov	bl, dl
	add	bl, ah
	or	al, bl
	xor	al, ah
	stosb				;es:[di++]:= al
	loop	fb20

	inc	dx
	cmp	dl, 200-1
	jbe	fb10

;Display a message
;(es=ds)
	mov	si, offset Msg
	mov	cx, bp			;X coordinate of start of message
dm10:	lodsb				;X:= DispCh(X,  Y,  Msg(I)); al:= [si++]
	call	DispCh			;(destroys di)
	mov	cx, gs			;X:= Glob0
	cmp	al, MsgTerm		;last character in message?
	jne	dm10			;loop if not

;Copy Image to screen
;(si=Image)
	mov	ch, 7Dh			;32000 = 7D00h  cl = don't care
	xor	di, di
	push	0A000h			;point es to video ram
	pop	es
	rep movsw			;es:[di++]:= ds:[si++]; cx--

;Speed limit = 18.2 frames per second
;Wait for next system timer interrupt
;Pure DOS (no Windoze) can get away with a single 'hlt' instruction here
	mov	al, fs:[46Ch]		;read system timer byte
wait1:	cmp	al, fs:[46Ch]		;wait for it to change
	je	wait1

;Exit program if Esc key is down
	in	al, 60h			;read scan code from keyboard controller
	cbw
	dec	ax			;Esc scan code = 01h when held down
	je	quit

	dec	bp			;shift message to the left STS pixels
	dec	bp
	cmp	bp, -(MsgLen*8*STS + 320) ;small message is shifted off screen
	jge	frameL
	jmp	mainL
quit:
;(ah=0)
	mov	al, 03h			;restore normal text display
	int	10h
	ret

;-------------------------------------------------------------------------------
;Display a character
; Inputs:
;  al = Ch
;  cx = X0
;  es = ds
; Outputs: di FtHi
;
DispCh:	mov	di, 7			;for J:= 0, FtHi-1 do
dc10:	pusha				;save al, cx; X:= X0
;Get byte from BIOS's font table
;Byte:= Peek(FtSeg,  FtOff + Ch*FtHi + J);
	cbw
	shl	ax, 3			;* font height
	lgs	bx, fs:[43h*4]		;get font table location
	add	bx, ax
	mov	ah, gs:[bx+di]

; ah = Byte	font byte
; bx = S	tile size
; cx = X	coordinates
; dx = Y
; si = I	index
; di = J

	mov	si, 8			;for each bit in the Byte...
dc20:	mov	bx, 12			;assume cx >= 0; size = large tiles
	imul	dx, di, 12		;start at bottom; Y:= S*J + Y0
	test	cx, cx			;if X < 0 then...
	jge	dc25
	mov	bl, STS			;reflect small character
	imul	dx, di, STS		;Y:= S*J + Y0 + 75 - 36
	add	dl, 75-36
dc25:	add	dl, 60			;+ Y0

	shl	ah, 1			;Byte:= Byte << 1;
	jnc	dc50			;if Byte & $80 then

	pusha				;save ax, cx
	mov	al, 0			;DrawTile(abs(X), Y, S, $00)
	call	DrawTile		;al=color, bx=S, cx=X, dx=Y
	popa				;restore ax, cx

	pusha				;save ax, bx, cx, dx
	mov	al, 0Fh			;DrawTile(abs(X+1), Y+1, S-2, $0F)
	dec	bx
	dec	bx
	inc	cx
	inc	dx
	call	DrawTile		;al=color, bx=S, cx=X, dx=Y
	popa				;restore ax, bx, cx, dx
dc50:
	add	cx, bx			;X:= X + S; move to next tile position

	dec	si			;next I
	jne	dc20

	mov	gs, cx			;return horizontal location for next char
					; (X)
	popa				;restore al, cx

	dec	di			;next J
	jns	dc10
	ret

;-------------------------------------------------------------------------------
;Draw a square tile
; Destroys registers
;
;Inputs:
; al = C	color
; bx = S	length of side (pixels)
; cx = X0	upper-left corner of tile (pixels)
; dx = Y0
; es = ds
;
DrawTile:
dt05:	neg	cx			;abs(X); creates mirror image of char
	js	dt05

	imul	di, dx, 320		;mov	di, Y0*320 + X0
	add	di, cx			;di points to upper-left corner of tile
	add	di, offset Image

;Clip to screen (X0 is always positive)
;If X0+S-1 >= 320 then return, i.e: if X0+S > 320 then return
	mov	si, 320
	add	cx, bx
	cmp	cx, si
	jg	dt90

	sub	si, bx
	mov	dx, bx			;for J:= 0, S-1 do...
dt10:	mov	cx, bx			;for I:= 0, S-1 do...
	rep stosb			;es:[di++]:= al;  cx--
					;Image():= color
	add	di, si			;move to start of next horizontal line

	dec	dx
	jg	dt10
dt90:	ret

;-------------------------------------------------------------------------------

FCtr	db	36	;frame counter
	db	' '	;filler to make .com file exactly 256 bytes long
Msg	db	'        ...greetz to 256b coders!  ', 02h
MsgTerm	equ	02h	;message terminator character

;Image buffer must immediately follow Msg
Image	equ	$	;64000 byte buffer for copy of screen

cseg	ends
	end	start
