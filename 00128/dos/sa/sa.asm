org 100h
use16

mov al,13h
int 10h

mov bh,0A0h
mov es,bx

cv = 7-4

xor cl,cl
pal_lp:
 mov dx,03C8h
 mov al,cl
 out dx,al
 inc dx
 xor bx,bx
 and al,31
 add al,al
 test cl,128/2
 je bra2
 mov bh,al
bra2:
 test cl,64*2
 je bra3
 mov bl,al
bra3:
 test cl,32
 jne bra4
 xor al,al
bra4:

 out dx,al
 mov al,bl
 out dx,al
 mov al,bh
 out dx,al
 inc cl
 jne pal_lp



; xor bx,bx
;t2:
; mov [es:bx],bl
; inc bl
; jne t2
;m1:
; jmp m1

 mov bl,cv
lp0:
mov byte [es:160+100*320],cv;7
lp1:
 xor di,di

lp2:
 mov al,[es:di]
 and al,bl;cv;7
 cmp al,bl;cv;7
 jne next

 inc byte [es:di-321]
 inc byte [es:di-319]
 inc byte [es:di+321]
 inc byte [es:di+319]

next:
 inc di
 cmp di,64000
 jne lp2
 
 cmp bl,byte [es:0]
 jne get_key
 inc bl
 and bl,7-4
get_key:
 in al,60h
 dec al
 jne lp1
 ret