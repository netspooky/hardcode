; entry.asm
;
; asmcompo.org demo by Robert (rob_ert in #asm on EFnet, Robert on Freenode)
; http://robert.zizi.org/

        org     0x100
main:
        mov     ax,0x1000
        mov     es,ax
        mov     ax,0x7c0
        mov     ds,ax
        mov     di,0x100
        xor     si,si
        mov     cx,0x100
        rep     movsw
        jmp     0x1000:foo
foo:
        push    cs
        pop     ds
        push    cs
        pop     es
        mov     ax,0x13
        int     0x10
        mov     di,pal
pal_init:
        mov     cl,0
.wtr:   mov     al,0x3f
        sub     al,cl
        stosb
        mov     ah,cl
        shl     ah,1
        mov     al,0x3f
        sub     al,ah
        stosb
        stosb
        inc     cx
        cmp     cl,0x20
        jb      .wtr
        mov     cl,0
.rtg:   mov     al,0x1f
        stosb
        mov     al,cl
        stosb
        stosb
        inc     cx
        cmp     cl,0x20
        jb      .rtg
        mov     cl,0
.gtb:   mov     al,0x1f
        sub     al,cl
        stosb
        stosb
        mov     al,0x1f
        stosb
        inc     cx
        cmp     cl,0x20
        jb      .gtb
        mov     cl,0
.btw:   mov     al,cl
        shl     al,1
        stosb
        stosb
        mov     al,cl
        add     al,0x1f
        stosb
        inc     cx
        cmp     cl,0x20
        jb      .btw
        call    modpal
        call    setpal
        mov     dx,0x3c8
        mov     al,7
        out     dx,al
        inc     dx
        mov     al,0
        out     dx,al
        out     dx,al
        out     dx,al
        call    clear
draw:
        call    clear
        mov     di,100
        mov     dh,145
        mov     bx,[n]
        call    sin
        add     cx,0x100
        shr     cx,5
        add     dh,cl
.yloop: mov     dl,16
.xloop: push    dx
        call    zline
        pop     dx
        inc     dx
        cmp     dl,256-48
        jb      .xloop
        dec     dh
        dec     di
        jnz     .yloop
        inc     word[n]
        call    modpal
        call    setpal
        call    update
        mov     ah,1
        int     0x16
        jz      draw
        mov     ah,0
        int     0x16
.death:
        jmp     short .death
zline:
        mov     bh,0
        mov     bl,dl
        add     bx,[n]
        call    sin
        xchg    ax,cx
        mov     bh,0
        mov     bl,dl
        shl     bx,1
        add     bx,[n]
        call    sin
        push    dx
        imul    cx
        mov     cx,0xa00
        idiv    cx
        pop     dx
        mov     bh,0
        mov     bl,dh
        shl     bx,1
        call    cos
        xchg    dx,bx
        imul    cx
        mov     cx,0x100
        idiv    cx
        xchg    ax,cx
        mov     al,bh
        shr     al,2
        add     bl,al
yline:
        mov     al,200
        sub     al,bh
        mov     bh,al
        add     bx,buffer
        mov     si,bx
        mov     al,0x80
        neg     cx
        js      .positive
        inc     cx
.neg_loop:
        dec     ax
        dec     ax
        sub     si,256
        mov     [bx],al
        mov     [si],al
        add     bx,256
        loop    .neg_loop
        ret
.positive:
        neg     cx
        inc     cx
.pos_loop:
        add     si,256
        mov     [bx],al
        mov     [si],al
        inc     ax
        inc     ax
        sub     bx,256
        loop    .pos_loop
        ret
clear:
        mov     di,buffer
        xor     ax,ax
        mov     cx,(256*200)/2
        rep     stosw
        ret
update:
        mov     dx,0x3da
.test1: in      al,dx
        test    al,8
        jnz     .test1
.test2: in      al,dx
        test    al,8
        jz      .test2
        push    es
        mov     ax,0xa000
        mov     es,ax
        mov     di,32
        mov     si,buffer
        mov     dx,200
.copyline:
        mov     cx,256/2
        rep     movsw
        add     di,64
        dec     dx
        jnz     .copyline
        pop     es
        ret
cos:
        add     bl,0x10
sin:
        test    bl,0x20
        jnz     .negative
        and     bx,0x1f
        mov     cl,[sine_table+bx]
        mov     ch,0
        ret
.negative:
        and     bx,0x1f
        mov     cl,[sine_table+bx]
        mov     ch,0
        neg     cx
        ret
modpal:
        mov     si,pal
        mov     di,pal2
        mov     cx,0x80
.next:
        lodsb
        push    cx
        mov     bx,[n]
        shr     bx,1
        call    cos
        add     cx,0x100
        shr     cx,5
        add     al,cl
        pop     cx
        stosb
        lodsb
        push    cx
        mov     bx,[n]
        call    sin
        add     cx,0x100
        shr     cx,5
        add     al,cl
        pop     cx
        stosb
        movsb
        loop    .next
        ret
setpal:
        mov     cx,0x80
        mov     al,0x40
        mov     si,pal2
.next:  mov     dx,0x3c8
        out     dx,al
        inc     dx
        push    ax
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        pop     ax
        inc     ax
        loop    .next
        ret
sine_table:
        db      0,25,50,74,98,121,142,162,181,198,213,226,237,245,251,254
        db      255,254,251,245,237,226,213,198,181,162,142,121,98,74,50,25
n       dw      0
        [section .bss]
pal     resb    0x80*3
pal2    resb    0x80*3
buffer:

;times	510-($-$$) db 0
	dw	0xAA55