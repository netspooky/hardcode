;first version of dandelion [on steroids]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;does not loop

org 100h
use16

start:   push 0a000h
         pop es
         push 09000h
         pop fs
         push 08000h
         pop ds
         mov al,13h
         int 10h

;assuming:
;cx = 255
;bx = ax = 0

mov cx,0ffffh ;clear vscreen
clr:
mov si,cx
mov byte[ds:si],255
loop clr

        mov dx,0x3C9
;        dec cx      ;0ffffh
pal:    shrd ax, cx, 18
        out dx,al ;r
        out dx,al ;g
        out dx,al ;b
        inc cl
        jnz pal
;loop pal


mov word [bp],240 ;seed
mov word [bp+2],64000-80 ;tree
mov word [bp+4],cx;0 ;crown of tree
mov word [bp+6],cx;0 ;init of "leaves"
mov word [bp+8],cx;0 ;number of stars
mov word [bp+10],cx;0 ;movement of "leaves"
main:


cmp word [bp],64000 ;cheap movement of seed
jae nodrop

add word [bp],320
mov si,word [bp]
mov byte[ds:si-320],255
mov byte[ds:si],cl ;cl = 0

nodrop:

cmp word [bp],64000
jb nogrow

cmp word [bp+2],64000-80-320*100 ;grown to the max?
jbe nogrow
sub word [bp+2],320
mov si,word [bp+2]
mov word[ds:si],07777h;07777h

nogrow:

cmp word [bp+2],64000-80-320*80
ja nobloom


cmp word [bp+4],673 ;full bloom?
ja nobloom

mov cx,word [bp+4] ;size of flower
inc cx
again2:

mov si,word [bp+2]  ;set blooming part
again:

in al,40h;dec ax  ;don't stay 0
;mov cx,2 ;make clouds bigger
;create "grid" with rules on the fly
gate0:
;inc ax
adc dx,ax  ;don't stay 0
mul dx
shr al,5   ;256/32

jnz gate1
add si,320 ;move down
gate1:
cmp al,1   ;move left
jne gate2
dec si
gate2:
cmp al,2   ;move right
jne gate3
inc si
gate3:
cmp al,3   ;move up
jne gate4
sub si,320
gate4:
;loop gate0 ;make eg -1 +320 possible in one run

go:
;cmp ah,127          ;keep color?
;jb stay
;dec bx              ;rise color for shades
stay:
cmp byte[ds:si],50
jbe drop
dec byte[ds:si]
;or byte[ds:si],cl;bl  ;set new pixel
drop:
loop again
inc word [bp+4]
;add word [bp+4],5
nobloom:

cmp word [bp+4],673 ;crown not grown yet
jnae nowind


cmp word [bp+6],cx ;check if stuff got grabbed ;cx=0 here
jne noinit        ;it got grabbed

;########################
;speed ah, color al ---> word!
;
;make "starfield" by saving "seeds" in one loop
xor si,si ;index starts at 0
mov di,320*35
windy:
mov al,byte [ds:di]   ;get color
cmp al,255            ;is it a part of the flower?
je breaker           ;nope
;mov byte [ds:di],10      ;testing
mov word [dotspos+si],di  ;grab pos
mov byte [fs:si],al  ;grab color

inc si ;move index
inc si ;2 because of word

breaker:
inc di
cmp di,320*159
jna windy

inc word [bp+6] ;1 ;set value to grabbed
mov word [bp+8],si ;save index (seeds*2)

noinit:
;jmp nowind ;testing

;move "seeds"
xor si,si
xor ax,ax
move:
mov di,word[dotspos+si] ;get pos for display
mov bl,byte[fs:si] ;get col
;in al,40h
mul bx
mul di
shr al,6
inc al ;never 0!
xor ah,ah
mov byte[ds:di],255 ;delete old one
sub word[dotspos+si],ax ;change saved pos of "seed"
sub di,ax               ;change pos for new "seed"
mov byte[ds:di],bl      ;drop it on the screen

cmp byte[fs:si],254
jae nix
inc byte[fs:si]
inc byte[fs:si]
nix:

inc si ;move index
inc si ;2 because of word
cmp si,word [bp+8]
jna move

nowind:



;flip
mov di,320*35 ;only copy visible area!
flip:
mov al,byte [ds:di] ;grab + clear
mov byte [es:di],al  ;drop to screen
inc di
cmp di,320*159
jnae flip

mov dx, 3dah ;wait for vsync for constant speed
;vsync1:
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2


         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

dotspos dw 16125*2 dup ? ;there is a lot to be saved