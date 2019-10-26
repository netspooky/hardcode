; pxor - 256b pc\dos intro - by wbcbz7 z8.o4.0x7e1
; works even on 8088\CGA\pcquacker ;)

format binary
org 0x100
use16

; data start address
rdata   equ     0x300

sprite  equ     ((rdata + 255) and (not 255))   ; sprite location (256 byte align)
sintab  equ     (sprite + (64*64))              ; sintab location (256 byte align)

start:
        ; set mode 0x1 (40x25 color)
        inc     ax                      ; ax = 0 on startup
        int     0x10
        
sprgen:
        ; ---------------------------------
        ; generate sprite [64x64 attribute]
        mov     di, sprite
        mov     bx, pxlat
        mov     si, 64
    .yloop:
        mov     cl, 64                  ; cx = 0xff at startup, ch = 0
    .xloop:    
        ; get distance
        mov     ax, cx
        sub     ax, 32
        imul    ax
    
        push    ax
        mov     ax, si
        sub     ax, 32
        imul    ax
        pop     dx
    
        add     ax, dx
    
        ; ax = (y^2)+(x^2)
    
        ; sqrt() from fido7.demo.design debris (by manwe?)
        push    bx
        xor     bp, bp
        xor     bx, bx
        mov     dx, ax
        xor     ax, ax
    .sqrt:
        add     bx, bp
        add     bp, 2
        inc     ax
        cmp     bx, dx
        jle     .sqrt
        pop     bx
    
        and     al, 15
        shr     al, 1
        shr     al, 1
        xlatb                   ; grab attribute data from table
        stosb   
    
        loop    .xloop
    
        dec     si
        jnz     .yloop
    
        ; generate sine table
        ; from ad astra by g0blinish
        
        mov     di, sintab
        lea     si, [di + 127]
        
        xor     dx, dx
       ;xor     cx, cx          ; cx = 0 from previous loop
        mov     bl, 66
slp:
        add     dx, cx
        add     cx, 4
        mov     al, dh

        shr     ax, 1
        mov     [di], al
        mov     [si + 128], al  ; unfortunaly can't optimise it further :( 

        neg     al
        add     al, 32
        mov     [si], al
        inc     di
        mov     [di + 127], al
        
        dec     si
        dec     bl
        jnz     slp
        ; sine in [0, 32] range
        
        ; get textmode segment
        mov     bh, 0xB8        ; bl = 0 from previous loop
        mov     es, bx
        
        ; disable damn cursor
        mov     ah, 1
        mov     ch, 0x20
        int     0x10
        
        ; enable speaker
        in      al, 0x61
        or      al, 3
        out     0x61, al
        
        ; main loop
        xor     bp, bp          ; frame counter
_loop:
        mov     si, sintab
        mov     ax, bp
        mov     [.char], al
        xor     ax, ax
        mov     cl, 6           ; log2(64) - for adjusting address
        
        ; wait for retrace
        mov     dx, 0x3DA
    .retr2:
        in      al, dx
        and     al, 8
        jnz     .retr2    
    .retr1:
        in      al, dx
        and     al, 8
        jz      .retr1
        
        ; grab pos for first sprite
        mov     bx, bp
        add     bl, dl          ; bl += 0xDA
        mov     dx, bp
        shr     dx, 1           ; adjust it
        add     bl, dl
        
        xor     bh, bh
        
        mov     al, [si + bx]
        shl     ax, cl
        mov     bl, dl
        mov     bl, [si + bx]
        or      bx, ax
        add     bh, (sprite shr 8)
        push    bx
        xor     ah, ah
        
        ; grab pos for second sprite
        mov     dx, bp
        mov     bx, bp
        shr     bx, 1           ; adjust it
        add     bl, dl
        
        xor     bh, bh
        
        mov     al, [si + bx]
        shl     ax, cl
        mov     bl, dl
        mov     bl, [si + bx]
        or      bx, ax
        add     bh, (sprite shr 8)
        pop     si
        
        ; si - 1st, bx - 2nd
        xor     di, di
        
        ; lay 'em
        mov     dl, 25
    .y_loop:
        mov     cx, 40
    .x_loop:
        lodsb
        add     al, [bx]
        mov     ah, al
        
        ; fcking fasm
        db      0xB0        ; mov al, ?
.char   db      0

        stosw
        
        inc     bx
        loop    .x_loop
        
        add     bx, (64 - 40)
        add     si, (64 - 40)
        dec     dl
        jnz     .y_loop

        inc     bp
        
        ; sound
        lea     ax, [bp + si]
        add     ax, bx
        and     al, 0x7F
        add     al, 0x20
        out     0x42, al
        
        ; kbhit()
        mov     ah, 1
        int     0x16
        jz      _loop
        
        ; exit
        ; disable speaker
        in      al, 0x61
        and     al, 0xFC
        out     0x61, al
        
        ret
        
        ; stuck in 0x1 mode (sorry, no bytes left for mode save\restore)
        
; attribute data
pxlat   db      0x21, 0x13, 0x36, 0x18