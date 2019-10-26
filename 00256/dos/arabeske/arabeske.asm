; arabeske.asm
;
; A Generations	pattern
; (see MCell at	http://www.mirwoj.opus.chelm.pl/ca/ for	more patterns)
;
; Created by Frank Buss	(fb@frank-buss.de)
;
; It's public domain, use it for whatever you want.
;
; Compile it with NASM (http://nasm.sourceforge.net) like this:
; nasmw	-f bin -o arabeske.com arabeske.asm


%define	SCREEN_WIDTH 320
%define	SCREEN_HEIGHT 200

%define	CA_WIDTH (SCREEN_WIDTH + 2)
%define	CA_HEIGHT (SCREEN_HEIGHT + 2)

; try changing this, every value a slightly different effect
%define	NUMBER_OF_STATES 65


section	.text
		org   100h
		
		; get old video	mode
		;
		mov ah,	0xf
		int 0x10
		push ax
	
		; switch to 320x200x256, default palette is fine
		;
		mov ax,	0x13
		int 0x10

		; clear	first CA
		;
		mov ax,	ds
		add ax,	0x1000
		mov bx,	ax
		mov es,	ax  ; first CA starting	at ds +	0x1000
		push es	    ; save for later use
		mov cx,	CA_WIDTH * CA_HEIGHT / 2
		xor di,	di
		xor ax,	ax
		cld
		rep stosw
		
		; clear	second CA
		add bx,	0x1000	; second CA starting at	ds + 0x2000
		mov es,	bx
		mov cx,	CA_WIDTH * CA_HEIGHT / 2
		xor di,	di
		xor ax,	ax
		rep stosw

		; init first CA	with one cell in the center
		;
		pop ds	; get segment to first CA
		inc byte [CA_HEIGHT / 2	* CA_WIDTH + CA_WIDTH /	2]

		; loop until key pressed
		;
		mov ax,	0xa000
		mov gs,	ax  ; g-segment	for graphics area
		std
      
		; wait for horizontal sync
		;
NextFrame:	mov dx,	0x3da
WaitVSync_l1:	in al, dx
		test al, 8
		jnz WaitVSync_l1
WaitVSync_l2:	in al, dx
		test al, 8
		jz WaitVSync_l2

		; show and update CA
		;
		mov si,	CA_WIDTH * (CA_HEIGHT -	1) - 2	  ; CurrentCA index
		mov di,	si				  ; NextCA index
		mov bx,	SCREEN_WIDTH * SCREEN_HEIGHT - 1  ; graphics index

NextLine:	mov cx,	SCREEN_WIDTH  ;	current	column
NextPixel:	lodsb
		mov [gs:bx], al

		; update CA
		;
		or al, al  ; if	0, check if it has to birth
		jz Check
		inc al	   ; if	not 0, next cell generation
		jmp CheckEnd
Check:		xor dl,	dl  ; count neighbours
		add dl,	[si - CA_WIDTH]
		add dl,	[si - CA_WIDTH + 1]
		add dl,	[si - CA_WIDTH + 2]
		add dl,	[si]
		add dl,	[si + 2]
		add dl,	[si + CA_WIDTH]
		add dl,	[si + CA_WIDTH + 1]
		add dl,	[si + CA_WIDTH + 2]
		cmp dl,	1
		jne CheckEnd
		mov al,	1  ; birth, if exactly one new cell is around

CheckEnd:	cmp al,	NUMBER_OF_STATES  ; test maximum age
		jl SetNext
		mov al,	0		  ; die
SetNext:	mov [es:di], al		  ; set	new state

		dec bx	; graphics index
		dec di	; NextCA index

		; check	for next pixel
		;
		loop NextPixel

		; check	for next line
		;
		sub si,	2  ; previous line for CurrentCA
		sub di,	2  ; previous line for NextCA
		
		cmp bx,	0xffff
		jne NextLine
 
		; exchange first CA and	next CA	for the	next CA	generation
		;
		push ds
		push es
		pop ds
		pop es

		; check	for key	press (exits program)
		;
		mov ah,	1
		int 0x16
		jz NextFrame

		; eat the key
		;
		mov ah,	0
		int 0x16

		; restore video	mode
		;
		pop ax
		xor ah,	ah
		int 0x10

		; back to DOS
		;
		mov ah,	0x4c
		int 0x21
