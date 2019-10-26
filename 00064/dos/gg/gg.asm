;This source was written in orGASM

        org 100h

start:
        mov     al, 13h
        int        10h

        lds bp,[bx]

        dec     byte [si]

drawloop:
        adc     si, 222
        adc     si, 333
        add     byte [si], 333
        adc     si, 333
        adc     si, 333
        add      byte [si], 333
        neg     si

        jmp     drawloop