;mr. nicebot // come to revision
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: ICO OST - heal

;well, hacked together 2 ideas and made mr. nicebot out of it
;for your invitro needs :D
;mr. nicebot also blinks!

org 100h
use16

level equ 320*18-10 ;for adjustment of the whole bot

start:   push 0a000h ;vga
         pop es
         mov al,13h
         int 10h

         mov ah,09h      ;print string
         mov dx,text     ;ds needs to be unchanged
         int 21h         ;so change afterwards

         push 09000h ;vscreen
         pop ds


main:

;background
mov bx,160 ;height

set1:
mov cx,319 ;width is good enough
set2:

mov ax,cx ;width
xor dx,dx
div bx ;height
add ax,bp ;global for change of color
add ax,bx ;height

xor ax,dx
sub ax,bx

shr al,3  ;well, make some decent colors
add al,69 ;because standard palette only

imul di,bx,320
add di,cx
add di,320*18 ;center
mov byte[ds:di],al

loop set2
dec bx
jnz set1

inc bp ;global var for color change

;top
xor di,di
mov ax,193+7
corner2:
mov bx,ax
corner:
mov byte[ds:bx+di+320*27+79+level],bh
dec bx
jnz corner
dec ax
dec ax
add di,321
cmp di,321*15
jne corner2

xor dx,dx ;pos of the maul

;right
xor di,di
side2:
mov cx,90
mov bx,di
side:
mov word[ds:bx+320*116+167+level],dx ;0
shld si,bx,17
mov byte[ds:si+320*176+199],ch ;some extra element
sub bx,319
loop side
add di,321
cmp di,321*12
jne side2

xor di,di
mov ax,122
head2:
mov bx,ax
head:
mov cl,16
cmp dl,20 ;pos of mouth
jne nomouth
dec cl
nomouth:
mov byte[ds:bx+di+320*50+100+level],cl
dec bx
jnz head
dec ax
dec ax
add di,321
inc dx
cmp di,321*60
jne head2

mov si,320*58
in al,40h
cmp al,4
jbe blink
dec byte[ds:si+130+level]
dec byte[ds:si+193+level]
blink:


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

;flip
;di = cx = bx = 0 here
mov di,320*20
flip:
xor ax,ax
xchg ax,word[ds:di] ;grab vscreen
stosw              ;drop + inc di
cmp di,320*178
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

text db 'Come_to_REVISION_2o16!_Nicebot_',3,'_you!_:D$'
nop ;256