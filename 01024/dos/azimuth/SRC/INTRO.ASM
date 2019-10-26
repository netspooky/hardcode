extern _render

global _putchar
global _make_noise
global _clear_buffer
global _checker_floor
global _sin
global _cos
global _star
global _play

SEGMENT _TEXT CLASS=CODE
    
    resb 100h

; Entry point
..start:
    
    finit

; Get the address of the next segment
    ; (Notice that the C code we're using is compiled with -1 which means
    ; 186/286 compatible. This means it won't use fs or gs)
    mov bx, ds
    add bx, 0x1000
    mov gs, bx
    
; Initiailize mode 13h graphics
    mov ax, 13h
    int 10h
    
; Initialize the palette (we'll only use 64 colors)
    mov cx, 255
    palette_loop:
        mov dx, 0x03C8
        mov ax, cx
        out dx, al
        inc dx
        out dx, al
        out dx, al
        out dx, al
        loop palette_loop

; We'll use di for the frame counter.
    xor di, di
    
render_loop:    
; Push the current tick count
    push 40h
    pop es
    push word [es:6Ch]

; Render the next frame to the buffer
    push di
    ;push gs
    call _render
    ;pop bx
    
; Flip the buffer to the VGA segment 0xA000
    ; Wait for vertical retrace
    mov dx, 3DAh
    vsync1: 
        in al, dx
        and al, 8
        jnz vsync1
    vsync2: 
        in al, dx
        and al, 8
        jz vsync2
    
    ; Copy buffer to VGA segment    
    push ds
    push gs
    pop ds
    push 0xA000
    pop es
    cld
    xor si, si
    xor di, di
    xor cx, cx
    dec cx
    rep movsb
    pop ds
    
; Update frame counter and quit if user hit Escape
    pop di ; Frame counter
    pop bx ; Timer count
    
    ; Add difference between last timer count and current timer to frame
    ; counter and subtract it from the scroller position
    push 40h
    pop es
    mov dx, word [es:6Ch]
    sub bx, dx
    sub di, bx
    add si, bx

    in al, 60h
    dec al
    jnz render_loop

; Bail
quit:
    
; Switch back to text mode    
    mov ax, 3h
    int 10h
    ret

_make_noise:
; Usage: void make_noise()
; Fills the buffer with noise
;    i = 0;
;    for (y = 0; y < 200; y++) {
;        for (x = 0; x < 320; x++) {
;            bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5));
;            lfsr = (lfsr >> 1) | (bit << 15);
;            buffer[i] = (lfsr & 1) << 5;
;            i++;
;        }
;    }
    push di
    mov bx, [lfsr]
    push gs
    pop es
    xor di, di
    mov cx, 64000
    _make_noise.loop:
        mov dx, bx
        mov ax, bx
        shr ax, 2
        xor dx, ax
        shr ax, 1
        xor dx, ax
        shr ax, 2
        xor dx, ax
        shl dx, 15
        shr bx, 1
        or bx, dx
        mov ax, bx
        and ax, 1
        shl ax, 4
        stosb
        loop _make_noise.loop
    
    ; Save random seed
    mov [lfsr], bx
    pop di
    ret

