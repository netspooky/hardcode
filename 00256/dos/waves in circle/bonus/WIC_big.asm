; Подземные ядерные испытания

.model tiny
.code
.386

org 100h

start:
mov ax,12h
int 10h

mov dx,3dah
in ax,dx

mov dx,3c0h
mov al,0fh
m0:
out dx,al
out dx,al
dec al
jns m0

mov al,20h
out dx,al

mov di, offset pal
mov cx,14*3
fldz

m1:
fld st
fsin
fmul st(0),st(0)
fimul i63
fistp word ptr[di]
inc di
fadd	palstep	
loop m1
fcomp

main_loop:
mov di, offset temp
fld1
fadd st(0),st(0)
fidiv r0
fst dword ptr [di-4]	;a2
fldpi
;fadd st(0),st(0)
fdivr
fistp word ptr [di]	
mov bp,[di]
fldz			; a

circle_loop:
fld st(0)
fsincos		; c s a 
fild e		; e c s a
fmul st(0),st(2)	; h c s a
fld st(0)		; h h c s a
fmul st(0),st(0)	; h*h h c s a
fild r		; r h*h h c s a
fmul st(0),st(0)	; r*r h*h h c s a
fsubr			; r*r-h*h h c s a
fsqrt			; d h c s a
fxch			; h d c s a
fld st(1)		; d h d c s a
fpatan		; u d c s a
fadd st(0),st(0)	; u d c s a
fxch st(2)		; c d u s a
fild e		; e c d u s a
fmul st(0),st(1)	; e*c c d u s a
fsubr st(0),st(2)	; v c d u s a
fxch			; c v d u s a
fmul st(0),st(1)	; c*v v d u s a
fiadd e		; x3 v d u s a

;fist word ptr [di]
;mov cx,[di]
;add cx,320

fxch st(4)		; s v d u x3 a
fmul st(0),st(1)	; y3 v d u x3 a

;fist word ptr [di]
;mov dx,[di]
;add dx,240
;xor bh, bh
;mov ah, 0ch
;mov al, 15
;int 10h

fxch			; v y3 d u x3 a
fisubr r0		; r1 y3 d u x3 a
fxch			; y3 r1 d u x3 a
fxch st(2)		; d r1 y3 u x3 a	
fadd st(0),st(0)
fld st(1)		; r1 d r1 y3 u x3 a
fdiv st(0),st(1) ; r1/d d r1 y3 u x3 a
fsub dword ptr f0_5
frndint		; q1 d r1 y3 u x3 a
fxch st(2)		; r1 d q1 y3 u x3 a
fxch			; d r1 q1 y3 u x3 a
fmul st(0),st(2)	; d*q1 r1 q1 y3 u x3 a
fsub			; r1-=d*q1 q1 y3 u x3 a
fld st(3)		; u r1 q1 y3 u x3 a
fsub st(0),st(6)	; u-a r1 q1 y3 u x3 a
fsincos		; c s r1 q1 y3 u x3 a
fmul st(0),st(2)	; c*r1 s r1 q1 y3 u x3 a
fsubp st(6),st(0)	; s r1 q1 y3 u x3 a
fmul			; s*r1 q1 y3 u x3 a
faddp st(2),st(0)	; q1 y3 u x3 a
fxch			; y3 q1 u x3 a
fxch st(2)		; u q1 y3 x3 a
fldpi
fadd			; u+pi q1 y3 x3 a 
fmul			; u1 y3 x3 a

fldpi
fmul dword ptr f0_5
fsub

fsincos		; c s y3 x3 a
fld st(0)		; c c s y3 x3 a
fmul st(0),st(4)	; c*x3 c s y3 x3 a
fld st(2)		; s c*x3 c s y3 x3 a	
fmul st(0),st(4)	; s*y3 c*x3 c s y3 x3 a
fadd			; x2 c s y3 x3 a

fistp word ptr [di] ; c s y3 x3 a
mov cx,[di]
add cx,320	
fmulp st(2),st(0) ; s y3*c x3 a
fmulp st(2),st(0) ; y3*c x3*s a
fsubr			; y2 a

fistp word ptr [di] ; a
mov dx,[di]
add dx,240	
 
xor bh, bh
mov ah, 0ch
mov al, c0
int 10h

sub cx,320
neg cx
add cx,320
int 10h

fadd dword ptr [di-4]	;a2
dec bp
jnz circle_loop

fcomp

;;;;;;;;;;;;;;;

inc r0
dec n0
jnz m6
	
mov n0,2
inc c0
cmp c0,15
jnz m4
mov c0,1

m4:
std
mov si, offset pal + 14*3 - 1
mov di, offset pal - 1
movsb
movsb
movsb
mov di, si
add di, 3
mov cx, 14*3
rep movsb

cld
mov dx, 3c8h
mov al, 0
out dx, al
inc dx
out dx,al
out dx,al
out dx,al
mov si, offset pal
mov cx, 14*3
m5:
lodsb
out dx,al
loop m5
mov al,63
out dx,al
out dx,al
out dx,al


m6:
in al, 60h
dec al
jnz main_loop

retn

palstep dd 0.97738438		
r	dw 235
e	dw 235			
f0_5	dd 0.5	
i63	dw 3fh
r0	dw 1
c0	db 4
n0	db 2

a2	dd ?
temp	dw ?
	db 3 dup (?)
pal	db 15*3 dup (?)

end start
