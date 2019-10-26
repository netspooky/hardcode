number_1        equ     2000

code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h
.386
start:  push    0a000h
        pop     es
        mov     al, 0013h
        int     10h
        mov     dx, 03c8h
        out     dx, al
        inc     dx
@0113:  sub     al, al
        out     dx, al
        out     dx, al
        mov     al, cl
        shr     al, 02
        out     dx, al
        loop    @0113

@main:  inc     si
        cmp     si, number_1
        jl      @main2
@main1: push    cx
        mov     cx, word ptr @@_e
        mov     dx, word ptr @@_f
        test    cx, cx
	jg      @a
        dec     dx
        inc     cx
@a:     test    dx, dx
	jg      @b
        inc     cx
        inc     cx
@b:     cmp     cx, 319  ;(319, dec Y)
	jl      @c
        cmp     dx, 198
	jg      @c
        inc     cx
        inc     dx
@c:     mov     word ptr @@_e, cx
        mov     word ptr @@_f, dx
@d:     mov     cx, word ptr @@_a
        mov     dx, word ptr @@_b
        cmp     cx, 319  ;(319, inc Y)
	jl      @e
        dec     cx
        inc     dx
@e:     cmp     dx, 199  ;(dec X, 199)
	jl      @f
        dec     cx
        dec     cx
@f:     test    cx, cx
	jg      @g
        cmp     dx, 1
	jl      @g
        dec     cx
        dec     dx
@g:     inc     cx
        mov     word ptr @@_a, cx
        mov     word ptr @@_b, dx
        dec     word ptr @@_e
        xor     si, si
        pop     cx

       cmp     flag1, 1
       je      @here2
@here1: cmp     cx, 254
       jne     @here12
       mov     flag1, 1
       jmp     short   @main2
@here12:inc     cx
       jmp     short   @main2
@here2: cmp     cx, 1
       jne     @here22
       mov     flag1, 0
       jmp     short   @main2
@here22:dec     cx

;        inc     cx;count10
        push    ax
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;READ keyboard for <ESC>
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
        in      al, 060h
        cmp     al, 01
        pop     ax
        je      @quit
@main2:;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; RANDOM NUM.  ax = -32768 to +32768.    
; random number = "AX".                                     "GET A DOG UP YA"
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
        imul    ax, 3
        inc     ax
;----------------------------------------------------------------
; Determines which point (0,0), (320, 0) or (320, 200) to go to.
;----------------------------------------------------------------
	cmp     ax, -10923
	jg      @2
        db      081h, 0C5h      ; add   bp, 00000h      ;a
@@_a    db      000h, 000h
@@_b equ $+2
        add     bx, 199
	jmp     short @calc
@2:     cmp     ax, 10923
	jg      @3
        add     bp, 160
        add     bx, 99
        add ax, 3
        jmp     short @calc
@3:     db      081h, 0C5h      ; add   bp, 00000h      ;a
@@_e    db      000h, 000h
@@_f    equ     $+2
        add     bx, 199
;---------------------------------------------------
;Calculate the two formula's for the next pixel... 
;---------------------------------------------------
@calc:  shr     bp, 1
	shr     bx, 1                           
;------------------------------------
;PUTPIXEL routine. (x,y) -> (bp, bx)
;------------------------------------
        imul    di, bx, 320
        mov     dx, 319
        sub     dx, bp
        add     di, dx
        mov     byte ptr es:[di], cl;count10
	jmp     @main

@quit:  mov    ax, 0003h
	int    10h
	retn

flag1 db ?

   code    ENDS
END     start









;  _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _
;_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_
; \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/

