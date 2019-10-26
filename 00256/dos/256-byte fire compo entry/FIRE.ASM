%TITLE "Hehehe 256 byte fire for compo by GB / Weird Magic"

        IDEAL
        DOSSEG
        P386
        JUMPS

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Vertical Retrace]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

MACRO   vr
        mov     dx,03dah
        in      al,dx
        test    al,8
        jz      $-3
ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Palette Decrunch]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

MACRO   makepal
        lea     si,[pal]

;bl should be made zero at this point..but it is still zero since it hasn't been
;used yet
mainpl:
        lea     di,[here]
        xor     bp,bp           ;bp is used
        mov     dl,3            ;aargh
w3l:
        lodsb
        mov     cl,al
        lodsb
        mov     dh,al
        mov     ax,bp           ;was [g]
rl1:
        add     al,dh
        adc     ah,0
        mov     [di+bx],ah      ;put kleur
        add     di,3
        loop    rl1

        mov     bp,ax           ;was [g]
        dec     dl
        jnz     w3l

        inc     bx
        cmp     bx,3
        jb      mainpl
ENDM

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[CODE Segment]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

SEGMENT Cseg
        ASSUME cs:cseg, ds:cseg

        ORG 100h
begin:
        push    0a000h
        pop     es
        mov     al,13h
        int     10h

        makepal

        mov     dx,03d4h
        mov     al,09h
        out     dx,al
        inc     dx
        in      al,dx
        and     al,0f0h
        add     al,3
        out     dx,al

        lea     si,[here]
        xor     al,al
        mov     dx,03c8h
        out     dx,al
        inc     dx
        mov     cx,768
        rep     outsb                   ;yeah fuck it....fuck safety....:)

mainloop:

        vr
        mov     di,320*100
        mov     cl,160
plot:
        mov     ax,32743
        mul     [count]
        add     al,254
        mov     [count],ax
        shr     ax,7
        mov     bp,ax                   ;bp is niet gebruikt
        mov     ah,al
        stosw
        loop    plot

        push    ds
        push    es
        pop     ds                      ;ds niet meer nodig

        xor     di,di
        mov     cl,100
plotl:
        mov     dl,160
plotl2:

        movzx   ax,[di+320]
        movzx   bx,[di+318]
        add     ax,bx
        movzx   bx,[di+640]            ;640
        add     ax,bx
        movzx   bx,[di+322]
        add     ax,bx

        shr     ax,2
        jz      @@10
        dec     ax
@@10:
        mov     ah,al
        stosw
        dec     dl
        jnz     plotl2
        loop    plotl

        pop     ds

        cmp     [star+2],5*320
        ja      update
        mov     [star+0],bp
        mov     [star+2],320*99+6

update:
        mov     di,[star+2]
        add     di,[star+0]
        mov     ax,0ffffh
        stosw
        add     edi,318
        stosw
        sub     [star+2],640

        mov     ah,1
        int     16h
        jz      mainloop

        mov     ax,3
        int     10h
        retn

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[Some DATA shit]ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

LABEL   pal     byte

        db      48, 48, 32, 120,176,0              ;red wave 4,84,82
        db      48, 80, 32, 20,176,112             ;green wave 24,100,38
        db      48,168, 32, 30,176,32              ;blue wave 58,44,56

here    db      768 dup (?)

star    dw      ?,?
count   dw      ?
r       db      ?

ENDS

        END     begin

