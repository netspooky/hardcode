;Mach 5 by Harekiet

cpu 386
org	0100h

COLORCENTER EQU 44
COLORRANGE EQU 6

;set video segment
push 0xa000
pop es

;Setup video mode
or al, 13h
int	10h

;rotate index
fldz

restart:

;Setup SI for move
mov si, temp + 16
CONST400 equ $ - 2
push si
xor di, di

;Copy Screen during vsync
mov cx, 32768 - 8
rep movsw
;bx is a the temp value for the coloradding counter
lea bx, [word si + COLORRANGE]
colorRange equ $ - 2
CONST0054 equ $ - 2

;Location for the temp buffer
pop di

mov bp, -100
CONST100 equ $ - 2

nextRow:
mov dx, -160
CONST160 equ $ - 2

nextPixel:

;0 angle

;Generate an angle
fld st0
fsincos

;0 sin
;1 cos
;2 angle

;sin/cos x/y
mov [si], dx
fild word [si]
fmulp st2
mov [si], bp
fimul word[ si]

;0 sin * x
;1 cos * y
;2 angle

;Generate distance from line and scale this a bit
fsubp st1
fimul word [si + (colorRange - temp)]
;fdiv dword [si + (CONST0054 - temp )]
fabs
;Make the center part 0
;fisub word [si + (CONST400 - temp)]
fiadd word [si + (CONST100 - temp)]
;Negative values will go nan and stay 0
fsqrt
;Make the color bars move
fisub word [bx]
;Make a copy
fst dword [si]
fsin
;0 color
;1 angle
;Add a secondary slower moving compnent
fld dword [si]
fidiv word [si + (colorCenter - temp)]
fcos
;Create the final color based on these 2 components
faddp st1
fimul word [si + (colorRange - temp)]
fiadd word [si + (colorCenter - temp)]
;Final color store and display
fistp word [di]
inc di

inc dx
cmp dx, 160
js nextPixel

inc bp
cmp bp, 100
js nextRow

;Move the color bars forward
inc word [bx]

;Calculate an angle for the next frame
fild word [bx]
fidiv word [si + (CONST100 - temp)]
fsin
;Reduce the speed of change 
fmul dword [si + (CONST0054 - temp )]

;Increase the rotation angle
faddp st1

;Wait till retrace starts
mov	dx, 03dah
CONST3da equ $ - 2
wait_on:
in	al,dx
test	al,8
jz	wait_on

;Standard keyboard loop
mov	ah,1			;Check for keypress
int	16h
jz restart

;2 bytes left to make the fpu happy with cleaning up stack
fninit
retn	


colorCenter:
dw COLORCENTER

temp:



