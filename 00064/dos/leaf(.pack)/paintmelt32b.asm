org 100h
mov al,0x13
int 0x10
lds bx,[bx]
L:
imul bx, byte 13
mov al, [bx-319]
and al, [bx-321]
or al, [bx-320]
G:
dec ax
mov [bx],al
dec bx			
mov ah,1
int 0x16
jz L
ret