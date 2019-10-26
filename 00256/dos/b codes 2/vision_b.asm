;vision of the architect (alternative version)
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

org 100h
use16

;assuming: bx = 0 cx = 255 ax = 0

start:   push 0a000h     ;vga
         pop es
         mov al,13h
         int 10h

         push 08000h     ;buffer for city
         pop gs
         push 07000h     ;vscreen
         pop fs

        mov dx,0x3C9
        xor cx,cx ;no inc cx because of loop pal2

pal:    mov al,bl ;first half
        out dx,al ;r
        out dx,al ;g
        shrd ax,cx,17
        out dx,al ;b
        cmp cl,64
        jb allright
        inc bx
        allright:
        inc cx
        cmp cl,127
        jne pal

pal2:   shrd ax,cx,17 ;second half
        out dx,al ;r
        out dx,al ;g
        mov al,bl
        out dx,al ;b
        cmp cl,63
        ja allright2
        dec bx
        allright2:
        loop pal2

;bx = 0 here
set_map:
in al,40h
mul bx
shr al,3 ;prepare data for direct use to speed up things a little
inc ax   ;never 0
mov byte[gs:bx],al
inc bx
jnz set_map

main:

sub word[hlp],320 ;move city

;grab data from area and translate it to iso'ish visuals
;bx = always 0 here
;xor bx,bx ;y
iso4:
mov cl,30 ;x and leave a little gap for design
iso3:
imul si,bx,320   ;y on raster
add si,cx        ;x on raster
add si,word[hlp] ;move whole raster

movzx ax,byte[gs:si] ;grab data
imul ax,ax,320       ;and create height of tower
mov word[hlp2],ax    ;out of it

xor ax,ax ;start with height = 0

uphigh:
;mov bp,319*5 ;y of tower
mov bp,318*4 ;this gives you extra facade design for no extra bytes
             ;when also changing commented code below
iso2:
mov di,11    ;x of tower
iso1:

imul si,bx,319*5 ;right pos on raster
imul dx,cx,11    ;right pos on raster
add si,dx        ;pos of isometric object
add si,bp        ;add drawing dimensions
add si,di        ;add drawing dimensions
sub si,ax        ;add height

;mov dh,byte[hlp+1]
imul dx,word[hlp],2 ;color management
add dh,bl
sbb dh,cl
add dh,ah

cmp di,11    ;make nice sharp corners
jne skip
sub dh,bl
skip:

;cmp bp,319*5 ;make nice sharp corners
cmp bp,318*4  ;enable to add facade
jne skip2
add dh,cl
skip2:

mov byte[fs:si+320*35],dh

dec di
jnz iso1
;sub bp,319
sub bp,318 ;enable to add facade
jnz iso2

add ax,320
cmp ax,word[hlp2]
jne uphigh  ;full tower drawn?

loop iso3   ;next tower on raster x

inc bx
cmp bx,31;31 ;next tower on raster y
jna iso4

;cut the corners to make it looks like
;a sketch with paint
;di = cx = bp = 0 here
;bx = 32 so use it
corner:
mov cx,word[pal+bx+19] ;always the same data
shr cx,11
;inc cx ;never 0
add cx,9
add di,cx               ;add for movement while drawing 1 element
add di,cx               ;add for movement to next pos of next element
draw:
imul ax,cx,321*3        ;creates spikes
                        ;using ax saves 1b at sub ax,321
draw2:
mov bp,ax                ;combine for neg below
add bp,di
mov byte[fs:bp+112-320],ch ;top ;including adjust
neg bp
mov byte[fs:bp],ch    ;bottom ;including adjust

sub ax,321
jnz draw2
dec di
loop draw

dec bx
jnz corner               ;all spikes done?


mov dx,3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;xor di,di
mov cx,0ffffh/2
flip:
mov ax,word[fs:di] ;grab vscreen
stosw               ;drop it including inc di
loop flip

         in al,60h            ;read keyboard buffer
         dec ax               ;ah = 0 so save 1b
         jnz main             ;nothing so go on
breaker: ret                  ;use the ret at rotate

hlp dw ?
hlp2 dw ?