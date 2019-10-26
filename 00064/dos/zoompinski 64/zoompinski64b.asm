db 134/4,122/4,222/4; C64 fore- and background
db 72/4,0x0c,170/4	; from "Zoompinski" by Plush

push 0xa000-40		; set screen origin
pop es				; to y = 2 (hide crap)

mov al,0x13			; mode 13
int 0x10			; set mode

mov dx,0x3c9		; use our code as
rep outsb			; color palette

S: xor dx,dx		; dx=0 for DIV
mov bx,320
mov ax,di
idiv bx				; [x,y] = [dx,ax]

sub dx,160			; center X

mul cl				; zoom
imul dx,cx			; zoom

mov bp,dx			; rotation
add dx,ax			; by 45
sub ax,bp			; degrees

and ah,dh			; zoompinski ;)

salc				; color 0 or 1 
jz F				; depending on
inc ax				; "and" pattern

F: stosb			; write pixel
test di,di
jnz S				; next pixel

or cl,bl			; keep zoom range

in al,0x60			; check key
dec al
loopnz S			; next frame
ret					; quit on ESC