org 100h
push 0xa000-70
pop es
mov al,0x13
int 0x10
X: 
sub dh,[si]
pusha
fild word [bx+si]				; c
fidiv word [bx-14]				; a
fsincos							; sin cos a
fild word [bx-8]				; x sin cos a
fmulp st2						; sin x*cos a
fimul word [bx-9]				; y*sin x*cos a
faddp							; y*sin+x*cos a
fabs							; m a
fdivr dword [byte si+valx-1-256-3] ; m a
fistp word [byte bx-5]			 ; a
popa
test al,0x7f
jz S
sub ax,bp
aam 23
add al,32+24
S: stosb
mov ax,0xcccd
valx:
inc di
inc di
mul di
jnz X
inc bp
in al,0x60
dec ax
jnz X
ret
