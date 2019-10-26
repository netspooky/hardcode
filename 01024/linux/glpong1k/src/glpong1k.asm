; glPong1K by fake
; base code: anti
; game logic: udo
;
; OpenGL Pong in 1020bytes
; http://fake.cute-ninjas.com



	bits	32
	extern	dlopen
	extern	dlsym

; fullscreen instead of window
%define FULLSCREEN	
; ignore errors, programm will exit sooner or later anyway
%define NOEXIT 1
; save space, but only "kill -9" kann stop the programm
;%define NO_SDL_QUIT 1

; we could use jumpgates, but didn't have the time to implement this
	%macro	CALL	1
		mov	edi, %1
		call	[edi]
	%endmacro

	section text progbits alloc exec write align=1
	
; don't ask
%define	XAOS	

; the next line kind of "primes" the deflate algorithm with the right value
; can make a difference of about 20 bytes
DUMMY	db	0	; best with SDL_Quit ... retune for final
	
; finish this
	global	_start
_start:

%ifdef XAOS
; load needed libs
tiny_init:
        mov     edi, funcptrs	 	; point to fuction pointer array
	mov	esi, realnames-1 	; point to list of .so and symbols; -1 because we increment in loadso ...
loadso:
	inc	esi
	cmp	byte [esi], 0	; zero ?
	je	load_done	; done !
	mov	eax, 0x102 	; mode = RTLD_NOW+RTLD_GLOBAL
	push	eax		; push mode
	;push	0x102		; push mode = RTLD_NOW+RTLD_GLOBAL
        push    esi		; push .so name

; skip the string (.so name)
findZero:
	lodsb			; look at each byte
	or	al, al		; zero ?
	jnz	findZero
	
; open .so
open_so:
        call    dlopen		; leaves the handle in EAX
				; leave mode and .so on the stack for later dlopen calls before each dlsym
; now test symbol name
	cmp	byte [ esi ], 0	; 1st byte of function zero ?
	jne	sym		; no, load it!
				; yes, end of .so. 
	pop	ebx		; remove .so and mode from stack
	pop	ebx		; remove dlopen mode from stack
	jmp	loadso		; skip to next .so

; get the function pointer
sym:
        push    esi		; symbol
        push    eax		; handle
	call    dlsym
	pop	ebx		; junk
	pop	ebx		; junk

; nice idea, but the jumpgate is not working
%ifdef USE_JUMPGATE
;	mov	byte [edi], 0xeb	; jmp
;	inc	edi		; skip one byte
%endif
        stosd			; store address of function
	jmp	findZero

load_done:
; -------------------------------------------------	
; -------------------------------------------------	
; ------------------ REAL main --------------------
; -------------------------------------------------
; -------------------------------------------------
; open a window
	global	main
main:	
	xor	eax, eax		
	mov	ebx, eax
	add	eax, byte 0x21		; just video + timer
;	or	eax,0x00100000		; no parachute	; debugging	; REMOVE FOR FINAL
	push	eax
	CALL	t_SDL_Init

; if we need even more space, we could drop the error handling	; and we do
%ifndef NOEXIT
	or	eax, eax
	jz	setVideoMode
%endif	

setVideoMode:
	; eax is 0
%ifdef FULLSCREEN
	add	eax, 0x80		; + fullscreen
	shl	eax, 24
%endif
	mov	al, 0x03		; HW surface + OpenGL
	push	eax
	mov	bl, 32
	push	ebx
	mov	bx, 0x300		; 768
	push	ebx
	mov	bx, 0x400		;1024		; packs better than the next line
	push	ebx
	CALL	t_SDL_SetVideoMode
%ifndef NOEXIT	
	or	eax, eax
	jnz	forever
	jmp	myExit
%endif

forever:
	push	8
	CALL	t_SDL_Delay


; ------ DRAW ------
; are these constants or offsets ?!
; this is a horrible hack, but I'm too tired to fix this right now ... and it's working

P1SY		equ	1
P2SY		equ	13
BASX		equ	28
BASY		equ 	25

P1		equ	0
;P1PX		equ	3
P1PX		equ	P1+3
P1PY		equ	0
P2PX 		equ	15
P2PY		equ	12
BAPX 		equ	27
BAPY 		equ	24

