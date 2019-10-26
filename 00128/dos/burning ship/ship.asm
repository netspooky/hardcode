;Burning Ship by Harekiet
;nasm ship.asm -o ship.com

cpu 386
org	0100h

;Step count determines the size of the tree
WIDTH equ 1024
HEIGHT equ 768
MODE equ 117h			;1024x768x16bpp
;How many samples to do per pixel, WIDTH * SAMPLECOUNT < 32767
%ifndef DOSBOX
SAMPLECOUNT equ 31
%else
SAMPLECOUNT equ 8
%endif
;How many iterations per sample
ITERATECOUNT equ 60

;What variable to init SI with
SIBASE equ xIndex

;AX should be 0
push ax

;Setup vesa video mode.
mov	ax,4f02h
CONST_6000:
mov bx, MODE | 0x4000
int	10h

;Setup SI for direct byte offset addressing
mov si, SIBASE
%ifndef DOSBOX
;Read the lfb address from vesa
;Stick the table right at xIndex to be rewritten later
push si
pop di
;Get vesa video mode info
mov ax, 4f01h
push bx
pop cx
int 10h
;Extract the lfb addtress
mov edi, [di+0x28];
%else
;Just force the dosbox lfb address
mov edi, 0xc0000000
%endif
;Pop the 0 still on the stack
;set es to start of ram for lfb addressing
pop es

loopY:

;Have to use dx since we're reading this value for float
mov dx, SAMPLECOUNT
CONST_SAMPLES equ $ - 2

mov word [si + ( xIndex - SIBASE)], (WIDTH * SAMPLECOUNT )
loopX:

;cy = center.y + range * y
fild word [si + yIndex - SIBASE]
fidiv word [si + CONST_6000 - SIBASE]
fsub dword [si + floatConstY - SIBASE]

;cx = center.x + (range * x) /samplecount
fild word [si + xIndex - SIBASE]
fidiv word [si + CONST_SAMPLES - SIBASE]
fisub word [si + CONST_10000NEG - SIBASE]
fidiv word [si + CONST_6000 - SIBASE]

;Calculate the location we're interested in
;make p0x, p0y
fldz
floatConstY:		;There's a 0.02 ish constant here
fldz

;Do the fractal calculation
mov cx, ITERATECOUNT
CONST_ITERATE equ $ - 2

loopFind:
;st0 p0x
;st1 p0y
;st2 cx
;st3 cy
;py = 2 * fabs( p0x*p0y ) - cy
fld st1
CONST_10000NEG equ $ - 1
fmul st1
fabs
fadd st0
fsub st4

;st0 py
;st1 p0x
;st2 p0y
;st3 cx
;st4 cy

;px = p0x*p0x -p0y*p0y - cx
fld st1
fmul st0

fld st3
fmul st0
fsubp st1, st0
fsub st4

;st0 px
;st1 py
;st2 p0x
;st3 p0y
;st4 cx
;st5 cy

;p0 = p
fstp st2
fst st2

;st0 py
;st1 px
;st2 py
;st3 cx
;st4 cy
;c = (px + py) < limit
fadd st1
ficomp word [si + CONST_SAMPLES - SIBASE]
;ficomp word [si + CONST_ITERATE - SIBASE]
fnstsw  AX 
sahf
ja foundIt

loop loopFind

foundIt:
;Add the result for multiple samples
add bx, cx

dec dx
jnz dontSave

;Reset dx
mov dl, SAMPLECOUNT
;Reset bx for next sampling
xor ax, ax
xchg ax, bx
%ifdef DOSBOX
;compensate for the lack of additions
shl ax, 2
%endif
;Save a word using es:[edi]
db 67h
stosw

dontSave:

;Just reset the whole stack
fninit

dec word [si+xIndex-SIBASE]
jnz loopX

dec word [si+yIndex-SIBASE]
jge loopY

;waitkey
mov ah, 0
int 16h
;exit
ret

yIndex dw HEIGHT - 1
xIndex:



