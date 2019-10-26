
org 100h

init:
    mov dx, 0xa000
counter EQU $-2
    mov es, dx
start:
    mov ax, 13h
    int 10h

    mov cx, 20
    add byte[counter], cl
delay:
    hlt
    loop delay

    mov byte [phase], 1

    mov si, 100

    mov ebp, edx
anim:
    dec si
    jz start

    mov edx, ebp

    pusha

    mov dx, 0x3c8
    xor al, al
    out dx, al
    inc dx
    mov cx, 3*256
palloop:
    out dx, al
    inc al
    or al, 4
    loop palloop

    mov dx, 0x3da

    hlt
vsync1:
    in al, dx
    test al, 8
    jnz vsync1

vsync2:
    in al, dx
    test al, 8
    jz vsync2

    xor di, di
    mov ch, 64000/256
    xor ax, ax
    rep stosb

    cmp byte[counter], 100
    jbe noanimation

    mov al, [dir]
    add [phase], al
    jz reverse
    cmp [phase], byte 50
    jnz noreverse
reverse:
    xor [dir], byte 254
noreverse:
noanimation:

    popa

    mov cl, 32
startdraw:
    push cx

    mov di, 100*320+160

    movzx ax, byte [phase]
    mov bx, cx
    and bl, 1
    imul bx, bx, 640
    sub bx, 320
    imul bx, ax
    add di, bx
;    mov bx, cx
;    and bl, 2
;    dec bx
;    imul bx, ax
;    add di, bx

    mov ah, cl

    mov cl, 101    
draw:
    imul edx, byte 3
    bswap edx

    cmp dl, cl
    ja nonewdir

    mov bx, 1
    test dx, dx
    jp norow
    mov bx, 320
norow:
    js noneg
    neg bx
noneg:

nonewdir:
    cmp si, cx
    jnz nohilite2
    es mov byte [di], 15
nohilite2:


    add di, bx
    es or byte [di], ah

    cmp si, cx
    jnz nohilite1
    es or byte [di], 31
nohilite1:

    loop draw
    pop cx
    loop startdraw

    in al, 60h
    dec al
    jz exit

    jmp anim

exit:
    ret

dir: db 1
phase: db 0
