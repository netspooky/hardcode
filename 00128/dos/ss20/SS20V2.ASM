;128b Intro

;'ss20'

;it had to be something like fireworks
;but dad said it looked like ss20 missile launch

;by zZz //[KCN] research group
;Makeevka/Ukraine

;finished on 28.05.2000

;tasm 4.1, 117b w/o string
.model tiny
.586
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
       shr      al,1
       out      dx,al
       mul      al
       shr      ax,6
       out      dx,al
       mov      al,cl
       shr      al,1
       out      dx,al
       loop     lp1

       ;di=0,si=0
;---------------------------------------------loop
lp2:
       mov      bl,10
lp4:
       sub      di,320
jp5:
       test     bh,100000b
       jz       short jp2
       add      di,cx
       jmp      short jp3
jp2:
       sub      di,cx
jp3:
       mov      byte ptr [di],127
       cmp      di,bp
       jnb      short jp4
       inc      bh
       inc      cl
       and      cl,1
jp4:
       add      bp,35
       dec      bl
       jnz      short lp4
lp3:
       mov      al,[si]
       test     al,11111100b
       jz       short jp1
       dec      al
       mov      [si+320],al
       dec      al
       mov      [si+321],al
       mov      [si+319],al
       mov      [si+1],al
       mov      [si-1],al
       mov      [si],al
       dec      al
       mov      [si-320],al
jp1:
       sub      si,dx

       dec      dx
       jnz      short lp3


       in       al,60h
       test     al,1
       jz       short lp2

       mov      ax,03h
       int      10h

       retn
string db ' zZz//[KCN]'
end startx