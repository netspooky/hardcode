;
;  Horizontal Slice (Scene)
;  Revision 2 (2000.2.21)
;
;  Developed by Wu (Boo Khan-Ming) from Malaysia.
;  Entry submission for ASMCOMP3 (http://www.tomsoft.clara.net/asm/compo/)
;
;  WWW:    http://www.geocities.com/SiliconValley/Horizon/3409
;  E-mail: bookm@tm.net.my
;

        TITLE HS
        .MODEL TINY
        .286

        .DATA
ID      DB      "WU-HS!"

        .CODE
        .STARTUP

        mov     al, 03h
        int     10h
        push    0b800h
        pop     es
Reset:
        mov     dx, 9
Redo:
        call    FillDn
        push    dx
        xor     dx, dx
        call    FillDn
        pop     dx
        call    FillUp
        push    dx
        xor     dx, dx
        call    FillUp
        pop     dx
        inc     dx
        cmp     dx, 16
        jz      Reset
        mov     ah, 01h
        int     16h             
        jz      Redo
        mov     ax, 0003h
        int     10h
        mov     ah, 4ch
        int     21h

FillUp  PROC
        mov     di, 3840
        mov     cl, 25
Redraw1:push    cx
        mov     cl, 80
        mov     al, 0dch
        mov     ah, dl
        rep     stosw
        sub     di, 320     
        mov     cl, 4
Delay1: call    Retrace
        loop    Delay1 
        pop     cx
        loop    Redraw1 
        ret
FillUp  ENDP

FillDn  PROC
        xor     di, di
        mov     cl, 25
Redraw2:push    cx
        mov     cl, 80
        mov     al, 0dch
        mov     ah, dl
        rep     stosw
        mov     cl, 4
Delay2: call    Retrace
        loop    Delay2
        pop     cx
        loop    Redraw2
        ret
FillDn  ENDP

Retrace PROC
        push    dx
        mov     dx, 03dah
A:      in      al, dx
        test    al, 8
        jnz     A
B:      in      al, dx
        test    al, 8
        jz      B
        pop     dx
        ret
Retrace ENDP

        END
