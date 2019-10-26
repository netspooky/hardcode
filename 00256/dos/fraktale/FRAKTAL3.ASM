org $100

        mov     ax,$13
        int     $10
        mov     ax,$a000
        mov     es,ax
        mov     dx,$03c8
        mov     al,0
        out     dx,al
        inc     dx
        out     dx,al
        out     dx,al
        out     dx,al
        mov     al,63
        out     dx,al
        out     dx,al
        out     dx,al
        xor     eax,eax
        xor     di,di
        mov     cx,64000/4
        cld
        rep     stosd
.pêtla: mov     ax,3
        call    random
        mov     bx,dx
        mov     di,dx
        mov     ax,[x+bx+di]
        sub     ax,[xp]
        sar     ax,1
        cwd
        xor     ax,dx
        sub     ax,dx
        mov     [xp],ax
        mov     ax,[y+bx+di]
        sub     ax,[yp]
        sar     ax,1
        cwd
        xor     ax,dx
        sub     ax,dx
        mov     [yp],ax
        mov     ax,[yp]
        mov     bx,320
        mul     bx
        add     ax,[xp]
        and     eax,$ffff
        mov     byte [es:eax],1
        in      al,$60
        dec     al
        jnz     .pêtla
        mov     ax,$03
        int     $10
        mov     ah,$4c
        int     $21

random:
        mov     bx,[liczba]
        add     bx,$2345
        ror     bx,7
        sub     bx,[kupka]
        add     [kupka],bx
        mov     [liczba],bx
        mul     bx
        ret

xp      dw 1
yp      dw 1
x       dw 0,0,640
y       dw 0,400,0
kupka   dw 7
liczba  dw 12