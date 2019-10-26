;by zZz //[KCN] research group
;Makeevka/Ukraine
.model tiny
.586
.587
.code
locals
org 100h

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
       mov     bp,0
lp2:
       inc     bp
       mov     mul1,0
       mov     cl,0ffh
lp3:
       mov     ax,bp
;       shr     ax,5
       mov     data,ax

       dec     cl

       mov     di,mul1
       in      al,40h
       and     al,111111b
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

       mov     mul1,di

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
       cmp     mul1,100
       jbe     lp3

;---syncro
;       mov      al,fs:[46ch]
;lxp2:
;       cmp      al,fs:[46ch]
;       je       short lxp2
;-----------

       in      al,60h
       test    al,1h
       jz      lp2

       mov     ax,3
       int     10h

       ret
data dw ?
mul1 dw 10
end startx




