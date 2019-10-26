;Water

;122b

;not a release, part of drip_f

;by zZz //[KCN] research group
;Makeevka/Ukraine

.model tiny
.386
.code
org 100h

Start:
       mov      gs,ax

       mov      ax,13h
       int      10h

       mov      ah,4ah       ;ресайзим себя
       mov      bx,1000h
       int      21h

       mov      ah,48h       ;создаем скрин-буффер
       int      21h
       mov      ds,ax

       push     0a000h
       pop      es
lp1:
       mov      dx,3c8h
       mov      al,cl
       out      dx,al
       inc      dx
       xor      al,al
       out      dx,al
       out      dx,al
       mov      al,cl
       out      dx,al
       loop     lp1

       ;di=0,si=0
xor si,si
xor di,di
xor al,al
;---------------------------------------------main loop
;dlp1:  ;blank buffer
;       mov      byte ptr [di],0
;       dec      di
;       loop     dlp1

;---------------------------рисуем полосы (вода)
       mov      word ptr data,0
       mov      ah,1
lp4:
       mov      bl,al
       add      bl,15

       mov      [si],bl
       inc      si
       add      al,ah

       cmp      al,10 ;ширина полосы
       jne      short jp7
       neg      ah
jp7:
       test     al,al
       jnz      short jp8
       neg      ah
jp8:
       loop      lp4

;-----------------------------------draw circles
;jp4:
;       in       al,40h
;       add      bp,ax
;       mov      dx,5
lp2:
;       mov      si,bp
;       cmp      dx,20
;       je       short jp4
;       inc      dx
;       sub      bp,320
;
;       mov      cx,dx
;       neg      cx
;jp2:
;       push     dx
;       mov      ax,dx
;       mul      ax
;       mov      bx,ax
;
;       mov      ax,cx
;       imul     ax
;
;       pop      dx
;
;       sub      bx,ax
;
;       push     bx
;       fild     word ptr ss:[-4]
;       fsqrt
;       fistp    word ptr ss:[-4]
;       pop      bx
;jp5:
;       mov      byte ptr [si+bx],0h
;       neg      bx
;       mov      byte ptr [si+bx],0h

;       add      si,320
;       inc      cx
;       cmp      cx,dx
;       jle      short jp2

;-----------------------------water
lp3:
       mov      al,[di]
;       cmp      al,25
;       jnb      short jp3
       mov      [di+1],al
jp3:
       add      di,bx
       inc      bx
       jnz      short lp3

;-----------------------копия на экран
       mov      bx,si
       mov      si,di
       xor      cx,cx
       dec      cx
       rep      movsb
       mov      si,bx
;---------синхро-таймер
       mov      al,gs:[46ch]
lxp2:
       cmp      al,gs:[46ch]
       je       short lxp2
;---------скан клавиатуры
jkeyscan:
       in       al,60h
       test     al,1
       jz       short lp2

;       mov      ah,49h ;прочистим память
;       push     ds
;       pop      es
;       int      21h

       mov      ax,03h
       int      10h

       retn
data:
end start