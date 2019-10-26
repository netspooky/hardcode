.model tiny
.code
.386

org 100h

start:
mov ax,13h
int 10h

push 0A000h
pop es

fninit

fld f_2pi
fidiv n
fstp pn

main_loop:

xor di,di
mov y,199
loop_y:

mov x,319
loop_x:

fldz		;k1 
fld1		;k2
mov zn,1

mov cx,n
local_loop:
mov i,cx
fild i
fmul pn
fadd time
fsincos
fimul r
fiadd x
fisub x0
fxch
fimul r
fiadd y
fisub y0
fld st(1)
fld st(1)
fpatan
fimul zn
faddp st(4)
fmul st(0),st(0)
fxch
fmul st(0),st(0)
fadd
fsqrt
neg zn
js m1
fld1
fdivr
m1:
fmul
loop local_loop

fsqrt	
fsqrt

fld1
fxch
fyl2x


fld time
fsin
fadd st(0),st(0)
fmul
fxch
fdiv f_2pi
fadd
fadd st(0),st(0)

fld st(0)
frndint
fsub
fimul _24

fistp temp
mov ax, temp
add ax, 48
;mov ah,al
;mov es:[di+320],ax
;stosw
stosb

dec x
jns loop_x

;add di,320

dec y
jns loop_y

fld time
fadd d_time
fstp time

in al,60h
dec al
jnz main_loop

retn

_24		dw 24
n		dw 6
x0		dw 160
y0		dw 100
r		dw 60
time		dd 0.0
d_time	dd 0.02
f_2pi		dd 6.2831853

x	dw ?
y	dw ?
zn	dw ?
i	dw ?
temp	dw ?
pn	dd ?

end start
