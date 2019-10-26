;dandelion [on steroids]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: skeewiff - a man of constant sorrow

org 100h
use16

start:   push 0a000h
         pop ds      ;screen
         push 08000h
         pop es      ;seeds buffer (coordinates)
         push 09000h
         pop fs      ;color buffer
         mov al,13h
         int 10h

;assuming:
;cx = 255
;bx = ax = 0

;clear visible area
mov di,320*139
clr:
dec byte [ds:di-1];make 0 (black) ---> 255 (bright)
dec di
jnz clr

reset: ;reset here because cx gets reset too
        mov dx,0x3C9
        xor cx,cx
pal:    shrd ax, cx, 18
        out dx,al ;r
        out dx,al ;g
        shr al,1
        out dx,al ;b
        inc cl
        jnz pal
;loop pal

mov bx,240 ;seed
mov word [bp+2],240+320*139 ;plant
mov word [bp+4],cx;0 ;crown of tree
mov word [bp+8],cx;0 ;number of stars
main:


cmp bx,240+320*139 ;cheap movement of seed
jae nodrop

mov byte[ds:bx],255 ;erase old seed
add bx,320
mov byte[ds:bx],cl ;cl = 0 here ; set new seed

jmp nowind ;skip everything because seed not fallen yet
nodrop:
mov bh,255

cmp word [bp+2],240+320*80 ;grown to the max?
jbe nogrow

sub word [bp+2],320
mov si,word [bp+2]
inc word[ds:si];1 ;mov word[ds:si],07777h

jmp nowind ;skip everything because not grown to the max

nogrow:

mov cx,word [bp+4] ;size of flower
inc cx

cmp cx,574 ;in full bloom?
ja nobloom          ;yes


mov si,word [bp+2]  ;set blooming position
again:

in al,40h ;don't stay 0
;inc ax
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

cmp byte[ds:si],1 ;avoid glitchy appearence
jbe drop           ;by 0 - 1 = 255
dec byte[ds:si]

drop:
loop again

inc word [bp+4] ;more bloom!

jmp nowind

nobloom:


cmp word [bp+4],575
ja noprepare

;prepare to speed things up
xor di,di;mov di,1
change:
cmp byte[ds:di],bh
je weiter ;no part of flower so skip
shl byte[ds:di],1
dec byte[ds:di] ;so get 255 at last step below
weiter:
inc di
cmp di,320*139-1
jna change ;last pair of index does not have grabbed values
inc word [bp+4]

noprepare:

;move "seeds"
xor di,di;mov di,1
move:
mov si,di
;xor ax,di
xor dx,dx
mov dl,byte[ds:di] ;get color for setting
cmp dl,bh;cmp byte[fs:si],255 ;reached max fading?
je nix
mov byte[ds:di],bh ;delete old one
sub al,dl
shr al,4
xor ah,ah
inc ax
sub si,ax
inc dx
inc dx
mov byte[ds:si],dl ;delete old one
mov cl,1 ;not everything has faded
nix:

inc di
cmp di,320*139-1
jna move ;last pair of index does not have grabbed values

dec cl;cmp cl,0 ;everything faded
jnz reset; je reset ;drop new seed

nowind:

mov dx, 3dah ;wait for vsync for constant speed
vsync1:      ;and avoid glitches because of erasing old seeds'n'stuff
in al,dx
test al,8
jnz vsync1
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