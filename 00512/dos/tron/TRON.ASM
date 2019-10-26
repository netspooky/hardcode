;----------------------------------------------------------------------------
; tron.asm                              copyright (c) 1997, brioche/aspirine
;----------------------------------------------------------------------------
; kinda 2 player nibble game as seen in a well known old movie called 'tron'
;----------------------------------------------------------------------------
; mainly optimized for size but my first goal was to have fun! :)
; this proggy assumes that all the common registers are set to zero and that
; the direction flag is clear.
; nothing more to say about this source except that it has been assembled
; with borland tasm 3.1 and linked with tlink 5.1
;----------------------------------------------------------------------------
; about the lack of comments: real coders don't need comments! :)
;----------------------------------------------------------------------------
; this is freeware but e-mails are welcome!     106146.1452@compuserve.com
;----------------------------------------------------------------------------


		.386
		.model  tiny

SC_ESC          equ     1                       ;several scancodes in use
SC_UP           equ     72                      
SC_DOWN         equ     80
SC_LEFT         equ     75
SC_RIGHT        equ     77
SC_A            equ     16
SC_Q            equ     30
SC_W            equ     44                      ;oops!
SC_X            equ     45                      ;azerty frenchy keyboard! :)

player          struc

off             dw      ?
hdir            dw      ?
vdir            dw      ?

		ends

movseg          macro   _dst, _src              ;quite useful macro

		push    _src
		pop     _dst

		endm

code            segment use16

		assume  cs:code, ds:code, es:code, ss:code
		org     100h
		
start:          mov     al, 13h               ;mmm... not so sure :)
		int     10h

		xor     ax, ax                ;init palette
		mov     dx, 3c8h
		out     dx, al
		inc     dx
		mov     cl, 5*3
		mov     si, offset palette
		rep     outsb

		mov     ax, 3509h             ;init keyboard
		int     21h
		mov     word ptr old9, bx
		mov     word ptr old9+2, es
		mov     ah, 25h
		mov     dx, offset new9
		int     21h
		
		movseg  es, 0a000h              ;now es = video mem

		mov     eax, 01010101h          ;build the back grid
		xor     edx, edx
		xor     di, di

		mov     bl, 25                  ;draw inner grid
gridlp1:        mov     cx, 40*7
gridlp2:        stosb
		add     di, 7
		loop    gridlp2
		call	hline
		dec     bl
		jnz     gridlp1

		xor     di, di                  ;outer grid (game bounds)
		shl	eax, 1
		call	hline
		mov     cl, 198
gridlp3:        stosb             
		add     di, 318
		stosb
		loop    gridlp3
		call	hline

mainloop:       mov     dx, 3dah                ;wait for vertical retrace
		in      al, dx
		test    al, 8
		jz      $-3
		in      al, dx
		test    al, 8
		jnz     $-3

		cli                           ;compute both player's position
					      ;interrupts are disabled during
		mov     bx, offset plyr1      ;this operation to avoid any
		call    dothestuff            ;kind of trouble :)
		mov	di, si		      ;di = player 1	
	
		mov	bx, offset plyr2       
		call    dothestuff            ;si = player 2

		cmp     byte ptr es:[di], 1
		seta    cl	              ;player 1 crashed?
		
		cmp     byte ptr es:[si], 1
		seta    ch                    ;player 2 crashed?

		mov     byte ptr es:[di], 3   ;draw both players on screen
		mov     byte ptr es:[si], 4 

		sti

		or	cx, cx
		jz	chkesc			;nobody crashed
		cmp	cl, ch
		je	exaequo			;both crashed
		jb	win1			;player 1 wins
		ja	win2			;player 3 wins
				
chkesc:		cmp     escape, 0
		je      mainloop
		
		mov     ax, 3
		int     10h

		mov     dx, offset byemsg
		jmp     bye

exaequo:	mov	winplyr, '?'
		jmp	win1

win2:           mov     winplyr, '2'

win1:           mov     dx, offset winmsg

bye:            mov     ax, 3   
		int     10h

		mov     ah, 09h                 ;print some messages
		int     21h                             

		lds     dx, dword ptr old9      ;reset keyboard stuff
		mov	ax, 2509h
		int     21h

		ret

;-- new keyboard handler ----------------------------------------------------

new9:           push    ax		  ;kinda huge ugly 'switch() case...'
		push    ds
		push    si

		mov     ax, cs
		mov     ds, ax

		in      al, 60h
	
new9_esc:       cmp     al, SC_ESC                      ;exit
		jne     new9_up				
		mov     escape, 1			;teacher's coming! :)
		jmp     new9_ack

new9_up:        mov     si, offset plyr1

		cmp     al, SC_UP                       ;player1 up
		jne     new9_down

		jmp     mvup          

new9_down:      cmp     al, SC_DOWN                     ;player1 down
		jne     new9_left

		jmp     mvdown

new9_left:      cmp     al, SC_LEFT                     ;player1 left
		jne     new9_right
		
		jmp     mvleft

new9_right:     cmp     al, SC_RIGHT                    ;player1 right
		jne     new9_a

		jmp     mvright

new9_a:         mov     si, offset plyr2

		cmp     al, SC_A                        ;player2 up
		jne     new9_q
		
		jmp      mvup

new9_q:         cmp     al, SC_Q                        ;player2 down
		jne     new9_w

		jmp     mvdown

new9_w:         cmp     al, SC_W                        ;player2 left
		jne     new9_x
		
		jmp     mvleft

new9_x:         cmp     al, SC_X                        ;player2 right
		jne     new9_ack

		jmp     mvright

new9_ack:       in      al, 61h		  ;send release code to kb ctrl
		mov     ah, al
		or      al, 80h
		out     61h, al
		mov     al, ah
		out     61h, al

new9_eoi:       mov     al, 20h              		;end of interrupt
		out     20h, al

		pop     si
		pop     ds
		pop     ax

		iret

mvup:           cmp     byte ptr [si].vdir, 0
		jne     new9_ack
		mov     [si].hdir, 0
		mov     [si].vdir, -320
		jmp     new9_ack
		
mvdown:         cmp     byte ptr [si].vdir, 0
		jne     new9_ack
		mov     [si].hdir, 0
		mov     [si].vdir, 320
		jmp     new9_ack

mvleft:         cmp     byte ptr [si].hdir, 0
		jne     new9_ack
		mov     [si].hdir, -1
		mov     [si].vdir, 0
		jmp     new9_ack

mvright:        cmp     byte ptr [si].hdir, 0
		jne     new9_ack
		mov     [si].hdir, 1
		mov     [si].vdir, 0
		jmp     new9_ack

dothestuff:     mov     si, [bx].off         
		add     si, [bx].hdir        
		add     si, [bx].vdir          
		mov     [bx].off, si         ;new player's offset
		ret

hline:		mov	cl, 80
		rep	stosd
		ret

;-- data --------------------------------------------------------------------

X1		= 159-100
Y1		= 99
X2 		= 159+100
Y2		= 99

plyr1           player < X2+(Y2*320), -1, 0 >
plyr2           player < X1+(Y1*320), +1, 0 >
escape          db      0
palette         db      3, 8, 13                                ;bknd
		db      6, 11, 16                               ;inner grid
		db      8, 13, 18                               ;outer grid
		db      0, 46, 50                               ;player 1
		db      50, 50, 0                               ;player 2
winmsg          db      10, 13, 'Player '
winplyr         db      '1'
		db      ' Wins!', 13, 10, 10                    ;trick here
byemsg          db      'by brioche/aspirine$'              

old9            dd      0                               ;removable zero data


code            ends

		end     start           		;eat this! :)
