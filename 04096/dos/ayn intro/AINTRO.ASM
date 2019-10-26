;
; Made this demo back in 1998, was 17 age old by that time,
; released it in 2001, hope it's helpfull
;
        ORG     100h

main    :
        call    setup_buffer

        mov     ax,13h
        int     10h

        call    setup_palette

        mov     si,palette
        call    set_palette

        call    tentacul_start
        call    julia_start
        call    rain_start
        call    scroller_start

        mov     ax,3
        int     10h

        mov     ax,cs
        mov     ds,ax
        mov     ah,9
        mov     dx,my_sign
        int     21h

        mov     ax,4c00h
        int     21h

my_sign db      0dh,0ah,'- Ayn Intro - , by Wael M. Araiby 2001(c)'
        db      0dh,0ah,'My current email is : wael_araiby@yahoo.com'
        db      0dh,0ah,'If you ported the code to linux , send me a notice ;)'
        db      0dh,0ah,'$'
        
%include "mistrain.inc"
%include "julia.inc"
%include "tentacul.inc"
%include "scroller.inc"
%include "globals.inc"
