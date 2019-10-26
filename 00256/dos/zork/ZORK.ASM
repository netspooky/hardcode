;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Source Of 256b Intro 'Zork' ³ FileName: Zork.asm               Fustic'98 ³
;ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
;³                             code: Fustic/Platoon                         ³
;³                      (c) 1998 Krzysztof Szymko (Fustic)                  ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                   .186
                   jumps
                   assume cs:code
                   code segment

                   org     100h        ;COM of coz..

Start32:           mov     al,13h      ;32 bit rlz.. ;)
                   int     10h         ;320*200*8Bpp

                   mov     dx,03c8h
                   mov     al,128
                   out     dx,al
                   inc     dx
                   mov     cl,64
Pal1:              mov     al,bl
                   out     dx,al
                   xor     ax,ax
                   out     dx,al
                   out     dx,al
                   inc     bx
                   loop    Pal1
                   mov     cl,64
Pal2:              dec     bx
                   mov     al,bl
                   out     dx,al
                   xor     ax,ax
                   out     dx,al
                   out     dx,al
                   loop    Pal2        ;Paletka

                   mov     bp,25       ;Delta SI
Petelka:           push    Buffer
                   pop     es
                   xor     di,di
                   mov     cx,200
PerY:              mov     bx,320
PerX:              mov     ax,cx
                   mul     si
                   mul     bx
                   sar     ax,8

                   cmp     al,128
                   ja      Stawiaj
                   xor     ax,ax
Stawiaj:           stosb
                   dec     bx
                   jnz     PerX
                   loop    PerY

                   cmp     si,256*10
                   jb      Okneg
                   neg     bp
OkNeg:             add     si,bp

                   pusha               ;Sierpinski
                   mov     Byte Ptr es:[30*320+160],SierpKolor
                   push    cs
                   pop     es
                   mov     di,Offset ArrayNo1
                   mov     cx,320/2
                   xor     ax,ax
                   rep     stosw
                   mov     Byte Ptr es:ArrayNo1[160],1

SierpLoop1:        mov     bp,1
SierpLoop2:        mov     al,cs:ArrayNo1[bp-1]
                   xor     al,cs:ArrayNo1[bp+1]
                   jz      SierpWPixel

                   push    Buffer
                   pop     es
                   mov     di,30+1
                   add     di,bx
                   imul    di,320
                   add     di,bp
                   mov     Byte Ptr es:[di],SierpKolor

SierpWPixel:       mov     cs:ArrayNo2[bp],al
                   inc     bp
                   cmp     bp,319
                   jb      SierpLoop2

                   push    cs
                   pop     es
                   mov     di,Offset ArrayNo1
                   inc     di
                   push    cs
                   pop     ds
                   mov     si,Offset ArrayNo2
                   inc     si
                   mov     cx,318/2
                   rep     movsw

                   inc     bx
                   cmp     bx,127
                   jb      SierpLoop1

                   mov     dx,3dah
Plam1:	           in      al,dx
   	           and     al,8
    	           jnz     Plam1
PLam2: 	           in      al,dx
	           and     al,8
	           jz      Plam2       ;Plamka

                   push    Buffer
                   pop     ds
                   xor     si,si
                   push    0a000h
                   pop     es
                   xor     di,di
                   mov     cx,64000/2
                   rep     movsw       ;Ramka..
                   popa

                   in      al,60h
                   dec     ax
                   jnz     petelka     ;Sprawdz ESCa

Exit:              mov     al,3
                   int     10h         ;Tryb textowy,
                   push    cs
                   pop     ds
                   lea     dx,Autor
                   mov     ah,9
                   int     21h         ;autor
                   ret                 ;i adijos..

 Buffer           equ 09000h
 SierpKolor       equ 9
 Autor             db 'Code: Fustic/Platoon$'
 ArrayNo1          db 320 dup (?)
 ArrayNo2          db 320 dup (?)

              code ends
              end start32
