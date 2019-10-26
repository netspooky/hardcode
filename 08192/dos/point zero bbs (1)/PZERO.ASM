;  point zero bbstro (c) random and goblin of xtatic.
;  --------------------------------------------------
;  1995/1996/1997


.MODEL  LARGE
.386
.STACK  200h
.DATA
	assume	DS:@DATA
maxstars	EQU	2* 900
maxZ	EQU	3500
size_x	EQU	320
size_y	EQU	200
maxX	EQU	320
maxY	EQU	130
warpspd	EQU	2
RotateX	EQU	3         ; The lower, the faster
RotateY	EQU	6
cursor	dw	?
texton	db	0
RandSeed	dw	?                       ; random generator seed.
yesno	db	0
Stand_pal db 768 dup (?); Used to store the Standard BIOS palette
tmp_pal   db 768 dup (?); Temporary palette, used for fades
;EndMsg	db	'Point Zero: +612-809-7016',0dh,0ah
;		db	'  Intro By: Random & Goblin of xtatic.',0dh,0ah
;		db	'$'
align 2
ANSI LABEL BYTE
	include pz_ansi.inc
include font.inc
;//Point Zero ... One of NSW Biggest Art Related Boards .. Ansi/VGA/E-magz/Demos
;//and Music .. Sysop Z-Force .. Co's Ext/Edge/Kurrupt .. Affils-o-plenty
;//Madnet/Bloodnet .. +612-809-7016 .. Call NOW!         ... NOW I SAID!
text	db	'POINT ZERO @@@ ONE OF THE BIGGEST NSW ART RELATED BOARDS @@ '
	db	'ANSI=VGA=EMAGZ=DEMOS AND MUSIC @@ SYSOP Z=FORCE @@ '
	db	'CO=OPS EXT=EDGE=KURRUPT @@ AFFILS=O=PLENTY @@ MADNET=BLOODNET @@ '
	db	';612=8O9=7O16 @@ CALL NOW?          NOW I SAID?'
	db	'                                    '
align 2
currlett	dw	0
currlettpos	dw	0
msglength	EQU	OFFSET currlett - OFFSET text - 1

StarPlas    db  (maxX)*(maxY)   dup (0)

.FARDATA    FarStuff
	assume  FS:FarStuff
include PALETTE.INC		;PALETTE

fadeout db  0
decitv  db  0
align 2
starXpos	dw	maxstars	DUP (0)
starYpos	dw	maxstars	DUP (0)
starZpos	dw	maxstars	DUP (0)

mb           segment para public '' use16
	buffer db 320*21 dup (0) ;?
ends


.CODE
	assume  CS:@CODE
start:
	   mov ax,0040h
	   mov es,ax
	   mov di,006ch
	   mov ax,es:[di]
	   mov [RandSeed],ax

	push	@DATA
	pop	es
	mov	di,offset Stand_pal
	call	Read_Pal

	mov ax,0013h
	int 10h             ; Init graphics mode.

	push	SEG PALETTE			;Setup Pal
	pop	es
	mov	dx,OFFSET PALETTE
	xor	bx,bx
	mov	cx,127;0FFh
	mov	ax,1012h
	int	10h

	push	@DATA  			 ;Setup the Data segements.
	pop	ds
	push	FarStuff
	pop	fs
	push	0a000h
	pop	es

loopbegin:              ; Main loop begining.
	mov si,maxstars ;currstars
	mainloopbegin:
		mov ax,starZpos[si]
		cmp ax,maxZ-(maxZ/4)
		jg NewStar
			cmp ax,2
		jg  Zok
		NewStar:            ;Create new star.
			call	random
			shr	ax,5
			sub	ax,760
			mov	starXpos[si],ax
			call	random
			shr	ax,6;5
			sub	ax,450
			mov	starYpos[si],ax
			mov	starZpos[si],maxZ-(maxZ/2)
		Zok:

		mov	ax,starXpos[si]         ;Cal the X di for the star.
		movsx	dx,ah
		shl	ax,8                ;Mul x by 256 (scrdiv)
		mov	cx,starZpos[si]
		idiv	cx              ;Div x by z
		add	ax,120	;maxX/2

		cmp ax,maxX-1
		jge NewStar
		cmp ax,1
		jle NewStar
		mov di,ax

		mov	ax,starYpos[si]         ;Cal the Y di for the star.
		movsx	dx,ah
		shl	ax,8                ;Mul y by 256 (scrdiv)
		idiv	cx              ;Div y by z
		add	ax,maxY/2

		cmp ax,maxY-1 ;/2
		jge NewStar
		cmp ax,1
		jle NewStar

		mov bx,ax               ;Mul Y by 320 (maxX)
		movsx   dx,ah
		shl ax,8
		movsx   dx,bh
		shl bx,6
		add ax,bx
		add di,ax               ;di = Y * 320 + X

