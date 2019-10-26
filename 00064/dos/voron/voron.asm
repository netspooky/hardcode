;voron
;64 byte MS-DOS intro
;
;by fsqrt
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;25-09-2013

;Dynamic Voronoi diagram,
;esc exit and coder colors are included!

org 0x100
    xchg ax, cx
    mov al, 0x13
    int 0x10
    les bp, [bx]
    mov bh, 4
LA: adc bl, cl
    adc [bx], bh
    loop LA
    mov cl, 99
L0: mov bl, 0xFC
    mov [si+1], bl
L:  mov ax, 0xCCCD
    mul di
    mov al, dh
    sub al, [bx]
    imul al
    xchg ax, dx
    sub al, [bx+1]
    imul al
    add ax, dx
    cmp ax, [si]
    ja p1
    mov [si], ax
    mov [es:di], bl
p1: sub bl, bh
    jnz L
    inc di
    jnz L0
    in al, 0x60
    dec al
    jnz LA
    ret
	