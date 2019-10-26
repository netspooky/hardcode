global _vsync
global _ticks
global _set_palette
global _getkey
global _putchar
global _sin

SEGMENT _TEXT CLASS=CODE
    
_set_palette:
; Usage: set_palette(int color, int r, int g, int b)
; Changes the color palette
    mov bx, sp
    mov dx, 3C8h
    mov ax, word [bx + 2]
    out dx, al
    inc dx
    mov ax, word [bx + 4]
    out dx, al
    mov ax, word [bx + 6]
    out dx, al
    mov ax, word [bx + 8]
    out dx, al
    ret

_vsync:
; Usage: vsync()
; Blocks until vertical refresh is complete
    mov dx, 3DAh
L1: in al, dx
    and al, 8
    jnz L1
L2: in al, dx
    and al, 8
    jz L2
    ret

_ticks:
; Usage: ticks()
; Returns current time of day in ticks (ticks occur at 18.2 Hz)
; http://www.merlyn.demon.co.uk/pas-time.htm#L46C
    push 40h
    pop es
    mov ax, word [es:6Ch]
    ret

_getkey:
    xor ax, ax
    in al, 60h
    ret

_putchar:
; Usage: putchar(int x, int y, int c, int buf_seg)
; Y = y;
; for (j = 0; j < FHEIGHT; j++) {
;     X = x;
;     line = alphabet[(c << 3) + j];
;     for (i = 0; i < FWIDTH; i++) {
;         p = line & 0x80 ? 7 : 0;
;         if ((X > 0) && (X < XRES))
;             buffer[X + Y * XRES] = p;
;         line <<= 1;
;         X++;
;     }
;     Y++;
; }
    
    push bp
    mov bp, sp
    pusha
    push fs ; Callee save
    
    mov  es, [bp + 10]
    push 0xF000
    pop fs
    
    mov di, [bp + 6] ; ax = Y = y
    
    xor cx, cx ; j = 0
    _putchar.jloop:
        mov si, [bp + 4] ; dx = X = x
        mov bx, [bp + 8] ; bx = c
        shl bx, 3
        add bx, cx
        add bx, 0xFA6E ; bx = 0xFA6E + (c >> 3) + j
        mov bl, byte [fs:bx] ; bl = line (F000:FA6E contins BIOS 8x8 font)
    
        push cx
        xor cx, cx ; i = 0
        _putchar.iloop:
    
            ; dl = p = (line & 0x80) ? 7 : 0;
            mov bh, bl
            xor dx, dx
            and bh, 0x80
            jz _putchar.L1
            mov dl, 255
            _putchar.L1:

            ; vga[X + Y * XRES] ^= p
            push bx
            mov ax, di
            mov bx, 320
            push dx
            mul bx
            pop dx
            add ax, si
            mov bx, ax
            cmp si, 0
            jl _putchar.L2
            cmp si, 319
            jg _putchar.L2
            xor byte [es:bx], dl
            _putchar.L2:
            pop bx
            shl bl, 1 ; line <<= 1
            
            inc si ; X++
            inc cx ; i++
            cmp cx, 8
            jne _putchar.iloop
    
        pop cx
        inc di ; Y++
        inc cx ; j++
        cmp cx, 8
        jne _putchar.jloop
    
    pop fs
    popa
    pop bp
    ret

_sin:
; Usage: int sin(int x)
; Returns the sine of an integer
    mov bx, sp
    finit
    fild word [bx + 2]
    fidiv word [_sin.scale]
    fsin
    fimul word [_sin.scale2]
    fiadd word [_sin.scale2]
    fistp word [bx + 2]
    mov ax, [bx + 2]
    ret
_sin.scale:
    dw 100
_sin.scale2:
    dw 50


SEGMENT _DATA CLASS=DATA
SEGMENT _BSS CLASS=BSS
SEGMENT _BSSEND CLASS=BSSEND
GROUP DGROUP _TEXT _DATA _BSS _BSSEND
