; SinDots by Harekiet for 256 byte EFnet's #ASM intro compo.
;
; Saw this effect once in some Pascal vga graphics effects collection by
; Bas van Gaalen. So thought let's give him some credit for it :)

; Press a key other than ESC to change the pattern
;
; Compile with NASM

org	0100h
;Setup video and segment
mov	al,13h
int	10h

push	cs
pop	ax
add	ah,10h
push	ax
pop	fs

shl	si,1		;si=1000h

;Initialize some values with random values
newrandom:
push	cs
pop	es
mov	ah,2ch
int	21h		;Use dos time function for some nice seed
add	cx,dx
add	[seed],cx

push	si
pop	di

mov	cx,sintables*2
makeem:
mov	bp,1024
mov	bx,3048
call	random
stosw			;Table size between 512-2047
xor	bp,bp
xchg	bx,ax
call	random		
stosw			;Table main index between 0 and size
inc	bp
mov	bx,5
call	random		;Table main speed between 1 and 4
stosw
inc	bp
call	random		;Table temp speed between 2 and 4
stosw
stosw			;For the loop index
loop	makeem


push	0a000h		;Video segment
pop	es

updatescreen:

;Wait for retrace
mov	dx,03dah
wait_off:
in	al,dx
test	al,8
jnz	wait_off
wait_on:
in	al,dx
test	al,8
jz	wait_on

;Copy the virtual screen and clear it
xor	bx,bx
mov	di,bx
mov	ch,320*100/256
copyclear:
mov	ax,[fs:di]
mov	[fs:di],bx
stosw
loop	copyclear

;Draw the dots
mov	bp,dx			;We have 3dah dots to draw
drawdots:
fldz				;Zero x and y pos
fldz

;Calculate the coordinate for a dot
mov	cl,sintables*2
push	si			;Save si since it's gonna get added too
calcpos:
cmp	dx,bp			;Check if it's first time
jb	not_first
;increase table with main speed
mov	ax,[si+_index]		;Table position
add	ax,[si+_speed]		;Table speed
cmp	ax,[si]			;Table size
jb	main_fine
sub	ax,[si]
main_fine:
mov	[si+_index],ax		;Store the new position
mov	[si+_tindex],ax		;Use this as the new temp position
not_first:
mov	ax,[si+_tindex]		;Table temp position
add	ax,[si+_tspeed]		;Table temp speed
cmp	ax,[si]			;Table size
jb	temp_fine
sub	ax,[si]
temp_fine:
mov	[si+_tindex],ax

fldpi				;Get 4*pi
fadd	st0
fadd	st0
fidiv	word [si+_size]		;4*pi/table size
fimul	word [si+_tindex]	;(4*pi/size)*index
fsin				;Take the sinus
test	cl,1			;Check if it's an X or an Y position
jz	addother
fimul	word [ysize]		;Mul by size
faddp	st1			;Add it to y
jmp	nextpos
addother:
fimul	word [xsize]		;Mul by size
faddp	st2			;add it to x
nextpos:
add	si,10
loop	calcpos
;Store	x and y
fistp	word [si]		;Store Y position
mov	di,[si]
imul	di,320
fistp	word [si]		;Store X position
mov	bx,[si]
mov	al,dl			;Get some nice colors from standard vga palette
and	al,31
add	al,32
mov	[fs:di+bx+32160],al
pop	si			;restore SI back to 1000h

dec	dx
jnz	drawdots

mov	ah,1			;Check for keypress
int	16h
jz	updatescreen
mov	ah,0
int	16h
cmp	al,27			;Not escape change pattern
jz	stopit
jmp	newrandom

stopit:
mov	ax,03h			;restore screen	to text mode
int	10h
retn				;Return to cd20 at psp:0

random:		;Return random number between bp and bx in ax
	imul	ax, [seed], 121
	inc	ax
	mov	[seed], ax
	xor	dx,dx
	div	bx
	xchg	ax,dx
	cmp	ax,bp
	jb	random
	ret


sintables equ 5
ysize dw 200/2/sintables
xsize dw 320/2/sintables

seed	equ 2			;Let's put the seed in the PSP

_size	equ 0
_index	equ 2
_speed	equ 4
_tspeed	equ 6
_tindex	equ 8
_result	equ 10

