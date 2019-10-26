ideal
p386n
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
assume cs:main_code,ds:main_code
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
segment main_code para 'code'
org 100h

main:
                mov     bp,offset sintab+255
                mov     si,offset sintab
                mov     di,offset sintab+128
                mov     cl,64
@@genloop:
                lodsb
                mov     [bp],al
                neg     al
                stosb
                mov     [bp-128],al
                dec     bp
                loop    @@genloop

                mov     al,13h
                int     10h

                push    0a000h
                pop     es

                mov     dx,3c8h
                xor     al,al
                out     dx,al
                inc     dx              ; cl =0
@@palette1:
                mov     al,cl
                out     dx,al
                out     dx,al
                out     dx,al
                inc     cl
                cmp     cl,64
                jnz     @@palette1
                dec     cl
@@palette2:
                mov     al,cl
                out     dx,al
                out     dx,al
                out     dx,al
                loop    @@palette2
                out     dx,al
                out     dx,al
                out     dx,al
@@mainloop:
                mov     dx,3dah
                in      al,dx
                test    al,8
                jz      $-3
                push    bp
                xor     di,di
                movzx   si,[sintab+bp]
                mov     cl,199
@@vertloop:
                mov     bl,[sintab+bp]
                mov     dl,160
@@horloop:
                mov     al,[sintab+bx]
                add     al,[sintab+si]
                shr     al,1
                stosw
                inc     bl

                dec     dl
                jnz     @@horloop

                inc     si
                and     si,255
                inc     bp
                and     bp,255
                loop    @@vertloop
                pop     bp

                inc     bp
                and     bp,255

                in      al,60h
                cmp     al,1
                jnz     @@mainloop
@@theend:
                mov     al,3
                int     10h
;                jmp     cs:0
                int     20h
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
  label         sintab byte
  include       "sintab.db"
  db 192 dup(?)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ends main_code
end main
