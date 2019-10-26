;wAMMA
;y0bi / wAMMA
;2012-10-4
org 100h
section .text

    mov al,13h
    int 10h
;-------------------
    mov ah,09h
    mov dx,logo
    int 21h
;-------------------
    push 6000h
    pop ds
    xor bx,bx    ;sin
    mov ch,63    ;cos
    mov bp,402   ;frq
    xor di,di
SinLoop:
    mov ax,cx
    imul bp
    test di,1
    jnz Skip
    mov ax,cx
    sar ax,6
    mov [di],ax
    neg dx
Skip:
    add bx,dx
    xchg bx,cx
    inc di
    jnz SinLoop
;-------------------
;Logo text
    push 0a000h
    pop es
    push 8000h
    pop fs
MakeBGLoop:
    mov bx,di
    shr bh,2
    shr bl,2
    mov al,[es:si+bx]
    shld si,bx,8
    shl si,6
    mov [fs:di+50+50*256],al
    inc di
    jnz MakeBGLoop
;-------------------
    push 07000h
    pop gs

MainLoop:
;si = loop counter
;-------------------
;Palette rotation
    mov dx,3c9h
    xor bx,bx
PaletteLoop:
    mov cx,3
JokuLoop:
    mov ax,si
    shr ax,cl
    cbw
    xor al,ah
    mov ah,bl
    not ah
    shr ah,1
    sub al,ah
    jns ok
    xor ax,ax
ok:
    mov ah,bl
    and ah,15
    shl ah,2
    add al,ah
    cbw
    or al,ah
    shr al,1
    out dx,al
    loop JokuLoop
    inc bl
    jnz PaletteLoop
;-------------------
    mov di,2048
AngleLoop:
    mov dx,[si]
    shl dx,6
    mov ah,128
    add dh,ah
    mov cx,[si+512]
    shl cx,5
    add ch,64
RadLoop:
    call interpolate
    cmp byte [fs:bx],0
    je NoLite
    pusha
    shr ah,5
    mov bp,30
LiteLoop:
    call interpolate
    add byte [gs:bx],ah
    salc
    or byte [gs:bx],al
    dec bp
    jnz LiteLoop
    popa
NoLite:
    dec ah
    jnz RadLoop
    dec di
    dec di
    jnz AngleLoop
;-------------------
FlipLoop:
    mov al,[gs:di]
    shr byte [gs:di],1
    and al,0f0h
    mov cx,di
    ror ch,cl
    shr ch,5
    add al,ch
    mov [es:di+bx],al
    shld bx,di,8
    shl bx,6
    inc di
    jns FlipLoop

    lodsw
    lodsw

    in al,60h
    cmp al,1
    jne MainLoop
;-------------------
interpolate:
    mov bl,dh
    mov bh,ch
    add dx,[di]
    add cx,[di+512]
    ret

    logo    db  'wAMMA$'