.model tiny
.stack 50h

.data

timer word ?
x word ?
y word ?
dis dword ?
fdis dword ?
numer dword  30000
wid word 320
mx word 0
x1 word 3 dup (?)
y1 word 3 dup (?)
color byte ?


.386
.code
ORG 100h

main:
mov  ax,0013h
int  10h
xor cx,cx
pallete :
mov dx,03C6h
mov ax,0ffh
out dx,al
mov dx,03C8h
mov ax,cx
out dx,al
mov dx,03C9h
push cx
shr cx,2
mov ax,cx
out dx,al
out dx,ax
out dx,al
pop cx
inc cx
cmp cx,256
jne pallete
ml:
xor ax,ax
int 1Ah
mov timer,dx
call render
call moveblobs
wt:
xor ax,ax
int 1Ah
sub dx,timer
jz wt
mov ah,01
int 16h
cmp al,27
jne  ml
mov  ax,0003h
int  10h
int  20h

putpixel proc near
      pusha
      mov ax,0A000h
      mov es,ax
      mov bx,y
      mov cx,y
      shl bx,8
      shl cx,6
      add bx,cx
      add bx,x
      mov ch,color
      mov es:[bx],ch
      popa
      ret
putpixel endp


render proc near
   pusha
   mov cx,64000
loop1:
   xor bx,bx
   mov fdis,0
   xor dx,dx
   mov ax,cx
   div wid
   mov y,ax
   mov x,dx
  loop2:
      mov ax,y
      sub ax,y1[bx]
      shr ax,1
      mul ax
      cwde
      mov dis,eax
      mov ax,x
      sub ax,x1[bx]
      shr ax,1
      mul ax
      cwde
      add dis,eax
      xor edx,edx
      mov eax,numer
      inc dis
      div dis
      cwde
      add fdis,eax
      add bx,2
      cmp bx,4
jbe loop2
     cwde
     mov eax,fdis
     cmp eax,255
     jb il
     mov al,255
il:
    mov color,al
    call putpixel
loop loop1
popa
ret
render endp

moveblobs proc near
pusha
  cmp mx,220
  jb incr
  mov mx,0
incr:
  inc mx
  mov ax,mx
  mul ax
  shr ax,7
  mov cx,mx
  mov x1[0],cx
  mov y1[0],ax
  mov bx,200
  sub bx,ax
  mov x1[2],cx
  mov y1[2],bx
  mov bx,320
  sub bx,ax
  mov x1[4],bx
  mov y1[4],cx
popa
ret
moveblobs endp

END main