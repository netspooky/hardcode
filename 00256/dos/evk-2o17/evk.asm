;evk/2o17
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: aes dana - grasslands

;after making the 3rd place at the wild compo
;at revision 2o17 and still thinking about
;all the awesome releases i was quite motivated
;to get back to code. i thought about an invitro
;and played around with some ideas. in the end
;i decided to make a block of text instead of
;a single line which led to the overall design.
;again i spent a lot of time finding colors i
;am happy with - even if the total mount is not
;that high. the highlight idea was used in an
;(still) unreleased intro (might be part of
;another collection in the future). it took some
;time to optimize to gain the needed space but
;it worked out in the end.

;after the first 5 bytes 20 bytes of the code
;are used as variables with fixed initial values
;to avoid any setup code while having a nice
;start.

org 100h
use16

;assuming: bx = 0 cx = 255 ax = 0

start:   push 0a000h     ;vga
         pop es
         push 07000h     ;michael buffer string bikini
         pop fs
         mov al,13h      ;320*200*256
         int 10h         ;screen completely 0 after setting
                         ;the videomode

         mov bp,text1    ;offset of 1st line of text
         mov bl,4        ;3 lines in total
boxie:   mov ah,09h      ;print string to vga
         mov dx,bp       ;ds needs to be unchanged
         int 21h
         add bp,8        ;jump to next string
         mov cl,33       ;counter to get to the next line on screen
         mov dx,text3+7  ;fill with space from last string
         filler:
         int 21h         ;fill until next line
         loop filler

         dec bx          ;all 3 lines/strings drawn?
         jnz boxie

         push 08000h     ;set ds as vsceen
         pop ds

;copy string
get_string:
mov al,byte[es:bx] ;grab
mov byte[fs:bx],al ;drop
inc bx
jnz get_string

main:

;draw a bar
;mov bx,320*84;=6900h
mov bh,69h ;-1b
mov cx,26*320;28*320=2300h
bar:
mov byte[ds:bx],39;57
inc bx
;cmp bx,320*110
;jne bar
loop bar

;cut the bar
;cx = 0
mov ax,320*80+128+14 ;adjust pos of cuts
mov cl,14            ;number of cuts
stripes3:
mov bx,321*30        ;height of cuts
stripes1:
mov si,cx            ;thickness of cuts
stripes2:
mov di,si            ;copy thickness
add di,ax            ;add pos of cuts
mov byte[ds:di+bx],ch ;cut
dec si
jnz stripes2         ;cut whole thickness
sub bx,321
jnz stripes1         ;cut full height

sub ax,cx            ;change pos of cuts
sub ax,cx            ;based on the number of cuts
loop stripes3        ;for different sizes


;create moving stripes
mov di,20 ;draw 10 elements
all:
mov ax,di ;create speed
shr ax,3  ;makes 3 smooth planes (3/4/3 = all 10 elements)
inc ax    ;never 0
add ax,word[cs:start+di+5];by using code (+5 for nice start
                          ;and highlight shown between stripes)
cmp ax,320                ;there is always the same beginning
jnae allright             ;with a nice movement to bring things
sub ax,320                ;into place
allright:
mov word[cs:start+di+5],ax  ;save new pos

imul bx,di,319*4 ;height of element based on its number
lines1:
mov cx,di        ;different thickness for each element
inc cx           ;a.k.a. better than le sneaky nop
lines2:
imul dx,di,319*2 ;center things
mov si,cx        ;add thickness
sub si,dx        ;add center
add si,ax;word[cs:start+di] ;add pos

;mov bp,si       ;create background elements
;add bp,bx       ;by inverting the 10 in the foreground
;neg bp
imul bp,si,-1;save 1b
sub bp,bx
mov byte[ds:si+bx+320*96],45;43;9;42;56;43;66
cmp byte[ds:bp+320*96+320*2],ch ;only draw in background
jne nope
mov byte[ds:bp+320*96+320*2],55;32;9;55;9;42;1;42;92
nope:
loop lines2

sub bx,319
jnz lines1 ;draw full height

dec di
dec di
jnz all    ;all elements done?

;draw the string + shadow into foreground
;di = cx = bx = 0
do_string:
cmp byte[fs:bx],cl  ;pixel in buffer?
je no
mov byte[ds:bx+320*86+19+178],cl;16     ;draw shadow
mov byte[ds:bx+320*85+20+178],43;14 ;80 ;draw letter
no:
inc bx
;cmp bx,320*24 ;=1e00
;cmp bh,1eh
;jne do_string
jnz do_string ;flush whole buffer and save 3b

;draw a highlight on the string
;based on last element from above
highlight:
cmp byte[ds:si],43    ;only highlight the letters
jne okok
mov word[ds:si],0f0fh ;highlight'em
mov byte[ds:si-1],al  ;add a little extra
okok:
sub si,321
jnc highlight         ;simply draw down to end of screen/memory

mov dx,3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;flip
;cx = di = 0 here
flip:
xor ax,ax           ;clear background
xchg al,byte[ds:di] ;grab vscreen
stosb               ;drop it including inc di
loop flip           ;do whole screen

         in al,60h            ;read keyboard buffer
         dec ax               ;ESC?
         jnz main             ;nothing so go on
breaker: ret

;         0        1         2         3         4         5
;         12345678901234567890123456789012345678901234567890
text1 db '2oYears$'
text2 db 'Evk2o17$'
text3 db '>>>>GO! $' ;blank space is filler to create the text block