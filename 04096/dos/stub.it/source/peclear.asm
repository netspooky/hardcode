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
mov si,tableClear
mov cx,tableClearLength
.clear:
push cx
lodsw
xchg ax,dx
xor cx,cx
mov ax,4200h
int 21h
mov ah,40h
xor cx,cx
inc cx
mov dx,di
int 21h
pop cx
loop .clear
retn
txtCopyright db 'PeClear v.1.0 (C) by Tyler Durden',0ah,0dh,'website: http://www.tylerdurden.net.ru/',0ah,0dh,'email: peclear@tylerdurden.net.ru',24h
tableClear dw 2h,3h,4h,5h,6h,7h,8h,9h,0ah,0bh,14h,15h,16h,17h,26h,27h,4ch,64h,65h,66h,6ch,6dh,70h,71h,76h,90h,91h,104h,105h,106h,107h,108h,10ch,128h
tableClearLength=($-tableClear) shr 1