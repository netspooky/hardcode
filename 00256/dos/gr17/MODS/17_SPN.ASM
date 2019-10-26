;gr17 mod - spn99
;(spn99 - my university group)

;by zZz //[KCN] research group
;Makeevka/Ukraine
.model tiny
.586
.587
.code
locals
org 100h

data equ word ptr dat
sprite equ byte ptr dat+2
strlen equ 6

Startx:;)
;       jmp      mainbody
       mov      fs,ax
       mov      ax,13h
       int      10h

       push     0a000h
       pop      es

       mov      ah,2
       xor      bh,bh
       xor      dx,dx
       int      10h
       lea      dx,str1
       mov      ah,9h
       int      21h

       xor      di,di
       mov      cx,2560
lsp1:
       mov      al,es:[di]
       mov      [di+sprite],al
       inc      di
       inc      si
       dec      cx
       jnz      lsp1


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
       mov     di,20
lp2:
       mov     mul1,0
       mov     cl,0ffh
lp3:
       mov     ax,bp
       mov     data,ax

       dec     cl

       push    mul1

       in      al,40h
       and     al,111b
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

       pusha
       xor      si,si
       lea      si,sprite
       mov      di,31840-(strlen/2)*8+4-4*320
       mov      cx,2560
lxsp1:
       mov      al,[si]
       test     al,al
       jz       lxsj1
       mov      byte ptr es:[di],0
lxsj1:
       inc      di
       inc      si
       dec      cx
       jnz      lxsp1
       popa


       inc     mul1
       mov     ax,limit
       cmp     mul1,ax
       jbe     lp3


       inc     bp
       dec     di
       jnz     lp2

       inc     byte ptr limit

;---syncro
;       mov      al,fs:[46ch]
;lxp2:
;       cmp      al,fs:[46ch]
;       je       short lxp2
;-----------
       in      al,60h
       test    al,1h
       jz      lp4

       mov     ax,3
       int     10h

       ret
mul1 dw 10
limit  dw 0
str1 db 'ëèç 99$'
dat:

end startx




