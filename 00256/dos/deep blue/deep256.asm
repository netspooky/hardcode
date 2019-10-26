;----------------------------------;
;"Deep blue" intro by Tyler Durden ;
;Compiled with Fasm v.1.50         ;
;255 bytes version                 ;
;----------------------------------;
;website: www.tylerdurden.net.ru   ;
;email: deep@tylerdurden.net.ru    ;
;----------------------------------;
org 100h
mov al,13h
int 10h
mov ah,4ah
mov bh,(program_end+100h) shr 4+1
int 21h
salc
mov dx,3c8h
out dx,al
inc dx
scasw
.palette_set:
mov cl,63
.palette_inc:
xchg ax,di
out dx,al
out dx,al
xchg ax,di
out dx,al
cmc
jc .palette_inc
.inc:
inc ax
loop .palette_inc
xor byte [.inc],7h
jp .palette_set
mov cl,3
.create_buffers:
mov bh,10h
mov ah,48h
int 21h
stosw
loop .create_buffers
.wait:
mov di,320*200/2-320*8*3/2+320/2-9*(3*8-1)/2
mov si,string
mov cl,9
.draw_string:
db 2eh
lodsb
pusha
shl ax,3
xchg ax,si
mov ax,1130h
mov bh,3
int 10h
push es
pop ds
mov es,[cs:water_1]
add si,bp
mov cl,8
.draw:
mov dl,8
lodsb
.draw_line:
shl al,1
jnc .skip
pusha
salc
mov cl,3
.c:
stosb
stosb
stosb
add di,320-3
loop .c
sub di,320*3-3
popa
.skip:
scasw
inc di
dec dl
jnz .draw_line
add di,(320-8)*3
loop .draw
popa
add di,8*3-1
loop .draw_string
push cs
pop ds
mov bx,[seed]
add bx,di
xor bl,bh
mov [seed],bx
mov es,[water_2]
mov ds,[water_1]
mov [bx],bx
xor di,di
xor si,si
.water:
call .blur_it
sub ax,bx
jns .move
xor ax,ax
.move:
stosb
loop .water
mov [cs:water_2],ds
mov [cs:water_1],es
mov es,[cs:buffer]
dec cx
rep movsw
push es
pop ds
mov cl,5
.blur:
call .blur_it
shr ax,1
add ax,bx
shr ax,1
stosb
test di,di
jnz .blur
loop .blur
push 0a000h
pop es
dec cx
rep movsb
;hlt <-uncomment this to syncronized with timer
in al,60h
das
jc .wait
.blur_it:
mov al,[di+1]
mov bx,ax
mov al,[di-1]
add bx,ax
mov al,[di+320]
add bx,ax
mov al,[di-320]
add ax,bx
shr ax,1
xor bh,bh
mov bl,[es:di]
retn
string db 'Deep Blue'
seed dw ?
water_1=63
water_2=65
buffer=67
program_end: