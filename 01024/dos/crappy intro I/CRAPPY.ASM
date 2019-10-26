;ллллллллллллллллллллллллллллллллллллллллллллл  Questions
;ллл     Crappy Intro I source code        ллл  mail to
;ллл Copyright (c) 1995 by Albert Software ллл  albert@sarma.ee
;ллл      Very commented....indeed         ллл
;ллллллллллллллллллллллллллллллллллллллллллллл
; I compiled with tasm 2.5
; tasm crappy.asm
; tlink /t crappy.obj
.MODEL TINY
.CODE
.286
ORG 100H
START:				; Check for a 286 

	push	sp
	pop	dx
	cmp	dx,sp
	jz	Is286		; Yes...we have one!
	lea	dx,CrapPC	; No...we don't
	jmp	LastHi

				; Check for VGA
Is286:	mov	ax,01a00h
	int	10h
	cmp	al,01ah
	jne	Bye
	
				; We have an AT with VGA...Yes!
	
	lea	di,Stars
	mov	cx,600
	xor	al,al
	rep	stosw		; Zero our Star database

	mov	ax,0013h
	int	10h		; Mode 13h

	lea	si,Stars
	call	LoadP		; Load a zero pallete...everithing's black

	mov	ax,0a000h
	mov	es,ax		; Spank video segment to es

Hiding:	call	AdvS		; Call the Star procedure 
	dec	cs:Number	; 255 times...remove this,
	jnz	Hiding		; and see why!
	
	mov	ah,2
	xor	bh,bh		; Place the cursor in almost
	mov	dx,080Eh	; the middle of the screen
	int	10h

	lea	si,Kiri
	mov	cx,14
UUsTa:	mov	ah,0eh
	mov	bl,7
	lodsb
	int	10h
	dec	cs:Taht
	loop	UusTa		; Show crap message with int 10 teletype


	lea	si,Colors
	call	LoadP		; Now load our cool pallete

;	Э This is the main procedure Э

Veel:	mov	cx,1000		; Wait for Vertical retrace 1000 times...
Ikka:	call	WaitV		; it's for the delay
	loop	Ikka

	mov	ax,0F000h
	mov	ds,ax		; DS now points to font segment
	mov	si,0FA6Eh	; SI now points to font offset
	call	MakeL		; Spank a crap line on screen
	call	Scroll		; Scroll the crap
	call	AdvS		; Advance and show all the stars...sigh
	mov	ah,1
	int	16h		; Has a key been pressed?
	jz	Veel		; No...not yet
	xor	ah,ah
	int	16h
	mov	ax,0003h
	int	10h		; Return to text mode
Bye:	push	cs
	pop	ds		; Remove this for cool effect.
	lea	dx,Albert
LastHi:	mov	ah,9
	int	21h
	ret			; and to dos

;	Э Main procedure ends Э


;--------- Show and Advance stars -----
Advs:	xor	si,si			; Zero register
NextS:	mov	di,cs:Stars.OldDi+si	
	mov	al,cs:Stars.OldC+si	; Remove the old dot by
	mov	es:[di],al		; writing old color on it
	mov	di,cs:Stars.X+si	; di = x
	cmp	cs:Stars.X+si,320	; Are we in range?
	jg	SOut			; No...This star is out
	cmp	cs:Stars.X+si,0		; Is the star a dead one
	jne	GoodS			; No it's not
SOut:	mov	cx,190			; Yes it is
	call	Random			; 
	mov	cs:Stars.Y+si,dx	; Y= random number(190)
	mov	cx,5
	call	Random			; Speed = random number(5)
	inc	dl			; Inc dl in case it's a zero
	mov	cs:Stars.Speed+si,dl
	mov	cs:Stars.X+si,1
	mov	di,cs:Stars.X+si

GoodS:	mov	bx,cs:Stars.Y+si
	mov	ax,320
	mul	bx			; di = y*320+x
	add	di,ax
	mov	bl,cs:Stars.Speed+si	; Add the speed of star
	xor	bh,bh
	add	cs:Stars.X+si,bx
	add	di,bx
	mov	al,byte ptr [es:di]
	cmp	al,7
	je	Red			; Was the star red?
	mov	cs:Stars.OldC+si,0	; No
	jmp	NotOk
