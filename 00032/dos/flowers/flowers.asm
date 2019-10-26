;This source was written in orGASM

        org 100h

start:
        mov     al, 13h
        int     10h
        
        lds bp,[bx]

        dec     byte [si]

drawloop:
        inc     si
        inc     si
        add     byte [si], 2
        inc     si
        inc     si
        inc     byte [si]
        ror      si, 2
        imul    si, 229
        out      dx, al

        jmp     drawloop