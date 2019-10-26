; WARNING
; this was coded in a few hours
; not really optimized and maybe horrible even!
org 100h
push 0xa000-50
pop es
mov al,0x13
cwd
inc cl
L:							; custom palette
int 0x10
mov ax,0x1010
dec dh
test bl,0x40
jz skip3
dec ch
dec cl
skip3:
inc bx
jnz L
mov al,0x13
int 0x10
mov ah,9					; display party message
mov dx,txt
int 0x21
X:
mov ax,0xCCCD
mul di
add dh,165
mov ax,bp					; bouncing
sub dl,al
shl al,2
and al,63
test al,63
jz skip1
xor al,63
skip1:
sub al,31
imul al
sar ax,5
sub dh,al
pusha
fninit
fild word [ bx-8]			;<- dh+dl				; x
fst st1												; x x
fmul st0											; x*x x
fild word [ bx-9]			;<- dl+bh				; y x*x x
fst st3												; y x*x x y
fmul st0											; y*y x*x x y
faddp st1											; y*y+x*x x y 	
fchs 												; -y*y-x*x x y
fadd dword [num-2]									; r*r-y*y-x*x x y
fsqrt												; z x y 
fist word [bx-4]			;->ax
fst st3												; z x y z
fpatan												; arc1 y z
fmul dword [num2-2]									; arc1' y z
fistp word [bx-6]			;->cx					; y z
fpatan												; arc2
fmul dword [num2-2]									; arc2'
fistp word [bx-8]			;->dx					; 
popa
test ah,0x80
jz draw
salc
jmp short drawskip
draw:
add dx,bp					; pattern/color mapping
xor cx,dx
shr ax,9
shr cx,3
and cl,1
imul cx, byte 64
add ax,cx
not al
sub al,23
FF:
drawskip:
stosb
test di,di
jnz X
add di, 12*320				; don't overwrite the text!
inc bp
mov dx,0x0331				; boing sound
mov al,0x3F
out dx,al
dec dx
mov al,0xc9
out dx,al
mov al,56
out dx,al
mov al,0x99
out dx,al
test bp,0x0f
jnz soundskip
mov al,56
skip6:
out dx,al
mov al,127					; LOUD!
out dx,al
soundskip:
in al,0x60					; check for ESC
dec al
jnz X
mov ax,3					; textmode
int 0x10
mov ah,9					; display party message again =)
mov dx,txt
int 0x21
ret							; quit
num:
dw 0x4dc0		; 160²
num2:
dw 0x41a2		; 64 / pi
txt:
db 'DESiRE wishes everybody a happy QBPARTY',0x03
db '$'
