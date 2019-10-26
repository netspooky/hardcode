;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Outputs variables as color components ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú AH is RED, BH is GREEN and BL is BLUE
;úúúú Returns nothing
dumpregs        proc

        mov     al, ah
        out     dx, al
        mov     al, bh
        out     dx, al
        mov     al, bl
        out     dx, al

        ret

endp    dumpregs


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Sets program colors ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters
;úúúú Returns nothing
setpal  proc

        xor     bx, bx
        mov     ax, bx
        mov     dx, 3c8h
        out     dx, al
        inc     dx

        mov     cx, 63
sp1tag:
        call    dumpregs

        inc     ah
        inc     bl

        loop    sp1tag

        mov     cx, 63
sp2tag:
        call    dumpregs

        dec     ah
        dec     bl

        loop    sp2tag

        mov     cx, 63
sp3tag:
        call    dumpregs

        inc     bh
        inc     bl


        loop    sp3tag

        mov     cx, 63
sp4tag:
        call    dumpregs

        dec     bh
        dec     bl

        loop    sp4tag

        ret

endp    setpal



greenpal proc

        xor     bx, bx
        mov     ax, bx
        mov     dx, 3c8h
        out     dx, al
        inc     dx

        mov     cx, 128
gpt1:
        call    dumpregs

        mov     bh, 128
        sub     bh, cl
        shr     bh, 2

        loop    gpt1

        xor     bx, bx
        mov     bl, 63

        mov     cx, 63
gpt3:
        call    dumpregs

        inc     ah
        inc     bh

        loop    gpt3

        mov     cx, 63
gpt4:
        call    dumpregs

        dec     ah
        dec     bh

        loop    gpt4

        call    dumpregs
        call    dumpregs

        ret

endp    greenpal