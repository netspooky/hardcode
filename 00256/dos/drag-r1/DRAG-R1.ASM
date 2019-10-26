count   equ     32767

code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	.386
	ORG     100h
start:					;assumes BX= 00000h
        push    02000h
        pop     es
        mov     al, 0013h
        int     10h

@011a:  inc     si
        cmp     si, count
        jl      @0185

@@_a    equ     $+1
        mov     cx, 000A0h
@@_b    equ     $+1
        mov     dx, 00050h
        cmp     cx, 0118h
        jl      @@_0
        dec     cx
        inc     dx
@@_0:   cmp     dx, 160
        jl      @@_1
        dec     cx
        dec     cx
@@_1:   cmp     cx, 80
        jg      @@_2
        cmp     dx, 80
        jl      @@_2
        dec     cx
        dec     dx
@@_2:   inc     cx
        mov     word ptr @@_a, cx
        mov     word ptr @@_b, dx

        push    ax
        push    es
        pop     ds
        push    0a000h
        pop     es

        mov     cx, 0fffeh
        push    cx
        xor     si, si
        xor     di, di
        rep     movsw

        pop     cx
        push    ds
        pop     es
        xor     ax, ax
        rep     stosw

        push    cs
        pop     ds

        in      al, 60h
        cmp     al, 01
        pop     ax
        jz      @@_quit

@0185:  imul    ax, 3
        mov     cx, bx
        add     cx, bp
        mov     dx, bx
        neg     dx
        add     dx, bp
        test    ax, ax
        jg      @01ad
        add     dx, 75
        sub     ax, cx
        mov     bx, word ptr @@_a
        shr     bx, 1
        add     cx, bx
        mov     bx, word ptr @@_b
        shr     bx, 1
        add     dx, bx
        jmp     @01c8

@01ad:  add     dx, 125
        mov     bx, 320
        sub     bx, word ptr @@_a
        shr     bx, 1
        add     cx, bx
        mov     bx, 200
        sub     bx, word ptr @@_b
        shr     bx, 1
        add     dx, bx
        add     ax, cx

@01c8:  shr     cx, 1
        shr     dx, 1
        mov     bx, cx
        mov     bp, dx

        imul    di, dx, 320
        add     di, 150
        mov     byte ptr es:[di+bx], 2
        jmp     @011a

@@_quit:mov     ax, 0003h
        int     10h
        ret

code    ends
end     start

