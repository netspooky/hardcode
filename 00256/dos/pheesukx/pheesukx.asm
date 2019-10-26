; pheesukx - 250b shitro by wbcbz7 13.o5.2o17 - qbparty2017
; definitely last place intro :)

; coded in 3-4 hours tyring to make a freedir tunnel but completely failed
; so adding some cancered palette should save it :)

; breaking <10fps limit even under vmware (not counting real HW such as cel300a :D)

format binary
org 0x100

; vars

xres            =     320
yres            =     160

tunsize         equ     40000.0f   ; squared

start:  
        mov     al, 0x13    ; ax = 0 at startup
        int     0x10
        
        mov     bh, 0x80
        mov     ds, bx      ; texture offset
        mov     es, bx      ; and once again  
        mov     gs, bx      ; and once again  
        
        mov     dx, 0x3C8
        xchg    cl, ch
        xor     ax, ax
        out     dx, al
        inc     dx
        inc     cx
    .palloop:
        mov     al, cl
        out     dx, al
        shr     al, 1
        out     dx, al
        add     al, cl
        shr     al, 2
        out     dx, al
        inc     cx
        jnz     .palloop
        
        ; silly XOR pattern :)
        ; cx = 0 at end
    .texloop:
        in      al, 0x40
        sar     al, 5
        add     al, cl
        or      al, ch
        xor     al, cl
        stosb
        loop    .texloop
        
        mov     cx, 0xA190
        mov     es, cx          ; setup video segment
        
        push    cs
        pop     ds
        
        ; main loop
        xor     bp, bp
mainloop:
        xor     di, di
        ; no wait for retrace this time
        
        mov     dx, yres
    .y_loop:
        mov     cx, xres
    .x_loop:
        mov     ax, dx
        sub     ax, yres/2
        mov     [tmp], ax
        fild    word  [tmp]
        fmul    dword [_1fov]       ; diry
        fst     st2                 ; diry ? diry
        fmul    st0, st0            ; diry^2 ? diry
        
        mov     ax, cx
        sub     ax, xres/2
        mov     [tmp], ax
        fild    word  [tmp]
        fmul    dword [_1fov]       ; dirx diry^2 ? diry
        fst     st2                 ; dirx diry^2 dirx diry
        
        ; normalizing
        fmul    st0, st0            ; dirx^2 diry^2 dirx diry
        faddp   st1, st0            ; dirx^2+diry^2 dirx diry
        fld1                        ; 1.0f dirx^2+diry^2 dirx diry
        faddp   st1, st0            ; dirx^2+diry^2+1.0f dirx diry
        fsqrt                       ; sqrt(dirx^2+diry^2+1.0f)=l dirx diry
        
        fdiv    st2, st0
        fdiv    st1, st0
        fld1
        fdivrp  st1, st0            ; 1/l diry/l dirx/l
        
        ; insert rotation here
        fxch    st1
        fld     st1                 ; dir.y dir.x dir.y dir.z
        fld     st1                 ; dir.x dir.y dir.x dir.y dir.z
        mov     [tmp], bp
        fild    word [tmp]
        fdiv    dword [sc256]
        fsincos                     ; sin(bp) cos(bp) dir.x dir.y dir.x dir.y dir.z
        fxch    st1
        fmul    st2, st0
        fmulp   st5, st0            ; cos(bp) dir.x dir.y dir.x dir.y dir.z
        fmul    st2, st0
        fmulp   st3, st0            ; dir.x dir.y dir.x dir.y dir.z
        faddp   st2, st0            ; dir.y dir.x dir.y+dir.x dir.z
        fsubp   st2, st0
        fxch    st1
        
        ; calculate a
        fld     st2
        fmul    st0, st0
        fld     st2                 ; dir.y dir.x dir.z dir.y dir.x
        fmul    st0, st0            ; dir.y^2 dir.x^2 dir.z dir.y dir.x
        faddp   st1, st0            ; dir.y^2+dir.x^2=a dir.z dir.y dir.x
        
        ; calculate delta
        fld     dword [tunsz]       ; c a dir.z dir.y dir.x
        ;fmul    dword [_2]
        ;fmul    dword [_2]
        
        ; hahahahaha!
        ; as we know, common discriminant formaula suggests us to
        ; do multiplies by 2, 4 and other shit. but did it really needed? :)
        
        fmul    st0, st1            ; 4*a*c a dir.z dir.y dir.x
        fsqrt                       ; sqrt(4*a*c)=delta a dir.z dir.y dir.x
        
        ; calculate t
        fdivrp  st1, st0
        ;fdiv    dword [_2]          ; 0.5*delta/a=t dir.z dir.y dir.x
        
        ; lerp
        fmul    st3, st0            ; t dir.z dir.y dir.x*t
        fmul    st2, st0            ; t dir.z dir.y*t dir.x*t
        fmulp   st1, st0            ; dir.z*t dir.y*t dir.x*t
        
        ; calculate u
        fistp   word  [tmp]         ; i.y i.x
        mov     bl, byte [tmp]
        add     bx, bp
        
        ; calculate v
        fpatan
        fmul    dword [sc256]
        fistp   word  [tmp]
        
        mov     bh, byte [tmp]
        mov     al, [gs:bx]
        stosb
        
        dec     cx
        jnz     .x_loop
        dec     dx
        jnz     .y_loop
        
        inc     bp
        
        ; kbhit()
        mov     ah, 1
        int     0x16
        jz      mainloop
        
        ; end :)
        ret
        
vars:

;fov     equ 100.0f           ; field of view

; fckin fasm is unable to calculate floating point expressions >_<

_2      dd  2.0f
_1fov   dd  0.01f            ; 1/fov
sc256   dd  162.97f          ; something like 2*256.0f/pi
tunsz   dd  tunsize

; unintialized data
tmp     dw ?





