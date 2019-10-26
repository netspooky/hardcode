org 100h
mov al,0x13
int 0x10
lds bx,[bx]
L:
imul bx, 13
mov al, [byte bx+si-256+319]
xor al, [byte bx+si-256+320]
or al, [byte bx+si-256+321]
G: 
dec ax
mov [bx],al
inc bx			
mov ah,1
int 0x16
jz L
ret