;dandelion on steroids 2 // welcome to the jungle
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: arno cost & arias - magenta (camo & krooked remix)

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
;this time no two bars to free the sky!
mov di,320*130
clr:
dec byte [ds:di-1];make 0 (black) ---> 255 (bright)
dec di
jnz clr
;cmp di,320*131
;jne clr

reset: ;reset here because cx gets reset too (cx <> 0)

        mov dx,0x3C9
        xor cx,cx
pal:    shrd ax,cx,18
        out dx,al ;r
        shr al,1
        out dx,al ;g
        out dx,al ;b
        inc cl
        jnz pal

;vars
;cx = 0 here

mov bx,222    ;pos of falling seed and origin of jungle
mov [bp+4],cx ;size of jungle and check if seeds grabbed or not
mov [bp+8],cx ;number of seeds

main:
in al,40h     ;randomize because of vsync

cmp bx,222+320*130 ;cheap movement of seed
jae nodrop

mov byte[ds:bx],255 ;erase old seed
add bx,320
mov byte[ds:bx],cl      ;cl = 0 here ; set new seed

jmp nowind ;skip everything because seed not fallen yet

nodrop:

cmp word [bp+4],612 ;full grown jungle?
ja nobloom          ;yes (513) so move it

mov cx,word [bp+4]  ;get size of jungle
inc cx

;often used routine because it just looks so nice :>
mov si,bx ;set origin position
again:

in al,40h  ;don't stay 0
adc dx,ax  ;don't stay 0
mul dx
shr al,6   ;256/64 ;256/32 so not every step is growing

jnz gate1
sub si,320 ;move up
gate1:
cmp al,1   ;move left
jne gate2
dec si
gate2:
cmp al,2   ;move right
jne gate3
inc si
gate3:
cmp al,3   ;move down
jne gate4
add si,320
gate4:

cmp si,320*130     ;no growing into ground
ja drop
mov byte[ds:si],al ;almost black but 1b less ;)

drop:
loop again

inc word [bp+4] ;more bloom!

jmp nowind      ;skip everything because not grown to the max

nobloom:

cmp word [bp+4],614 ;check if stuff got grabbed
                    ;513 = not grabbed
je noinit           ;it got grabbed

;make seed-starfield by saving seeds in one loop
xor si,si            ;index starts at 0
xor di,di
windy:
mov al,byte [ds:di]  ;get color
cmp al,255           ;got only air and no part of jungle?
je breaker           ;yes so do nothing
mov word [es:si],di  ;grab pos
in al,40h            ;randomize colors for different fadings
mul di
mov byte [fs:si],al  ;save random color

inc si ;move index
inc si ;2 because of word

breaker:
inc di
cmp di,320*130-1   ;visible area ends here
jna windy

inc word [bp+4]    ;set value to all grabbed: 513 ---> 514
mov word [bp+8],si ;save index (seeds*2)

noinit:

;move "seeds"
xor si,si ;index starts at 0
;xor cx,cx ;cx = 0 here
move:
mov di,word[es:si] ;get pos for display
mov dl,byte[fs:si] ;get color for setting
add al,dl          ;make speed ;sub: fast ---> slow / add/mov: slow ---> fast
shr al,5           ;make speed
xor ah,ah          ;no fail at sub
inc ax             ;never 0!
mov byte[ds:di],255 ;delete old one
sub word[es:si],ax ;change saved pos of seed
sub di,ax          ;change pos for new seed
mov byte[ds:di],dl ;drop it on the screen

cmp dl,255         ;reached max fading?
je nix             ;yes
inc byte[fs:si]    ;fade color to bright
mov cl,1           ;not everything has faded
nix:

inc si             ;move index
inc si             ;2 because of word
cmp si,word [bp+8]
jne move           ;last pair of index does not have grabbed values

dec cx             ;everything faded?
jnz reset          ;yes, so reset drop new seed

nowind:

mov dx,3dah ;wait for vsync for constant speed
vsync1:
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