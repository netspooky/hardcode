;This source was written in orGASM

        org 100h

start:
        mov     al, 13h
        int        10h

        lds bp,[bx]

        dec     byte [si]

drawloop:
        adc     si, 2
        adc     si, 3 
        add     byte [si], 3
        adc     si, 3
        adc     si, 3
        add      byte [si], 3
        neg     si

        jmp     drawloop