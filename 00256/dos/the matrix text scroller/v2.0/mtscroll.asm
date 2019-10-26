;The Matrix Text Scroller v2.0
;Coded by G3 (tgm80@mail.ru)
;Some optimization ideas and comments by Boreal
;tasm /m task.asm
;tlink /x /3 /t task.obj
.model tiny
.386
.code

ScreenWidth	equ	80		;normal (mode 3) text screen dimensions
ScreenHeight	equ	25
MsgRow	equ	(ScreenHeight-8)/2	;character row that message starts on

		org 100h
;assume ax=0000, bx=0000, cx=00FF, di=-2
Start:
	push	0B800h			;es points to text screen
	pop	es
	push	0FFA6h			;fs points near 8x8 font table
	pop	fs			; which is at F000:FA6E

	push	di			;initial seed for random number (= -2)

	mov	ah,02h			;set attribute of entire screen to green
	mov	di,32*ScreenWidth*2	;di points to additional screen in memory
	mov	ch,ScreenHeight*ScreenWidth/256	; (a little extra is ok)
	rep	stosw			;(al=0)
		
MainLoop:

;Copy from additional screen in memory to screen
	xor	di,di
	mov	si,32*ScreenWidth*2
	mov	cx,si
	rep	movs	byte ptr es:[di], byte ptr es:[si]

;Fill additional screen in memory with random hex characters (di points to char at begin of bottom line)
	mov	cx,ScreenHeight*ScreenWidth
L10:
	pop	ax			;ax = random number
	imul	ax, 9421		;seed = seed*9421 + 1
	inc	ax			;ref: "Master Class Assembly Language"			
	push	ax			;page 840
	shr	al,4			;00h <= al <= 0Fh

	add	al,'0'			;convert to ASCII hex character
	cmp	al,'9'
	jna	L20
	add	al,'A'-'9'-1
L20:
	stosb				;es:[di--]:= al
	inc	di			;skip attribute byte
	loop	L10			;loop until bottom row is filled

;Bump index (bx) to next horizontal bit position in Message
	inc	bx
	cmp	bx,(EndMess-Message)*8	;end of message?
	jne	L30			;jump if not
	xor	bx,bx			;reset index to start of message
L30:

	mov	cx,8			;for 8 vertical dots in the font...
	mov	di,(32+MsgRow)*ScreenWidth*2+1	;point to screen attribute 4 Message
L40:

;Move attribute bytes in message left one character space (= 2 bytes)
	mov	ax,ScreenWidth-1	;for screenWidth many attribute bytes...
	lea	si,fs:[di+2]		;si = di + 2
L50:
	movs	byte ptr es:[di], byte ptr es:[si]  ;move attribute left one char posn.
	inc	di			;point to next attribute byte
	inc	si		
	dec	ax			;loop for screenWidth attribute bytes
	jne	L50

;Get character font from BIOS table and write it to screen using attribute bytes
	pusha				;save bx and cx
	push	bx
	shr	bx,3			;convert Message bit index to char index
	mov	bl,[bx+offset Message]	;get char from Message
	shl	bx,3			;get character's font index
	sub	bx,cx			;add pixel row to index
	mov	al,fs:[bx+0Eh+8]	;get font byte from table
	pop	cx			;get char's bit index
	and	cl,07h			;number of places to shift pixel into
	inc	cx			; carry flag
	shl	al,cl
	popa				;restore bx and cx	

	mov	al,0Ah			;set light green assuming pixel is set
	jc	L60			;jump if pixel is set
	mov	al,02h			;else set dark green
L60:
	stosb				;es:[di++]:= al
	inc	di			;point to next attribute byte
	loop	L40			;cx--

;Add one new line
	pop	bp			;bp = random number
	push	bp
	shr	bp,9			;0 <= bp <= 127 (real used only 0 <= bp <= 79)
	mov	[si+bp],al		;length of new line, al=02h (sometimes al=0Ah) 

;Draw vertical lines
	mov	di,1-ScreenWidth*2
L70:
	lodsb
	and	al,1Fh
	je	L90			;jump if al=0
	inc	ax
	mov	[si-1],al		;increment line
	pusha
	xchg	ax,cx			;cx = length of line
L80:
	mov	al,0Ah			;light green
	stosb				
	add	di,ScreenWidth*2-1	;next row
	loop	L80
	mov	al,0Fh			;set bottom character of line to white
	stosb
	popa
L90:
	inc	di
	inc	di
	js	L70

	hlt				;wait for interrupt (delay 1/18 second)
					;(works better than int 1Ah in a window)
					;(except for Windows 3.1)
		
	in	al,60h			;al = keystroke
	dec	ax
	jnz	MainLoop		;loop until keystroke = ESC

	mov	al,03h
	int	10h			;clear screen

	int	20h			;exit back to DOS (free space character)
		

Message	equ	$-1

	db	'        Wake up Neo... '
	db	'        The Matrix has you... '
	db	'        Follow the white rabbit...'
EndMess:

end Start

