org 100h
mov bl,[80h]
mov byte [81h+bx],al
xchg ax,bp
mov dx,txtCopyright
int 21h
mov dx,82h
mov ax,3d01h
int 21h
xchg ax,bx
mov dx,2
xor cx,cx
mov ax,4200h
int 21h
mov ah,40h
xor cx,cx
inc cx
mov dx,dotValue
int 21h
retn
txtCopyright db 'Dot.it v.1.0 (C) by Tyler Durden',0ah,0dh,'website: http://www.tylerdurden.net.ru/',0ah,0dh,'email: dotit@tylerdurden.net.ru',24h,0
dotValue db 2eh