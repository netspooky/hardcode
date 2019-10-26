;
; D A R K N E S S
; SUBJECT ........ bump mapping through on-the-fly generated texture
; CODE ........... subz3ro
; OBJECTIVE ...... 256B Intro Compo at Fiasko 2k
;
; Compile with TASM 3.0 or higher, and "/m2" option set.
;
; Key reference: Space ... Switch texture,
;                Esc ..... Quit.
;
        .386
        ideal

segment code
        assume  cs:code,ds:code,ss:code
        org     100h

START:  pusha
        mov     ax,13h
        int     10h
        push    09000h
        pop     ds
        push    0a000h
        pop     es
        mov     bx,64000
@1:     mov     cl,255
        xor     ax,ax
        add     ax,bp
        xor     al,ah
        add     ax,bx
        ror     al,cl
        xor     ah,al
        inc     bp
        cmp     [cs:indexer],0
        jz      @2
        shr     bp,cl
@2:     mul     cx
        mov     [bx],dl
        dec     bx
        jnz     @1
        mov     dl,4
@3:     lodsb
        mov     bl,[si]
        add     ax,bx
        mov     bl,[si+320-1]
        add     ax,bx
        mov     bl,[si+320]
        add     ax,bx
        shr     ax,2
        mov     [si],al
        loop    @3
        dec     dx
        jnz     @3
        mov     bx,60
        xor     di,di
@4:     mov     cl,255
        mov     dx,3c8h
        mov     al,1
        out     dx,al
        inc     dx
@5:     mov     ax,cx
        shr     ax,3
        out     dx,al
        shl     ax,1
        out     dx,al
        cmp     bx,-1
        jnz     @6
        xor     ax,ax
@6:     out     dx,al
        loop    @5
        cmp     di,60
        jl      @7
        mov     bx,-1
@7:     cmp     di,-60
        jg      @8
        mov     bx,1
@8:     add     di,bx
        mov     [cs:locator],di
        pusha
        mov     di,320*4
        mov     si,-100
@9:     mov     bp,-160
@10:    movzx   ax,[ds:di+1]
        movzx   bx,[ds:di-2]
        sub     ax,bx
        mov     bx,bp
        sar     bx,1
        sub     bx,[cs:locator]
        sub     ax,bx
        movzx   cx,[ds:di+320]
        movzx   dx,[ds:di-640]
        sub     cx,dx
        mov     dx,si
        sar     dx,1
        sub     dx,[cs:locator]
        sub     cx,dx
        imul    ax,bx
        imul    cx,dx
        add     ax,cx
        cwd
        xor     ax,dx
        shr     ax,5
        inc     ax
        or      ah,ah
        jz      @11
        mov     al,255
@11:    stosb
        inc     bp
        cmp     bp,157
        jle     @10
        add     di,2
        inc     si
        cmp     si,90
        jle     @9
        popa
        in      al,60h
        cmp     al,ESCAPE
        jz      @12
        cmp     al,SPACE
        jnz     @4
        popa
        xor     [cs:indexer],1
        jmp     START
@12:    popa
        mov     al,3
        int     10h
        ret

indexer db      1
locator dw      ?

SPACE   equ     39h
ESCAPE  equ     01h

ends
end     START
