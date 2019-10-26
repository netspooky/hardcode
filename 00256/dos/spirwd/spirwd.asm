; spirwd - 244\247b intro for dihalt'16 by wbc\\bz7 l8.ob.zolb
; blah blah fucking shit blurred spiral (lack of ideas :)
; works on dosbox\mustdie98\dos71

; p133+\fpu\vga\nosound :p

; spirwd.com   - compo version
; spirwd_s.com - safe version

format      binary
org         0x100
use16

safe    equ     0 ; set 1 for safe version compiling

start:
        mov     al, 0x13
        int     0x10
        
        ; set segment regs
        mov     bh, 0xA0
        mov     ds, bx          ; trick
        mov     bh, 0x80        ; temp framebuffer
        mov     es, bx
        
        ; set palette
        ; assume cx = 0x00FF
        mov     dx, 0x3C8
        xchg    cl, ch
        xor     ax, ax
        out     dx, al
        inc     dx
palloop:
        ; set red
        mov     al, cl
        shr     al, 2
        out     dx, al
        ; set green
        shr     al, 1
        mov     ah, cl
        shr     ah, 4
        add     al, ah
        out     dx, al
        ; set blue
        mov     al, cl
        shr     al, 2
        or      al, 0xC0
        add     al, ah
        sbb     ah, ah
        or      al, ah
        out     dx, al
        inc     cx
        jnz     palloop
        
        ; cx = 1 now (why?), clear 64kb temp framebuffer
        dec     cx
        xor     ax, ax
        rep     stosb           ; di = 0xFFFE + wraparound ;)
 
        ; swap segments
        push    ds
        push    es
        pop     ds
        pop     es
        
        ; main loop
        xor     bp, bp          ; probably not needed
mainloop:
        mov     dl, 0xDA
        ; commented since frameloop won't fit into vertical retrace anyway
;retr2:
;        in      al, dx
;        test    al, 8
;        jnz     retr2    
retr1:
        in      al, dx
        test    al, 8
        jz      retr1
        
        ; flip buffer
        xor     si, si
        xor     di, di
        mov     cx, 16000
        rep     movsd
        
        ; fpu magic
        mov     si, sp
        mov     cx, 400         ; num of particles
hujak:
        ; input:  cx - particle number, bp - frame counter
        ; output: ax - x, bx - y
        pusha
        push    ds
        push    cs
        pop     ds
        mov     di, add_vars
        ; hujak spiral hrenovina :)
if safe
        finit
end if 
        fild    word  [ds:si-12]    ; c
        fmul    dword [ds:di+16]    ; i_csc*c
        fcos                        ; cos(i_csc*c)
        fimul   word  [ds:si-4]     ; i*cos(i_csc*c)
        fmul    dword [ds:di+12]    ; i_sc*i*cos(i_csc*c) = i_add
        
        fild    word  [ds:si-12]    ; c i_add
        fmul    dword [ds:di+4]     ; c*c_csc i_add
        fcos                        ; cos(c*c_csc) i_add
        fmul    dword [ds:di]       ; c_sc*cos(c*c_csc) i_add
        fadd    dword [ds:di+8]     ; c_asc+c_sc*cos(c*c_csc) i_add
        fimul   word  [ds:si-12]    ; c*(c_asc+c_sc*cos(c*c_csc)) = c_add i_add
        
        faddp   st1, st0            ; c_add+i_add = angle
        fst     st1                 ; angle angle
        fcos                        ; cos(angle) angle
        fimul   word  [ds:si-4]     ; i*cos(angle) angle
        fistp   word  [ds:si-2]     ; angle
        fsin                        ; sin(angle)
        fimul   word  [ds:si-4]     ; i*sin(angle)
        fistp   word  [ds:si-8]     ; -
        pop     ds
        popa
        
        add     ax, 160
        add     bx, 101
        cmp     ax, 318
        jae     .next
        cmp     bx, 198
        jae     .next
        
        ; plot to screen
        imul    di, bx, 320         ; well...
        add     di, ax
        mov     al, 0xFF
        mov     [ds:di], al
        mov     [ds:di+1], al
        mov     [ds:di-1], al
        mov     [ds:di+320], al
        mov     [ds:di-320], al
        
.next:
        loop    hujak
        
        ; blur (cx = 0 from previous routine)
        ; address wrapping included :)
        lodsb
.blur:
        add     al, [ds:si+1]
        rcr     al, 1
        mov     ah, [ds:si+320]
        add     ah, [ds:si-320]
        rcr     ah, 1
        add     al, ah
        rcr     al, 1
        mov     [ds:si], al
        inc     si
        loop    .blur
        
        inc     bp
        
        ; kbhit()
        mov     ah, 1
        int     0x16
        jz      mainloop
        
        ; end :)
        ret
        
; additional vars
add_vars:
c_sc    dd      0.005f
c_csc   dd      0.03f
c_asc   dd      0.02f
i_sc    dd      0.41f
i_csc   dd      0.004f

; x = i*cos((c_asc + c_sc*cos(c_csc*c))*c + i_sc*cos(i_csc*c)*i);