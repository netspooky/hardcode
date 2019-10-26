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
            push    0A000h              ; no trick to avoid the 16 bytes glitch
            pop     es

re:
            xor     di,di
            inc     cx
            mov     bx,199              ; y coordinate
yloop:
            mov     bp,319              ; x coordinate
xloop:
            mov     si,5
            mov     ax,bx
            xor     ax,bp
            test    ax,100000b
            jz      notranslation       ; no translation for every other
            mov     si,cx               ; 32x32 square
notranslation:
            lea     ax,[bx+si]          ; draw 16*16 squares
            aaa                         ; with thick lines
            lea     ax,[bp+si]
            aaa
            salc
            not     al                  ; black on white is nicer!
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
