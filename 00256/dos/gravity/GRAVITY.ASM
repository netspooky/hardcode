;*********************************************************;
;* GRAVITY.ASM -- Simple little gravity (orbits) demo in *;
;* assembly language -- this is totally public domain    *;
;*********************************************************;
;
; Optimizations by David Lindauer, gclind01@starbase.spd.louisville,edu
;
; I did NOT try to squeeze every last byte out of this; I thought it
; more important in some instances to maintain functionality rather
; than degrade the thing even slightly by performing an optimization.
; OTOH if I was sure there would be no apparent difference in the
; visual affect I went ahead and did it.
;
; My .COM file is 241 bytes, assembled with TASM /m2 and linked with
; tlink.  I am very happy with that as it is less than half the original
; 489 byte size... although to be honest I junked a hundred bytes in about
; five minutes work just by changing the offsets from word size to byte
; size.

.Model Tiny
.386
.Code
Org 100h
;_________________________________________________________________________
;
; Rearranged data.  There are still 6 blocks but each block has
; all its data contiguous.  ordering IS important as this order
; was chosen to maximize the code
;
; Also, the NEW arrays were a waste of both data space and code space
; so they went fast
;
YSpeed = word ptr 0
XSpeed = word ptr 2
YPos = word ptr 4
XPos = word ptr 6

;_________________________________________________________________________
; I moved this where I could see it.  Not that it was NOT initialized
; anyway/
points = 8000h
;_________________________________________________________________________
;
; Random ranges in code segment saves a few bytes
;
random        macro        range,offset
        call        Rand
        dw        range
        db        offset
        endm

;_________________________________________________________________________
;
; Main program
;
Prog        Proc
;
; we used FS here because ES is used in the RANDOM routine
;

            push 0                  ;fS = 0
            pop fs
            mov bp,fs:[046Ch]       ;Seed random number
            			    ; keeping random number in BP for now
                                    ; this saves a few bytes

;
; CX is univerally used for a loop index so I could utilize the
; LOOP instruction.  Loop initilzation paraemters are kept on the
; stack throughout as it is more efficient to do a push/pop pair
; thanto reload all the time
;
            mov di,offset points
            mov cx,6
	    push cx
	    push di
;
; note that AX will have garbage when we start... unless in the
; debugger
;
; Initializion loop
;
InitLoop:
            random 13,-6
            random 17,-8
            random 100,50
            random 160,80
            loop InitLoop        ;Loop back

;
; Now set up the display parameters
;
            mov ax,13h              ;Switch to mode 13h
            int 10h                 ;usssing Video BIOS
            push 0A000h             ;Point ES to video memory
            pop es
	    mov bp,318		    ; optimized constant for DRAW routine

;
; This is the main loop.  I folded as many loops together as I could
; to avoid having to reload registers.
;
MainLoop:
	    pop si
	    pop cx
	    push cx
	    push si
;
; I used subroutines HEAVILY... in every case they saved a few or
; a lot of bytes.  Also notice that this program does NOT work exactly
; the same as the old one since I do the MOVE before the draw to optimize
; the code.  But the initial position was random anyway so there is no
; noticeable visual effect
;
; incidently the colors are reverse ordered from what they were originally
; but there is no way for a viewer to know that...
;
DrawLoop:
            call Move
            call Move
            mov bl,cl               ;Color in AL, AH
            mov bh,cl
            add bh,8
            call Draw
            loop DrawLoop


;
; Standard delay--- this could be optimized to a LOOP instruction except
; we don't know the target CPU speed.  We could STILL optimize it to
; a loop instruction since the contest rules specifically state the speed
; of the display can vary...  but I elect to leave it at the standard
; rate for portability.
;
; Also, notice I am NOT loading DL.  This saves a whole byte, but the
; timing can vary slightly now.  Since the variance is about a quarter of
; a millisecond there is no noticeable difference (The human eye can't
; resolve much below a 60th of a second)
;
            mov dh,62500/256            ;which is 1/16 second
            mov ah,86h
            int 15h

	    pop si
	    pop cx
	    push cx
	    push si
;
; calculation loop.  More subroutine calls
;
; The sequencing in this loop is EXTREMELY dependent on what happened
; in the immediate past... there is a lot of subtle optimization involved
;
CalcLoop:
	    pop di
	    pop dx
	    push dx			; We are loading the params for the
	    push di			; inner loop NOW for optimization
	    push si			; purposes
            mov ax,100
            call compare2		; note the compares do a CMPSW
            mov ax,160			; which increments DI.  This is
            call compare2        	; an important part of the optimization
