;up // shine on
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: american zeros - madness

;no story, just fun while colding :)

org 100h
use16

;assuming: cx = 255
;          bx = 0

;used vars:
;bp+si = color
;bp+126+si = pos

start:   push 0a000h ;vga
         pop es
         push 09000h ;original screen
         pop ds
         mov al,13h
         int 10h

;for making it running good
;by using proper values at the start
mov di,cx
init:
inc ax
mul di
adc word[bp+di],ax
dec di
loop init

        mov dx,0x3C9
;        xor cx,cx ;no inc cx because of loop pal2

pal:    shrd ax,cx,17
        out dx,al ;g
        out dx,al ;g
        out dx,al ;b
        inc cx
        cmp cl,127
        jne pal
        mov bl,63
pal2:   mov al,bl;second half
        out dx,al ;r
        out dx,al ;g
        shrd ax,cx,17
        out dx,al ;b
        cmp cl,63
        ja allright2
        dec bx
        allright2:
        loop pal2

main:
;make a bar behind the stripes
;ch = 0
mov si,320*50
bar:
mov byte[ds:si+320*104-1],ch ;2 color cycles each single cycle of background color
dec si
jnz bar

;raster
;si = 0
;bh = 0 (after 1st frame)
mov dx,si
mov cl,60
corner1:
mov bl,3*29
;si=0
corner:
mov word[ds:si+bx+230-320],dx
mov word[ds:si+bx+230],dx
sub bx,3
jnz corner
add si,320*3
loop corner1

mov si,2*62 ;61 rectangles - in theory
draw:
shrd ax,si,22 ;create value for change
inc ax
add byte[bp+si],al    ;change color
mov bx,word[bp+126+si];get pos

;triangle me beautiful
mov cl,16 ;ch = 0
line1:
mov di,cx
line2:
mov dx,di
sub dl,byte[bp+si]
shl dl,2
mov byte[ds:bx+di+1-320*16],dl
dec di
jnz line2
add bx,320
loop line1

;movementementica
mov ax,si               ;align speed at number of box
add al,bh               ;and pos
shr ax,6                ;to make it parallax
inc ax                  ;and never 0
imul ax,ax,321
sbb word[bp+126+si],ax ;get+erase carry flag
;cmp word [pos+si],64000
jnc okay ;jb okay
;create a new box within a defined area
in al,40h               ;random for new pos
;mul si
shr al,1 ;0..127
;xor ah,ah
;add ax,64000-320*2+32*1
mov ah,0e5h             ;niftey
mov word[bp+126+si],ax ;set new starting pos
okay:

;make stripes of different size + color
movzx bx,byte[bp+si]
mov di,si
shr di,3
inc di
mov ax,di
imul dx,di,180*3 ;pos of layers
imul di,di,319*3 ;length
sub bx,dx        ;center things
mov dx,bx        ;save pos
okay2:
mov bx,dx ;restore pos
mov cx,ax ;width
okay3:
mov word[ds:bx+di+320*131],bx
inc bx ;move left
loop okay3
sub di,319 ;move up
jnz okay2

dec si
dec si
jnz draw ;worked with all sets?

;slow down
mov dx, 3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;si = 0
;ch = 0
;triangle
mov cl,80
cornr1:
mov bx,cx
;si=0
cornr:
mov byte[ds:si+bx-257],ch
dec bx
jnz cornr
sub si,320
loop cornr1

mov di,320*34
flip:
mov ax,di
sub ah,byte[bp+2]   ;change bg color
mov al,ah
xchg ax,word[ds:di] ;grab vscreen
stosw              ;drop + inc di
cmp di,320*164
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on
breaker:                       ;for testing
         mov ax,03h            ;keep it clean :)
         int 10h
         ret