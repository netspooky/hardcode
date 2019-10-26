comment #

        sphere.asm

        put some 3D thingie into your life =)
        spheres rulez, destroy cubes

        attrib 256 bytes intro compo

        frizhard^tcm
#

.MODEL TINY
.386p
LOCALS @@
JUMPS

w       EQU     word ptr
b       EQU     byte ptr
n       EQU     near ptr
d       EQU     dword ptr

MAX_POINTS      EQU     12
MAX_CIRCLES     EQU     6

.CODE

ORG     100h

main_:

        Mov     AL, 013h
        Int     010h

        Mov     BH, 0A0h
        Push    BX
        Pop     ES
        Mov     BX, 8

        ; 1.- Generar la esfera

        Lea     DI, tobj_esfera
        Mov     DL, MAX_CIRCLES

@@BUCLE_GENERA_ANILLOS:

        Fld     d [f_y]         ; y
        Fmul    ST, ST          ; y*y
        Fld     d [f_max_rad]   ; max_rad | y*y
        Fsubr                   ; max_rad-y*y
        Fsqrt                   ; f_rad

        ;Mov     CL, BL
        Mov     CL, MAX_POINTS
        Fldz                    ; ang | f_rad

@@BUCLE_GENERA_CIRCULOS:

        Fld     d [f_y]         ; y | ang | f_rad
        Fstp    d [DI+4]        ; ang | f_rad

        Fld     ST              ; ang | ang | f_rad
        Fsincos                 ; sin(ang) | cos(ang) | ang | f_rad
        Fmul    ST, ST(3)       ; f_rad*sin(ang) | cos(ang) | ang | f_rad
        Fstp    d [DI]          ; cos(ang) | ang | f_rad
        Fmul    ST, ST(2)       ; f_rad*cos(ang) | ang | f_rad
        Fstp    d [DI+BX]       ; ang | f_rad

        Add     DI, 12

        Fadd    d [f_inc_ang]
        Loop    short @@BUCLE_GENERA_CIRCULOS

        Fcompp
        Fld     d [f_y]
        Fadd    d [f_inc_y]
        Fstp    d [f_y]

        Dec     DL
        Jnz     short @@BUCLE_GENERA_ANILLOS

        ; Esfera generada =)

@@MAIN_LOOP:

        ; Pintar en pantalla

        ; retrazo vertical

comment #

        Mov     DX, 03DAh

@@WAIT_1:

        In      AL, DX
        And     AL, BL
        Jnz     short @@WAIT_1

@@WAIT_2:

        In      AL, DX
        And     AL, BL
        Jz      short @@WAIT_2

#

        ; borrar pantalla

        ;Xor     DI, DI
        Lea     DI, vscreen
        Mov     CH, 0FAh
        ;Mov     AH, AL
        ;Rep     Stosw
@@BORRA:
        Mov     b [DI], AL
        Inc     DI
        Loop    short @@BORRA

        ; 2.- rotar y proyectar la escena

        Lea     DI, tobj_esfera
        Mov     CL, MAX_POINTS*MAX_CIRCLES

@@BUCLE_3D:

        ; 2.1.- rotar

        ;Mov     AX, w [i_frame]
        ;Mov     w [i_temp], AX

        ;Fild    d [i_temp]
        Fild    d [i_frame]
        Fmul    d [f_pi128]
        Fsincos                 ; sin(angx) | cos(angx)
        Fld     d [DI+4]        ; y | sx | cx
        Fmul    ST, ST(1)       ; y*sx | sx | cx
        Fld     d [DI+BX]       ; z | y*sx | sx | cx
        Fmul    ST, ST(3)       ; z*cx | y*sx | sx | cx
        Faddp                   ; z*cx+y*sx | sx | cx
        Fstp    d [fy_rx]
        Fld     d [DI+BX]
        Fmul    ST, ST(1)       ; z*sx | sx | cx
        Fld     d [DI+4]        ; y | z*sx | sx | cx
        Fmul    ST, ST(3)       ; y*cx | z*sx | sx | cx
        Fsubp                   ; y*cx-z*sx | sx | cx

        ; 2.2.- proyectar

        Fadd    d [f_centro]
        Fdivr   d [f_dp]        ; 256/f_z+30

        Fld     d [fy_rx]
        Fmul    ST, ST(1)
        Fistp   d [i_temp]
        Mov     AX, w [i_temp]
        Add     AX, 100
        Imul    AX, 320

        Fmul    d [DI]
        Fistp   d [i_temp]
        Mov     SI, w [i_temp]
        Add     SI, AX

        Mov     b [SI+vscreen+160], DH

        Add     DI, 12

        Fcompp

        Loop    short @@BUCLE_3D

        Inc     w [i_frame]

        Lea     SI, vscreen
        Xor     DI, DI
        Mov     CH, 07Dh
        Rep     Movsw

        ; 3.- Comprobar tecla

        In      AL, 60h
        Dec     AL
        Jnz     @@MAIN_LOOP
        
        Mov     AX, 03h
        Int     010h

        Ret

f_y     dd      -10.0
f_inc_y dd      3.96
;f_inc_ang       dd      0.392699        ; 2*PI / 16
f_inc_ang       dd      0.523598        ; 2*PI/12
f_max_rad       dd      110.0
f_dp    dd      256.0
f_centro        dd      30.0
f_pi128 dd      0.0245436       ; PI/128

i_frame dd      0
i_temp  dd      0

.DATA?

f_invz  dd      ?
fy_rx   dd      ?
fz_rx   dd      ?
tobj_esfera     dd MAX_POINTS*MAX_CIRCLES*3   dup     (?)
vscreen db      64000   dup     (?)

END     main_
