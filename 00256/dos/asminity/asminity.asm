
; asmcompo 7 entry by matja.
; thanks to razzi and scali for ideas and help.
; shouts to wb, katz, mortiis, two9a, mov, kryczek, mcarp, hex86, zid.
; 10-component self-similar ifs fractal,
; vagely forming the letters 'asm' (try squinting -_o)
; bake with nasm.

org 0x100

section .text

start:
    mov al, 0x12
    int 0x10
    fninit

    mov si, ifs_vectors_packed
    mov di, ifs_vectors
unpack_table:
    lodsb
    cbw
    mov [di], ax
    fild word [di]
    fidiv word [hacky_const_256-1]
    fstp dword [di]
    add di, 4
    loop unpack_table

    fldz
    fldz
    fldz

    push word 0xa000
    pop es

main:
    mov cx, 32768   ; cls
    xor di, di
    xor ax, ax
    rep stosw

    dec cx          ; 65535 points

draw_frame:
    push cx
    mov ax, bp      ; generate pseudo-random number, bp = seed
    mov bx, 13
    mul bx
    xchg ah, al
    mov bp, ax      ; ax = pseudo-random number

    xor dx, dx
    mov bx, 10
    div bx
    mov si, ifs_vectors
    imul dx, 24
hacky_const_256:    ; use the 00 of the last instruction and the 01 of the
                    ; next as a word-sized 256 constant in unpack_table                    
    add si, dx

use_transform:

    ; newx = x*[si] + y*[si+4] + [si*16]
    ; newy = x*[si+8] + y*[si+12] + [si*20]
    ; sx = x*scale+xoffset
    ; sy = y*scale+yoffset

    mov di, FPU_SCALE       
    mov bx, temp16

    fld st1                     ; x, i, x, y
    fmul dword [si]             ; x*[si], i, x, y
    fld st3                     ; y, x*[si], i, x, y
    fmul dword [si+4]           ; y*[si+4], x*[si], i, x, y
    faddp st1, st0              ; x*[si]+y*[si+4], i, x, y
    fadd dword [si+16]          ; x*[si]+y*[si+4]+[si+16], i, x, y
    fld st2                     ; x, newx, i, x, y
    fmul dword [si+8]           ; x*[si+8], newx, i, x, y
    fld st4                     ; y, x*[si+8], newx, i, x, y
    fmul dword [si+12]          ; y*[si+12], x*[si+8], newx, i, x, y
    faddp st1, st0              ; x*[si+8]+y*[si+12], newx, i, x, y
    fadd dword [si+20]          ; x*[si+8]+y*[si+12]+[si+20], newx, i, x, y
    fxch st4                    ; y, newx, i, x, newy
    fmul dword [di]             ; y*scale, newx, i, x, newy
    fld st2
    fcos
    fmulp st1, st0
    fadd dword [FPU_OFFSET]     ; y*-scale+yoffset, newx, i, x, newy
    fistp word [bx]             ; newx, i, x, newy
    mov ax, [bx]                
    imul ax, 80
    fxch st2                    ; x, i, newx, newy
    fmul dword [di]             ; x*scale, i, newx, newy
    fadd dword [FPU_OFFSET]     ; x*scale+xoffset, i, newx, newy
    fistp word [bx]             ; i, newx, newy
    mov cx, [bx]                
    mov bx, cx
    shr bx, 3
    add bx, ax
    mov ax, 0x0180              ; ah = 1 for int 0x16, al = 128 for pixel
    ror al, cl
    or [es:bx], al

    pop cx
    loop draw_frame

    fadd dword [FPU_INC]

    int 0x16
    jz near main

    mov ax, 3
    int 0x10

exit:
    ret

ifs_vectors_packed:

db  40, -48,  80,  32, -39, 12
db  47, -16,  33,  32,   0, 21
db  40, -32, -33, -32,   3, 22
db  13, -48,  67,  16,  26, 13
db  20, -32, -26, -32,  32, 26
db -47, -64,  67, -32, -19, 20
db  60,  16,   0,  48, -38,  8
db -40, -32, -13,  48,  42, 13
db -33, -64,  60, -32,  54, 19
db  47, -16,  33,  32,   0,  2

FPU_SCALE   dd 1200.0
FPU_OFFSET  dd 300.0
FPU_INC     dd 0.02

db "spu"

section .bss

temp16 resw 1
ifs_vectors resd 60


