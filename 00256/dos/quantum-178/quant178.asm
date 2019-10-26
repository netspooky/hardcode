; Quant178.asm

.model tiny
.code
.386

org 100h

start:

mov	ax,11h
int	10h

mov ax, 1000h
mov bx, 100h
int 10h

push 0a000h
pop es

fninit
fldz

main_loop:

mov bx, offset buffer
mov cx,38400
m1:
mov [bx], byte ptr 0	
inc bx
loop m1

fldz
mov bp,40240

m2:
fld st
fmul c
fadd st(0),st(2)
fsin
fld st(1)
fmul d
fadd st(0),st(3)
fsin
fmul
fmul b
fadd a
fld st(1)
fsincos
fmul st(0),st(2)
fistp y
fmul
fistp x
mov di,y
add di,240
imul di,80
mov ax,x
add ax,320
cwd
mov bx,8
idiv bx
add di,ax
mov cl,dl
mov al,128
shr al,cl
or buffer[di],al

fadd step
dec bp
jnz m2

mov si,offset buffer
xor di,di
mov cx,38400
rep movsb

fcomp st(0)
fadd d_time

in	al,60h		
dec	al
jnz	main_loop

mov ax,3
int 10h

retn

;;;;;;;;;;;;;;;;;;;;;;;;;;

a	dd 144.4
b	dd 87.6
c	dd 4.96875
d	dd 0.03125

step	dd 0.0025
d_time	dd 0.005

x 	dw ?
y 	dw ?

buffer db 38400 dup (?)

end	start

 