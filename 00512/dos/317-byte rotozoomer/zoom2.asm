; 317-byte rotozoomer (would be 304 w/o the wait-for-retrace code)
; /Mic, 2003
;
; Use [Esc] to exit
;
; tasm zoom2.asm
; tlink /t zoom2.obj

.model tiny		
.486			
code segment use16	
assume cs:code, ds:code	
org 0100h		

start:		 
mov al,13h	
int 10h
mov ax,cs
add ah,10h
mov es,ax
mov si,offset bitmap
xor di,di
mov bl,80h
mov cx,128
@@unpack:
rol bl,1
jnc @@1
lodsb
mov ah,al
@@1:
xor al,al
shr ah,1
setc al
shl al,5
stosb
loop @@unpack
push es
push 0a000h
pop es
pop fs
mov bl,5
mov scale,1000
mov byte ptr rot,1
@@mainloop:
call draw
add y,128
inc byte ptr rot
@@4:
add scale,bx
cmp scale,1100
jge short @@2
cmp scale,2
jl short @@2
jmp short @@3
@@2:
neg bx
@@3:
mov dx,986
@@6:
in ax,dx
and al,8
jnz short @@6
@@7:
in ax,dx
and al,8
jz short @@7
in al,60h
dec al
jnz short @@mainloop
mov al,03h		
int 10h
mov ah,04ch		
int 21h
zoom:
xor bx,bx 
xor si,si
xor di,di
mov cx,200
@@y_loop: 
push cx 
mov ax,i 
mov cx,320
push bp
@@x_loop: 
add ax,ddx 
add bp,ddy 
mov bl,ah
mov dx,bp
shr dx,8
and dl,070h
shr bl,3
and bl,0fh
or bl,dl
mov bl,fs:[si+bx] 
mov es:[di],bl 
inc di 
loop @@x_loop 
mov ax,d2x
pop bp
add i,ax
add bp,d2y
pop cx 
loop @@y_loop 
popa
ret
draw:
pusha
mov si,offset rot
fild word ptr [si+12]
fstp dword ptr [si+44]
fild word ptr [si]	; rot
fmul dword ptr [si+16]  ;vfix1
fld st(0)
fsincos
fmul dword ptr [si+44] ;scale
fistp word ptr [si+4] ;ddx
fmul dword ptr [si+44]
fistp word ptr [si+6]
fadd dword ptr [si+20] ;vfix2
fsincos
fmul dword ptr [si+44] ;scale2
fistp word ptr [si+8] ;d2x
fmul dword ptr [si+44]
fistp word ptr [si+10]
mov bx,100
mov cx,160
mov ax,[si+8]
mul bx
mov bp,ax
mov ax,[si+4]
mul cx
add ax,bp
mov bp,32768
sub bp,ax
mov [si+2],bp
mov ax,[si+10]
mul bx
mov bp,ax
mov ax,[si+6]
mul cx
add ax,bp
mov bp,[si+14]
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
y dw 0 
vfix1	dd 0.02454 
vfix2	dd 1.57079 

code ends	
END start	
