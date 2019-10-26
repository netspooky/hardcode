; *********************************************************************************************

; "A Mind Evolves" - by HellMood ^ DESiRE
; 256 bytes Intro for DosBox / Windows XP / FreeDos / MsDOS
; inspired by "a mind is born" ( tribute to lft )
; 2nd place @  QBParty 2017

; plays MIDI music, highly recommended to be executed with WinXP

; As a preview:
; https://www.youtube.com/watch?v=d8y7ylsCfiI

; Download Video:
; https://drive.google.com/open?id=0BwHoYivk_PQfbDhIbndPclR2S2s

; Contact:
; helmut.toedtmann@gmail.com

; *********************************************************************************************

; compile with NASM

; there are several optimizations possible
; but this is planned to run on every possible DOS platform
; and there are some bytes spend to actually speed up things
; nevertheless i'm open to any hints how to optimize this =)

%define base 30			; the base note for the melody
%define trickoffset -3		; for adressing with SI after the initial bytesaving tricks
%define offs 40				; the dimension of the fractal, not every number works!
%define midichannel 0x0D	; the MIDI channel to play on, influence on 2nd instruction !!

org 100h
; the first three bytes are MIDI data to initalize
; UART mode and select an electric piano as instrument
; "OUTSB" is a very efficient command to write data from
; memory directly to ports. Since register SI is pointing
; to the start of the code, it's best to find MIDI data
; arrangement, which is exectuable, aligns well, and does
; no harm (at best, is actually useful, which is hard)
; SI is altered after several OUTSB commands, keep in mind!

aas						; fake instruction, does "nothing"
db 0xc0 + midichannel,4 ; calls INT4, which does nothing on all tested platforms

mov dx,0x331			; set to MIDI service port
outsb					; activate UART mode
dec dx					; set to MIDI data port
outsb					; change instrument on specific channel 
outsb					; change to specific instrument


const1:  				; holds 0x0068, constant divisor for animation
push 0x8000				; defines our offscreen buffer for the fractal brain
pop gs

push 0xa000				; defines a pointer to the screen
pop es

clrbuf:
	mov [gs:di],al		; only for freedos / real dos
	dec di				; clear possible garbage
jnz clrbuf				; in the offscreen buffer

mov al,0x13 			; switch to 320x200, only with the int4 call trick above!
int 0x10				; other channels might change AH with the trick above


; The IFS formula used for the brain fractal
; copy paste to http://cs.lmu.edu/~ray/notes/ifs/
; to see what it looks like
; +0.5 -0.5 +0.5 +0.5 .0 1.0 0.5
; -0.5 +0.5 +0.5 +0.5 .0 .5 0.5

; now generate the fractal in the offscreen buffer
; it's hard to describe what's going on if you're
; new to my approach, it's best to check the pouet thread
; http://www.pouet.net/topic.php?which=10164

; BX, SI -> X,Y coordinates
; DX -> temporary variable
; AX -> current "color"
; EBP -> iteration history of 32
; DI -> composed pointer to the offscreen

pusha							; since everything is scrambled after, complete push
	EL:
		mov dx,bx				; save X
		sub bx,si				; X -> X - Y
		add si,dx				; Y -> Y + X

		shr ax,1				; "forget" last iteration
		sar bx,1				; X -> (X - Y) / 2
		sar si,1				; Y -> (X + Y) / 2

		rcl ebp,1				; based on parity, create a branch bit
		jnc BR					; which is used 32 iterations later !
			
			neg bx				; X -> (Y - X) / 2
			add si,byte offs	; Y -> (X + Y) / 2 + offset

			or ah,0x02			; Set a bit into the color
								; this defines the coarsity of the brain
		BR: sub si,byte offs*2	; Y -> (X + Y) / 2 - offset

		imul di,si,320			; create screenpointer from X,Y ( X is added later)

		push ax					; save iteration history
		and al,7				; map history to color
		add al,16+4				; which is 8 colors from the VGA default grayscale
		mov [gs:bx+di+225-320],al ; -320 puts into signed byte range!
		pop ax					; restore iteration history

	loop EL						; plot 64 K pixels ( 255 on first run )
	cmp al,0					; since 64 K pixels are not enough
	jnz EL						; loop several times to "thicken" the fractal
popa							; restore registers after everything was scrambled
	
	
	