;		mov ax,di
;		mov di,starZpos[si]                 ;Find the increment value.
;		shr di,5
;		mov cl,StarAdVal[di]
;		mov di,ax
		mov	ax,starZpos[si]
		shr	ax,8
		mov	cx,136
		sub	cl,al

		;xor ah,ah               ;Check that the star add val is
		;xor ch,ch               ;not above maxcol when added.
		mov al,StarPlas[di]
		add ax,cx
		cmp ax,127
		jb  addit
			mov al,127
		addit:
		sub al,decitv
		cmp al,127
		jbe alnotz
			xor al,al
		alnotz:
		xor bh,bh
		mov bl,StarPlas[di-1]
		add bx,cx
		cmp bx,127
		jb  addit2
			mov bl,127
		addit2:
		sub bl,decitv
		cmp bl,127
		jbe blnotz
			xor bl,bl
		blnotz:

		mov StarPlas[di],al         ;Add val.
		mov StarPlas[di-1],bl       ;Add val.

		mov ax,starXpos[si]   ; Spin on X axis
		cmp ax,0
		jge @add
			neg ax
			mov cl,RotateY
			shr ax,cl ;6 8
			add starYpos[si],ax
			jmp @notadd
		@add:
			mov cl,RotateY
			shr ax,cl ;6 8
			sub starYpos[si],ax
		@notadd:
		shl ax,warpspd
		add     starZpos[si],ax
		mov     ax,starYpos[si]   ; Spin on Y axis
		cmp     ax,0
		jge @add2
			neg ax
			mov cl,RotateX ;5
			shr ax,cl
			neg ax
			jmp @notadd2
		@add2:
			mov cl,RotateX ;5
			shr ax,cl
			@notadd2:
			add starXpos[si],ax
		@NextStar:

		dec si
		dec si
	jnz mainloopbegin

	push    es
	mov ax,ds
	mov es,ax
	mov di,OFFSET StarPlas[maxX]      ; Calculate the StarPlas bit colour.
	nextbit:
		xor bh,bh
		xor dh,dh
		xor ah,ah
		mov bl,[di+size_x]      ;One pix below cur.
		mov al,[di-size_x]      ;One pix above cur.
		add bx,ax

		mov al,[di-1]       ;One pix to left.
		mov dl,[di+1]       ;One pix to right.
		add ax,dx
		add ax,bx
		shr ax,2                ;Divide by 4
		test    yesno,0ffh
			jz  skipdec
				dec al              ;Dec the col every second time.
		skipdec:
		cmp al,0
		jge writeit
			xor al,al
		writeit:
		sub al,decitv
		cmp al,127
		jbe alnotza
			xor al,al
		alnotza:

		stosb
		cmp di,OFFSET StarPlas[(maxX*maxY)-maxX]
	jb  nextbit
	xor yesno,1


mov ax,mb           ;Font shit, By Goblin.
mov es,ax

mov ax,[currlett] ;al
;xor ah,ah
mov si,ax
add si,offset text
mov al,ds:[si]      ; al now holds the actual character
cmp al,32
je @its_a_space

sub al,'1'
xor ah,ah
shl ax,2
mov bx,ax
;shl bx,1
add ax,bx
add ax,bx
add ax,[currlettpos] ;al
;adc ah,0
mov si,ax
add si,offset font

mov di,319
mov cx,21
@21loop:
movsb
add si,503
add di,319
loop	@21loop

@its_a_space:

mov bx,21
xor di,di
mov si,1
push ds
;mov ax,es
;mov ds,ax
push	es
pop	ds
@21loop2:
mov cx,79   ;319
rep movsd   ;b
movsw
movsb
inc si
inc di
dec bx
jnz @21loop2
pop ds

inc [currlettpos]

cmp [currlettpos],12
jne @notNextLetter
mov [currlettpos],0
inc [currlett]
@notNextLetter:
;mov al,[msglength]
cmp [currlett],msglength ;al
jne @notloop
mov [currlett],0
@notloop:

	pop	es

	mov ax,mb
	mov gs,ax
	mov si,OFFSET StarPlas
	mov di,(32000-(maxX)*(maxY)/2)+640              ;Draw Plas to screen.

	mov	cx,(320*10)/4			;Do above font.
	rep	movsd

	mov	al,120			;Colour of font bit.
	mov	dx,21
	NextLineInFontBit:
		mov	cx,320
		AddFontLoop:				;Do font part.
			mov	ah,gs:[di-(((32000-(maxX)*(maxY)/2)+640)+320*10)]
			cmp	ah,0
			je	isnotextline
				mov	ax,cx
				shr	ax,1
				add	ax,8
				cmp	al,115
				jb	okokokok
					mov	al,115
				okokokok:
				cmp	texton,0
				jne	isnotextline
				stosb
				inc	si
				jmp	donebity
			isnotextline:
			movsb
			donebity:
		loop    AddFontLoop
		dec	dx
	jnz	NextLineInFontBit

	isnotextline_fin:			;Do below font.
	mov	cx,(320*(maxY-31))/4
	rep	movsd

	mov	dx,3dah
	VRT:
		in	al,dx
		test	al,8
	jnz	VRT				;wait until Verticle Retrace starts
	NoVRT:
		in	al,dx
		test	al,8
	jz	NoVRT			;wait until Verticle Retrace Ends
