; mikrowave ...---... cc17 ...---... pc256b __.*^^*.__.*^^*.__.*^^*.__.*^^*.__
; --wbcbz7 lzo87e1

format binary

        org     0x100
start:
        ; set VESA banked 320x200 15bpp mode
        mov     ax, 0x4f02
        mov     bx, 0x10d
        int     0x10
        
        ; set third 64k bank
        mov     ax, 0x4f05
        xor     bx, bx
        mov     dx, 2           ; 0x20 for fcking 4kb banks (cirrus logic etc)
        int     0x10
        
        ; center screen so 320x100 "screen" appears in center of screen
        ; and starts rignt on bank position start
        mov     ax, 0x4f07
        mov     dl, 154
        inc     cx              ; cx = 0xff at startup
        int     0x10            ; set (256, 154) start pos
        
        ; set video segment
        mov     ch, 0xA0
        mov     es, cx
        
        ; set virtual screen segment
        mov     ch, 0x80
        mov     ds, cx
        
        xor     bp, bp
frame:

        ; wait for retrace start
        mov     dx, 0x3da
    .retr1:
        in      al, dx
        and     al, 8
        jz      .retr1
        
        ; flip 'n' clear virtual screen
        ; also clears cx to 0
        xor     si, si
        xor     di, di
        mov     cx, (320*100)
    .flip:
        movsw
        mov     word [ds:si-2], 0x5f37
        loop    .flip
        ; cx = 0 after loop
        
        ; draw random horizontal lines
        ; dh = 3 
    .rnd:
        in      al, 0x40
        xor     ax, bp
        mov     di, ax
        imul    di, 640
        mov     cx, 320
    .rndlp:
        sub     [ds:di], word 0x1463
        inc     di
        inc     di
        loop    .rndlp
        ;-----
        dec     dh
        jnz     .rnd
        
        ; draw diagonal lines
        mov     cl, 12
    .lines:
        mov     si, cx
        shl     si, 4
        mov     di, si
        add     si, bp
        sub     si, 1440            ; correction
        shl     si, 1               ; unfortunaly no bytes left for wrap fix, so
        add     di, bp              ; after 5-10 seconds you will notice shifts or 
        shl     di, 2               ; something like that. sorry :)
        neg     di
        mov     dl, 103
    .yloop:
        mov     dh, 24
    .xloop:
        sub     [ds:si], word 0xC43
        add     [ds:di], word 0x421
        inc     si
        inc     si
        dec     di
        dec     di
        dec     dh
        jnz     .xloop
        ;-----
        add     si, (640-50)
        sub     di, (640-46)
        dec     dx              ; dh = 0 from .xloop
        jnz     .yloop
        ;-----
        loop    .lines
        
        ; draw....ehm...dots?
        
        mov     bx, 3200
        mov     dx, 0x3C64      ; also reused floating point constant
    .dots:
        mov     si, bp
        and     si, 0xFE30
        add     si, bx
        shl     si, 3           ; and also reused fp const ;)
    .fp1:
        lea     di, [bx + si]
        xor     di, 0xFDCA
        shr     si, 6
        shl     di, 2

        mov     ax, [ds:si]
        and     ax, dx
        sub     [ds:di], ax
        dec     bx
        jnz     .dots
        
        ; draw sinus hrenovina
        mov     cx, bp
        mov     dx, 0x2d73
    .twister:
        
        push    ds
        push    cs
        pop     ds
        
        ; here is a trick - use PSP stuff for storing temp fpu vals
        ; bx = 0 from previous loop
        
        mov     [bx], cx
        fild    word [bx]           ; y
        fld     st0                 ; y
        fmul    dword [.fp1-2]      ; y*s1        | [.fp1-2]  = 0x388d03e6 = 6.72413E-5
        fmulp   st1, st0
        mov     [bx], bp
        fild    word [bx]           ; fr
        fmul    dword [.dots-4]     ; fr*s2 y*s1  | [.dots-4] = 0x3c64ba0c = 0.013960373
        faddp   st1, st0            ; fr*s2+y*s1
        fsin                        ; sin(y*s1)
        fmul    dword [smul]        ; smul*sin(y*s1) y
        fistp   word [bx]           ; y
        
        mov     di, cx
        add     di, bp
        imul    di, 80
        add     di, [bx]
        sub     di, sp              ; sp = 0xFFFC or something like that, so what about
        shl     di, 1               ; using it for aligning a little? :))
        
        pop     ds
        sub     [ds:di], dx
        sub     dx, 0x842
        and     dx, 0x3DCA
        
        loop    .twister
        
        inc     bp
        
        ; kbhit()
        mov     ah, 1
        int     0x16
        jz      frame
        
        ; exit
        ; since we used PSP fpu temp storage trick, "CD 20" sequence at CS:0
        ; will be probably destroyed, so do int 0x20 instead of ret
        
        ;int     0x20           ; embedded into const ;)
        
        ; this is only one fp const which i decided to not embed into code but place it
        ; as dedicated const. that is far nicer ;)
        
smul    dd      0x417a20cd      ; = 15.633008
