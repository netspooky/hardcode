org 100h
start:
pop cx
mov ah,3ch
mov dx,data_exe
int 21h
xchg ax,bx
mov ah,40h
dec cx
int 21h
mov ah,3eh
int 21h
xchg ax,bx
mov ah,4ah
int 21h
push dx
mov ax,4b00h
int 21h
pop dx
mov ah,41h
int 21h
data_exe: