p386
model   tiny
segment bxxx    use16 'code'
        assume  cs:bxxx,ds:bxxx,es:bxxx,fs:bxxx,gs:bxxx,ss:bxxx
        org     100h
        entry:
        mov     ax,1130h
        mov     bh,06h
        int     10h
        push    es
        push    cs
        pop     es
        pop     ds
        mov     si,bp
        mov     di,0200h
        mov     cx,0800h
        rep     movsw
        push    cs
        pop     ds
        mov     ax,0013h
        int     10h
        push    0a000h
        pop     es
        mov     di,24*320
        mov     ah,07h
        mov     bx,offset text
        mov     cl,60h-3*8
        mov     dx,1080h
      @textloop:
        movzx   si,byte ptr [bx]
        shl     si,04h
        add     si,0200h
        push    di
      @yloop:
        lodsb
      @bitloop:
        call    @delay
        test    al,dl
        jz      short @nopixel
        xchg    al,ah
        stosb
        stosb
        stosb
        stosb
        stosb
        xchg    al,ah
        jmp     short @goon
      @nopixel:
        add     di,0005h
      @goon:
        ror     dl,01h
        cmp     dl,80h
        jne     short @bitloop
        add     di,320-40
        dec     dh
        jnz     short @yloop
        mov     dh,10h
        pop     di
        add     di,40
        inc     bx
        dec     cl
        pushf
        test    cl,07h
        jnz     short @nowrap
        add     di,320*16
        inc     ah
      @nowrap:
        popf
        jnz     short @textloop
        mov     bl,100
        sub     di,di
        mov     si,64000-320
        xor     al,al
      @c1:
        mov     cx,320
        rep     stosb
        add     di,320
        push    di
        mov     di,si
        mov     cx,320
        rep     stosb
        sub     si,2*320
        pop     di
        call    @delay
        call    @delay
        call    @delay
        call    @delay
        dec     bl
        jnz     short @c1
;      @wait:
;        mov     ah,00h
;        int     16h
;        cmp     al,27
;        jne     short @wait
        mov     ax,0003h
        int     10h
        retn
        text:   db '.title  '
                db '256Bytro'
                db '.code   '
                db 'ClouSeau'
                db '.msg    '
                db 'thnx for'
                db 'FIASKO98'
                db '.warning'
                db 'the end '
      @delay:
        push    cx
        mov     ecx,22222h
      @d1:
        dec     ecx
        jnz     short @d1
        pop     cx
        retn
      @align:   db '$'
ends    bxxx
end     entry