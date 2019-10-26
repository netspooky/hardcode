°ÍHæ!¾¹_ü¬Í)âû°æ!Í ;So you could unpack this! What a hard encoding, eh? :)
;If you use this stuff for base for your product, or you can optimize this,
;please send those to me!
;'bout the comments:If you're a good coder, you don't need a plenty of comments!

;Keret:
xx1=1
yy1=3
xx2=319
yy2=198
.Model Tiny
.386
.Code
Org 100h

.Startup
        mov     al,13h
        int     10h

        mov     ah,4ah           ; Memory allocation
        mov     bh,10h;4096      ; Bx *16 bytes
        int     21h
        mov     ah,48h
        int     21h
        mov     fs,ax
        mov     es,ax
;        xor di,di
kor2:
        mov     bp,100h              ; lightmap : sqrt (si*si)+(bp*bp)
kor3:                               ;(si=si-128; bp=bp-128 for centering)
        lea     ax,[bp-80h]
        imul    al
        xchg    dx,ax
        lea     ax,[si-80h]
        imul    al
        add     ax,dx
        mov     K,ax
        fild    K
        fsqrt
        fistp   K
        mov     ax,K
;        add     al,ah ;To kill an ugly jumping pixel; but almost invisible
        sub     al,7dh
        jc      short kor4
        db      0d6h  ;set al to carry -=> 0 (undocumented)
kor4:
        stosb
        dec     bp
        jnz     kor3
        dec     si
        jnz     kor2


        mov     ah,48h
;        mov     bh,10h;x,4096
        int     21h
        mov     ds,ax
        mov     di,-5*320
backg:                         ;backg: 1+random(16)+([x-320]+[x-319])/2
        add     si,cx
        rol     si,cl
        ror     cx,1
        add     cx,1234h
        lea     ax,[si-bp]
        sar     ax,12
        inc     ax
        mov     dl,[di]
        inc     di
        mov     bl,[di]
        add     bx,dx
        shr     bx,1
        add     ax,bx
        mov     [di+319],al
        dec     bp
        jnz     backg

        mov     dx,3c8h        ; grey palette
        xchg    ax,bp
        out     dx,al
        inc     dx
col:
        mov     cl,6
zizz:
        out     dx,al
        loop    zizz
        dec     al
        jnz     col
Main:
        push    ds
        push    cs
        pop     ds

        call    one             ; Calculating the path
        fcos                    ; (the proc is exist only to size-shorting)
        fimul   Const120
        fistp   K
        mov     ax,K

        call    one
        fsin
        fimul   Const35
        fistp   K
        mov     bp,K
        inc     Alfa ;A l‚p‚sk”z
        push    0a000h
        pop     es
        pop     ds
        mov     di,-7*320+64-xx1
        mov     cl,yy2-3
I2:     mov     si,xx2+1 ;-1 **
I1:
        mov     bl,ds:[di+1]   ;(bl=x pixel difference)
        sub     bl,ds:[di-1]
        sbb     bh,bh
        add     bx,si
        sub     bx,ax
        or      bh,bh
        jnz     NoPut

        mov     dl,ds:[di+320] ;(bh (here dx)= y p.diff.)
        sub     dl,ds:[di-320]
        sbb     dh,dh
        add     dx,cx
        sub     dx,bp
        jl      NoPut

        mov     bh,dl          ;bx=a pixel's place on the lightmap-the color
        mov     bl,fs:[bx]
        mov     es:[di],bl
NoPut:
        dec     di
        dec     si
        jnz     I1
        loop    I2
        mov     ah,1
        int     16h
        jz      main
        mov     ax,3
        int     10h
        ret

one proc
        fldpi
        fidiv   Const180
        fimul   Alfa
        ret
one endp

Const180 dw     180
Const120 dw     120
Const35 dw      35
Alfa    dw      270
Author  db      'Carrot'
K       dw      ?

End






                            Sorry, dudez!
Don't worry if you can't use this source. You may be a looser.
My goal isn't to do this unavailable,but do it for those,who're worthy for it.

      I hope the force may be with ya: Thomas Carrot / B.C.Div (Ex Thitanium)