;by zZz //[KCN] research group
;Makeevka/Ukraine
.model tiny
.586
.587
.code
locals
org 100h

data equ word ptr dat

Startx:;)
;       jmp      mainbody
       mov      fs,ax
       mov      ax,13h
       int      10h

       push     0a000h
       pop      es

lp1:
       mov      dx,3c8h
       mov      al,cl
       out      dx,al
       inc      dx
       shr      al,2
       out      dx,al
       out      dx,al

       add      al,10
       test     al,11000000b
       jz       pelj1
       mov      al,0ffh
pelj1:

       out      dx,al
       inc      bx
       loop     lp1

mainbody:
lp4:
;       mov     bp,0
       mov     di,200
lp2:
       mov     mul1,0
       mov     cl,0ffh
lp3:
       mov     ax,bp
;       shr     ax,5
       mov     data,ax

       dec     cl

       push    mul1

       in      al,40h
       and     al,11111b
       xor     ah,ah
       add     mul1,ax

       finit
       fild    data
       fsincos
       fimul   mul1
       fistp   data
       mov     bx,data
       fimul   mul1
       fistp   data

       pop     mul1

       mov     ax,data
       mov     dx,320
       mul     dx
       add     bx,ax

       mov     dl,cl
       add     bx,31840
       mov     byte ptr es:[bx],dl
       dec     cl
       mov     byte ptr es:[bx+1],dl
       mov     byte ptr es:[bx-1],dl
       mov     byte ptr es:[bx+320],dl
       mov     byte ptr es:[bx-320],dl



       inc     mul1
       mov     ax,limit
       cmp     mul1,ax
       jbe     lp3


       inc     bp
       dec     di
       jnz     lp2

       inc     byte ptr limit

;---syncro
       mov      al,fs:[46ch]
lxp2:
       cmp      al,fs:[46ch]
       je       short lxp2
;-----------
       in      al,60h
       test    al,1h
       jz      lp4

       mov     ax,3
       int     10h

       ret
mul1 dw 10
limit  dw 0
adder db 1
dat:

end startx




