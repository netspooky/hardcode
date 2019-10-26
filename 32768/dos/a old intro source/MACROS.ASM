; -ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä-Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄ
;for 320*200 fixed..
proc  putlogo
                push    0a000h
                pop     es

                mov     bx,[cs:logocol] ;palet olayi..
                mov     cx,bx            ;kac renk set'lencek
                sal     bx,1
                add     cx,bx
                mov     dx,3c8h
                xor     al,al
                out     dx,al
                inc     dx              ;3c9

                mov     ax,[cs:Palet]
                mov     si,ax
        @@s01:  lodsb
                out     dx,al
                loop    near ptr @@s01
                ret                             ;SADECE BU OLAY ICIN....
endp putlogo
; -ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä-Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄ
;for 320*200 fixed..
proc  putlogo2
                push    0a000h
                pop     es

                mov     cx,[cs:PanelY]        ;gfx'i bas olayi..
                xor     di,di
                mov     ax,[cs:PanelTX]
                mov     bx,320
                mul     bx
                add     di,ax
                mov     ax,[cs:Bitmap]
                mov     si,ax
                mov     ax,[cs:PanelFX]
                mov     bx,320
                mul     bx
                add     si,ax
        @@s02:  push    cx di
                mov     cx,[cs:PanelX]
                rep     movsb

                pop     di
                add     di,320          ;modulo
                pop     cx
                loop    near ptr @@s02
                ret
endp    putlogo2
; -ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä-Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄ
proc fixpalet
                mov     bx,40           ;palet olayi..
                mov     cx,bx            ;kac renk set'lencek
                sal     bx,1
                add     cx,bx
                mov     dx,3c8h
                mov     al,150  ;19
                out     dx,al
                inc     dx              ;3c9

                mov     ax,offset bm_pal
                mov     si,ax
                add     si,150*3        ;19*3
        @@s01:  lodsb
                out     dx,al
                loop    near ptr @@s01

                ret
endp fixpalet
; -ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä-Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄ
macro   calcdi
                mov     di,dx           ;320*x+y
                shl     di,2
                add     di,dx
                shl     di,6
                add     di,cx
endm    calcdi
; -ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä-Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄ
macro   calcsi
                mov     si,dx           ;320*x+y
                shl     si,2
                add     si,dx
                shl     si,6
                add     si,cx
endm    calcsi
; -ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä-Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄ
macro   vbl
local waitvbl, waitvbl2
                push    dx ax
                mov     dx,3dah

waitvbl:        in      al,dx
                test    al,8
                jnz     near ptr waitvbl

waitvbl2:       in      al,dx
                test    al,8
                jz      near ptr waitvbl2
                pop     ax dx
endm    vbl
; -ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä-Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄ
macro   vbl2
local waitvbl
                push    dx ax
                mov     dx,3dah

waitvbl:        in      al,dx
                test    al,8
                jnz     near ptr waitvbl
                pop     ax dx
endm    vbl2
; -ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä-Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄ
macro   vbl3
local waitvbl
                push    dx ax
                mov     dx,3dah

waitvbl:        in      al,dx
                test    al,8
                jz      near ptr waitvbl
                pop     ax dx
endm    vbl3
; -ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä-Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄÄ
macro   screen13
                mov     ax,13h
                int     10h
endm    screen13
; -ÄÄÄÄ--ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä-Ä-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--ÄÄÄÄ
