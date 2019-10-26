;sin.asm

.model tiny
.386
.387
.code
        org     100h

main    proc

        push    cs
        pop     ds

        push    0A000h
        pop     es


        mov     ax,0013h
        int     10h

        mov     dx, 03C8h
        mov     al, 1
        out     dx, al
        inc     dx

        mov     cx,0FFh
        xor     bl,bl

pal1:
        mov     al,0FFh
        mov     ah,cl
        shr     ah,2
        sub     al,ah
        out     dx, al

        xor     al,al
        out     dx,al
        out     dx, al
        loop    pal1

        mov     bh,1
m1:
        mov     es:[di],bl

        add     bl,bh

        cmp     bl,255
        jne     m2
        neg     bh
m2:
        cmp     bl,0
        jne     m3
        neg     bh
m3:

        xor     ah,ah
        int     1Ah
        sub     dx,clock
        cmp     dx,30
        jb      m4

        xor     ah,ah
        int     1Ah
        mov     clock,dx
        xor     esi,esi
        inc     factor
m4:

        add     di,factor


        mov     ah,1
        int     16h
        jz      m1
m40:
        xor     ah,ah
        int     16h

xit:

        mov     ax,0003h
        int     10h

        mov     ax,4C00h
        int     21h

clock   dw      0
factor  dw      5
vbuf    dw      ?

main    endp

        end     main
