.386

ASSUME CS:CODE,DS:CODE


NIBLTB          equ 512+256

NIBLENGTH       equ 5
NIBPOSX         equ 26
NIBPOSY         equ 8
NIBDELTALENG    equ 4
NIBSPEED        equ 30000

CODE    SEGMENT USE16
        org     100h
Start:
        mov     al,13h
        int     10h
;--------------------------- clear nibbles table ------------------------------
;wypelnia zawsze puste pola '-', potem do konca linii (128 pol - 256b) zajete '*'
;i jeszcze cala kolejna linie na zajete
;	----**** ********
;a potem cofe sie o ta jedna linie

        mov     di,NIBLTB
        mov     cx,256
        mov     dx,51
        jmp     @fill2
@fill1:
        mov     cl,80
        xor     al,al			;moze xor	ax,ax
        rep     stosw
        mov     cl,(128-80)+128		;256-80
@fill2:
        mov     ax,2
        rep     stosw
        sub     di,256
        dec     dx
        jnz     @fill1

        mov     fs,ax                   ;// set snake direction (to rite side)
;------------------------------------------------------------------------------
        push    0a000h
        pop     es

        mov     bx,NIBPOSX*2+256*NIBPOSY+NIBLTB
        mov     bp,NIBLENGTH+3-NIBDELTALENG
        jmp     @putrandom
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
mainloop:
        xor     di,di
        mov     si,NIBLTB+256
        mov     cl,199
@yloop:
        mov     dx,319
        push    si
@xloop:
        lodsw
        dec     ax
        mov     ax,33+3*256
        jg      @after1
        mov     al,45
        je      @after1
        mov     al,133
@after1:
        and     ah,dl
        jz      @nopea
        dec     si
        dec     si
@nopea:
        and     ah,cl
        jnz     @okkk
        shr     al,1
@okkk:
        stosb
        dec     dx
        jge     @xloop

        pop     si
        test    cl,3
        jnz     @nope2
        add     si,256
@nope2:
        dec     cx
        jge     @yloop
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
        inc     cx
        
        mov     di,fs
        mov     ah,1
        int     16h
        jz      @nokeypressed

        mov     dl,ah
        mov     si,offset keytab
        mov     cl,4
@checkkey:
        lodsb
        cmp     al,dl
        lodsw
        jnz     @nopekey1
        test    ax,di
        jnz     @nopekey1
        xchg    ax,di
@nopekey1:
        loop    @checkkey

        mov     ax,0c00h
        int     21h
@nokeypressed:
        dec     dl                      ;// check if esc key was pressed
        jz      quiting

        xchg    ax,di
        mov     fs,ax
        add     bl,al
        add     bh,ah
;------------------------------------------------------------------------------
        cmp     [bx],bp
        jae     @notnew
        cmp     word ptr [bx],1
        ja      quiting
@check:
        jnz     @NotNew
;//////////////////////////////////////////////////////////////////////////////
;////////////////////// snake has eaten growing box ///////////////////////////
;//// - lenghten snake & put next random growing box //////////////////////////
;//////////////////////////////////////////////////////////////////////////////
@putrandom:
        add     bp,[dleng]              ;// length += dlength
        add     [dleng],4               ;// dlength += 4

        mov     ax,gs
        add     ax,9248h
        ror     ax,3
        mov     gs,ax
        and     ax,4095
        xchg    ax,dx
find0:
        mov     si,NIBLTB+256
        mov     ch,(50*128)/256
find1:
        lodsw
        or      ax,ax
        jnz     nopefind
        dec     dx
        jle     found
nopefind:
        loop    find1
        jmp     find0
found:
        inc     word ptr [si-2]
;------------------------------------------------------------------------------
;//////////////////////////////////////////////////////////////////////////////
;//////////////// put snake head //////////////////////////////////////////////
@notnew:
        mov     word ptr ds:[bx],3
@after:
;------------------------------------------------------------------------------
        mov     si,NIBLTB
        mov     ch,52
@wwr:
        lodsw
        cmp     ax,3
        jb      @nopenib1
        inc     ax
        cmp     ax,bp
        jbe     @oki1
        xor     ax,ax
@oki1:
        mov     [si-2],ax
@nopenib1:
        loop    @wwr
;------------------------------------------------------------------------------
;//////////////////////////////////////////////////////////////////////////////
;//////////////// wait some time //////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////
        mov     ah,86h
        mov     dx,NIBSPEED
        xor     cx,cx
        int     15h
        jmp     mainloop
quiting:
        ret
;//////////////////////////////////////////////////////////////////////////////
;------------------------------------------------------------------------------
keytab  db 75,0FEh,0
        db 77,2,0
        db 72,0,0FFh
        db 80,0,1
dleng   dw NIBDELTALENG
nibtab  db 256*53 dup (?)


CODE    ENDS

END     Start

