format binary
org 100h
use16

start:
mov ah, 9
mov dx, text
int 21h
ret
text db 'CallNow$'