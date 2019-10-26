org 100h
use16

  mov ax, 13h
  int 10h
  mov ax, 0A000h
  mov es, ax

  xor bx, bx
  mov si, 0C8h

ylp:
  mov cx, 320

xlp:
  mov ax, 0BEh
  call calc1
  mov di, ax
  mov ax, 55h
  call calc1
  shl al, 1
  sub di, ax
  mov ax, 0EAh
  call calc1
  shl al, 1
  add di, ax
  mov ax, 82h
  call calc1
  sub ax, di

check1:
  inc al
  jz short check1
  cmp al, 0FFh
  jnz short putbyt
  dec al

putbyt:
  mov [es:bx], al
  inc bx
  loop xlp

  dec si
  jne short ylp


 push cs
 pop es

 xor bp,bp
wait_vr:
  mov dx, 3DAh
  in al, dx
  test al, 8
  jz short wait_vr

 mov di,rgb
 push di

 xor cl,cl
mkpal1:
 push cx

 xor bx,bx
 xor ax,ax

 add cx,bp
 mov bh,cl
 test bh,64
 je noinv
 xor bh,255
noinv:
 and bh, 63

test cl,128
jne red
mov bl,bh
 jmp putt
red:
 mov al,bh
;-------put to memory
putt:
 cmp cl,64
 jg put2
 cmp cl,192
 jl put2
 mov ah,bh
 xor ah,63
put2:
 stosw
 mov al,bl
 stosb
 pop cx
 inc cl
 jne mkpal1
 
 pop si

 mov dx,03C8h
 xor al,al
 out dx,al
 inc dx
 mov cx,768
 rep outsb

 inc bp



 in al,60h
 dec al
 jne wait_vr
;-------------------
calc1:
  sub ax, cx
  imul ax
  mov bp, ax
  mov ax, 63h
  sub ax, si
  imul ax
  add ax,bp

  push bx
  push cx
  push dx
  mov dx, ax
  mov bx, 80h
  mov cx, 8


clp1:
  mov al, bh
  or al, bl
  mul al
  cmp ax, dx
  ja short skippy
  or bh, bl

skippy:
  shr bl, 1
  loop clp1
  mov al, bh
  cbw
  pop dx
  pop cx
  pop bx
  retn

rgb:
