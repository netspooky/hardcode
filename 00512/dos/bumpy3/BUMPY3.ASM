.Model Tiny   ;(C) Tom Carrot aka buzz armpit
.386          ; thank to : balazs dan, GRGA, P.Rotter, myself :)
Code    Segment use16
        Assume  cs:code,ds:code
        Org     100h

Start:
        mov     al,13h
        int     10h

        mov     ax,es
        add     ax,1000h
        mov     es,ax
loc_2:                        ;lightmap
        inc     bh
loc_3:
        lea     ax,[bx-80h]
        imul    al
        xchg    dx,ax
        lea     ax,[si-80h]
        imul    al
        add     ax,dx
        mov     [bp+si],ax   ;[bp+si] is an ex-var
        fild    word ptr[bp+si]
        fsqrt
        fistp   word ptr[bp+si]
        mov     ax,[bp+si]
        add     al,ah ;without this a pixel can appear in the screen sometimes
        sub     al,7dh
        jc      short loc_4
        db      0d6h  ;ax=0
loc_4:
;        shr     al,1
        imul    al     ; Exponential lightmap (in my opinion cooler)
        xchg    al,ah
        not     al
        stosb
        dec     bx
        jnz     loc_3
        dec     si
        jnz     loc_2

        mov     ax,es
        add     ax,1000h
        mov     ds,ax
        xor     cx,cx
bpc_for1:
        add     si,cx        ; background averaged randomness
        rol     si,cl
        ror     cx,1
        add     cx,1234h
        lea     ax,[si+bx]
        mov     [di],al
        inc     di
        dec     bx
        jnz     bpc_for1
        xchg    ax,bx
        xor     cx,cx
        mov     bp,3  ;11 is cool
smooth:
        mov     dl,[di-321]
        mov     al,[di-320]
        add     dx,ax
        mov     al,[di-319]
        add     dx,ax
        mov     al,[di-1]
        add     dx,ax
        mov     al,[di+1]
        add     dx,ax
        mov     al,[di+319]
        add     dx,ax
        mov     al,[di+320]
        add     dx,ax
        mov     al,[di+321]
        add     dx,ax
        shr     dx,3
;        jz      S2
;        dec     dl
S2:     mov     [di],dl
        dec     di
        loop    smooth
        dec     bp
        jnz     smooth

        mov     dx,3c8h          ;grey palette
        xchg    ax,cx
        out     dx,al
        inc     dx
col:
        out dx,al
        out dx,al
        out dx,al
        dec al
        jnz col
        mov ah,0a0h
        mov fs,ax
Main:
        push ds
        push cs
        pop  ds

        mov     di,-7*320+64-1 ; :)
        call one                ; Calculating the path of light
        fcos                    ; (the proc is exist only to shorting)
        fimul   Const120
        fistp   word ptr[di] ;k
        mov     ax,[di] ;k
        sub     ax,90

        call    one
        fsin
        fimul   Const120;85
        fistp   word ptr[di] ;k
        mov     bp,[di] ;k
        sub     bp,150

        inc     Alfa ;A l‚p‚sk”z
        pop     ds

        mov     cl,200
I2:     mov     si,320
I1:     mov     bl,[di+1]      ; x directional angle
        sub     bl,[di-1]
        sbb     bh,bh
        shl     bx,2 ;5        ; increase depth
        add     bx,si
        sub     bx,ax          ; moving lightmap
;        jl      NoPut
        mov     dl,[di+320]    ; y -||-
        sub     dl,[di-320]
        sbb     dh,dh
        shl     dx,2 ;5
        add     dx,cx
        sub     dx,bp
        jl      NoPut
;        or      ch,ch
;        jnz     NoPut
        shr     bx,1           ; zoom the lightmap
        shr     dx,1
        or      bh,bh
        jnz     noput

        mov     bh,dl
        mov     bl,es:[bx]     ; put a lightmap to the angle
        mov     fs:[di],bl
NoPut:  dec     di
        dec     si
        jnz     I1
        loop    I2

        mov     ah,1
        int     16h
        jz      main
Ki2:    mov     ax,3
        int     10h
Ki:     ret


one proc
        fldpi
        fidiv   Const180
        fimul   Alfa
        ret
one endp

Const180 dw     180
Const120 dw     120
Alfa    dw      270

Code    Ends
        End     Start
