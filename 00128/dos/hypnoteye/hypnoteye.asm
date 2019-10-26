org 100h
push 0xa000 - 70							; rrrolas trick I
pop es										; (advanced)
mm:
or al,0x13									; 320x200 in 256 colors
cwd
L:											; custom palette
add cl,1
int 0x10
mov ax,0x1010
add ch,4
add dh,8
inc bx
jnz L
X:
mov ax,0xcccd								; rrrolas trick II
mul di
sub dh,byte [si]
pusha
fninit
fild word [byte bx-8]		;<- dh+dl		; x
fst st1										; x x
fmul st0									; x*x x
fild word [byte bx-9]		;<- dl+bh		; y x*x x
fst st3										; y x*x x y									
fmul st0									; y*y x*x x y 
faddp st1									; y*y+x*x x y
fsqrt										; r x y
fidivr dword [byte si+mm-3-0x100]			; invr x y
fistp word [byte bx-5]		;-> al+ch		; x y
fpatan										; arc
fmul dword [byte si+num-2-0x100]			; arc/pi*256
fistp word [byte bx-8]		;-> arc -> dx	;
popa
add dx,bp									; time influence
shr dx,2
test al,0x80								; inner bound
jnz colskip
cmp al,0x1e									; outer bound
jg F2
salc
jmp short colskip
F2:
add ax,bp									; time influence
xor ax,dx									; arc influence
colskip:
stosb										; write
inc di										; dither
inc di
jnz X
mov dx,0x0331
mov al,0x3F
out dx,al
dec dx
mov al,0xC0
out dx,al
inc bp										; next frame
mov al,11
out dx,al
mov al,0x90
out dx,al
imul ax,bp,byte 9							; hypnotic scale ;)
aam 84
out dx,al
out dx,al
in al,0x60									; check for ESC
dec al
jnz X
ret											; exit
num:
db 0xa2,0x42

