;barbarian (older version)
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:


barcolors equ 504fh ;colors of the 2 main bars

org 100h
use16

;assuming: bx = 0 cx = 255 ax = 0


org 100h
use16

;assuming: bx = 0 cx = 255 ax = 0

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

;xor bx,bx
string:
mov al,byte[es:bx] ;get
mov byte[fs:bx],al ;set + adjust for no jumping while scrolling
inc bx
jnz string

main:

inc bp ;starter of the stripes
cmp bp,319
jna ok
mov bp,cx ;0 after 1st run

ok:

;create moving stripes
mov cl,5 ;number of stripes
mov si,bp
mov dx,barcolors ;4f=79
laser:
mov bx,32+6;+8;+12
laser1:
mov byte[ds:si+bx],dl

imul di,si,-1
add di,bx

mov ax,dx
sub al,61
cmp byte[ds:di],al;50
ja neinnein

mov ax,bp
;shr ax,1
imul ax,ax,319*2
cmp dh,79
je change
imul ax,ax,-2
change:
add ax,di
mul cl
and ax,bx
shr ax,2
add al,17

mov byte[ds:di],al;al
neinnein:


dec bx
jnz laser1
add si,321
jnc laser ;over 0ffffh?
xchg dl,dh ;new color on next stripe
loop laser




;bar
mov di,bp
shr di,1
imul di,di,320
dec di ;adjust
mov bx,320*11
bar:
cmp byte[ds:di+bx],79
je nonono
mov byte[ds:di+bx],102
nonono:
dec bx
jnz bar


mov bx,di
;create a window + insert scrolling text
mov dx,319*11
scrollie2:
mov di,90
scrollie:
mov si,dx
add si,di
mov al,byte[fs:bp+si-320*4+200]
cmp al,cl
jne noo
;cmp byte[ds:bx+si+195],79
;je noo
sub byte[ds:bx+si+197-320],103-66;dh; dh = rainbow
noo:
dec di
jnz scrollie
sub dx,319
jnz scrollie2



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

;tranditional bars
mov bx,320*40-1
liney:
mov byte[ds:bx],cl ;0
dec bx
cmp bx,320*158-1
jne liney



xor di,di
xor si,si
mov dx, 3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2



;flip
;cx = 0 here
;di = 0 here
;flip:
;mov ax,1211h
;xchg ax,word[ds:di] ;grab vscreen
;stosw              ;drop + inc di
;cmp di,cx
;jne flip

;same size as above but less intructions
flip:
movsw
mov word[ds:di-2],1211h ;grab vscreen
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
;text db 'GREETS FLY TO ALL SIZECODERS$'
;text db 'GREETS FLY TO THE 256B POSSE$'
 text db 'GREETS TO THE 256B SQUAD$'