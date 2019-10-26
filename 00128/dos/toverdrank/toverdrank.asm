org 100h

push 0xa000-70					; rrrolas trick I
pop es							; (advanced)
mov al,0x13						; 320x200 in 256 colors
int 0x10

X:
mov ax,0xCCCD					; rrrolas trick II
mul di
sub dh,[si]						; [si] = [0x100] = 0x68
pusha
fninit							; real DOS needs this!
fild word [byte bx-8]			; <- dx
fst st1
fmul st0
fild word [byte bx-9]			; <- dl+bh
fst st3
fmul st0
faddp st1
fsqrt
fsqrt							; sqrt(sqrt(x²+y²))
fistp word [byte bx-4]			; -> r		-> ax
fpatan
fmul dword [byte si+num-2-0x100]
fist word [byte bx-8]			; -> arc'	-> dx
popa
shr ax,1

add ax,dx						; r + arc'
sub ax,bp						; time influence

mov cl,24						; wrap to a 24 color band
xor dx,dx
div cx
xchg dx,ax

add al,32+24					; shift into sweet colors

stosb							; write
add di,cx						; dither offset

jnz X
inc bp							; next frame
mov dx,331h
mov al,3Fh						; uart mode
out dx,al
dec dx
mov al,0C0h						; change instrument...
out dx,al
mov al,101						; ...to this !!!
out dx,al
mov al,90h						; play note..
out dx,al
imul ax,bp,byte 3
aam 85							; hypnotic scale ;)
out dx,al		
mov al,90						; volume = 90
out dx,al

in al,0x60						; check for ESC
dec al
jnz X

mov al,176						; disable sound (all notes off)
out dx,al
mov al,123
out dx,al
out dx,al

mov ax,3						; return to textmode
int 0x10

mov dx,txt						; displaying the crew name =)
mov ah,9
int 0x21

ret								; exit
num:
dw 0x4174						; 48 / pi (scale for arc)
txt:
db 'dSr$'
