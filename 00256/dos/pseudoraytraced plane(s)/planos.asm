;       Plano de pseudo-raytracing con textura.
;       por iolo (7-10-2001)
;       mail: satsat@igijon.com

        .286
        DOSSEG
        .MODEL TINY
        .DATA

        .CODE
        org 100h

inicio:
        finit
        mov     ax,13h
        int     10h

        push    0a000h
        pop     es
ef:

        mov dx,3dah
esp1:   in al,dx
        test al,8h
        jnz esp1
esp2:   in al,dx
        test al,8h
        jz esp2

        call    pintaframe

        mov ax,0b00h
        int 21h
        cmp al,0ffh
        jne ef

fin:
        mov     ax,3h
        int     10h

        lea     dx, cadena
        mov     ah,9
        int     21h

        ret

pintaframe:
        xor     di,di
        mov     si,63680
        mov     cx,320
        mov     dx,76

.386
        fld     inican2
        fld     inican1

sigfila:

        fld st(1)
        fsincos
        fld st(2)
        fsincos
        fstp dix
        fmul st(2),st(0)
        fmulp 

        fldpi
        fldpi
        fmulp
        fxch
        fdivp
        fld dix
        fmul st(0),st(1)
        fadd posz
        fistp word ptr Xtek
        fmulp
        fist Zori
        fld posz
        fcos
        fild ampZ
        fmulp
        faddp
        fistp Ztek

        fadd ix
.286
        mov bx,Xtek
        xor bx,Ztek
        xor ax,ax
        test bl,2
        jz pon
        mov al,23h
pon:
        mov     bx,Zori
        shr     bx,2
        sub     al,bl

        cmp     al,25h
        jge     borra
        cmp     al,10h
        jge     ponlo
borra:
        xor     ax,ax

ponlo:
        mov     es:[di],al
        mov     es:[si],al

        inc di
        inc si
        loopnz sigfila

        sub si,640

.386
        fstp auxf
        fadd iy
        fld     inican1

        fld posz
        fadd incpz
        fstp posz
.286
        mov cx,320
        dec dx
        jnz ssigfila
        ret
ssigfila:
        jmp     sigfila

inican2 dd      1.0471975511965977
inican1 dd      2.09439510239319
ix      dd      -0.00327249234748
iy      dd      0.005235987755982
incpz   dd      0.0005
posz    dd      0.0
ampZ    dw      16
cadena  db      '256 ok',10,13,'$'

dix     dd      ?
Xtek    dw      ?
Ztek    dw      ?
Zori    dw      ?
auxf    dd      ?

end     inicio

