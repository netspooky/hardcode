; Rotate Triple X.
; Bushy.   09-October-1998.


number_1        equ     30000

code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h
.386
start:  push    06000h
	pop	es
        mov     al, 013h
	int     10h
@main:  inc     si
	cmp	si, number_1
	jl	@main2
@main1:
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;	(E,F)
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

        mov     cx, word ptr @@_e
        mov     dx, word ptr @@_f
        call    @@_call
        mov     word ptr @@_e, cx
        mov     word ptr @@_f, dx
@d:     mov     cx, word ptr @@_a
        mov     dx, word ptr @@_b
        call    @@_call
        mov     word ptr @@_a, cx
        mov     word ptr @@_b, dx
@h:     mov     cx, word ptr @@_c
        mov     dx, word ptr @@_d
        call    @@_call
        mov     word ptr @@_c, cx
        mov     word ptr @@_d, dx
        mov     cx, word ptr @@_g
        mov     dx, word ptr @@_h
        call    @@_call
        mov     word ptr @@_g, cx
        mov     word ptr @@_h, dx


        push    es
        push    es
        pop     ds
        push    0a000h
        pop     es
        mov     cx, 0fffeh
	sub	si, si
	sub	di, di
        rep     movsw
        dec     cx
        pop     es
        push    ax
        sub     ax, ax
        rep     stosw
        push    cs
        pop     ds

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
;----------------------------------------------------------------
; Determines which point (0,0), (320, 0) or (320, 200) to go to.
;----------------------------------------------------------------
	mov	di, -16384
	cmp     ax, di
	jg      @2
        db      081h, 0c5h
@@_a    db      000 , 000
        db      081h, 0c3h
@@_b    db      000 , 000
	jmp     short @calc
@2:     sub     di, di
	cmp     ax, di
	jg      @3
        db      081h, 0c5h
@@_c    db      099 , 000
        db      081h, 0c3h
@@_d    db      000 , 000
	jmp     short @calc
@3:     mov     di, 16384
	cmp	ax, di
	jg	@4
        db      081h, 0c5h
@@_e    db      099 , 000
        db      081h, 0c3h
@@_f    db      099 , 000
	jmp	short @calc
@4:     db      081h, 0c5h
@@_g    db      000 , 000
        db      081h, 0c3h
@@_h    db      099 , 000
;---------------------------------------------------
;Calculate the two formula's for the next pixel... 
;---------------------------------------------------

@calc:  shr     bp, 1
        shr     bx, 1

;------------------------------------
;PUTPIXEL routine. (x,y) -> (bp, bx)
;------------------------------------
        add     bx, 25
        imul    di, bx, 320
        mov     cl, 10
        call    @@@_@
        add     di, 5
        mov     cl, 2
        call    @@@_@
        jmp     @main

@quit:  mov    ax, 0003h
	int    10h
        ret

@@@_@:  mov     byte ptr es:[di+bp], cl
        mov     byte ptr es:[di+bp+99], cl
        mov     byte ptr es:[di+bp+99+99], cl
        ret



@@_call:test    cx, cx;cmp     cx, 1   ;(0,dec Y)
        jg      @a
        dec     dx
        inc     cx
@a:     test    dx, dx;cmp     dx, 1   ;(inc X, 0)
        jg      @b
        inc     cx
        inc     cx
@b:     cmp     cx, 99   ;(319, dec Y)
        jl      @c
        cmp     dx, 99
        jg      @c
        inc     cx
        inc     dx
@c:     dec     cx
        ret

filler  db 0

   code    ENDS
END     start

