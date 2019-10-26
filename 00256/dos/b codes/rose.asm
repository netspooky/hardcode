;electric rose [of decay]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: birds. outside

org 100h
use16

start:   push 0a000h
         pop es
         push 09000h
         pop ds
         mov al,13h
         int 10h

;fill:
;mov byte[ds:si],15
;inc si
;jnz fill

;mov di,320*50-1
;bars:
;mov byte[ds:di],0
;dec di
;cmp di,320*140-1
;jne bars

mov si,320*140
fill:
mov byte[ds:si],ah
cmp si,320*50-1
jne black
mov ah,15
black:
inc si
cmp si,320*140-1
jne fill

reset:
mov di,320*99+80

main:


in al,40h
adc dx,di
mul dx
shr al,5 ;div 32
mov dh,48 ;leaf color
mov word[bp],12 ;leaf size width
mov bx,320*7 ;leaf size height
cmp al,3
ja way4
movzx si,al
shl si,1
mov si,word[cs:moving+si] ;greets + thanks to orbitaldecay
way4:
cmp ah,123 ;make rose/leaf when ah has that value
jne way5
cmp al,4   ;rose?
jne leaf
mov dh,40 ;rose color
shl word[bp],2 ;rose width
shl bx,3 ;rose height
leaf:
;bx = width
bloom1:
mov cx,word[bp]
bloom:
mov si,di
add si,cx
cmp byte[ds:si+bx],15 ;inside visible area?
jne skip1             ;also skips when there is a rose/leaf
mov byte[ds:si+bx],dh
skip1:
loop bloom
sub bx,320
jnz bloom1
jmp main

way5:
cmp al,4
jae main

mov cl,4 ;size of line to draw -1
draw:
add di,si
cmp di,320*140 ;don't draw/move outside of visible area!
ja reset
cmp di,320*50 ;don't draw/move outside of visible area!
jb reset
;cmp byte[ds:di],0 ;bar area?
;je skip2          ;yes otherwise draw no matter if rose/leaf is there
mov byte[ds:di],16
;skip2:
loop draw

xor si,si
fade:
cmp byte[ds:si],16
jb nein; only above 15!
cmp byte[ds:si],30
ja nein

cmp word[bp+4],4 ;frame counter
jne nein

inc byte[ds:si] ;fade trunk
jmp nein2

nein:
cmp byte[ds:si],40 ;40 rot und 48 grün
jb nein2

in al,40h
mul si
cmp al,148 ;for different movement speed
ja nein2  ;skip to have a solid block falling

mov al,byte[ds:si];get color
mov ah,15 ;color for old pos
cmp si,64000
jb move ;move area

mov al,0 ;set 0 for no more movement
move:
cmp si,320*140
jb moveon

mov ah,0 ;area on bar
moveon:
mov byte[ds:si],ah ;erase old pos

mov cx,si ;different speed
shr cx,15
inc cx
imul bx,cx,320

;mov byte[ds:si+320],al
mov byte[ds:si+bx],al

nein2:

dec si
jnz fade


inc word[bp+4]
cmp word[bp+4],16
jna nope
mov word[bp+4],si ;reset frame counter


nope:
;si = 0 here
flip:
mov cl,byte[ds:si]
mov byte [es:si],cl
dec si
jnz flip


         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on
outto:
         mov ax,03h            ;keep it clean :)
         int 10h
         ret
moving dw 1,-1,320,-320