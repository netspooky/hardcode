;============================================================================
; In Hell At Christmas Time? / luks
;============================================================================

[org 0x100]
[section .text]

BEGIN   mov     al,0x13
        int     0x10

        inc     ch
PALETTE mov     dx,0x03C8
        mov     al,cl
        out     dx,al
        inc     dx
        shr     al,2
        mov     bl,3
COLORS  out     dx,al
        mul     al
        shr     ax,6
        dec     bl
        jnz     COLORS
        loop    PALETTE

MAIN    mov     ax,cs
        add     ah,16
        mov     ds,ax

        mov     ax,0x1130
        mov     bh,0x01
        int     0x10

        mov     di,48*320+32

        xor     bx,bx
        inc     byte [cs:COUNTER]
        jns     DRAWMSG
        mov     bl,9

DRAWMSG movzx   si,[cs:bx+STRINGS]
        inc     bx
        shl     si,3
        jz      ENDMSG
        mov     cl,8
CHARY   mov     dh,[es:bp+si]
        inc     si
        mov     ch,8
CHARX   shl     dh,1
        jnc     NOPIXEL

        push    bx
        call    RANDOM
        and     ax,byte 0x03
        imul    ax,320
        mov     bx,ax
        call    RANDOM
        and     ax,byte 0x03
        add     bx,ax
        mov     word [di+bx],0xFFFF;255
        pop     bx

NOPIXEL add     di,byte 4
        dec     ch
        jnz     CHARX
        add     di,320*4-8*4
        loop    CHARY
        add     di,8*4-320*8*4
        jmp     short DRAWMSG

ENDMSG  push    ds
        pop     es

        call    RANDOM
        and     al,ah
        jnz     FIREFX

HELLFX  call    RANDOM
        and     ah,2
        mov     al,[di]
        sub     al,ah
        stosb
        loop    HELLFX

FIREFX  movzx   ax,[di]
        movzx   dx,[di-1]
        add     ax,dx
        mov     dl,[di+1]
        add     ax,dx
        mov     dl,[di+320]
        add     ax,dx
        shr     ax,2
        jz      STORE
        dec     al
STORE   stosb
        loop    FIREFX

        push    word 0xA000
        pop     es

        mov     dx,0x03DA
RETRACE in      al,dx
        test    al,8
        jnz     RETRACE

        xor     si,si
        mov     di,36*320
        mov     ch,40
        rep     movsd

WAITING xor     ah,ah
        int     0x1A
        and     dl,1
        jnz     WAITING

        mov     ah,0x11
        int     0x16
        jz      near MAIN

        mov     ax,0x03
        int     0x10

RANDOM  mov     ax,123
        imul    ax,byte 123
        rol     ax,byte 5
        mov     [cs:RANDOM+1],ax

        ret

STRINGS db      "X-Mas", 39, "01", 0
        db      24, " H‰LL ", 25, 0

COUNTER db      0