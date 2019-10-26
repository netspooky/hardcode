
            ;From 1027 bytes to 256 bytes. Not bad size optimising.


code    SEGMENT PARA PUBLIC 'code'
        ASSUME cs:code, ds:code, es:code, ss:code
        dq      32 dup (?)
        .386

start   proc    near
        mov     al, 13h
        int     10h

        mov     di, offset dac
        push    di
        mov     dl, 63
        sub     cl, cl
@@_1:   sub     al, al
        stosb
        mov     al, cl
        stosb
        stosb
        inc     cx
        cmp     cl, dl
        jle      @@_1

        mov     cl, dl;63
@@_2:   mov     al, dl;63
        sub     al, cl
        stosb
        mov     al, dl;63
        mov     ah, cl
        stosw
        dec     cx
        cmp     cl, 0ffh
        jne     @@_2
        inc     cx

@@_3:   mov     al, dl;63
        stosb
        sub     al, cl
        mov     ah, cl
        stosw
        inc     cx
        cmp     cl, 64;dl
        jl      @@_3

        mov     cl, 64;dl
@@_4:   mov     al, cl
        dec     ax
        stosb
        stosb
        stosb
        loop    @@_4

        push    0a000h
        pop     es

        pop     si
        mov     dx, 3c8h
        out     dx, al
        sti
check:  mov     dx, 3dah
        in      al, dx
        test    al, 8
        jz      check
        mov     cx, 256
step:   mov     dx, 03c9h
        lodsb
        out     dx, al
        lodsb
        out     dx, al
        lodsb
        out     dx, al
        loop    step
        cli

bax:    in      al,  060h
        dec     ax
	je	exit
        xor     di, di
bagain: mov     cx, dirleft[di]
        mov     ax, xvar[di]
        add     ax, cx
        test    ax, ax
        jne     not1
        mov     cx, 1
not1:   cmp     ax, 290
        jne     not2
        mov     cx, -1
not2:   mov	dirleft[di], cx
        mov     xvar[di], ax
	mov     cx, dirup[di]
        mov     ax, yvar[di]
        add     ax, cx
        test    ax, ax
        jne     not3
        mov     cx, 1
not3:   cmp     ax, 170
        jne     not4
        mov     cx, -1
not4:   mov     yvar[di], ax
	mov	dirup[di], cx
        inc     di
        inc     di
        cmp     di, 6
        jne     bagain


        xor     bp, bp
        mov     cx, 3
@@_5:   mov     bx, xvar[bp]
        mov     ax, yvar[bp]
        push    cx
        imul    di, ax, 320
        add     di, bx
        mov     cx, 30
badd2:  push    cx
        mov     cl, 30
badd:   inc     byte ptr es:[di]
        inc     di
        loop    badd
        pop     cx
        add     di, 290
        loop    badd2
        pop     cx
        inc     bp
        inc     bp
        loop    @@_5
        jmp     bax

exit:   mov     ax, 3
	int	10h
        ret
start   endp




xvar    dw   0, 100, 200
yvar    dw 100,   0, 100
dirup   dw   1,   1,   1
dirleft dw   1,   1,   1

dac    db 64 * 12 dup (?)

code      ends
           end start

