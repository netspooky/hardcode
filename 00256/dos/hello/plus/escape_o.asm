;lilia and sammie // their great escape (old version)
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: steaming satellites - how dare you!

;very early version of lilia and sammie where i tried to make it happen
;with the drawing "filter". it did not work out and is very fugly. But
;I fiddled around to get it down to 256b to keep it real ;)

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;here goes the original data
         pop fs
         push 08000h ;here is the crayonized copy of original data
         pop gs
         mov al,13h
         int 10h

;screens are cleared at first flip of screen to vga
main:

mov si,100 ;number of clouds * 2 because accessing word
cloudie:
mov di,word[cloudpos+si]   ;get pos (random at 1st run)
;mov bx,word[cloudsize+si] ;get length (random at 1st run)
;xor bh,bh                 ;length not more that 255
mov bl,byte[cloudsize+si]  ;even if bh <> 0 at first frame it won't matter
again:
add bl,30                 ;minimum size
jz again                  ;no 0 a.k.a. fugly error dammit!
mov ax,bx                 ;save for later use

draw_cloud:
mov byte[fs:di+bx],66     ;not too bright
mov byte[fs:di+bx+321],65 ;not too bright
dec bx
jnz draw_cloud

;use lenght for movement so smaller clouds are slower
shr ax,5                     ;ah = 0
inc ax                       ;never 0
imul dx,ax,321*2             ;create movement
add word[cloudpos+si],dx     ;move
cmp word[cloudpos+si],64000  ;outside of screen?
jnae allright                 ;if so create new data for the cloud
;jnc allright ;this works instead of 2 lines above but has popping out clouds
              ;on top of screen
in al,40h
mul dx;ax
;sbb ax,dx
shr al,2 ;not that big (ah will be cleared at reading value above)
mov byte[cloudsize+si],al ;length

allright:
dec si
dec si
jnz cloudie ;sets at pos 0 are not used!

;draw the ship of lilia and sammie
;plus the ones that are after them!
;xor si,si ;si = 0 here
xor di,di
ship:
mov bx,word[ship_pos+si]    ;get stuff ... obviously
mov al,byte[ship_color+di]
mov ah,al                   ;for a fat line
movzx cx,byte[ship_size+di] ;length
draw_ship:
mov word[fs:bx],ax
add bx,321
loop draw_ship

sub word[bp+si],322      ;draw their enemies
mov bx,word[bp+si]       ;and simply use the stack for pos
cmp si,8
ja allrightie
neg bx                   ;make it more dynamic
allrightie:
mov cl,byte[ship_size+di];just use data of the ship
shl cl,1                 ;size up the drama!
fire:
mov byte[fs:bx],67       ;they are coming for you!
add bx,321               ;lilia and sammie! watch out!
loop fire                ;O_____O

inc di
inc si
inc si
cmp si,14
jne ship                  ;all sets done?


;### crayoniz0r :D ###
xor bx,bx
;do the crayon strokes
;bx = 0 here
crayon:
cmp byte[fs:bx],57;79;65 ;no action with background color
je skip

in al,40h ;make pseudo random lenght of strokes
mul bx    ;bla
sbb dx,ax ;bla
shr dx,13 ;allow 0 to give other colors a chance
jz skip   ;so if 0 skip drawing

shr ax,14  ;random from above
add ax,319 ;make it possible to move diagonal in both ways
mov cx,ax  ;or even vertical (below at move instead of 319!)
mul dx     ;and now this
mov di,ax  ;makes the strokes more random

;imul di,dx,319 ;length of stroke

mov si,bx ;base where we are on the screen
sub si,di ;sub lenght to make start point of stroke
add di,bx ;make end point of stroke

mov al,byte[fs:bx] ;get color
stroke:
mov byte[gs:si],al ;draw to vscreen
add si,cx;319      ;move
cmp si,di          ;reached end point?
jne stroke         ;nope so go on

skip:
dec bx
jnz crayon         ;do it with whole screen

;no black bars this time \:D/
;bx = 0 here
flip:
mov al,57;79;65           ;background color
mov byte[fs:bx],al        ;clean original data screen
xchg al,byte[gs:bx]       ;grab and clear drawn data screen
mov byte[es:bx],al        ;drop to vga
inc bx
jnz flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

nop ;256

;            cockpit    |     body of ship    |  weapons    |     body of ship    | ray of nrg
ship_pos dw 320*80+120, 320*75+110, 320*82+124, 320*90+122, 320*90+138, 320*90+140, 320*98+136
ship_size db        10,         26,         18,          6,          5,          4,        102
ship_color db        1,         30,         29,          4,         28,         27,         44

cloudpos dw 200 dup ?
cloudsize dw 200 dup ?