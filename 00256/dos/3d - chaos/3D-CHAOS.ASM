;컴컴컴컴컴컴
;3D - CHAOS.
;
;   ..bushy..
;
;컴컴컴컴컴컴

code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
        dq      32 dup (?)
        .386

start:  push    06000h
        pop     es
        mov     al, 013h
        int     10h
@@_1:   inc     si
        cmp     si, 30000
        jne     @@_3
        push    ax
        mov     cx, word ptr @@_e
        mov     dx, word ptr @@_f
        push    word ptr @@_flag1
        call    @@_8
        pop     word ptr @@_flag1
        mov     word ptr @@_e, cx
        mov     word ptr @@_f, dx
        mov     cx, word ptr @@_c
        mov     dx, word ptr @@_d
        push    word ptr @@_flag2
        call    @@_8
        pop     word ptr @@_flag2
        mov     word ptr @@_c, cx
        mov     word ptr @@_d, dx
        mov     cx, word ptr @@_a
        mov     dx, word ptr @@_b
        push    word ptr @@_flag3
        call    @@_8
        pop     word ptr @@_flag3
        mov     word ptr @@_a, cx
        mov     word ptr @@_b, dx
        push    es
        push    es
        pop     ds
        push    0a000h
        pop     es
        mov     cx, 0fffeh
        xor     si, si
        xor     di, di
        rep     movsw
        dec     cx
        pop     es
        xor     ax, ax
        rep     stosw
        push    cs
        pop     ds
	in      al, 060h
        dec     ax
        pop     ax
	je      @quit

@@_3:   imul    ax, 3
	cmp     ax, -10923
        jg      @@_4
        db      081h, 0C5h      ;how does one force TASM to compile a
@@_a    db      080, 000h       ; 4 byte opcode for MOV BP, 0080h
        db      081h, 0C3h      ; or even a MOV BX, 0000h?
@@_b    db      050, 000h       ; (Used for self mod code.)
        jmp     short @@_6
@@_4:   cmp     ax, 10923
        jg      @@_5
        db      081h, 0C5h
@@_c    db      160, 000h
        db      081h, 0C3h
@@_d    db      150, 000h
        jmp     short @@_6
@@_5:   db      081h, 0C5h
@@_e    db      020, 001h
        db      081h, 0C3h
@@_f    db      25, 000h
@@_6:   shr     bp, 1
        shr     bx, 1
        imul    di, bx, 320
        mov     byte ptr es:[di+bp], 4
        mov     byte ptr es:[di+bp-12], 9
        jmp     @@_1

@quit:  mov    ax, 0003h
	int    10h
	retn

@@_8:   pop     di
        pop     ax
        cmp     al, 1
        jne     @b
        cmp     cx, 317
        jl      @a
        mov     al, 0
@a:     inc     cx
        jmp     @d
@b:     cmp     cx, 12
        jg      @c
        mov     al, 1
@c:     dec     cx
@d:     cmp     ah, 1
        jne     @f
        cmp     dx, 197
        jl      @e
        mov     ah, 0
@e:     inc     dx
        jmp     @h
@f:     cmp     dx, 12
        jg      @g
        mov     ah, 1
@g:     dec     dx
@h:     push    ax
        jmp     di


@@_flag1   dw ?
@@_flag2   dw ?
@@_flag3   dw ?

   code    ENDS
END     start

