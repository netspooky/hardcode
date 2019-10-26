;
;       CHICKEN.ASM - The chicken race
;
;       By Rolf Larsson, witchdoc@ludd.luth.se
;       Usa and abuse in any way you like :-)
;
code segment para public 'code'
assume ds:code,cs:code,es:code,ss:code
org     100h
Start:

                mov     ax,12h          ;VGA 640x480
                int     10h
                mov     bx,0
                mov     ax,40h
		mov	ds,ax

mainloop:
                mov     dx,3dah
Vert0:          in      al,dx
                test    al,8
                jz      Vert0           ;Test sync
Vert1:		in	al,dx
                test    al,8
                jnz     Vert1

                inc     word ptr cs:lpos
                dec     word ptr cs:rpos

                mov     ax,0C0Dh
                mov     cx,cs:[lpos]
                mov     dx,row
                int     10h
                inc     ax
                mov     cx,cs:[rpos]
                int     10h

                cmp     word ptr cs:[lpos],320
                jz      crash

                mov     ax,word ptr ds:[1ah]
		mov	word ptr ds:[1ch],ax	;Clear keyb buffer

                mov     ah,1
                int     16h

                cmp     al,'z'
                jz      lchicken
                cmp     al,'m'
                jz      rchicken

                jmp     mainloop

lchicken:       mov     bp,offset schick
                mov     dl,5
                jmp     quit

rchicken:       mov     bp,offset schick
                mov     dl,67
                jmp     quit

crash:          mov     bp,offset scrash
                mov     dl,37

quit:           mov     ax,cs
                mov     es,ax
                mov     ax,1300h
                mov     bx,12
                mov     dh,5
                mov     cx,8
                int     10h

                mov     ax,0
                int     16h

                mov     ax,3
                int     10h

                mov     ah,4ch          ;Quit and de-allocate memory
                int     21h

row     EQU     240
lpos    dw      0
rpos    dw      640
schick  db      "CHICKEN!"
scrash  db      "CRASH!  "
ends

end start
