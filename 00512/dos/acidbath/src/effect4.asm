; The double buffer segment is in GS.
; The frame counter is in DI.
; Preserve FS and GS
; 29 bytes max

; dx = (x - 160);
; dy = (y - 108);
; buffer[x + y * 320] = ((dx^dy)>>2) + 32000/(dx*dx + dy*dy + 1) + frame;
effect4:
        sub ax, 108
        sub dx, 160
        mov si, ax
        xor si, dx
        shr si, 2
        push dx
        mul ax
        mov bx, ax
        pop ax
        mul ax
        add bx, ax
        inc bx
        mov ax, 32000
        xor dx, dx
        div bx
        add ax, di
        add ax, si
        
