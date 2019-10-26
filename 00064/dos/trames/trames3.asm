; ---------------------------------------------
; Trames, a 64 bytes effect for no good reason
; Rouquemoute/Titan, January 6 2007
; ---------------------------------------------

; Don't stare at the screen for too long...

; Inspired by a painting by Francois Morellet (Trames, 1965)
; on display at the Zentrum fur Kunst und Medientechnologie in Karlsruhe.
; Don't miss this museum next time you go to The Ultimate Meeting!

; Greetings go to Bonz, Picard, Silique, Baze, and especially to Pirx
; for his HardCode intro collection, Rrrola for his optimization comments
; on pouet and Lord Kelvin for his neat commented codes.
; I learned a great deal from those three sources.

; Compile with FASM


org 100h

            mov     al,13h              ; set up VGA
            int     10h
            les      bp,[bx]

re:
            xor     di,di
            inc     cx
            mov     bx,199              ; y coordinate
yloop:
            mov     bp,319              ; x coordinate
xloop:
            mov     ax,bx
            xor     ax,bp
            mov     si,bp
            add     si,bx
            add     si,cx
            shr     si,6
            or      si,ax
            add     al,0                ; clear auxiliary carry

            lea     ax,[bx+si]          ; draw 16*16 squares
            aaa                         ; with thick lines
            lea     ax,[bp+si]
            aaa
            salc
            and     al,15
            stosb
            dec     bp
            jns     xloop
            dec     bx
            jns     yloop

            mov	    dx,03DAh            ; wait for retrace
retrace:
            in      al,dx
            test    al,08h
            je      retrace
            
            mov     ah,1
            int     16h                 ; key pressed?
            jz      re                  ; yes => demo

            ret                         ; no => die
