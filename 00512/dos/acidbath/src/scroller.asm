%define CHAR_COLOR 0x000F
%define Y_POS      3

; SI: Position of scroller (starts at 320 and decrements each frame)
; message: Pointer to message to print
; Preserve FS and GS
; MAKE SURE message IS NOT AN EMPTY STRING AND IS NULL TERMINATED!!
    
    mov di, message
    print.loop:
        xor bx, bx
        mov bl, byte [di]
        push di
        push 0xF000
        pop es
        mov di, Y_POS ; DI = Y = y
        xor cx, cx ; j = 0
        putchar.jloop:
            push si ; SI = X
            push bx ; BX = character
            shl bx, 3
            add bx, cx
            add bx, 0xFA6E ; BX = 0xFA6E + (c >> 3) + j
            mov bl, byte [es:bx] ; (F000:FA6E contins BIOS 8x8 font)
        
            putchar.iloop:
    
                ; If x < 0 or x >= 320, then skip this
                cmp si, 0
                jl putchar.nodraw
               
                cmp si, 319
                jge putchar.breakiloop
            
                ; if !(bl & 0x80) then skip this
                mov bh, bl
                and bh, 0x80
                jz putchar.nodraw
            
                ; buffer[X + Y * XRES] = CHAR_COLOR
                push bx
                mov ax, di
                mov bx, 320
                mul bx
                add ax, si
                mov bx, ax
                mov word [gs:bx], CHAR_COLOR ; cx for rainbow
                pop bx
            
                putchar.nodraw:
            
                inc si ; X++
                shl bl, 1 ; line <<= 1
                jnz putchar.iloop
        
            putchar.breakiloop:
            inc di ; Y++
            inc cx ; j++
            cmp cx, 8
            pop bx
            pop si
            jne putchar.jloop
        
        pop di
        inc di
        add si, 8
        cmp byte [di], 0
        jne print.loop
    
