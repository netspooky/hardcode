comment #

        Haremos algo para la attrib compo :)

        mmm ... un viejo efecto de tele rotando paleta? :)

        Frizhard^TCM 2k
#

.MODEL TINY
.386p
LOCALS @@
JUMPS

w       EQU     word ptr
b       EQU     byte ptr
n       EQU     near ptr

.CODE

ORG     100h

main_:

        ; No necesitamos pantalla virtual :)
        ; Todo directamente a la VGA

        Mov     AL, 013h
        Int     010h

        ;Push    DS
        ;Pop     ES

        ; 1.- Generar una paleta aleatoria (64 primeros colores)

        Mov     CL, 64
        Lea     DI, rand_val

        Push    CX
        Push    DI

@@BUCLE_1:

        Mov     AL, CL
        Dec     AX
        Stosb
        Loop    @@BUCLE_1

        ; paleta generada. ahora la "randomizamos" (q mal suena :)

        Pop     DI
        Pop     CX
        Push    CX
        Push    DI

@@BUCLE_2:

        Call    n random
        And     AX, 03Fh
        Xchg    BX, AX
        Lea     BX, [rand_val + BX]

        Mov     AL, b [BX]
        Mov     DL, b [DI]
        Mov     b [BX], DL
        Stosb
        Loop    @@BUCLE_2

        ; paleta "randomizada". ahora la creamos

        Pop     SI
        Pop     CX

        Lea     DI, rand_pal

@@BUCLE_3:

        Lodsb
        Stosb
        Stosb
        Stosb
        Loop    @@BUCLE_3

        ; paleta ok. ahora ya toca la parte del efecto

        Call    n cambiar_paleta

        Push    0A000h
        Pop     ES

        Xor     DI, DI
        Mov     CX, 64000/2

@@BUCLE_5:

        Call    n random
        And     AX, 03F3Fh
        Stosw
        Loop    @@BUCLE_5

@@BUCLE_6:

        Call    n rotar_paleta
        Call    n wait_vr
        Call    n wait_vr
        Call    n cambiar_paleta

        Mov     AH, 1
        Int     016h
        Jz      @@BUCLE_6

        ; han pulsado una tecla ... ya vale, pesao

        Xor     DI, DI
        Mov     SI, 199*320

        Mov     AX, 0FEFEh

@@BUCLE_7:

        ;Push    DI

        ;Push    SI
        ;Push    AX

        Pusha

        Call    n rotar_paleta
        Call    n wait_vr
        Call    n wait_vr
        Call    n cambiar_paleta
        ;Pop     AX
        ;Pop     SI

        ;Pop     DI

        Popa

        ;Push    DI

        Mov     CX, 320
        ;Push    CX
        Rep     Stosw

        Push    DI

        Mov     DI, SI
        ;Pop     CX
        Mov     CX, 320
        Rep     Stosw

        Pop     DI
        ;Add     DI, 320
        Sub     SI, 640

        Cmp     DI, SI
        Jb      short @@BUCLE_7

        Mov     AX, 03h
        Int     010h

        Push    CS
        Pop     DS

        Lea     DX, end_mess
        Mov     AH, 9
        Int     021h

random  PROC    near

        Mov     AX, w [rcons1]

        Mul     w [rseed]

        Inc     AX
        Add     AX, DX
        Inc     w [rcons1]
        Mov     w [rseed], AX

        Ret

random  ENDP

cambiar_paleta  PROC    near

        Lea     SI, rand_pal

        Mov     DX, 03C8h
        Xor     AX, AX
        Out     DX, AL

        Mov     CL, 64*3
        Inc     DX

@@BUCLE_4:

        Lodsb
        Out     DX, AL
        Loop    @@BUCLE_4

        Ret

ENDP

rotar_paleta    PROC    near

        Push    ES

        Push    DS
        Pop     ES

        Lea     DI, rand_xchg
        Push    DI
        Lea     SI, rand_pal
        Push    SI
        Movsw
        Movsb

        Pop     DI
        Mov     CL, 63*3
        Rep     Movsb

        Pop     SI
        Movsw
        Movsb

        Pop     ES

        Ret

ENDP

wait_vr PROC    near

        Mov     DX, 03DAh

@@W_1:

        In      AL, DX
        And     AL, 8
        Jnz     SHORT @@W_1

@@W_2:

        In      AL, DX
        And     AL, 8
        Jz      SHORT @@W_2

        Ret

ENDP


end_mess        db      '.frizhard 256 bytes attrib compo', 10, 13, '$'


.DATA?

rand_pal        db      64*3    dup     (?)
rand_val        db      64      dup     (?)
rand_xchg       db      3       dup     (?)

rcons1  dw      ?
rseed   dw      ?


END main_
