;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;
;Aim:  256 bytes
;Log:  400+, 268, 264, 238 bytes.
;
;by:    Bushy, the dopey git.
;date:  09-Oct-1998.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

number_1        equ     32000

fred    SEGMENT PARA PUBLIC 'fred'
        ASSUME cs:fred
        dq      32 dup (?)
        .386

start:  push    06000h
	pop	es
        mov     al, 013h
	int     10h

@main:  inc     si
	cmp	si, number_1
	jl	@main2

@main1: push    ax
        push    bx
        mov     cx, word ptr @@_e
        mov     dx, word ptr @@_f
        call    @@_call
        mov     word ptr @@_e, cx
        mov     word ptr @@_f, dx
        mov     cx, word ptr @@_c
        mov     dx, word ptr @@_d
        call    @@_call
        mov     word ptr @@_c, cx
        mov     word ptr @@_d, dx
        mov     cx, word ptr @@_a
        mov     dx, word ptr @@_b
        call    @@_call
        mov     word ptr @@_a, cx
        mov     word ptr @@_b, dx



		

@waydownhere:
        push    es
        pop     ds
        push    0a000h
        pop     es
        mov     cx, 0ffffh
        xor     si, si
        xor     di, di
        rep     movsw

        dec     cx
        push    ds
        pop     es
        xor     ax, ax
        rep     stosw

        push    cs
        pop     ds
        pop     bx
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;READ keyboard for <ESC>
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	in      al, 060h
        dec     ax
        pop     ax
	je      @quit

@main2:;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; RANDOM NUM.  ax = -32768 to +32768.    
; random number = "AX".                                     "GET A DOG UP YA"
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
        imul    ax, 3
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Determines which point (0,0), (320, 0) or (320, 200) to go to.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
	cmp     ax, -10923
	jg      @2
        db      081h, 0C5h      ; add   bp, 00000h
@@_a    db      000h, 000h
        db      081h, 0C3h      ; add   bx, 00000h
@@_b    db      000h, 000h
        jmp     @calc
@2:     cmp     ax, 10923
        jg      @3
@@_c    equ     $+2
        add     bp, 319
        db      081h, 0C3h      ; add   bx, 00000h
@@_d    db      000h, 000h
        jmp     @calc
@@_e    equ     $+2
@3:     add     bp, 160
@@_f    equ     $+2
        add     bx, 199
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;Calculate the two formula's for the next pixel... 
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
@calc:  shr     bp, 1
        shr     bx, 1
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;PUTPIXEL routine. (x,y) -> (bp, bx)
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
        mov     cx, 00904h
        call    @@_putp

	mov	dx, 199
	sub	dx, bx
        mov     bx, dx
        mov     cx, 0050Ah
        call    @@_putp

	jmp     @main

@quit:  mov    ax, 0003h
	int    10h
	retn


@@_putp:imul    di, bx, 320
        mov     byte ptr es:[di+bp], cl
        mov     dx, 320
        sub     dx, bp
        add     di, dx
        mov     byte ptr es:[di], ch
        ret


@@_call:cmp     cx, 318  ;(319, inc Y)
        jl      @e
        dec     cx
        inc     dx
@e:     cmp     dx, 198  ;(dec X, 199)
        jl      @f
        dec     cx
        dec     cx
@f:     cmp     cx, 2
        jg      @g
        cmp     dx, 2
        jle     @g
        dec     cx
        dec     dx
@g:     inc     cx
        ret

fred    ENDS
END     start
