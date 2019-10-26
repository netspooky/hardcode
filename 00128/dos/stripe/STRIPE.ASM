;128b intro
;
;'Stripe'
;
;by zZz //[KCN] research group
;Makeevka/Ukraine
;
;finished on 22.05.00
;
;94b w/o string
.model tiny
.386
.code
org 100h

Startx:;)

       mov      ax,13h
       int      10h

       push     0a000h
       pop      ds
lp1:
       mov      dx,3c8h
       mov      al,cl
       out      dx,al
       inc      dx
       out      dx,al
       shr      al,1
       out      dx,al
       shr      al,2
       out      dx,al
       inc      bx
       dec      cl
       jnz      short lp1

       ;di=0,si=0
       mov      si,32130 ;screen center (start of ribbon)
;---------------------------------------------loop
lp5:
;---------------------------------------------fader
       xor      di,di
lp7:
       mov      al,[di]
       test     al,11111110b
       jz       short jp4
       dec      al
       mov      [di-320],al
       dec      al
       mov      [di],al
jp4:
       inc      di
       jnz      short lp7

;---------------------------------------------main
       add      si,320
       mov      bx,si
       mov      cx,si
       mov      al,dl
       and      al,00001111b
       test     dl,00010000b
       jnz      short jp5
       add      si,ax
       jmp      short jp6
jp5:
       sub      si,ax
jp6:
       mov      word ptr [bx],0ffffh
       inc      dl

       in       al,60h
       test     al,1
       jz       short lp5

       mov      ax,03h
       int      10h

       retn
string db ' Made by zZz//[KCN] 94b w/o string'
data:
end startx