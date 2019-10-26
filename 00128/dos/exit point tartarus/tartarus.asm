;exit point tartarus // the final base jump
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: council of nine - chimes of the unfortunate

;the protagonist makes his final base jump from the highest skyscraper
;in existence - the one build in tartarus.

org 100h
use16

;assuming bx = 0 ch = 0
start:   push 0B800h ;screen
         pop es
         push 09000  ;vscreen to avoid flickering
         pop ds

         mov ax,1112h  ; Set up 80x50 text mode
         int 10h

         ;mov ax,1003h  ;disable blink (128) ---> full 16 bg colors (=
         ;int 10h

main:

;make building
;draw out of screen
;otherwise last row would be empty
mov di,58
line:
in al,40h
mul di
cmp ah,65  ;window?
seta cl
;add cl,254 ;make window (254) or not (255)
dec cx
dec cx
mov ch,14  ;color
mov word[ds:di+160*50+22],cx
dec di
dec di
jnz line

mov word[ds:di+160*50+74],0eb3h ;179 = b3h corner of building
                                ;to give it some shape

cmp al,30  ;make cloud?
ja nocloud ;nope

mov bl,al    ;bx = size of clouds
inc bx       ;0 = display error
shl bx,1     ;size up and make even for correct displaying
mov si,bx    ;si = pos of clouds

mul ax                  ;al and ah are random from above
;shr al,6                ; / 64
;movzx di,al             ;pos in memory
shrd di,ax,16+14
mov ch,9                ;make color color
add ch,cl               ;cl =254 or 255 so color is 7 or 8
mov cl,byte[cs:clds+di] ;get char

clouds:
mov word[ds:si+bx+160*50],cx   ;draw cloud on line of skyscraper
dec bx
dec bx
jnz clouds

nocloud:

skyscraper: ;use lines (skycraper + cloud) drawn above to make movement
mov cx,0dbh ;219 + color
xchg cx,word[ds:bx+160] ;get + erase (erase needed for clouds)
mov word[ds:bx],cx      ;set
inc bx
inc bx
cmp bx,160*50
jne skyscraper

;slow it down!
mov dx,3dah
;vsync1:
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;flipflip!
;slows down as fuck when done in skyscraper loop
flip:
mov al,byte[ds:bx]
mov byte[es:bx],al
dec bx
jnz flip ;no one will see the not copied pos at 0:0

;base jump0r
inc dx
mov word[es:160*47+84],dx ;3dbh

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on
         ret

clds db 176,177,178,219        ;shades of gr ... clouds