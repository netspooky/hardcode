;streams of gaia // the universe within
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: sólstafir - fjara

;Is it in space? Or is is under water? Who knows,
;who knows ...

;First release in 2o15 :)  I had the basic effect
;and  did not know  what to do with it so I added
;some elements just  for design.  And yes  FF VII
;was in my mind while searching a fitting  title.


org 100h
use16

start:   push 0a000h  ;vga
         pop es
         push 09000h  ;vscreen
         pop fs
         mov al,13h
         int 10h

        mov dx,0x3C9
        inc cx         ;ch = 1 cl = 0
pal:    xor al,al
        out dx,al ;r
        shrd ax,cx,18
        out dx,al ;g
        out dx,al ;b
        inc cl
        jnz pal

;make fixed sets of data
;xp = dosbox
mov bx,60000 ;15000 x 2 x 2
makedata:
inc ax
mul bx
mov word[pos+bx],ax
dec bx
jnz makedata

main:
mov di,5000 ;this is a nice number

draw:
mov ax,word[speed+di] ;get speed
shr ax,14
inc ax                ;never 0
sub word[pos+di],ax   ;move
fine:
mov word[bp],556      ;amplitude

cmp di,2                 ;last set for global movement
jne okay5                ;has a different amplitude
shr word[bp],1
okay5:

fninit                   ;safety
fild word [pos+di]       ;pos = angle
fidiv word [bp]          ;no 57 this time
fsincos
fimul word [bp]          ;sin*amplitude
fistp word [bp+2]        ;x
fimul word [bp]          ;sin*amplitude
fistp word [bp+4]        ;y

cmp di,2                 ;save values of last set
jne okay2                ;for global movement
imul dx,word[bp+4],320
add dx,word[bp+2]
mov word[bp+6],dx        ;save it

okay2:
imul si,word[bp+4],320   ;y
add si,word[bp+2]        ;x
add si,word[bp+6]        ;add movement

okay:
mov cx,ax                ;use speed (from above) for size
shl cx,1                 ;pump it up
loop2:
inc si                   ;move right
imul dx,ax,320
loop1:
mov bx,si
add bx,dx
add byte[fs:bx],13       ;original
shr bx,1                 ;shrink
neg bx                   ;invert
add byte[fs:bx],6        ;1/2 screen
add byte[fs:bx+320*103-191],6 ;1/2 screen
sub dx,320               ;move up
jnz loop1
loop loop2

dec di
dec di
jnz draw ;all sets done?

;some elements of design

;ah = 0 here
mov al,40
bars:
mov si,320
bars2:
imul bx,ax,320
add byte[fs:si+bx-1+320*140],al
neg si
neg bx
add byte[fs:si+bx+320*60],al
neg si
dec si
jnz bars2
dec ax  ;)
dec ax
jnz bars

;mov bx,90
;corner:
;mov cx,bx
;corner1:
;imul si,cx,320
;shr byte[fs:si+bx+320*19+229],1
;loop corner1
;dec bx
;jnz corner

;ch = 0 here
mov cl,64
line1:
mov bx,cx
xor si,si
line:
shr byte[fs:si+bx+19],2
add si,319
cmp si,64000
jnae line
loop line1


;create same game speed everywhere using vsync
mov dx, 3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;flip
;di = 0 here
mov di,320*20
flip:
xor ax,ax
xchg ax,word[fs:di] ;grab vscreen
stosw
cmp di,320*180;inc di
jne flip;jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

pos dw 15000 dup ?
speed dw 15000 dup ?