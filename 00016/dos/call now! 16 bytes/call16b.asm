org 100h
use16

db "C",0A0h,"ll",0EFh,0A2h,"w",13h
mov ah,9
mov dx,si
int 21h
ret
db "$"

       