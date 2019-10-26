;phoenix // from the flames
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: lefu - mon ami

org 100h
use16

start:   push 0a000h
         pop es
         push 09000h
         pop ds
         mov al,13h
         int 10h

        mov dx,0x3C9
        xor cx,cx     ;has to be 0 below anyway
pal:    mov ax,cx     ;border
        shr al,1
        out dx,al ;r
        out dx,al ;g
        shr al,1  ;
        out dx,al ;b
        inc cl
        cmp cl,127
        jne pal

pal2:   mov ax,cx    ;bird
        sub al,127
        shr al,1
        out dx,al ;r
        shr al,2  ;
        out dx,al ;g
        out dx,al ;b
        inc cl
        jnz pal2


;bp = amplitude/y
;bp+2 = for movement up down of wings
;bp+6 = new y
;bp+8 = degrees
;bp+10 = for calulation of sin ---> pi*degrees/180 = degrees/57 (180/3.14... = 57,...)
;bp+12 = for movement of bird


mov word[bp+10],57 ;for rad
main:

mov word [bp+2],1 ;wings are down
loop1:

mov word[bp],cx
sub word[bp],30 ;make high - 0 - low

fild word [bp+8]   ;pi
fidiv word [bp+10]     ;pi*grad
fsin
fimul word [bp]   ;sin*y
fistp word [bp+6] ;y

;set 2d pixel
imul di,word[bp+6],320
add di,[bp+8]          ;y*320+x = pos pixel

add di,word[bp+12]         ;move
mov byte [ds:di],240       ;vscreen with fake shading
mov byte [ds:di+320],240   ;make it strong
mov byte [ds:di+320*2],240 ;make it super strong
sub di,[bp+8]              ;other wing
sub di,[bp+8]
mov byte [ds:di],254       ;vscreen
mov byte [ds:di+320],254   ;make it strong
mov byte [ds:di+320*2],254 ;make it super strong


dec word [bp+8] ;worked with all degrees?
jnz loop1
mov word [bp+8],65 ;size of the bird = degrees


grid:
mov di,si          ;set position of pixel on vscreen

xor bx,bx
add bl,byte[ds:si] ;don't work with black#1 (border)
jz drop
cmp bl,128         ;don't work with black#2 (bird)
je drop

;create "grid" with rules on the fly
gate0:
sub ax,si  ;don't stay 0
add dx,ax  ;don't stay 0
mul dx
shr al,5   ;256/32

jnz gate1
add di,320 ;move down
gate1:
cmp al,1   ;move left
jne gate2
dec di
gate2:
cmp al,2   ;move right
jne gate3
inc di
gate3:
cmp al,3   ;move up
jne gate4
sub di,320
gate4:

dec bx              ;color for shades
mov byte[ds:di],bl  ;set new pixel on vscreen
;mov byte[es:di],bl  ;parallel flip to screen ---> speed up
drop:
dec si
jnz grid            ;work with full screen

;parallel flip above is too fast :(
flip:
mov al,byte [ds:si]  ;grab+clear vscreen
mov byte [es:si],al  ;drop to screen
inc si
jnz flip

;make borders
mov di,320*201
lines:             ;vertical
mov byte[ds:di],127
inc di
jnz lines

mov di,320*199
lines2:
mov word[ds:di+319],07f7fh ;horizontal
sub di,320
jnz lines2

sub word[bp+12],319 ;move bird

cmp cl,80     ;wing movement up and down
jne dropit
neg word[bp+2];change direction
dropit:
add cx,word[bp+2]
jnz loop1

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret