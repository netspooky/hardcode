
.model tiny
.code
.386

org 100h

start:
mov ax,13h
int 10h

mov ax,1017h
jmp pal_set

main_loop:
mov di, offset temp
fld1
fidiv word ptr [di-14]	;r0
fst dword ptr [di-4]	;a2
fldpi
fdiv dword ptr [di-8]	;f0_5
fdivr
fistp word ptr [di]	
mov bp,[di]
fldz				; a

circle_loop:
fld st(0)
fsincos			; c s a 
fild word ptr [di-10]	; e c s a
fmul st(0),st(2)		; h c s a
fld st(0)			; h h c s a
fmul st(0),st(0)		; h*h h c s a
fild word ptr [di-12]	; r h*h h c s a
fmul st(0),st(0)		; r*r h*h h c s a
fsubr				; r*r-h*h h c s a
fsqrt				; d h c s a
fxch				; h d c s a
fld st(1)			; d h d c s a
fpatan			; u d c s a
fadd st(0),st(0)		; u d c s a

fxch st(2)			; c d u s a
fild word ptr [di-10]	; e c d u s a
fmul st(0),st(1)		; e*c c d u s a
fsubr st(0),st(2)		; v c d u s a

fild word ptr [di-14]	; r0 v c d u s a
fsub st(0),st(1)		; r1 v c d u s a
fxch st(2)			; c v r1 d u s a
fmul st(0),st(1)		; c*v v r1 d u s a
fiadd word ptr [di-10]	; x3 v r1 d u s a
fxch st(5)			; s v r1 d u x3 a 
fmul				; y3 r1 d u x3 a
fxch st(2)			; d r1 y3 u x3 a

fadd st(0),st(0)		;fdiv dword ptr f0_5
fld st(1)			; r1 d r1 y3 u x3 a
fdiv st(0),st(1)		; r1/d d r1 y3 u x3 a
fsub dword ptr [di-8]		;dword ptr f0_5
frndint			; q1 d r1 y3 u x3 a
fxch st(2)			; r1 d q1 y3 u x3 a
fxch				; d r1 q1 y3 u x3 a
fmul st(0),st(2)		; d*q1 r1 q1 y3 u x3 a
fsub				; r1-=d*q1 q1 y3 u x3 a
fld st(3)			; u r1 q1 y3 u x3 a
fsub st(0),st(6)		; u-a r1 q1 y3 u x3 a
fsincos			; c s r1 q1 y3 u x3 a
fmul st(0),st(2)		; c*r1 s r1 q1 y3 u x3 a
fsubp st(6),st(0)		; s r1 q1 y3 u x3 a
fmul				; s*r1 q1 y3 u x3 a
faddp st(2),st(0)		; q1 y3 u x3 a
fxch				; y3 q1 u x3 a
fxch st(2)			; u q1 y3 x3 a
fldpi
fadd				; u+pi q1 y3 x3 a 
fmul				; u1 y3 x3 a
fsincos			; c s y3 x3 a
fld st(0)			; c c s y3 x3 a
fmul st(0),st(4)		; c*x3 c s y3 x3 a
fld st(2)			; s c*x3 c s y3 x3 a	
fmul st(0),st(4)		; s*y3 c*x3 c s y3 x3 a
fadd				; x2 c s y3 x3 a
fistp word ptr [di] 	; c s y3 x3 a

mov cx,[di]
add cx,160	
fmulp st(2),st(0) 	; s y3*c x3 a
fmulp st(2),st(0) 	; y3*c x3*s a
fsubr				; y2 a
fistp word ptr [di] 	; a
mov dx,[di]	
add dx,100
  
xor bh, bh
mov ax, si	;byte ptr [di-15] ;c0
mov ah, 0ch
int 10h

fadd dword ptr [di-4]	;a2
dec bp
jnz circle_loop

;fcomp

;;;;;;;;;;;;;;;

next_r:
inc word ptr [di-14]	;r0
inc si	;byte ptr [di-15]	;c0
cmp si,56	;byte ptr [di-15],56	;c0,56
jb m4
mov si,32	;byte ptr [di-15],32	;c0,32

m4:
lea bx, pal+22*3
mov edx,dword ptr [bx+2]
mov cx,23
m5:
mov eax,[bx]
mov [bx+3],eax
sub bx,3
loop m5
mov dword ptr [bx+2],edx

mov ax,1012h
pal_set:
mov bx,32
mov cx,24
lea dx, pal
int 10h

m6:
in al, 60h
dec al
jnz main_loop

retn

;c0	db 32
r0	dw 1
r	dw 100
e	dw 50			
f0_5	dd 0.5
a2	dd ?
temp	dw ?
pal	db 24*3+1 dup (?)

end start
