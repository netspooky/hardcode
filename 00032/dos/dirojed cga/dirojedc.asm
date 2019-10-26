cpu 8086
org 0x100

mov bx,0xb800
mov ds,bx
mov  al,4
int  10h
loopTop:
cmp  [bx],cl
adc  [bx],ch
mov ax,0xe5
imul bx
xchg bx,ax

mov  cl,[bx]
add  cl,[bx+di]
add  cl,[bx-81]
add  cl,[bx+79]
dec  bx

jmp loopTop