BALLINIT	equ	35

KEY_SP		equ	32
KEY_W		equ	119
KEY_S		equ	115
KEY_O		equ	111
KEY_K		equ	107

PADDLE_WIDTH	equ	1
PADDLE_HEIGHT	equ	11-1	; packs better ;)
BALL_WIDTH	equ	1
BALL_HEIGHT	equ	1

EDGE		equ	127-2*PADDLE_HEIGHT




		; ************************************************************************
		; ************************************************************************
		; *****
		; *** 				code section
		; ***** 
		; ************************************************************************
		; ************************************************************************
;		section .text align=0
draw:
		; total 314 bytes	; well, not so sure about this anymore
		
		; 10 bytes
		mov	esi, objects			; get address of object struct
		; ************************************************************************
		; handle keyboard input
		; ************************************************************************
	HANDLE_INPUT:	
		; 72 bytes
		mov	edi, aKey			; get address of keys array
		; left paddle
		; 17 bytes
		mov	al, byte [edi+KEY_W]		; 'w' pressed means up
		sub	al, byte [edi+KEY_S]		; 's' pressed means down
		add	al,al
		mov	byte [esi+P1SY], al		; store y speed paddle 1
		
		; right paddle
		; 17 bytes
		mov 	al, byte [edi+KEY_O]		; 'o' pressed means up
		sub	al, byte [edi+KEY_K]		; 'k' pressed means down
		add	al,al
		mov	byte [esi+P2SY], al		; store y speed paddle 2

		; start ball
		; 28 bytes
		cmp	byte [edi+KEY_SP], 0		; SPACE pressed?
		je	TEST_PADDLES      		; no? go on!
		
FIX1:
		rdtsc					; get randome
		and	eax, 3
		
		mov	ax, word [esi+BALLINIT+eax]	; set ball speed (x)
		mov	byte [esi+BASX], al
		mov	byte [esi+BASY], ah

		; ************************************************************************
		; test whether the ball hits (or exceeds) the left paddle.
		; in this case we negate the x speed and move the ball back into the field
		; if the ball misses the paddle we re-initialize the ball
 		; ************************************************************************
	TEST_PADDLES:
		; 85 bytes
		
		; 8 bytes
		mov	al, byte [esi+BAPX]
		mov	bl, byte [esi+BAPY]
	
		lea	edi, [esi+P1PX]
		
		xor	ecx, ecx
		inc	ecx
		inc	ecx
