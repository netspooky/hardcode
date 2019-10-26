%out TinyWorm by Xaya Iccita / Experiment.

.model tiny
.286
.code
        org     100h
s:      mov     ax,cs
        add     ax,4096
        mov     ds,ax
        push    0a000h
        pop     es

        mov     ax,19
        int     10h
        mov     di,64000
        mov     cx,1536
        rep     stosb           ;13h is fine.

        ; si remove pointer, di insert pointer, bp delay
        sub     si,si
        mov     bp,10

        jmp     mkfood

play:   mov     dx,03dah
lb1:    in      al,dx
        test    al,8
        jnz     lb1
lb2:    in      al,dx
        test    al,8
        jz      lb2
        mov     ah,1
        int     16h
        jz      advance
        sub     ah,ah
        int     16h
        cmp     ah,48h
        jne     notup
        mov     cs:cdir,-320
notup:  cmp     ah,50h
        jne     notdn
        mov     cs:cdir,320
notdn:  cmp     ah,4Bh
        jne     notlt
        mov     cs:cdir,-1
notlt:  cmp     ah,4Dh
        jne     advance
        mov     cs:cdir,1

advance:and     bp,bp
        jnz     norem
        lodsw
        xchg    ax,bx
        mov     byte ptr es:[bx],0
        mov     bx,ax
        inc     bp
norem:  dec     bp
        add     bx,cs:cdir
        mov     al,es:[bx]
        and     al,al
        jz      nofix
        cmp     al,00Dh
        je      remove
        mov     ax,3
        int     10h
        ret
nofix:  mov     [di],bx
        inc     di
        inc     di
        mov     byte ptr es:[bx],9
pot     label   byte
        jmp     play

remove: push    bx
        mov     bx,cs:foodo
        sub     ax,ax
        call    pixel
        call    random
        and     ax,63
        mov     bp,ax
        mov     cs:pot+1,offset zot-offset pot-2
        pop     bx
        jmp     nofix

zot:    mov     cs:pot+1,08Bh
mkfood: push    bx
mkfod:  call    random
        and     ax,0fffeh
        mov     bx,ax
        sub     ax,ax
        cmp     word ptr es:[bx],ax
        jnz     mkfod
        cmp     word ptr es:[bx+320],ax
        jnz     mkfod
        mov     cs:foodo,bx
        mov     ax,0d0dh
        call    pixel
        pop     bx
        jmp     play

pixel   proc
        mov     es:[bx],ax
        mov     es:[bx+320],ax
        ret
pixel   endp

;create pseudorandom value in range of 0..65535 which is returned in ax
random  proc                            ;linear random, theoretically
        mov     ax,cs:rseed             ;returns each and every value
        mov     dx,36421                ;between min/max in a series
        mul     dx                      ;of max-min+1 calls
        inc     ax
        mov     cs:rseed,ax
        ret
random  endp

cdir    dw      1

rseed   dw      ?
foodo   dw      ?

        end     s
