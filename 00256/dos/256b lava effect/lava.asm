; 256b lava effect
; /mic, 2003 | stabmaster_@hotmail.com | http://come.to/progzone
;
; Press [ESC] to exit the program.
;
; How to compile:
;  tasm lava.asm
;  tlink /t lava.obj
;

 
.model tiny		
.486				
code segment use16	
assume cs:code, ds:code	
org 0100h		


start:		
mov al,13h	
int 10h

push 0a000h
pop es
mov ax,cs
add ah,10h
mov fs,ax

mov di,0fa00h
mov cx,255
@@1:
mov temp,cx
fild word ptr [temp]
fmul dword ptr [factor]
fcos
fmul dword ptr [factor2]
fadd dword ptr [factor2]
fistp word ptr fs:[di]
inc di
loop @@1
mov bl,63
mov al,bl
mov fs:[di],al

xor al,al
mov ch,al
mov dx,03c8h
out dx,al
inc dx
out dx,al
out dx,al
out dx,al
mov cl,bl
@@p1:
mov al,bl
sub al,cl
out dx,al
xor al,al
out dx,al
out dx,al
loop @@p1
mov cl,bl
@@p2:
mov al,bl
out dx,al
mov al,bl
sub al,cl
out dx,al
xor al,al
out dx,al
loop @@p2
mov cl,bl
@@p3:
mov al,cl
out dx,al
out dx,al
mov al,bl
sub al,cl
out dx,al
loop @@p3
mov cl,bl
@@p4:
mov al,bl
sub al,cl
out dx,al
out dx,al
mov al,bl
out dx,al
loop @@p4
mov cl,3
@@p5:
out dx,al
out dx,al
out dx,al
loop @@p5

@@mainloop:
mov dx,[foo + 2]
mov cx,200
xor di,di
xor bx,bx
@@yloop:
inc dx
add dh,2
mov ax,[foo]
mov x1,al
mov x2,ah
mov bp,320
mov si,0fa00h
@@xloop:
inc x1
add x2,2
mov al,fs:[di]
shr al,2
mov bl,x1
add al,fs:[si + bx]
mov bl,x2
add bl,dl
add al,fs:[si + bx]
add bl,dh
add al,fs:[si + bx]
mov fs:[di],al
inc di
dec bp
jnz short @@xloop
inc dh
loop @@yloop
mov cx,16000
xor si,si
xor di,di
push ds
push fs
pop ds
rep movsd
pop ds
add factor,01ff02feh
in al,60h
dec al
jnz @@mainloop
mov al,03h		
int 10h
mov ah,4ch		
int 21h

temp label word
x1	db 0
x2	db 0
coord label byte
foo label word
factor	dd 0.02554	
factor2	dd 31.4
db 0

code ends
END start
