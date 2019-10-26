; TUNNEL CODE BY FRENZY
; ADAPTED BY SHADE

;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Tunnel table calculation ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters (uses coprocessor)
;úúúú Returns nothing
calctunnel  proc

        push    es

        mov     es, cs:[mandelseg]

        xor     di,di
        mov     bp,200
tytag:  mov     cx,160
txtag:  mov     ax,cx
        sub     ax,80
        mov     bx,bp
        sub     bx,100
        mov     [taux1],ax
        mov     [taux2],bx
        fild    [taux2]
        fild    [taux1]
        fpatan
        fimul   [degs]
        fdiv    [pi]
        frndint
        fistp   [word ptr taux3]
        imul    ax
        xchg    ax, bx
        imul    ax
        add     ax,bx
        mov     [taux1],ax
        fild    [taux1]
        fsqrt
        fistp   [taux1]
        mov     bx,[taux1]
        inc     bx
        mov     ax, 2560
        cwd
        idiv    bx
        shl     ax,8
        and     [word ptr taux3],255
        add     ax,[taux3]
        stosw
        loop    txtag
        dec     bp
        jnz     tytag

        pop     es

        ret
endp    calctunnel


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ Tunnel drawing routine ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters
;úúúú Returns nothing
drawtunnel      proc

        push    ds
        push    es

        mov     bx, [lastbuf]

        mov     [dumpsrc], bx
        mov     [dumpdst], vga

        mov     dx, 400
        mov     ds, cs:[mandelseg]
        mov     es, cs:[texture]
Tunnelmain:
        mov     cx,64000 / 2
        xor     di, di
tunnelloop:

        mov     bp, ds:[di]
        mov     al, es:[bp]
        mov     ah, al
        shr     ah, 1
        add     al, ah
        mov     ah, al

        add     [word ptr di], 514

        push    es
        mov     es, bx
        stosw
        pop     es

        loop    tunnelloop

        push    dx

        push    es
        mov     es, cs:[lastbuf]
        call    difumine
        pop     es

        call    dumpscr

        pop     dx

        dec     dx
        jnz     tunnelmain

        pop     es
        pop     ds

        ret

endp    drawtunnel


;úúúú----ÄÄÄÄÄÄÄÄÄÄÄÄÄ New texture for tunnel ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-----úúúú
;úúúú No input parameters
;úúúú Returns nothing
newtext proc

        push    es

        mov     es, cs:[texture]
        xor     di, di
        mov     cx, 0ffffh/2
nttag1:
        call    random
        mov     dx, ax
        shr     ax, 1
        add     ax, dx
        shr     ax, 1
        stosw
        loop    nttag1

        mov     cx, 4
mixtag2:
        xor     di, di
mixtag1:
        xor     ax, ax
        xor     dx, dx
        mov     al, es:[di+256]
        mov     dl, es:[di-256]
        add     ax, dx
        mov     dl, es:[di-1]
        add     ax, dx
        mov     dl, es:[di+1]
        add     ax, dx
        shr     ax, 2
        stosb
        or      di, di
        jnz     mixtag1

        loop    mixtag2

        pop     es

endp    newtext