XL:								; MAIN LOOP
	mov dx,0x3DA				; port number for checking retrace
	vsync:  	
		in al, dx					; wait
		and al, 8					; for
	jz vsync					; retrace	
	
	
	; calculate SINCOS only ONCE per frame, to speedup things on older CPUs
	; several bytes can be saved with putting the SINCOS into the pixelloop
	
	fild word [si]									; this contains the animation variable...
	fidiv word [byte si+const1+trickoffset-0x100] 	; ...which is scaled by a well chosen constant in the code
	fsincos				; sin cos
	
	cp2:							; the pixel loop ( DI is zero initially from clearing
									; the screenbuffer, this is important for quality!)
		mov bp, 320					; construct X,Y from the screenpointer
		xor dx, dx
		mov ax, di
		div bp
		
		sub ax, byte 82				; center the rotation to the perceived middle
		sub dx, byte 118			; point of the fractal brain

		; overview on where the registers are
		; after pushing everything on stack
		; AX  CX  DX  BX  SP  BP  SI  DI
		; -4  -6  -8 -10 -12 -14 -16 -18
		
		pusha					; also to save BX, which is also the
								; pseudorandom variable for the background dithering
			mov bx, -4			; since AX is the most accessed register on the stack
								; align BX to it, so FPU comands require less space
								
			; ROTOZOOMER FPU CODE
			
			; start with 		; sin cos
	
			fst st3				; sin cos ??? sin			
			fld st1				; cos sin cos ??? sin
			fst st5				; cos sin cos ??? sin cos
			fld st1				; sin cos sin cos ??? sin cos
			
			fst st4				; sin cos sin cos sin sin cos
			
								; fsincos puts the divisor for zoom
								; sometimes to zero, which creates
								; infinite zoom. while this is cool to
								; see sometimes, i wanted the zooming to 
								; be smooth : adding ~ 1.4 to [-1,1] does
								; the trick
			FLDL2E				; l2e sin cos sin cos sin sin cos
			
			faddp st5,st0		; sin cos sin cos zoom sin cos
			
			fimul word [bx]	; sin*x cos sin cos zoom sin cos
			fxch				; cos sin*x sin cos zoom sin cos
			fimul word [bx-4]		; cos*y sin*x sin cos zoom sin cos
			faddp				; cos*y+sin*x sin cos zoom sin cos
			fdiv st3
			fistp word[bx-10]	; sin cos zoom sin cos		-> BP
			
			fimul word [bx-4]		; sin*y cos zoom sin cos
			fxch				; cos sin*y zoom sin cos
			fimul word [bx]	; cos*x sin*y zoom sin cos
			fsubp				;-cos*x + sin*y zoom sin cos
			fdivrp st1			; result sin cos
			fistp word[bx]		; sin cos					-> AX
			
			; END ROTO ZOOMER FPU CODE
		
		popa
		
		imul bp,320					; construct offscreen pointer from
		add bp,ax					; [X,Y] (AX,BP)
		
		mov al,[gs:bp+82*320+118]	; implicit re-centering
		cmp al,0					; check if the offscreen contains a fractal brain
		jnz brainpart				; on this coordinates, skip background if so
		; background
			imul bx,byte 113		; pseudo random number
			dec bx					; iteration
			imul ax,di,byte -1		; bytes for style! this flips the screen, so
									; in effect, BLUE is on TOP, YELLOW on the BOTTOM
									; should remind a little to a beachy, meadowy scene
			
			and bh,(1<<5)-1 		; modifying BX without storing = DANGER! (but works)
			add eax,ebx				; and adding the random influence to screen coordinates
						
			shr eax,13				; bring down to 8 possible colors
			add al,32+24+12			; which are precisly mapped to the
									; bright [yellow,blue] part of the VGA palette

		; background end
		
		brainpart:
		stosb						; finally plot the pixel (either fractal or background)
	loop cp2						; and repeat

dec word [si]						; increment our animation variable
test byte [si],15					; play some music on every 15th frame
jnz XL								; repeat MAINLOOP



; MUSIC GENERATION 
; the following routine plays pentatonic scales
; a MAJOR and a MINOR scale are used and switched
; from time to time. Each consists of FIVE notes,
; they share THREE notes though, so SEVEN notes
; are stored at the bottom, the first five notes
; and the last five notes represent a scale each

; to create perceived variety, the notes are randomly
; shifted across three octaves. also the volume is
; adjusted to play deeper notes more loudly. This is
; earfriendly, and also creates a nicer timbre.

mov cl,5							; we want a chord of FIVE notes

LLL:
	mov dx,0x330					; switch to MIDI data port
	mov al,0x90 + midichannel		; announce note for the specified channel
	out dx,al
		
	imul bp,byte 3*7 				; 2nd pseudorandom number generator
	dec bp
	mov ax,bp						; construct a number between 0 and 4 
	aam 5							; from it, AH is used later for the octave!

	test word [si],512				; from "time to time" shift the pointer
	jnz SSS							; by two, effectively 
		add al,2					; switching between two pentatonic scaLes
	SSS:
	
	mov bx,musi						; get the BASE adress for the music data
	xlat							; and get the BASE note to play

	and ah,3						; reduce the potential octave shift to [0,3]
	aad 12							; shift to octave, (sets AH to 0, for ESC check =)
	
	out dx,al						; finally, play the note!
	neg al							; depending on the note
	add al,127+base+10				; alter the volume to play deeper notes louder
	out dx,al						; send volume value
loop LLL							; music note loop

in al,0x60							; check for escape
dec ax								; thanks to AAD (AH = 0)
jnz XL								; repeat MAINLOOP if no escape
ret									; end program

musi:
db 13+base,18+base					; two exclusive notes for scale1
db 20+base,15+base,10+base			; three shared notes
db 17+base,12+base					; two exclusive notes for scale2
