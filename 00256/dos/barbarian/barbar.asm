;barbarian // the mechanics beyond
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: dub killer - kate

;after scrollingham palace, r:7e1 and mantra i wanted to have a scrolling
;text inside a little window. since the whole routine eats up a lot of bytes
;plus 26 for the string itself i thought why not sticking to bars since the
;text is inside one. so here it is :D

;assuming: bx = 0 cx = 255 ax = 0 bp = ?
;global vars: bp for movement(s)

;barcolors equ 504fh ;colors of the 2 main bars
barcolors equ 4f41h ;colors of the 2 main bars

org 100h
use16

start:   push 0a000h     ;vga
         pop es
         mov al,13h
         int 10h

         mov ah,09h      ;print string to vga
         mov dx,text     ;ds needs to be unchanged
         int 21h         ;so change afterwards

         push 08000h     ;vscreen
         pop ds
         push 07000h     ;michael "the text" buffer
         pop fs

;no erasing and using the text on the fly. this would save 3 bytes but brings a visual
;error on the bottom of the glass bar. so skip that and drop the data into the buffer
string:
mov al,byte[es:bx] ;get
mov byte[fs:bx],al ;set
inc bx
jnz string

main:

inc bp     ;starter of the stripes
cmp bp,319
jna ok
mov bp,cx  ;0 after 1st run

ok:

;create moving stripes
mov cl,5               ;number of stripes
mov si,bp
mov dx,barcolors ;4f=79
laser:
mov bx,32+6;+8;+12 ;thickness
laser1:
mov byte[ds:si+bx],dl ;draw

imul di,si,-1         ;create background mechanics
add di,bx

mov ax,dx
sub al,40
cmp byte[ds:di],al    ;draw in background only!
ja neinnein

imul ax,bp,319        ;create ze pattern
cmp dh,79
je change
imul ax,ax,-2
change:
add ax,di
mul cl
and ax,bx
shr ax,2

add byte[ds:di],al    ;draw into background on existing pattern
neinnein:

dec bx
jnz laser1
add si,321
jnc laser             ;over 0ffffh?
xchg dl,dh            ;new color on next stripe
loop laser            ;do all stipes


;draw a moving black bar
mov di,bp ;get movement (0..319
shr di,1  ;/2 since screen is only 200 high
          ;and 160 fits about between the 2 black bars
imul di,di,320
dec di    ;adjust
mov bx,320*13
bar:
cmp byte[ds:di+bx],79 ;hide?
je nonono             ;yes
mov byte[ds:di+bx],cl;0
nonono:
dec bx
jnz bar

;create a window + insert scrolling text on the black bar
mov bx,di
mov dx,319*11 ;height of the window
scrollie2:
mov di,90     ;length of the window
scrollie:
mov si,dx
add si,di
mov al,byte[fs:bp+si-320*4+200] ;check for pixels of the text
                                ;theres +320 at freedos
                                ;let's take this as an OS feature ;)
mov ah,54  ;color 1
cmp al,cl ;cl = 0
je noo2
mov ah,16 ;) color 2
noo2:
cmp byte[ds:bx+si+45],79 ;also hide like the bar?
je noo
mov byte[ds:bx+si+45],ah;54;67;67;55 ;draw
noo:
dec di
jnz scrollie
sub dx,319
jnz scrollie2

;draw a glass bar that moves
imul bx,bp,2 ;=neg
glass:
mov di,70;160;70 ;thickness
glass2:
mov al,byte[ds:bx+di+320*2-5]
dec ax
mov byte[ds:bx+di],al
dec di
jnz glass2
add bx,320
jnc glass

;tranditional pal bars
mov bx,320*40-1
liney:
mov byte[ds:bx],cl ;0
dec bx
cmp bx,320*158-1
jne liney

mov dx, 3dah     ;wait for vsync for constant speed
;vsync1:         ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2


;cx = 0 here
;di = 0 here
;si = 320 here
flip:
movsw ;ds:si ---> es:di incl add di,2
mov word[ds:di-2],1112h ;set background pattern
cmp di,cx
jne flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main               ;nothing so go on
breaker:
;         mov ax,03h            ;keep it clean :)
;         int 10h
         ret                  ;use the ret at rotate

;         0        1         2         3         4         5
;         12345678901234567890123456789012345678901234567890
text db 'GREETS TO ALL SIZECODERS//$'
;text db 'GREETS TO THE 256B SQUAD//$'