;
; inner loop
;
CompLoop:
	    pop si                      ; pointer to curretn block
	    push si
            call Compare
            call Compare
	    lea di,[di+4]		; this saves a byte over an add
            dec dx
            jnz CompLoop
	    pop si

            call Limit 			; limit
            call Limit
            sub bx,bx			; do the erase NOW.  It doesn't matter
            call Draw			; when we do it as long as we do it
					; before the draw and after the delay
            loop CalcLoop
;
; moving this key check here saved us a branch
;

            mov ah,1                ;Check for a key
            int 16h                 ;BIOS keyboard
            jz MainLoop            ;Next iteration if no key

Done:       xor ax,ax               ;Eat the key
            int 16h		    ; this can be optimized out but
				    ; it makes the program a pain to use
				    ; so we go for convenience
            mov ax,3                ;Set text mode
            int 10h		    ; Again it isn't essential but
				    ; ease of use is an important factor
	    pop ax			; Clear our parms from the stack
	    pop ax
            ret			    ; fast way to return to DOS from COM
				    ; program

Prog        EndP
;_________________________________________________________________________
;
; Random number generator
; Works slightly different as the contents of AX on entry are different
;
; We deleted all the stack stuff for efficiency
; then we rewrote it so it gets its parms out of the code stream
;
; We save a byte by using the inc si series over an LEA in this case
; because the mov al,[si] would have to have an offset otherwise
;
Rand        Proc
                     ; register analysis saves lots of bytes due to
                ; lack of push/pop
            imul ax,bp,9421    ;Generate next random number
            inc ax
            mov bp,ax

            pop si                    ; get parameters offset
            sub dx,dx        ; more efficient to keep params in code stream
            div word ptr [si]
            inc si
            inc si
            mov al,[si]
            cbw         ; Saves us three bytes to sign extend here
            add ax,dx
            stosw
            inc si
            jmp si

Rand        EndP
;_________________________________________________________________________
;
; Draw routine
;
; I did little to this besides rearrange the registers.  Note that
; I optimized the constant 381 into BP in the main program.  That saved
; a byte.
;
; I also got rid of the range checking.  Watching the thing for a while,
; it stayed pretty close to the center, and a simple analysis showed
; that it would be VERY rare to wrap around in the X direction.  As for the
; Y direction... there is a buffer between the top and bottom of the
; screen and even if it got off-screen I didn't think it would pass through
; that.  For all intents and purposes it works fine without the range
; checking.
;
; oh XCHG when AX is one of the regs saves a byte over a move...
;
Draw        Proc
            lodsw
            xchg ax,dx                   ; ypos in DX
            lodsw                   ; xPOS in AX

            add ah,dl               ;Calculate offset
            shl dx,6
            add ax,dx
            xchg ax,di               ;Offset in DI
            xchg ax,bx
            stosb                   ;First line
            add di,bp              ;Next row
            stosw                   ;Second line
            stosb
            add di,bp              ;Next row
            stosb                   ;Third line
NoDraw:
            ret
Draw            Endp
;_________________________________________________________________________
;
; move one of the corrdinates of one of the blocks by the amount
; given by the speed
;
; save a couple of bytes doing a byte divide... doesn't matter since
; speeds are guaranteed to fit in a byte
;
Move        Proc
            mov bl,3                ;Dividing by 3
            lodsw                    ; get speed
            idiv bl
	    cbw
            add [si+2],ax            ; adjust position
            ret
Move        EndP

;_________________________________________________________________________
;
; Compare a corrdinate against another. SI points to current coord
; AX gets coord to compare with.
;
; A couple of bytes could be saved here at small cost to the visual
; effect.  Probably it wouldn't even be noticed.
;
; Note I used CMPSW to save 3 bytes over increments
;
Compare     Proc
            mov ax,[di]
compare2:

            cmp YPos[si],ax        ;Compare X to center
            jl c_1                  ;Less?
            jz c_2                  ;Same?
            sub YSpeed[si],2     ;No, subtract 1
c_1:        inc YSpeed[si]       ;Yes, add 1
c_2:
            cmpsw
            ret
Compare            EndP
;_________________________________________________________________________
;
; Limit the speed.  I figure if I want to use a power of 2 as the limit
; I could save some bytes here.  I tried limits of 32 and 64... they
; change the visual effect somewhat.  I simply didn't like the way
; it looked, although a limit of 32 was kind of cute... so I left it alone
;
Limit            Proc
            lodsw
            cmp ax,45    ;X too fast?
            jl c_9                  ;No, skip
            mov ax,45    ;Yes, adjust
c_9:        cmp ax,-45   ;X too fast?
            jg c_10                 ;No, skip
            mov ax,-45   ;Yes, adjust
c_10:
            mov [si-2],ax
            ret
Limit       EndP
End Prog