_putchar:
; Usage: void putchar(int x, int y, int c, int color)
; Draws a character on the screen from the BIOS 8x8 font    
    push bp
    mov bp, sp
    push di
    push si

    push 0xF000
    pop es
    
    mov di, [bp + 6] ; DI = Y = y
    
    xor cx, cx ; j = 0
    _putchar.jloop:
        mov si, [bp + 4] ; SI = X = x
        mov bx, [bp + 8] ; BX = c
        shl bx, 3
        add bx, cx
        add bx, 0xFA6E ; BX = 0xFA6E + (c >> 3) + j
        mov bl, byte [es:bx] ; (F000:FA6E contins BIOS 8x8 font)
        
        _putchar.iloop:
    
            ; If x < 0 or x >= 320, then skip this
            cmp si, 0
            jl _putchar.nodraw
            
            cmp si, 320
            jge _putchar.breakiloop
            
            ; if !(bl & 0x80) then skip this
            mov bh, bl
            and bh, 0x80
            jz _putchar.nodraw
            
            ; buffer[X + Y * XRES] = CHAR_COLOR
            push bx
            mov ax, di
            mov bx, 320
            mul bx
            add ax, si
            mov bx, ax
            mov ax, [bp + 10]
            mov word [gs:bx], ax
            pop bx
            
            _putchar.nodraw:
            
            inc si ; X++
            shl bl, 1 ; line <<= 1
            jnz _putchar.iloop
        
        _putchar.breakiloop:
        inc di ; Y++
        inc cx ; j++
        cmp cx, 8
        jne _putchar.jloop
    
    pop si
    pop di
    pop bp
    ret

_sin:
; Usage: int sin(int x, int scale)
; Returns sin(x * 2 * PI / 256) * scale    
    mov bx, sp
    fild word [bx + 2]
    fmul dword [trig_scale]
    fsin
    fimul word [bx + 4]
    fistp word [bx + 2]
    mov ax, [bx + 2]
    ret
    
_cos:
; Usage: int cos(int x, int scale)
; Returns cos(x * 2 * PI / 256) * scale
    mov bx, sp
    fild word [bx + 2]
    fmul dword [trig_scale]
    fcos
    fimul word [bx + 4]
    fistp word [bx + 2]
    mov ax, [bx + 2]
    ret

_checker_floor:
; Usage: void checker_floor(int time);

    push bp
    mov bp, sp
    pusha
    shl word [bp + 4], 4
    mov bp, [bp + 4]
    
    mov cx, 64000
    mov di, 32768
    _cf2.loop:
            mov ax, cx
            mov bx, 320
            xor dx, dx
            div bx
            
            cmp ax, 132
            jle _cf2.horizon
            
            sub dx, 160
            sub ax, 100
            mov bx, ax
            imul bx, bx
            push dx
            mov dx, 0x0032
            xor ax, ax
            idiv bx
            
            mov es, ax
            
            add ax, bp
            mov si, ax
            pop ax
            imul di
            idiv bx
            xor ax, si
            and ax, 128
            shr ax, 2
            
            mov bx, es
            shr bx, 8
            inc bx
            xor dx, dx
            div bx
            
            mov bx, cx
            mov byte [gs:bx], al
            jmp _cf2.next

        _cf2.horizon:
            mov bx, cx
            shr byte [gs:bx], 1
            
        _cf2.next:
            loop _cf2.loop
    
    popa
    pop bp
    ret

_star:
; buffer[temp] = 63;
; buffer[temp - 1] = 32;
; buffer[temp + 1] = 32;
; buffer[temp - 320] = 32;
; buffer[temp + 320] = 32;
; buffer[temp + 321] = 16;
; buffer[temp + 319] = 16;
; buffer[temp - 319] = 16;
; buffer[temp - 321] = 16;

    mov bx, sp
    mov bx, [bx + 2]
    mov al, 63
    mov [gs:bx], al
    shr al, 1
    mov [gs:bx - 1], al
    mov [gs:bx + 1], al
    mov [gs:bx - 320], al
    mov [gs:bx + 320], al
    shr al, 1
    mov [gs:bx + 321], al
    mov [gs:bx + 319], al
    mov [gs:bx - 321], al
    mov [gs:bx - 319], al
    ret

_clear_buffer:
; Usage: void clear_buffer()
    push di
    xor di, di
    push gs
    pop es
    xor cx, cx
    dec cx
    xor ax, ax
    rep stosb
    pop di
    ret

SEGMENT _DATA CLASS=DATA
lfsr: dw 127
trig_scale: dd 0.0245436926

dw ':)'

SEGMENT _BSS CLASS=BSS
SEGMENT _BSSEND CLASS=BSSEND
GROUP DGROUP _TEXT _DATA _BSS _BSSEND
