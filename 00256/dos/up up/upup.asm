;up up
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: message to bears - breathe

;something with a nice pattern for evoke 2o16 :] wiff xor
;tested under xp, dosbox and freedos.

;uses vsync.

;assuming: cx = 255 ax = 0

org 100h
use16

start:   push 09000h
         pop fs
         push 0a000h
         pop es
         mov al,13h
         int 10h

        mov dx,0x3C9
        xor cx,cx ;no inc cx because of loop pal2

pal:    mov al,bl ;first half
        out dx,al ;r
        shrd ax,cx,17
        out dx,al ;g
        out dx,al ;b
        cmp cl,64
        jb allright
        inc bx
        allright:
        inc cx
        cmp cl,127
        jne pal

pal2:   mov al,bl
        out dx,al ;r
        out dx,al ;g
        shrd ax,cx,17 ;second half
        out dx,al ;b
        cmp cl,63
        ja allright2
        dec bx
        allright2:
        loop pal2

;create individual colors for each cell
;needed for dosbox
col:
inc ax;in al,40h;have it different every run ... but tbh: who gives a fuck?
mul bl
mov byte[colors+bx],al
inc bl
jnz col

main:

;add le designe to the background at the right side
;xor di,di ;di = always 320*167 after 1st frame here
;bh = 0 here
liner:
mov bl,95+16
liner2:
xor byte[fs:di+bx-96],bl ;yeah yeah xor :D
shl byte[fs:di+bx-96],2
dec bx
jnz liner2
sub di,320
jnc liner

;draw cells, always 3 in 1 block
;
; 1     1
;    2     2
; 3     3      ->
;    1     1
;       2     2
;    3     3
;
;       |
;      \/
xor cx,cx; ch = index of color for each cell
         ; cl = number of segment

cells4:
xor ax,ax ;for rows
cells3:
xor dx,dx ;for columns
cells2:
xor cl,cl ;for cells
cells:

;change color for each cell
movzx di,ch            ;get index of individual color
inc byte[colors+di]    ;change of each cell
mov bl,byte[colors+di] ;get color

line2:
mov di,319*10          ;draw a rectangle rotated by 45 degrees
line3:
mov bp,10*321          ;draw a rectangle rotated by 45 degrees
line4:
movzx si,cl            ;get index of positions of the 3 cells of the block
mov si,word[bases+si]  ;get the position
add si,di              ;add rectangle data

add si,dx              ;add a new block to the right
add si,ax              ;add a new block below
mov byte[hlp],10       ;helpa helpa to shift the rectangle
again:                 ;to create a cell
mov byte[fs:bp+si],bl  ;draw
inc bp                 ;shift
dec byte[hlp]          ;helpa?
jnz again              ;shiftet to complete shape?

;cmp word[hlp3],0ffffh/2
cmp byte[hlp3+1],7fh
jb nonono
dec bx                 ;trickery
nonono:
;sub bp,10
sub bp,331;321         ;restore bp + change rectangle pixel
jnz line4              ;work it

sub di,319             ;change rectangle pixel
jnz line3              ;work it

;inc ch                 ;change color index for the cell

;inc cx                 ;change index of cell (1,2,3 --> 0,2,4)
;inc cx
add cx,0102h
cmp cl,6               ;worked all 3 cells of 1 block?
jne cells              ;nope

add dx,40              ;add a new block to the column
cmp dh,01h;dx,40*7;280 ;added all blocks?
jb cells2              ;nope?

add ax,320*30+20       ;add a new row of blocks below
cmp ah,96h; ax,(320*30+20)*4   ;added all rows?
jb cells3              ;nope?

add word[hlp3],64      ;for changing of cells (shading)

add word[hlp2],dx;dx = 280 but you won't see a difference to 320 ;)

;bh = ? bl = ? cl = 6 ch = ? dx = 280
;make the glass bar which moves
;okay, little error on left upper corner but that's how it is
okok:
mov bh,28h;bx,320*40-64;320*32=2800h
mov di,word[hlp2]
glass:
mov al,byte[fs:bx+di-4]
add al,cl;decent glass
mov byte[fs:bx+di],al
dec bx
jnz glass

;make it smooth with vsync
mov dx, 3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;flip + create black bars
mov di,320*29
flip:
mov ax,di
add ah,byte[colors]
mov al,ah
xchg ax,word[fs:di]  ;drop to screen
stosw
cmp di,320*167
jne flip

         in al,60h ;read keyboard
         dec al    ;check it, dammit!
         jnz main               ;nothing so go on

;         mov ax,03h            ;keep it clean :)
;         int 10h
         ret

;starting points of the 3 cells in 1 block
; 1
;    2
; 3
;            3              2            1
bases dw 320*51+12+83, 320*41+32+83, 320*31+12+83
hlp3 db ? ;well save 1b and invest into glass bar
hlp4 db ? ;since hlp3 procedured as word with 1b it is
          ;(almost) 0 at beginning

colors db 300 dup ? ;colors of each cell
hlp db ? ;helpa helpa
hlp2 dw ?