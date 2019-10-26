; dAMN Grafix!!! the Lord has gifted you with TEXTMODE!!! >>:}
; 
; are ye repentant?!
;
; (c:) 256 byte demo by Sassa
;      sassa@apiary.sumy.ua
;   _____
; @()(_)	[ well, i have nothing common with Apiary Inc 
; /\\  		[ that is located at http:\\www.apiary.com\ 8))
;		[ though i was pleased to see, that such a page exists ;))
;
; contribution to the '99 assembly competition
;
; Supposed Effect:
;  hey, man! can't you see, though slight, but still 3d???? >>:}
;  image transparency, superposition of colors in textmode. damn grafix.
;
; Supposed Responsibility:
;  none. :)
;
; Requirements:
;  - a)i8086 cpu or better (if force_8086)
;    b)i386 cpu or better (otherwise)
;  - generic EGA video card or better. with monitor, of course :))))
;  
;  - DOS 1.x or higher; not MD'98 
;      (under MustDie'98 startup register values are defined wrong (!) ;) way)
;
;  - do not drink neither strong beverage for 3 days :)))
;
;
; to see the effect you'd better run it from a pure DOS. under multitasking it
; may blink somehow distorted and spoil the effect. ;(
;
; Compile:
;  tasm damgrafx.asm
;  tlink -t damgrafx.obj
;

.model tiny
.code
.startup

;;;force_8086	equ	1	; if force_8086 mode is defined (no 386 instr)
				; my proggie grows by two bytes, 
				; still fitting 256 bytes limit ;P


color_1		equ	4		; colors of the film and screen image
color_2		equ	6		; ok, ok: i know, red and brown look
				; aggressive, but i had no space to pick
				; a better palette.
				; hint: do not use intensive colors. they yuck.

next_v_page	equ	1000h		; offset for the next video page

code2		equ	00000000b	; codes for EOT
code1		equ	01010101b

	call	off			; clrscr

        mov     bh,0b8h                 ; now BX=B800
        mov     es,bx

        scasw				; now DI=0 ;P (refer startup values)

        mov     si,offset img1

	mov	dx,color_1*100h+'@'	; set the color and filler char
l2:
        lodsb
	cmp	al,code1		; is it the EOT signal for the first
	jnz	l1_     		; table?

	add	di,next_v_page		; yes, right. let's fill the screen
	mov	dh,color_2		; image now.
	lodsb
l1_:
	mov	cl,al
	jcxz	off1			; oh, may be it is EOT for the next table?

	mov	ch,1			; nai, set stop bit for the bit map
loop1:
	mov	ax,dx
	shr	cx,1		; CX is not zero unless stop bit is shifted off
;;;	jz	l2			; sorry, ZF is not altered
					; on i186/188 processors after SHx
	jcxz	l2			; anyway, CX is zero ;)))
					; CX==0 -- the bit image is all passed
	jc	l21			; CY -- put filler

	mov	ah,0	      		; NC -- put blank 
					; ('put black' sounds better, though ;)
l21:
    	stosw
	jmp	short loop1		; shift next bit
off1:
;;
;; image is ready. rock-n-scroll! ;)
;;

        mov     dx,3d4h			; base video port

        mov     ax,0ch+next_v_page/2
        out     dx,ax		; setting start offset of the videopage
				; hi part; lo is still zero
				; now it should normally display the second
				; video page.
			;AH=(next_v_page/256)/2: take heed, that offset is taken
			; within zero color plane, thus twice less than
			; cpu sees it.

; we'll need:
; LCR: 3d4h, 18h
;   scan line for a split image: image from the actual video page is 
;     displayed above this line, and below it the image from the 0 offset
;     is displayed.
;
; OVR: 3d4h, 7 
;
; ...-+---4----+-...
;     | LCR D8 | 
;      ^^^^^^^ yeah, it is
;
; MSLR: 3d4h, 9 
; ...-+---6----+-...
;     | LCR D9 | 
; 
;


;
; film is the thing that slides behind (or is it on the top of?) the main image
;  there's some text written on it ;) now you can see?
;
;
; DI == Lowest possible scanline of the top of the film
;
; BX == Current point of the top of the film
;
;
	mov	bx,(25-5)*16		; 5 lines above the bottom of normal
        mov     di,bx			; VGA screen (well, on EGA the film may
			; disappear for some time due to this
			; should be set to (25-5)*14 then;
			; although i have no space to check
			; for the char height, it _works_)
wait_vert:

inc_1   label   byte
        dec     bx			; flip-flop; once it is inc, 
					; the other time it is dec ;))
        jz      slide_back		; ZF=1 if reached the top of the screen
					; flip the flop :))
        cmp     bx,di
        jc      n_sb			; CY - oh, well, obviously, if the 
slide_back:				;  utmost bottom line is reached
        xor     byte ptr inc_1,8                ; INC->DEC, DEC->INC

n_sb:

        mov     ah,8                    ; signal to wait vertical retrace
        mov     cx,di			; count for DI lines

wait_back:
        mov     dl,0dah
wait_:
        in      al,dx
        test    al,ah			; check the retrace flag
        jz      wait_

