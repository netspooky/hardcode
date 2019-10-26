; 256b rotozoomer 
; /mic, 2003 | stabmaster_@hotmail.com | http://come.to/progzone
;
; Use [Esc] to exit
;
; tasm zoom3.asm
; tlink /t zoom3.obj

.model tiny		
.486			
code segment use16	
assume cs:code, ds:code	
org 0100h		

start:
nop
fninit
mov ax,cs
add ah,10h
mov es,ax
mov si,offset bitmap
push si
xor di,di
mov bl,80h
mov cl,bl
mov dl,14
@@unpack:
rol bl,1
jnc short @@1
lodsb
mov bh,al
@@1:
shr bh,1
setc al
mul dl
stosb
loop @@unpack
pop si
push es
push 0a000h
pop es
pop fs
inc cx
inc cx
mov word ptr [si+12],1000
mov ax,13h	
int 10h
@@mainloop:
call draw
add word ptr [si+48],128
inc byte ptr [si]
@@4:
add word ptr [si+12],cx
cmp word ptr [si+12],1100
jge short @@2
cmp word ptr [si+12],2
jl short @@2
jmp short @@3
@@2:
neg cx
@@3:
in al,60h
dec al
jnz short @@mainloop
mov al,03h		
int 10h
mov ah,04ch		
int 21h
zoom:
xor bx,bx 
xor di,di
mov cx,200
@@y_loop: 
push cx 
mov ax,[si+2] 
mov cx,320
push bp
@@x_loop: 
add ax,[si+4] 
add bp,[si+6] 
mov bl,ah
mov dx,bp
shr dx,8
and dl,070h
shr bl,3
and bl,0fh
or bl,dl
mov bl,fs:[bx] 
mov es:[di],bl 
inc di 
loop @@x_loop 
mov ax,[si+8] 
pop bp
add [si+2],ax
add bp,[si+10] 
pop cx 
loop @@y_loop 
popa
ret
draw:
pusha
fild word ptr [si]	
fmul dword ptr [si+16]  
fsincos
fimul word ptr [si+12]
fist word ptr [si+4] 
fistp word ptr [si+10]
fimul word ptr [si+12]
fist word ptr [si+6]
fchs
fistp word ptr [si+8]
mov cl,7
mov ax,[si+8]
shl ax,cl
mov bx,[si+4]
shl bx,cl
add bx,ax
mov ax,32768
sub ax,bx
mov [si+2],ax
mov ax,[si+10]
shl ax,cl
mov bx,[si+6]
shl bx,cl
add ax,bx
mov bp,[si+48] 
sub bp,ax
jmp zoom
bitmap:
rot label word 
db 128,0
i label word 
db 0,0
ddx label word 
db 203,56
ddy label word 
db 149,4
d2x label word 
db 149,4
d2y label word 
db 149,68
scale label word 
db 213,57
db 0,0
vfix1	dd 0.02454 

code ends	
END start	
