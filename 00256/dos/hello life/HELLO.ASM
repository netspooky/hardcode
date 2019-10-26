; Hello life, a 208 byte intro.
; Written by Jomppa in 2002, some optimizations in 2003.
; Use NASM to compile...

bits 16
org 0x100

_start:
    mov     al, 0x13
    int     0x10
    push    word 0xA000
    pop     es
    mov     si, _lines
    xor     cx, cx
    xor     di, di
.lol:
    lodsb
    mov     bl, al
    and     bx, byte 00110000b
    shr     bx, 3
    mov     dx, [bx+_sizes]
    mov     bh, al
    aam     10H
    jz      short .past
    mul     byte [.b10+1]
    shl     bh, 1
    jnc     short .nope
    neg     ax
.nope:
    shl     bh, 1
    jnc     short .x
    add     cx, ax
    sub     di, ax
.x:
    add     di, ax
    pusha
    imul    ax, cx, 320
    add     di, ax
    mov     cl, dl
.floop:
    rep     stosb
    mov     cl, dl
    sub     di, cx
    add     di, 320
    dec     dh
    jnz     short .floop
.fend:
    popa
    jmp     short .lol

.past:
    mov     ax, ds
    add     al, 0x20
    mov     ds, ax
.l:
    mov     al, [es:bx]
    mov     [bx], al
    or      al, al
    jz      short .ll
    push    ds
    push    es
    pop     ds
    mov     ax, [bx-321]
    add     al, [bx-319]
    add     al, byte [bx-1]
    add     al, byte [bx+1]
    add     ax, [bx+320]
    add     al, ah
    add     al, [bx+319]
    pop     ds
.b10:
    sub     al, 10
    jz      short .ll
    dec     al
    setz    al
    inc     ax
    mov     [bx], al
.ll:
    inc     bx
    jnz     short .l
    dec     dl
    jnz     short .no_in
    xor     di, di
.icont:
    cmp     [es:di], byte 0
    jz      short .ino
    imul    dx, byte 71
    rol     dx, 1
    salc
    inc     ax
    inc     ax
    stosb
    dec     di
.ino:
    inc     di
    jnz     short .icont
    jmp     short .l
.no_in:
    mov     si, di
    dec     cx
    rep     movsw
    mov     ah, 1
    int     0x16
    jz      short .l
_end:
    mov     ax, 3
    int     0x10
  ret

_lines:db 65h,24h,23h,26h,25h,25h,24h,33h,85h,48h,5,8Ah,85h,96h,0D8h,44h,87h,0
_sizes:dw 1414h, 141Eh, 6414h, 4614h
