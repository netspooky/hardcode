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
.pêtla:
        fld     [x]
        fmul    [x]
        fld     [y]
        fmul    [y]
        fsubp
        fadd    [a]
        fld     [x]
        fmul    [y]
        fimul   [dwa]
        fadd    [b]
        fstp    [y]             ; y = 2*x*y+b
        fstp    [x]             ; x = x*x-y*y+a

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


dwa     dw 2
xp      dw 1
yp      dw 1
x       dq 0.0
y       dq 0.0
a       dq 0.31325
b       dq 0.560965
A       dw 250
B       dw 160
C       dw -200
D       dw 100