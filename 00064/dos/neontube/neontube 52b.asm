mov al,0x13
int 0x10
X: 
or al,[bp+si]
xor al,0x68
mov dx,0x79F
pusha
fild 	word	[bx-9]		; x
fild 	word	[bx-8]		; y x
fpatan						; arc
fst 	st1					; arc arc
fcos						; cos(arc) arc
fimul	dword	[si]		; l*cos(arc) arc
fidiv	word	[bx-8]		; l*cos(arc)/x arc
fistp	dword	[bx-4]		; arc
fimul	word	[bx]		; scarc
fistp	word	[bx-5]		; -
popa
sub ah,[bp+si]
xor al,ah
and al,16+8+4
stosb
mov ax,0xCCCD
mul di
jmp short X-1
