org 100h
use16


mov al,13h
int 10h;bl=0

out_pal:
 mov dx,03c8h
 mov al,bl
 out dx,al
 inc dx
 and al,127
 cmp al,64
 jl noneg
 neg al
noneg:
 and al,63
 out dx,al
 out dx,al
 out dx,al
 inc bl
 jne out_pal


 mov si,128
 xor di,di
 xor dx,dx
 xor cx,cx
 mov bl,64
slp:
 add dx,cx
 add cx,4
 mov al,dh
; neg al
 mov [cs:sint+di],al
 mov [cs:sint+si+128],al

 neg al
 add al,32*2
 mov [cs:sint+si],al

 mov [cs:sint+di+128],al

 
 dec si
 inc di
 dec bl
 jns slp



tw_lp2:
 push 08000h
 pop es
 xor si,si
 xor di,di
 xor ax,ax
 mov cx, 64000
 rep stosb
 xor di,di
;  COUNTER=COUNTER+1
 inc byte [cs:counter]
;    cc=cc+1
;    dd=dd+2
inc dl
inc dh
inc dh
xor si,si;Y
tw_lp:
;    For Y=0 To 191;479;255
;      xx.b=s(255&(cc+y))+s(255&(dd+y))
;      ;xx=xx>>1
;      ;xx.a=0

 mov bx,si
 add bl,dl
 movsx ax,byte[cs:bx+sint]
 mov bx,si
 add bl,dh
 movsx cx,byte[cs:bx+sint]
 add ax,cx
 mov [cs:xx],ax

;sv=s((y-counter)&255)*2
 mov bx,si
 sub bl,[cs:counter]
; add bl,bl
 movsx ax,byte[cs:bx+sint]
;    x1.a=s((sv+counter)&255)+lCenterX
;    x2.a=s((sv+counter+64)&255)+lCenterX
;    x3.a=s((sv+counter+128)&255)+lCenterX
;    x4.a=s((sv+counter+192)&255)+lCenterX
 
 push ax
 call line;x1,x2
 call line;x2,x3
 call line;x3,x4
 
 
 pop cx;cx=x4
 ;xchg ax,cx
 call line
 inc si
 add di,320
 jnc tw_lp

push dx
mov dx, 3dah
@wait1:
in al, dx
test al, 8
jz @wait1

;@wait2:
;in al, dx
;test al, 8
;jnz @wait2

pop dx

 push es
 pop ds
 push 0A000h
 pop es

 xor si,si
 xor di,di
 mov cx,64000
 rep movsb

  in al, 60h
  dec al
  jnz tw_lp2

 ret
; jmp tw_lp2


line:
;    If X2>X1
;      Plot(x1+xx,y,RGB(255,0,0))
;      Plot(x2+xx,y,RGB(192,0,0))
;    EndIf
 add bl,64
 movsx cx,byte[cs:bx+sint]
line1:
 push cx
 add ax,160/2
 add cx,160/2
 sub cx,ax;X_left<X_right?
 jc end_l
 push di
 add di,ax
 add di,[cs:xx]
 mov ax,cx
 rep stosb
 pop di
end_l:
 pop ax
 ret
xx: dw 0
counter: db 0
;------------test plot--------------
;tpl:
;xor bx,bx
;push 0A000h
;pop es
;tplp:
; mov ax,100*0
; add al,byte [cs:sint+bx]
; cwd
; imul ax,320
; add ax,bx
; mov di,ax
; mov byte [es:di],15
; inc bl
; jne tplp
 ret
sint: