;more than just code
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:



;what is the fascination about tiny intros? that is a question i sometimes
;come across. on one hand i think about the possibility of a bigger project
;but on the other hand there is this undefined feeling attached to 256 bytes
;and less. this magic boundary. a small project within its restictions, clear
;rules and the will to make something nice and hopefully fresh since - which
;is not the easiest task since such prods aren't a new thing. i'm trying to
;create good looking (and sometimes strange) things because i think that
;tinytros are more than just code.

barcolors equ 504fh;4041h+0101h; 504fh ;colors of the 2 main bars
;80=50h
;64=40h
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
         push 07000h
         pop fs

;xor bx,bx
string2:
mov dl,83;71 ;start with this color (in theory, inc dl below, so starts with +1)
xor si,si
next:
mov cl,33 ;4 letters are 32 pixels wide (8x4) 33 because next at 0 so 1...33 = 32
inc dx    ;change color
string:
dec cx    ;work all 32 pixels
jz next   ;done so next color

cmp byte[es:bx+si],ch ;ch always 0
je nope               ;if no pixel found then don't copy
                      ;mem at A000h always 0 at start
mov byte[fs:bx+si+320*90+25],dl ;grab string and put it into Michael Buffer
                                    ;at final pos
nope:
inc si
cmp si,320
jne string
add bx,si ;320
jno string2

main:

inc bp ;starter of the stripes
cmp bp,320
jna ok
mov bp,cx ;0 after 1st run

ok:

;create moving stripes
mov cl,7 ;number of stripes
mov si,bp
mov dx,barcolors ;4f=79
laser:
mov bl,14+32+6;+8;+12 ;bx = 0 after 1st run
laser1:
mov byte[ds:si+bx],dl

dec bx
jnz laser1
add si,321
jnc laser ;over 0ffffh?
xchg dl,dh ;new color on next stripe
loop laser


;draw the string on top/behind
;si somewhere between 0 and 321
overlay:
mov bx,dx;dx comes from above;barcolors ;4f=79
mov al,byte[fs:si]
cmp al,cl;0
je nopey
test al,1 ;bit 0 even or odd?
          ;2b smaller than bt ax,0
jnz noxchg
xchg bl,bh
noxchg:
cmp byte[ds:si],bl ;hide
je nopey
mov byte[ds:si+321],cl ;shadow!
mov byte[ds:si],al ;letter
nopey:
inc si
jnz overlay

;stripes 80, text 64+ bg 16/17
;reflection on the text
;bx = 0 here
sbb bx,bp;imul bx,bp,-1
ray:
mov si,10
ray2:
cmp byte[ds:si+bx],81;82
jb nonono
mov byte[ds:si+bx],15;31
nonono:
dec si
jnz ray2
add bx,319
jnc ray

;si = 0 here
inc word[fs:si] ;trrrricky
cmp word[fs:si],18
jna nicenice
mov word[fs:si],si
nicenice:

imul si,word[fs:si],320
mov di,si
mov cl,10 ;number of repetition
bar3:
mov ch,19 ;thickness of bar
bar2:
mov bx,320*9 ;length of bar
bar:
mov byte[ds:si+bx-60+320*3+30],al
mov byte[ds:di+bx-15-320*22+30],al
sub bx,320
jnz bar
add si,319
sub di,321
dec ch
jnz bar2
add si,320*18-319*19
sub di,320*18-321*19
loop bar3

;bx=0
;tranditional bars
mov ch,51h; cx,320*65-64;=5100h
liney:
mov byte[ds:bx+320*30-1],al ;0
dec bx
loop liney


mov dx, 3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2


mov si,di

;flip
;cx = 0 here
;si = di here
dec cx
rep movsb ;ds:si --> es:di

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main               ;nothing so go on
breaker:
;         mov ax,03h            ;keep it clean :)
;         int 10h
         ret                  ;use the ret at rotate


;        0        1         2         3         4         5
;        12345678901234567890123456789012345678901234567890
text db 'tinytrosmorethanjustcode$'