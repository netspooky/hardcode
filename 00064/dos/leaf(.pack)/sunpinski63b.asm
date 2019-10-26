org 100h
push 0x9FE2
sbb al,256-0x13
pop es
int 0x10
X: 
sub dh,[si]
	pusha
		fild 	word	[bx-9]		; x
		fild 	word	[bx-8]		; y x
		fpatan						; arc
		fst 	st1					; arc arc
cm:		fcos						; cos(arc) arc
		fimul	dword	[si]		; l*cos(arc) arc
		fidiv	word	[bx-8]		; l*cos(arc)/x arc
		fistp	dword	[bx-7]		; arc
		; fimul	word	[byte si+val-0x100]		; scarc
		fmul	dword	[byte si+val-2-0x100]		; scarc
		fistp	word	[bx-4]		; -
	popa
add ax,bp
add cx,bp
and al,255-1-2
and al,cl
jnz XX-1
sub al,0xd6
XX:
F:
stosb
mov ax,0xCCCD
mul di
sbb bp,bx	; new trick (no jc X)
inc bp
jmp short X
val:
db 0x23
db 0x43
