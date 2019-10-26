;wasp-24b
;256 byte MS-DOS intro
;for WeCan 2013
;by fsqrt
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;20-09-2013

;Code is lame, full of stupid jumps and without comments, beware!

org 0x100
db 0x49 ;(float)[cs:si-3]=5.24e5
    mov al, 0x13
c100 equ ($-$$)
    push 0xA000
    int 0x10
    lds dx, [si] ;ds=0x6813
    xchg ax, bx
    push ds
    pop es
	
P0: mov dx, 0x3C8
    mov al, cl
    out dx, al
    inc dx
    out dx, al
    test al, 192
    jnz P1
    shr al, 1
P1: out dx, al
    jns P2
    shr al, 2
P2: out dx, al
    loop P0

T0: add ax, di
    xor al, ah
    stosb
    loop T0

T1: lodsb ;di=si-258
    mov dl, [di+1]
    add ax, dx
    mov dl, [si-2]
    add ax, dx
    mov dl, [si-1]
    add ax, dx
    shr ax, 2
    stosb
    loop T1
    dec bx
    jnz T1

    pop es
    push ds
    pop gs
    push cs
    pop ds

L:  mov ax, 0xCCCD
    mul di
    sub dx, 0x6480
    xor ax, ax
    mov bp, sp
    mov bx, 0x1FE
R:  inc bx ;FF-"moon", 00-"planet", 01-"atmosphere"
    pusha
    fninit ;>
    fild word [bp-6] ;>y0
    fild word [bp-7] ;>y0 x
    fild word [si+time]
    fidiv word [si+c100] ;>y0 x a
    fsincos
    fld st0
    fmul st0, st3
    fxch st2
    fld st0
    fmul st0, st5
    faddp st3, st0
    fmulp st3, st0
    fmulp st3, st0
    fxch st1
    fsubrp st2, st0 ;>y x
    fldpi
    fimul word [c0+bx]
    fsubp st1, st0 ;>y x+dx
    fld dword [si-3]
    fimul word [r0+bx] ;>y x+dx r^2
    fld st1
    fmul st0
    fsubp st1, st0
    fld st2
    fmul st0
    fsubp st1, st0 ;>y x+dx r^2-x^2-y^2
    ftst
    fnstsw ax
    sahf
    popa
    jnb p0
    test bl, bl
    jnp pe
_R: jmp R

p0: fsqrt ;>y x z
    test bl, bl
    jns p1
    fxch st2
p1: fistp dword [si+az] ;>y x
    fpatan ;>a
    fimul word [si+c100]
    fistp word [si+az+2] ;>
    push bx
    mov bx, [si+az+1]
    jp p2
    sub bl, [si+time]
p2: add bh, [si+time]
    mov ah, [gs:bx]
    pop bx
    test bl, bl
    jnp p4
    shr ax, 10
    and al, 00111010b
    test bl, bl
    jnz p3
    mul byte [si+az+1]
    shr ax, 7
    jmp _R
p3: add al, 64
    jmp pe
p4: add ax, ax
    rcr al, 1 ;al+=ah&128
pe: stosb
    loop _L
    inc word [si+time]
    in al, 0x60
    dec al
    jz L2
_L: push L
L2: ret

r0 equ ($-$$-256)
db 2
db 33
db 37
c0 equ ($-$$-256)
db 40
db -82
db -82
time equ -12
az equ -10

	
	
	
	