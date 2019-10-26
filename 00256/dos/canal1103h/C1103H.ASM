;canal1103h
;
;
; --   |\|   |
; | ---| |---|
; --|-|   |-|--1103h
;
;
;256byt31ntr0tunn3l3f3ctw1thd1nam1cl1ght

;					..by Assembler !30T
;assembler_bot@yahoo.com   http:\\assemblerbot.host.sk ,   http:\\assemblerbot.wz.cz
;2003
[ORG 0x0100]
[SEGMENT .text]
    mov al,13h
    int 10h
    mov ax,ds
    inc ah
    mov es,ax

    ;pal
palette:
    mov dx,03c8h
PHASE equ $
    mov al,cl
    out dx,al
    inc dx
    shr al,2
    out dx,al
    out dx,al
    not al
    shr al,4
    out dx,al
    loop palette

nextframe:
    xor di,di

    mov bx,-100
rendery:
    mov cx,-160
renderx:
    fninit

    ;scale
    fild word [SCALE]

    ;x, y
    mov [si],cx
    fild word [si]
    mov [si],bx
    fild word [si]
    fadd st0
    fld st1
    fld st1

    ;r0
    fmul st0
    fxch st1
    fmul st0
    faddp st1
    fsqrt
    fxch st2

    ;u
    fpatan
    fld st0

    ;z-hit
    fld st3
    fmul st0
    fdivrp st3

    ;texture
    fld st2
    fdiv st4
    faddp st1
    fimul word [CONST03]
    fadd dword [PHASE]
    fsin
    fldl2t
    faddp st1
    fimul word [HEIGHT]
    fxch st1

    ;x-hit, y-hit
    fsincos
    fmul st4
    fxch st1
    fmul st4

    ;xs, ys
    fld dword [PHASE]
    fsin
    fimul word [HEIGHT]
    fld st0

    ;dxs, dys
    fsubp st2
    fsubp st2

    ;dzs
    fld st4
    fimul word [CONST03]

    fld dword [PHASE]
    fsin
    fld1
    faddp st1
    fmul st4
    faddp st1

    fsubp st4
    fxch st3

    ;D
    fmul st0
    fxch st1
    fmul st0
    faddp st1
    fxch st2
    fmul st0
    faddp st2

    ;l
    fxch st1
    fsqrt
    fild word [HEIGHT]
    fdivrp st1
    fmulp st1

    ;out
    fistp word [si]
    mov al,255
    cmp word [si],255
    ja draw
    mov al,byte [si]
draw:
    stosb

    inc cx

SCALE equ $+2
    cmp cx,160
    jl near renderx

    inc bx
    cmp bx,100
    jl near rendery

    push ds
    mov bx,es
    mov ds,bx

HEIGHT equ $
    push word 0a000h
    pop es

    mov ch,320*200/256/2
    xor di,di
    xor si,si
    rep movsw
    pop ds
    mov es,bx

    fldlg2
    fadd dword [PHASE]
    fstp dword [PHASE]

    mov ah,1
    int 16h
    jz near nextframe

CONST03 equ $+1
    mov ax,03h
    int 10h

    int 20h
heap:
