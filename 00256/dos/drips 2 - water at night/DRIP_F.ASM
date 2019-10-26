;'Drips 2: Water at Night'  final release

;by zZz //[KCN] research group
;Makeevka/Ukraine

;tasm 4.1 223b w/o string

;finished on 22.06.2000

.model tiny
.386
.code
org 100h

Start:
       mov      gs,ax

       mov      ax,13h
       int      10h

       mov      ah,4ah       ;ресайзим себя
       mov      bx,1001h
       int      21h

       mov      ah,48h       ;создаем скрин-буффер
       int      21h
       mov      fs,ax

       mov      ah,48h       ;создаем буффер под воду
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
;---------------------------рисуем полосы (вода)
;       mov      word ptr cs:[data],0
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
       loop     lp4

;---------------------------------------------main loop
;-----------------------------------draw circles
jp4:
       mov      dx,1
       inc      bp
lp2:
;------------blanking buffer
       xor      cx,cx
       dec      cx
       xor      al,al
       push     es
       push     fs
       pop      es
       rep      stosb
       pop      es
       inc      di
;------------------------
;------------------------
       mov      si,word ptr [bp]
       cmp      dx,15
       je       short jp4
       inc      dx
       sub      word ptr [bp],320

       mov      cx,dx
       neg      cx
jp2:
       push     dx
       mov      ax,dx
       mul      ax
       mov      bx,ax

       mov      ax,cx
       imul     ax

       pop      dx

       sub      bx,ax

       push     bx
       fild     word ptr ss:[-4]
       fsqrt
       fistp    word ptr ss:[-4]
       pop      bx
jp5:
       push     dx
       neg      dl
       sub      dl,30
       mov      dh,dl
       mov      fs:[si+bx],dx
       neg      bx
       mov      fs:[si+bx],dx
       pop      dx

       add      si,320
       inc      cx
       cmp      cx,dx
       jle      short jp2
;-----------------------------water
lp3:
       mov      al,[di]
       mov      [di+1],al
jp3:
       add      di,bx
       inc      bx
       jnz      short lp3

;-----------------------копия в буффер
       push     si
       xor      si,si
lbufc1:
       mov      al,fs:[si]
       mov      ah,[si]
       test     al,al
       jnz      jbufc1
       mov      fs:[si],ah
jbufc1:
       dec      si
       jnz      lbufc1
;-----------------------копия на экран
       mov      si,di
       xor      cx,cx
       dec      cx
       rep      movs byte ptr es:[di],fs:[si]
       pop      si
;---------синхро-таймер
       mov      al,gs:[46ch]
lxp2:
       cmp      al,gs:[46ch]
       je       short lxp2
;---------скан клавиатуры
jkeyscan:
       in       al,60h
       test     al,1
       jz       lp2

       mov      ax,03h
       int      10h

       retn
string db 0ah,0dh,'-=# Drips 2: Water at Night #=-'
data:
end start