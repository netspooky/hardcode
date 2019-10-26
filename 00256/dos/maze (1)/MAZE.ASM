;aim: 256
;280,

number_1        equ     15000
Colour	equ	10
Colour2	equ	2

;	1 = D. Blue	5 = Purple	9  = Blue	13 = purple
;	2 = Green 	6 = Brown/org?	10 = L.Green	14 = yellow
;	3 = Cyan	7 = White	11 = L.blue	15 = white
;	4 = Red		8 = Grey	12 = red	16 = black

code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h
.386
start:  push    06000h
	pop	es
        mov     ax, 013h
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
@@_c    db      199 , 000
        db      081h, 0c3h
@@_d    db      000 , 000
	jmp     short @calc
@3:     mov     di, 16384
	cmp	ax, di
	jg	@4
        db      081h, 0c5h
@@_e    db      000 , 000
        db      081h, 0c3h
@@_f    db      199 , 000
	jmp	short @calc
@4:     db      081h, 0c5h
@@_g    db      199 , 000
        db      081h, 0c3h
@@_h    db      199 , 000
;---------------------------------------------------
;Calculate the two formula's for the next pixel... 
;---------------------------------------------------

@calc:	shr	bp, 1				; S := ((S + X[R]) DIV 2);
	shr	bx, 1				; T := ((T + Y[R]) DIV 2);	

;------------------------------------
;PUTPIXEL routine. (x,y) -> (bp, bx)
;------------------------------------
        push    ax                     ;ax = random number (global), so PUSH.
        imul    di, bx, 320
	add	di, bp
	mov     al, colour;09			;  CYAN = 3.   BLUE = 9.
        add     di, 50
        stosb

        sub     di, 5
        mov     al, 2
        stosb

;        call    @@@_@
;        mov     dx, 99
;        sub     dx, bx
;        mov     cx, 99
;        sub     cx, bp
;        imul    di, dx, 320
;        add     di, cx
;        mov     al, colour2;04          ;  CYAN = 3.   BLUE = 9.
;        call    @@@_@
        pop     ax
        jmp     @main

@quit:  mov    ax, 0003h
	int    10h
        ret

;@@@_@:  stosb
;        add     di, 99
;        stosb
;        add     di, 99
;        stosb
;        add     di, 31802
;        stosb
;        add     di, 99
;        stosb
;        add     di, 99
;        stosb
        ret



@@_call:test    cx, cx;cmp     cx, 1   ;(0,dec Y)
        jg      @a
        dec     dx
        inc     cx
@a:     test    dx, dx;cmp     dx, 1   ;(inc X, 0)
        jg      @b
        inc     cx
        inc     cx
@b:     cmp     cx, 199;200;99   ;(319, dec Y)
        jl      @c
        cmp     dx, 199;99
        jg      @c
        inc     cx
        inc     dx
@c:     dec     cx
        ret


   code    ENDS
END     start

