; The double buffer segment is in GS.
; The frame counter is in DI.
; Preserve FS and GS
; 29 bytes max

; dx = x - 160
; dy = y - 108
; buffer[x + y * 320] = frame - (((dx*dx)>>1) ^ ((dy*dy)>>1))/(frame + 1);
effect2:
        sub ax, 108
        sub dx, 160
        push dx
        mul ax
        mov bx, ax
        pop ax
        mul ax
        shr ax, 1
        shr bx, 1
        xor ax, bx
        xor dx, dx
        div si
        sub ax, di