;comment ~
	mov	cx,200
	hVRT:
		in  al,dx
		test    al,1
	jnz hVRT             ; wait until Horizontal Retrace starts
	NohVRT:
		in  al,dx
		test    al,1
	jz  NohVRT           ; wait until Horizontal Retrace Ends
	loop	hVRT
;~

	cmp fadeout,0                   ;Fade pal out.
	je  skpfadeout
		cmp yesno,1
		jne skpfadeout
			inc decitv
			cmp decitv,9
			jae  endprog
	skpfadeout:

	cmp yesno,0
	jne loopbegin
		mov	ah,01h          ;Check if a key has been pressed.
		int	16h
		jz	loopbegin
		mov	ax,0600h        ;Get the key that was pressed.
		mov	dl,0ffh
		int	21h
		cmp	al,19;'S'
		jne	testESC
			xor	texton,1
		testESC:
		cmp	al,27           ;Was it ESC?
		jne	loopbegin
			mov fadeout,1
	jmp loopbegin                       ;Jump Back to Beginning.

	endprog:

	mov ax,03h          ; Go back to text mode.
	int 10h

	mov	cl,0
	call	fade			;Clear Palette.

	mov	ah,3h		;Save the cursor size.
	mov	bh,0
	int	10h
	mov	cursor,cx
	mov	ax,0103h            ;Cursor Off.
	mov	cx,3e1fh
	int	10h

	mov 	si,OFFSET ANSI
	push	0b800h
	pop	es 	     	;Dest seg
	xor 	di,di       	;dest off
	mov 	cx,ANSI_SIZE/4	;length
	rep 	movsd       	;Draw Ansi.

	mov  si,offset Stand_pal
	mov	cl,0
	@fade_in_txt:
		call	fade
		inc	cl
		cmp	cl,65
	jne	@fade_in_txt         ; Does a luverly fade in

	mov ah,02h                      ;Move Cursor.
	xor bh,bh
	mov dh,23
	xor dl,dl
	int 10h

	mov ax,0103h            ;Restore cursor.
	mov cx,cursor
	int 10h

	mov ah,04Ch         ; Terminate.
	int 21h

Random          proc near
			 push dx
			 mov     ax,[RandSeed]
			 mov     dx,8405h
			 mul     dx
			 inc     ax
			 mov     [RandSeed],ax
			 pop dx
			 ret
Random          endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Palette Reading Procedure
;
; Reads in the current palette
; Assumes: ES:DI points to palette to read to
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Read_Pal proc near
	mov     cx,768
	xor     al,al
	mov     dx,03c7h
	out     dx,al
	inc     dx
	inc     dx
	rep     insb       ; Read in the palette
	ret
ENDP Read_Pal

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; Palette Fading Procedure
;
; Sets the palette to a certain intensity, use in a loop for a palette fade
; Assumes:
; CL=0..64 for intensity of total palette
; DS:SI points to palette to fade
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Fade proc near
	pusha
	push es
	push ds
	mov  ax, seg tmp_pal
     mov  es, ax
     mov  ax, offset Tmp_pal
     mov  di, ax        ; ES:DI points to the Temporary palette

	mov  bx, 768
@palette_copy_loop:
	xor     ax,ax
	mov     al,byte ptr ds:[si]
     inc si
     mul     cl
     shr     ax,6
     mov     es:[di],al
	inc di
     dec     bx
     jnz     @palette_copy_loop

     mov     ax,offset tmp_pal
     mov     si,ax
	mov     ax,seg tmp_pal
	mov     ds,ax       ; Now output the temporary palette

	call    WaitVRT   ; Wait for retrace before outputting the palette
	mov     cx,768
     xor     al,al
	mov     dx,03c8h
	out     dx,al
	inc     dx
	rep     outsb       ; Output the palette

	pop ds
	pop es
	popa
	ret
ENDP Fade

WaitVRT	PROC	NEAR
	push	dx
	push	ax
	mov	dx,3dah
	@@VRT:
		in	al,dx
		test	al,8
	jnz	@@VRT				;wait until Verticle Retrace starts
	@@NoVRT:
		in	al,dx
		test	al,8
	jz	@@NoVRT			;wait until Verticle Retrace Ends
	pop	ax
	pop	dx
	ret
WaitVRT	ENDP

END start
