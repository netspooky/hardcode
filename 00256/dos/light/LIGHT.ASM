;      !      ___
; !_ ! !- !-!  !
;
;1nf0=256=byt3=1ntr0=v0lum3tr1c=l1ght=1nclud3d
;
;					..by Assembler !30T
;assembler_bot@yahoo.com   http:\\assemblerbot.host.sk ,   http:\\assemblerbot.wz.cz
;2002
[ORG 0x0100]
[SEGMENT .text]
    mov al,13h
    int 10h
    fninit
    mov ax,ds
    inc ah
    mov es,ax

palette:
    mov dx,03c8h
alpha equ $
    mov al,cl
    out dx,al
    inc dx
    out dx,al
    out dx,al
    mul al
    shr ax,5
    out dx,al
    loop palette

nextframe:
    xor di,di

    fld dword [alpha]
    fldlg2
    faddp st1
    fstp dword [alpha]

    mov bp,-100
rendery:
    mov bx,-160
renderx:
    fninit
;load
    fld dword [alpha]
    fsincos

    mov [si],bp
    fild word [si]
    fidiv word [scale]
    mov [si],bx
    fild word [si]
    fidiv word [scale]
;rotation
    fld st1
    fld st1
    fmul st4
    fxch st1
    fmul st5
    fsubp st1
    fxch st2
    fmulp st3
    fmulp st3
    fxch st2
    faddp st1
    ;st0=y st1=x
;raytrace
    xor ax,ax
    fldz
    fldpi
    fmul st0
    mov cl,64
nextstep:
    mov [si],cx

    fadd st2
    fxch st1
    fadd st3
    fxch st1

    fild word [si]
    fidiv word [volumescale]
    fadd dword [alpha]
    fsin

    fld st2
    fadd st1
    fmul st0
    fld st2
    faddp st2
    fxch st1
    fmul st0
    faddp st1
    fsqrt
    fld st0
;st0=r
    fistp word [si]
    mov dl,[si]
    cmp dl,4
    jbe texture
    cmp dl,16
    jae texture

;volumetric light
    mov [si],cx
    fidivr word [si]
    fadd dword [alpha]
    fidiv word [volumescale]
    fistp word [si]
    mov ah,[si]

    fld st1
    fld st1
    fpatan
    fistp word [si]
    and ah,[si]

    and ah,1
    add al,ah

    loop nextstep
    jmp short draw
texture:
;    shl ah,1 ;more light
    add al,ah
draw:
    shr cl,1
    add al,cl
    stosb

    inc bx
scale equ $+2
    cmp bx,160
    jl near renderx

    inc bp
    cmp bp,byte 100
    jl near rendery

    push ds
    mov bx,es
    mov ds,bx
    push word 0a000h
    pop es
    mov ch,320*200/256/2
    xor di,di
    xor si,si
    rep movsw
    pop ds
    mov es,bx

    mov ah,1
    int 16h
    jz near nextframe

volumescale equ $+1
    mov ax,03h
    int 10h

    int 20h
heap:
