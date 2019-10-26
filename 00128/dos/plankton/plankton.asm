;plankton
;128 byte MS-DOS intro
;for Outline 2014
;by fsqrt
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;31-05-2014

;Code can be much smaller and visually better,
;but have no time to improve it, sorry...

org 0x100
    mov al, 0x13
    int 0x10
    les bp, [bx]

A:  mov bl, 32
    mov dx, 0x3C8
    mov al, cl
    out dx, al
    inc dx
a1: mov al, cl
    test cl, bl
    jnz a2
    add al, al
a2: out dx, al
    add bl, bl
    jnz a1
    loop A
	
    fninit
L:  mov bl, 12
p:  mov ax, 0xCCCD
    mul di
    xor bp, bp
    push dx
p1: imul ax, [si], 32
    imul word [bx+si+16]
    add [bp-3], dl
    fild word [bp-4]
    fld st0
    fmul st0, st0
    dec bp
    neg bx
    js p1
    pusha
    faddp st2, st0
    fxch st1
    fsqrt
    fxch st2
    fpatan
    fimul word [bp-10]
    fiadd word [bp-8]
    fsin
    fabs
    fldpi
    fsubrp st1, st0
    fmulp st1, st0
    fild word [bx+si]
    fabs
    faddp st1, st0
    fistp word [bp-2]
    popa
    pop ax
    test ah, ah
    jns p2
    dec bx
    jnz p
p2: mov al, bl
    rol ax, 4
    stosb
    loop L
    inc word [si]
    in al, 0x60
    dec al
    jnz L
    ret
	