;		mov	cl, 2
	paddle_loop:
		; 26 bytes
		cmp	byte [edi], al			; test paddle against x of ball
		jne	next_paddle           		; is ball completly to the right? - go on!
		mov	dl, byte [edi+P1PY-P1PX]	; get y position
		cmp	dl, bl				; test bottom of paddle against y of ball
		jg	new_ball			; does the ball miss the paddle? - new ball!
		add	dl, byte 2*PADDLE_HEIGHT
		cmp	dl, bl				; test top of paddle against y of ball
		jl	new_ball
		jnl	swap_x_speed			; ball hits paddle, so swap x speed!
	next_paddle:	
		add	edi, byte P2PX-P1PX
		dec	cl
		jnz	paddle_loop
		jz	DISPLAY
		
	new_ball:
		; 10 bytes
		dec	ecx
		add	byte [points+ecx], 1		; does the ball miss the paddle? - new ball!
		xor	eax, eax			; re-init speed of ball to 0
		mov 	word [esi+BAPX], ax		; and position also
		mov	word [esi+BAPY], ax		; and position also
		jz	DISPLAY     			; go on!

	swap_x_speed:					; ball hits paddle, so swap x speed
		; 15 bytes
		neg	byte [esi+BASX]			; negate x speed
		
		; apply a little bit of random to the ball speeds 
		rdtsc					; get random	; !!! kills EDX !!!!
		and	al, 3		
		dec	al				; now -1 to 2
		mov	byte [esi+BASY], al		; save as new y speed

	DISPLAY:
		; 53 bytes
		push	_modelviewMatrix
		CALL	mlLoadMatrixf			; load modelview matrix
		pop	eax				; clear stack
		
		
		; ************************************************************************
		; load the stack with _ALL_ vertices
		; !! too many quads/vertices could overflow the stack
		; but three should be fine
		; in this loop we calculate the new position of all vertices forom the
		; old position, the speed and the size
		;
		; ************************************************************************
		; 74 bytes

		;mov	esi, objects
		mov	cl, 11 			; 6 vertices with x an y
	calc_loop
		mov	edi, esi		; point destination to source
		lodsw				; read pos and speed to ax
		mov	bx, ax			; save pos in bl, speed in bh
		lodsb				; load size in ax
		mov	dl, al			; save size in dl
		
		add	bl, bh			; calc new pos in ax

		mov	dh, -EDGE
		cmp	bl, dh			; test bottom
		jl	.swap
		mov	dh, EDGE
		sub	dh, dl
		cmp	bl, dh			; test top
		jng	.ok
	.swap
		mov	bl, dh
		neg	bh			; invert speed
	.ok	
		movsx	eax, bl
		stosb				; store new pos
		push	eax			; push new pos
		
		mov  	al, bh 		; restore speed
		stosb				; save inverted speed
		
		TEST	cl, 0x02
		jz	.skip
		add	bl, dl			; calc new pos2
 		mov	[esi+3], bl		; save new pos2
	.skip
		TEST	cl, 0x03
		jnz	.skip2
		push	yellow
	.skip2
		dec 	cl
		jns	calc_loop

		mov	bl, byte 5		; 3 quads


		;counter
		mov	dl, 80
		mov	ch, byte 1
	p_loop:
		mov	esi, counter
		movsx	eax, ch
 		mov	al, byte [esi+28+eax]
 		mov	ah, byte [esi+30+eax]
		mov	cl, 27
	count_loop:
		lodsb	
		add	dl, al
 		TEST	ah, 0x01
 		jz	next_seg
		movsx	edx, dl
		push	edx
		
	next_seg
		TEST	cl, 0x03
		jnz	next_seg2
 		TEST	ah, 0x01
 		jz	next_seg3
 		inc	bl 
		push	turq
	next_seg3
 		shr	ah, 1
	next_seg2
		dec	cl
		jns	count_loop

		mov	dl,  -70
		dec	ch
		jns	p_loop
		
		; ************************************************************************
		; now we have x and y of all vertices on the stack
		; repeatedly call glRects to draw the quads
		;
		; NOTE: under windows we do not have to update the stack pointer after the 
		; call. Otherwise we abend!
		;
		; NOTE: glRects seems to destroy all registers except ebx ....
		; ************************************************************************
		; 13 bytes
		xor	eax,eax
		sub	eax, byte EDGE
		push	eax
		push	eax
		neg	eax
		push	eax
		push	eax
		;color
		push	blue

		shl	eax, 1
		push	eax
		push	eax
		neg	eax
		push	eax
		push	eax
		;color
		push	black


	draw_loop
		CALL	mlColor3ubv
		;pop	eax
		add	esp, byte 4
		CALL	mlRects
%ifndef __UNDER_WINDOWS
		add	esp, byte 16		; windows doesn't clean the stack :(
%endif
		dec	bl
		jnz	draw_loop

		
		; return to caller
	EXIT:

post1:	
	CALL	t_SDL_GL_SwapBuffers
	mov	ecx, sdl_event
	push	ecx
	CALL	t_SDL_PollEvent
	pop	ecx		; restore sdl_event
	;xor	eax, eax	; clear
	mov	al, byte [ ecx+8 ]
	mov	ebx, aKey
	add	ebx, eax
;	cmp	byte [ sdl_event ], 2	; event type 2=KEY DOWN, 12=QUIT
	cmp	byte [ ecx ], 2
	jne	checkKeyUp
;	mov	byte [ aKey+eax ], 1
 	mov	byte [ ebx ], 1
%ifndef NOEXITx	
	cmp	al, 27			; exit on ESC
	je	myExit
%endif	
checkKeyUp:	
;	cmp	byte [ sdl_event ], 3	; event type 3=KEY UP
	cmp	byte [ ecx ], 3
	jne	notUp
;	mov	byte [ aKey+eax ], 0
 	mov	byte [ ebx ], 0
notUp:	
	jmp	forever

myExit:	
%ifndef NO_SDL_QUIT
	CALL	t_SDL_Quit
%endif	
	xor     eax,eax
	inc     eax			; function _close
					; rc in EBX is 0
        int     080h

%endif

%ifdef XAOS

;	section .data	; text is fine
;	section datainit progbits alloc exec write align=1

realnames
; GL
		db      "libGL.so",0
		db	"glLoadMatrixf",0
		db	"glColor3ubv",0
		db	"glRects",0
		db	0			; end of this .so
; SDL
		db	"libSDL.so",0
		db	"SDL_Init",0
		db	"SDL_Delay", 0
		db	"SDL_PollEvent",0
		db	"SDL_SetVideoMode",0
		db	"SDL_GL_SwapBuffers",0
%ifndef NO_SDL_QUIT
		db	"SDL_Quit", 0	
%endif	
		db	0			; end of this .so
		db	0			; end


; ---- DRAW ----
;		section .data align=0

		; the followin dataitem is the modelview matrix
_modelviewMatrix:
		dd	0x3c100000
		dd	0.0
		dd	0.0
		dd	0.0
		dd	0.0
		dd	0x3c100000
		dd	0.0
		dd	0.0
		dd	0.0
		dd	0.0
		dd	0x3c100000
		dd	0.0
		dd	0.0
		dd	0.0
black:		dd	0.0
		dd	0x3f800000
database:
objects:
		db	0-PADDLE_HEIGHT,	0, 	2*PADDLE_HEIGHT, 	-EDGE+2-PADDLE_WIDTH,	0,	2*PADDLE_WIDTH
		db	0,0,0,	0,0,0
		db	0-PADDLE_HEIGHT, 	0, 	2*PADDLE_HEIGHT,	EDGE-2-PADDLE_WIDTH,	0,	2*PADDLE_WIDTH
		db	0,0,0,	0,0,0
		db	0-BALL_HEIGHT, 		0, 	2*BALL_HEIGHT,		0-BALL_WIDTH,		0,	2*BALL_WIDTH
		db	0,0,0,	0
turq:		db	0
ballInitSpeed:
yellow:		db	-1,-1,1,1,-1
counter:				; 100/100
blue: 		db	0,0     	; 100/100
 		db	-2,7		; 105/98
 		db	-7,0		; 98/98
 		db	-5,7		; 100/93
 		db	-2,7		; 105/98
 		db	-12,14		; 107/93
 		db	-14,7		; 100/93
 		db	-9,14		; 105/91
 		db	-14,7		; 98/91
 		db	-12,14		; 100/86
 		db	-9,14		; 105/91
 		db	-19,21		; 107/86
 		db	-21,14		; 100/86
 		db	-16,21		; 105/84

points:		db	0,0
segs:		db	0x77		; 0
		db	0x24		; 1
		db	0x5d		; 2
		db	0x6d		; 3
		db	0x2e		; 4
		db	0x6b		; 5
		db	0x7b		; 6
		db	0x25		; 7
		db	0x7f		; 8
		db	0x6f		; 9




	section datauninit nobits alloc exec write align=1

;	section	.bss	align=0	; saves some. does it ?

sdl_event	resd	20	; last time I checked it was about 20
aKey		resb	256

;	section	.data	align = 0
	
symnames:
		; ORDER is extremly important -> same as above, skip "0" markers
		; the extra space for the jmp (1+4) comes extremely cheap. only 3 bytes in the gzipped version.
		
%ifdef USE_JUMPGATE
	%define	FPSIZE	5
%else
	%define	FPSIZE	4
%endif

funcptrs:
mlLoadMatrixf		resb	FPSIZE
mlColor3ubv		resb	FPSIZE
mlRects			resb	FPSIZE
t_SDL_Init		resb	FPSIZE
t_SDL_Delay		resb	FPSIZE
t_SDL_PollEvent		resb	FPSIZE
t_SDL_SetVideoMode	resb	FPSIZE
t_SDL_GL_SwapBuffers	resb	FPSIZE
%ifndef NO_SDL_QUIT
t_SDL_Quit		resb	FPSIZE
%endif

%endif

