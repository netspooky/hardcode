push 0xa000 - 50
or al,0x13
pop es
int 0x10
X: 
sub dh,[si]
pusha
fild 	word	[bx-9]		; x
fild 	word	[bx-8]		; y x
fpatan						; arc
fst 	st1					; arc arc
fcos						; cos(arc) arc
fimul	dword	[si]		; l*cos(arc) arc
fidiv	word	[bx-8]		; l*cos(arc)/x arc
fiadd	word	[bp+si]		; l*cos(arc)/x+offset arc
fistp	dword	[bx-7]		; arc
fimul	word	[byte si+val-0x100]		; scarc
fistp	word	[bx-5]		; -
popa
xor al,cl
and al,16+8+2
stosb
mov ax,0xCCCD
mul di
jo X
add word [bp+si],byte 23
in al,0x60
dec ax
jnz X
ret
val: dw 6519 ;  n = 160 * 256 / pi / 2 ; 0x1977
