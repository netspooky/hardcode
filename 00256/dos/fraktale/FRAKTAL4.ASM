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
        shl     dx,3
        mov     di,dx
        fld     [x]
        fmul    [a+di]
        fld     [y]
        fmul    [b+di]
        faddp
        fadd    [e+di]
        fld     [x]
        fmul    [c+di]
        fld     [y]
        fmul    [d+di]
        faddp
        fadd    [f+di]
        fstp    [y]             ; x = a[di]*x+b[di]*y+e[di]
        fstp    [x]             ; y = c[di]*x+d[di]*y+f[di]

        fld     [x]
        fimul   [A]
        fiadd   [B]
        fistp   [xp]

        fld     [y]
        fimul   [C]
        fiadd   [D]
        fistp   [yp]

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
kupka   dw 7
liczba  dw 12
x       dq 0.0
y       dq 0.0
a       dq 0.787879,-0.121212, 0.181818
b       dq-0.424242, 0.257576,-0.136364
c       dq 0.242424, 0.151515, 0.090909
d       dq 0.859848, 0.05303,  0.181818
e       dq 1.758647,-6.721654, 6.086107
f       dq 1.408065, 1.377236, 1.568035
A       dw 25
B       dw 160
C       dw -40
D       dw 100