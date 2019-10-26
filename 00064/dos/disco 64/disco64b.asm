org 100h
push 0xa000-70
M: aas
pop es
mov al,0x13
int 0x10
X: sub dh,[si]
sub dx,bp
pusha
fild word [bx-8]			;<- dh+dl				; x
fmul st0											; x*x
fild word [bx-9]			;<- dl+bh				; y x*x
fmul dword [bx+si]
fst st2												; y x*x y
fmul st0,st2										; y*y x*x y
faddp st1											; y*y+x*x y 	
fsubr dword [byte bx+si-0x100+newnum-3]				; r*r-y*y-x*x y
fsqrt												; z y 
fpatan												; arc2
fimul word [bx]					; arc2'
fistp word [bx-5]			;->ax					; -
popa
cmp al,0x80
jle F
add ax,bp
xor al,dh
and al,16+8+4
F: stosb
mov ax,0xCCCD
mul di
jc X
newnum:
dec bp
jmp short X
