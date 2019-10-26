;Breathing Tree by Harekiet
;nasm tree.asm -o tree.com

cpu 386
org	0100h

;Step count determines the size of the tree
STEPCOUNT equ 50

;fs is our temp segment, just stick it somewhere
push 0x7000
pop	fs

;set video segment
push 0xa000
pop es

;Setup video mode
mov	ax,13h
BXCONST13 equ $ - 2 - 100h
int	10h

restart:

;Source pixel
mov si, pixelX
BXCONSTBIG equ $ - 2 - 100h
;Write the new pixels
lea di, [si+12]

;start with a length step of 1
fld1
;branch loop counter
xor cx, cx
branchloop:
;Keep looping more for higher nodes
mov dx, 1
shl dx, cl
;use bx a counter offset
mov bx, 100h
BXCONST100 equ $ - 2 - 100h

nodeloop:

;Load parent angle
fld dword [si+8]
;Sway the entire tree to the sides a bit
fild word [bx]
fdiv dword [pixelX]
fsin
fidiv word [bx + BXCONST13]

faddp

;determine the delta for 2 children
fild word [bx]
fmul dword [counterScale]
;fidiv dword [bx + BXCONST13]
fsin 
;Divide the sines by pi to reduce the range a bit
fldpi
FDIVP st1

;Slight bit of random action, read a float as an int
mov ax,[si]
sar ax, 11
mov [di],ax
fild word [di]
fidiv word [bx+BXCONSTBIG]
faddp

;add 1 as the constant change
fld1
faddp
;Store the result added and subtracted to my parent in my children
fld st0
;st0 delta angle
;st1 delta angle
;st2 parent angle
;st3 length
fadd st2
fstp dword [di+8]
;Negate and scale down result for other child
fmul dword [angleScale]
fadd st1
fstp dword[di+8+12]
;st0 angle
;st1 length
;Generate the delta vectors
fsincos	
;fpu state
;st0 sin
;st1 cos
;st2 length
;Scale my x and y by length/steps
fld st2
fmul st1, st0
fmulp st2, st0
;Do the actual drawing
mov ch, STEPCOUNT
fldz 
drawLoop:
;st0 counter
;st1 dx * length/steps
;st2 dy * length/steps
;st3 length

;Y coordinate, add parent and store in child and use to calculate
fld st2
fmul st1
fadd dword [si+4]
fist dword [di]
imul ebp, [di], 320
;save the last coord for my child
fst dword [di+4]
fstp dword [di+4+12]

;X coordinate, add parent and store in child and use to calculate
fld st1
fmul st1
fadd dword [si+0]
fist word [di]
add bp, word [di]
;save the last coord for my child
fst dword [di+0]
fstp dword [di+12]
;The colour for this node heights pixels
mov al, cl
add al, 32
mov [fs:bp], al
;increase the counter
fld1
faddp
dec ch
jnz drawLoop

;Remove the counter, x, y
fucomp
fucompp

add di, 24
add si, 12
dec dx
jnz nodeloop

;Decrease length for the next nodes
fmul dword [lengthScale]

inc cx
cmp cl, 11
jb branchloop
;Remove the length
faddp

;Increase my counter
inc word [bx]

;Copy and clear screen

;Wait for retrace
mov	dx, 03dah
wait_off:
in	al,dx
test	al,8
jnz	wait_off
wait_on:
in	al,dx
test	al,8
jz	wait_on

;Copy the virtual screen and clear it
xor di,di
mov	ch,320*100/256
copyclear:
xor ax,ax
xchg ax,[fs:di]
stosw
loop	copyclear

;jmp restart
;some bytes to waste, do a proper exit
mov	ah,1			;Check for keypress
int	16h
jz restart
;mov ah,0			;Remove the pressed key
;int 16h
mov	ax,03h			;restore screen	to text mode
BXCONST03 equ $ - 2 - 100h
int	10h
retn	

angleScale dd -0.6	;Scale the other side of the tree gets
lengthScale dd 0.70710678 ;sqrt 0.5
;counterScale dd 0.09817477 ;Repeating pi every 32 frames
counterScale dd 0.062831853 ;Repeating pi every 50 frames

pixelX dd 160.0
pixelY dd 180.0
pixelAngle dd -1.570796	;half pi