wait_1:
        in      al,dx
        test    al,ah
        jnz     wait_1
                        		; NC, so DAS will do ok.
        mov     ah,1				; now we'll wait for horiz

        in      al,60h
	das				; any released key...
				; well, actually, not _any_, but 
        js      off	; works for any key from ESC upto scancode of 'P'
			; this trick provides waiting for the key being released
	; also divert values for AH _are_ possible (can be nonzero) this time :P
	; (in lieu of DEC AX, as some coders do;
	; some shells hook 9, so released ESC is retrieved after 
	; proggie has done all its evil deeds. i mean, irq on key release can be 
	; signaled _after_ the program terminates (if the demo is as smart and 
	; quick as this one ;))))
			
        loop    wait_back               ; trace as much as CX scan lines

	push	bx

	neg	bp                      ; BP==undefined, but it _will_ do the 
					; trick ;)
        js      set_split

        mov     bx,-1
       					; so, BX==current_scanline one time
					; and BX==somewhere_out_of_the_screen 
					; the other time
set_split:                              ; obviously this will do the "film"
        mov     dl,0d4h			; transparent

        mov     ah,bl
        mov     al,18h                  ; 18h = LCR : Line Compare Register
        out     dx,ax

        mov     al,7                    ; OVR: there's 8-th bit for LCR
        out     dx,al

        inc     dx
        in      al,dx

ifdef	force_8086
        mov     cl,4		
        shl     bh,cl
else
	.386    		
	shl	bh,4
endif
        mov     ah,bh

        and     ah,00010000b
        and     al,11101111b            ; Set the 8-th bit for LCR
        or      al,ah
        out     dx,al
        dec     dx

        mov     al,9                    ; MSLR
        out     dx,al

        inc     dx
        in      al,dx

        shl     bh,1
        and     bh,01000000b
        and     al,10111111b            ; set the 9-th bit for LCR
        or      al,bh
        out     dx,al

        pop     bx

        jmp     short wait_vert		; wait for vertical retrace

off:
	mov	ax,3
	int	10h
_ret:
        ret

;
; .OOOOO..OOO..O...O.OOOOO.O...O..OOO..OOOO...OOO.....OO...OOO..O...O..OOO..OOOO.
; ...O...O...O..O.O....O...OO.OO.O...O.O...O.O...O...O.O..O...O.O...O.O...O.O...O
; ...O...OOOOO...O.....O...O.O.O.O...O.O...O.OOOOO..O..O..OOOOO.O...O.OOOOO.OOOO.
; ...O...O......O.O....O...O...O.O...O.O...O.O......OOOOO.O......O.O..O.....O..O.
; ...O....OOO..O...O...O...O...O..OOO..OOOO...OOO......O...OOO....O....OOO..O...O
;
img1    label	byte

	db      00111110b, 00100111b, 11111010b, 00100010b, 11100111b 
	db      01110001b, 00110000b, 01001110b, 11100100b, 00111100b 
	db      10001000b, 01001000b, 00100001b, 10110110b, 00101000b 
	db      10001010b, 00101000b, 01010001b, 00010100b, 01000101b 
	db      10001000b, 10001111b, 00100000b, 10101010b, 00101000b 
	db      11111010b, 00100100b, 01011111b, 11110100b, 00111101b 
	db      10001000b, 01000000b, 00100001b, 10100010b, 00101000b 
	db      00001010b, 01111100b, 10000001b, 00010010b, 00100100b 
	db      00001000b, 00100111b, 00100010b, 00100010b, 11100111b 
	db      01110001b, 00100000b, 00001110b, 11100001b, 01000100b 
	db	code1

;
; ..O...OOO....O.....OOO..OOOO...OOO....OOOO........OOOO...O....OOOO..OOOO...O...
; .O...O.....O..O...O...O.O.....O.......O...O......O......O.O..O.....O......O.O..
; .O...O........O......O..OOOO..OOOO....OOOO........OOO..O...O..OOO...OOO..O...O.
; .O...O.....O..O....OO.......O.O...O...O...O..........O.OOOOO.....O.....O.OOOOO.
; ..O...OOO....O....OOOOO.OOOO...OOO....OOOO.......OOOO..O...O.OOOO..OOOO..O...O.
;

	db      11000100b, 00100001b, 00111000b, 10001111b, 11000011b 
	db      00000011b, 01111000b, 10000100b, 11100111b, 00010001b 
	db      00100010b, 01001000b, 01000100b, 01000001b, 01000000b 
	db      00000100b, 00000100b, 01001010b, 00010000b, 00101000b 
	db      00100010b, 01000000b, 00100000b, 11001111b, 11000011b 
	db      00000011b, 00111000b, 10010001b, 11100011b, 01000100b 
	db      00100010b, 01001000b, 00011000b, 01010000b, 01000100b 
	db      00000100b, 01000000b, 00011111b, 00000100b, 01111101b 
	db      11000100b, 00100001b, 01111100b, 10001111b, 11000011b 
	db      00000011b, 00111100b, 11010001b, 11110011b, 01000100b 
	db	code2

        end

