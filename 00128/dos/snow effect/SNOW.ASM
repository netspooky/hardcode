.286						  ;Tasm 5.0
Code    Segment Public 'Code'
        Assume  CS:Code
        Org     100h                              ; Shit starts here 

Start:

mov ax,13h	; set 320x200x256 video mode
int 10h

again:

mov     ah,1                            ; check if a key has
int     16h                             ; been pressed if then jam
je      nokey                           

mov ax,03h	; back to text mode
int 10h
int 20h

nokey:

cmp random,3
jne random_ny

   mov cx, [RandSeed]
   imul cx, 13A7h
   inc cx
   mov [RandSeed], cx

   mov cl, ch
   mov ch, 0

jmp koger

random_ny:		

    mov     ax,[RandSeed]
    mov     dx,8405h
    mul     dx     
    inc     ax
    mov     [RandSeed],ax

koger:

cmp randseed,319
jbe ok2
jmp random_ny

ok2:
inc random

	mov dx,1
	mov cx,randseed

loop2:		

	inc dx
	mov ax,0c00h
	int 10h

	inc dx
	mov ax,0c19h
	int 10h

inc dx

mov ah,0dh
int 10h
cmp al,0019h
je again2
sub dx,2

cmp dx,197
je again
jmp loop2

again2:
mov ax,0c07h
int 10h
jmp again

RandSeed dw ?
random db 0

code    ends
        end     start