Red:	mov	cs:Stars.OldC+si,al	; Yes
NotOk:	mov	byte ptr es:[di],bl	; Putting a dot on screen
	mov	cs:Stars.OldDi+si,di	; all ready?	;)
	
	add	si,size	Star		; Next star
	cmp	si,400
	jg	Alld
	jmp	NextS	
Alld:	ret

;-------------- Creates a random number -----------------
;	IN: cx=random number range
;	OUT: dx=random number

Random:	push	bx
	mov	ax,cs:Seed		; Uhhhhh
	mov	bx,9821			; Mhhh
	imul	bx
	inc	ax
	ror	al,1			; Ahaaaa
	add	ax,8191
	rol	ah,1			; I mean...
	mov	cs:Seed,ax
	xor	dx,dx
	div	cx			; Yeah, right...a random number
	pop	bx
	ret

;------- Wait for vertical retrace ----
WaitV:	mov	dx,3dah
@@1:	in	al,dx			; This one's selfexplanatory
	test	al,8
	jnz	@@1
@@2:	in	al,dx
	test	al,9
	jz	@@2
	ret

;---------- Procedure for loading pallete -----------
LoadP:	mov	dx,3c8h
	mov	al,1
	out	dx,al			; This one too
	inc	dx	
	mov	cx,7*3
	rep	outsb
	ret

;------------ Line drawing stuff ---------------------	
MakeL:	mov	di,61760-1		; Go to the right end of screen (down)
	mov	bx,cs:Taht		; Which letter
	mov	al,cs:Jutt[bx]		; Get our letter
	xor	ah,ah
	shl	ax,3			; Multiply letter with 8 to get it's
	add	si,ax			; offset.
	
	mov	cl,cs:Rida
	mov	dl,8

Nexton:	lodsb			; Load a byte from font pointer DS:SI
	mov	bl,1
	shl	bl,cl		; cl has the line...so shift the bit in bl
	and	al,bl		; and al with bl and find out if the bit is set
	jz	NoPix		; No?
	mov	byte ptr es:[di],7	; Color white
NoPix:	add	di,320		; Next screen line
	dec	dl
	jnz	Nexton
	dec	cs:Rida		; Next font line
	cmp	cs:Rida,0
	jne	Edasi
	mov	cs:Rida,8
	inc	cs:Taht
	cmp	cs:[Taht],330	; Are we done?
	jne	Edasi
	mov	cs:[Taht],0
Edasi:	ret

;------------- Scrolly -------------------------
Scroll:	cld
	push	es
	pop	ds
	mov	bl,8
	mov	si,61442	; si and di now point to low 8 lines on screen
	mov	di,61441
UUsrid:	mov	cx,319
	rep	movsb
	inc	si
	inc	di
	dec	bl
	jnz	Uusrid		; move all the lines
	ret
;--------------------------


Jutt	db 'Hi there!               Here it is...The first major(read minor!) '
	db 'production from Albert Software Inc.                 '
	db 'It really does deserve it''s name  ;)     BTW: This one''s 1024 '
	db 'bytes and made in 100% ASM.       '
	db 'OK. Greetz go to: Napalm Software, Denthor/Asphyxia, Draeden/VLA '
	db 'and all cool asm coders! END      '
	db '                                                    '
Kiri	db 'Crappy Intro I'
Taht	dw 14
Rida	db 8
Seed	dw 9821
Staract	db 0
Number	db 255
Colors	db	20,20,20
	db	30,30,30
	db	35,35,35
	db	40,40,40
	db	50,50,50
	db	63,63,63
	db	63, 0, 0
CrapPC	db	':-( Your PC is too crap for this crappy',10,13,'$'
Albert	db	'1KB Crappy Intro ver I.0',10,13
	db	'Copyright (c) 1995 Albert Software Inc.',10,13
	db	'Want the source code?',10,13
	db	'E-Mail me at:	albert@sarma.ee',10,'$'
Star	STRUC	
	X	dw	?
	Y	dw	?
	OldDi	dw	?
	OldC	db	?
	Speed	db	?
Star	ENDS
Stars	Star 1 dup (?)
END START


