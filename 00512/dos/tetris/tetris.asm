%define BGCOLOR 8 ; 0..6, 8

org 0x7c00

        clc
        jc      boot
        mov     si,0x0100
        mov     di,0x7c00
        mov     cx,512
        rep     movsb
        xchg    ax,cx
        call    play
        ret

boot    mov     sp,0xffff
        push    cs
fall    push    cs
        pop     ds
        pop     es
        mov     dx,0x03f2
        xor     ax,ax
        out     dx,al
        call    play
        jmp     word 0xffff:0x0000

play    inc     ax
        int     0x10
        mov     ah,0x01
        mov     cx,0x2000
        int     0x10
        cli
        xor     ax,ax
        push    ax
        push    ds
        mov     ds,ax
        mov     si,8*4
        mov     di,oldintr
        movsw
        movsw
        movsw
        movsw
        pop     ds
        push    es
        mov     es,ax
        mov     di,8*4
        mov     si,newintr
        mov     ax,cs
        movsw
        stosw
        movsw
        stosw
        pop     es
        call    blc_new
        sti
.play   hlt
        cmp     [play],byte 0x40
        je      .play
        cli
        mov     si,oldintr
        pop     es
        mov     di,8*4
        movsw
        movsw
        movsw
        movsw
        sti
        mov     ax,0x0003
        int     0x10
        ret

timer   dec     byte [fall]
        jnz     intrret
        mov     [fall],byte 4
        call    blc_rem
        inc     byte [blocky]
        call    blc_try
        jc      intrret
        call    blc_new
        jmp     short intrret

keyb    call    blc_rem
        in      al,0x60
        cmp     al,72
        je      .72
        cmp     al,75
        je      .75
        cmp     al,77
        je      .77
        cmp     al,80
        je      .80
        cmp     al,1
        je      .1
.end    call    blc_try
        jmp     short intrret
.1      call    blc_new.exit
        jmp     short .end
.72     xchg    ax,bp
        cmp     al,0
        je      .72_end
        cmp     al,3
        jae     .72_1
        test    ah,1
        jnz     .72_1
        call    blc_rot
        call    blc_rot
.72_1   call    blc_rot
        inc     ah
.72_end xchg    bp,ax
        jmp     short .end
.75     dec     byte [blockx]
        jmp     short .end
.77     inc     byte [blockx]
        jmp     short .end
.80     inc     byte [blocky]
        call    blc_tst
        jc      .80
        dec     byte [blocky]
        call    blc_put
        call    blc_new

intrret mov     al,0x20
        out     0x20,al
        iret

blc_new call    lines
        mov     di,block
        mov     si,blocks
.rand   in      ax,0x40
        and     ax,111b
        dec     ax
        js      .rand
        mov     bp,ax
        shl     ax,1
        add     si,ax
        mov     ax,0x0300
        movsw
        stosw
        call    blc_try
        jc      .end
.exit   dec     byte [play]
.end    ret

blc_rot mov     bx,[block]
        mov     cx,4
        rol     bx,cl
.1      push    cx
        mov     cx,0x0404
.2      rol     bx,cl
        rcl     dx,1
        dec     ch
        jnz     .2
        ror     bx,1
        pop     cx
        loop    .1
        mov     [block],dx
        ret

blc_try call    blc_tst
        pushf
        call    blc_pos
        call    blc_put
        popf
        ret

blc_pos mov     si,bsave
        mov     di,block
        jnc     .ok
        xchg    si,di
.ok     movsw
        movsw
        ret

blc_rem mov     bl,BGCOLOR
        jmp     short blc_put.draw
blc_put mov     bl,9
        add     bx,bp
.draw   stc
        call    blc_pos
        jmp     short blc
blc_tst clc
blc     pushf
        mov     cx,15
.next   mov     ax,1
        shl     ax,cl
        test    [block],ax
        jz      .ok
        mov     ax,cx
        mov     dl,4
        div     dl
        add     ax,[blocky]
        dec     al
        xchg    dx,ax
        popf
        pushf
        call    screen
        jc      .ok
        cmp     al,BGCOLOR
        je      .ok
        popf
        ret
.ok     loop    .next
        pop     ax
        stc
        ret

lines   clc
        mov     dl,20
.y      dec     dl
        js      .end
.newx   mov     dh,9
.x      jc      .x2
        call    screen
        cmp     al,BGCOLOR
        je      .y
        clc
        jmp     short .next
.x2     dec     dl
        jns     .1
        mov     al,BGCOLOR
        jmp     short .2
.1      clc
        call    screen
.2      inc     dl
        xchg    bx,ax
        stc
        call    screen
.next   dec     dh
        jns     .x
        jc      .y
        push    dx
        stc
        call    .newx
        clc
        pop     dx
        jmp     short .newx
.end    ret

screen  push    ds
        pushf
        mov     ax,0xb800
        mov     ds,ax
        mov     al,dl
        mov     ah,40
        mul     ah
        add     al,dh
        adc     ah,0
        shl     ax,1
        add     ax,0x00be
        xchg    si,ax
        popf
        jc      .put
.get    inc     si
        lodsb
        pop     ds
        ret
.put    mov     ah,bl
        mov     al,'Û'
        mov     [si],ax
        pop     ds
        ret

blocks  dw      1632, 1728, 3168, 240, 736, 1248, 2272
newintr dw      timer, keyb

dw 0xaa55

section .bss

block   resw    1
blocky  resb    1
blockx  resb    1
bsave   resb    4
oldintr resd    2
