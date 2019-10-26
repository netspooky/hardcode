
.model tiny
.code
.386

org     100h

start:
mov     ax,13h
int     10h

mov dx,3c8h
mov al,16
out dx,al
inc dx
mov cx,32
m0:
mov bx,cx
shl bl,2
sub bl,64
jge m1
neg bl
xchg bh,bl
m1:
mov al,bl
out dx,al
out dx,al
mov al,bh
out dx,al
loop m0


main_loop:
push ds
pop es
lea di,buf
mov y,0

fld	t
fsincos

m2:
fild y		;y c s
fisub y0
fldlg2
fadd
fmul st(0),st(0)	;yy c s
mov x,0

m3:
fild x		;x yy c s
fisub x0
fld st(0)		;xx xx yy c s
fmul st(0),st(0)	;xx*xx xx yy c s
fadd st(0),st(2)	;xx*xx+yy xx yy c s
fsqrt			;r xx yy c s
fld st(0)		;r r xx yy c s
fidiv m		;r/m r xx yy c s

fsin			;sr r xx yy c s 
fld st(0)		;sr sr r xx yy c s
fmul st(0),st(0)	;sr*sr sr r xx yy c s
fld1			;1 sr*sr sr r xx yy c s
fadd
fsqrt
fld1			;1 sqrt sr r xx yy c s
fdivr			;dz sr r xx yy c s
fmul st(1),st(0)	;dz sr*dz r xx yy c s
fxch st(2)		;r sr*dz dz xx yy c s
fdiv			;dr dz xx yy c s
fmul st(0),st(2)	;dx dz xx yy c s
fmul st(0),st(5)	;dx*s dz xx yy c s
fxch			;dz dx*s xx yy c s
fmul st(0),st(4)	;dz*c dx*s xx yy c s
fsubr			;dz xx yy c s
fimul w15		;abs(dz)*15 xx yy c s
fistp color		;xx yy c s
fcomp			;yy c s
mov ax,color
add al,32
stosb
inc x
cmp x,320
jb m3

fcomp			;c s
inc y
cmp y,200
jb m2

fcompp

fld t
fadd d_t
fstp t

push    0A000h
pop     es
mov     si,offset buf 
xor	  di,di
mov     cx,16000
rep     movsd
		      
in	al,60h
dec	al
jnz     main_loop

retn

t	dd 0.0
d_t	dd 0.01
w15	dw 15
m	dw 10
x0	dw 160
y0	dw 100

x	dw	?
y	dw	?
color	dw	?
buf	db	320*200 dup (?)     

end     start
