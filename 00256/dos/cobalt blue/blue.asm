;cobalt blue // blueprinted skies
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: sabled sun - signals v

;This is really heavy code recycling but it is not the
;1st time I did that. And who cares when the result looks
;very different from the original. Some things have to be
;done - it's that simple :D

;The code used and changed comes from my prod "breed"
;because I liked to explore the possibilities of those
;shapes a bit further :)

;Decisions on the design were hard this time and again I
;spend a few hours on that. The prod uses vsync to slow
;things down. The shapes change while the intro goes on.
;Bigger/more complex objects will cause heavy slowdowns
;which makes you check out the blueprints more carefully ;)
;The slowdowns are not that big on faster XP machines, freedos
;and dynamic/max settings under DosBox though.

;########

;assuming: cx = 255 si = 0100h bx = 0

;variables used:
;bp+0          for movement of design elements on the left
;bp+2 .. 12    for changing of colors
;bp+40 ... 52  positions
;bp+80 ... 92  loops/steps for drawing of objects
;bp+120        for changing of bp+2 ..12 (1 or -1)

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen
         pop ds
         mov al,13h
         int 10h

        mov dx,0x3C9
        inc cx        ;cl = 0 / ch = 1
pal:    shrd ax,cx,18
        out dx,al ;r
        out dx,al ;g
        xor al,al
        cmp cl,al ;0  ;don't change 0 (black)
        je noooo      ;this works on my xp machine, freedos
        mov al,63     ;and dosbox. does not work on
        noooo:        ;my old xp laptop. dunno why
        out dx,al ;b
        mov si,cx              ;create some data
        inc ax
        mul cl                 ;but don't fuck up by changing dx
        adc word[bp+si],ax     ;fills up enough data
        mov byte[bp+si+120],1  ;safety
        loop pal

main:
mov si,12           ;above 12 makes uglies
                    ;based on the way the shapes are created
                    ; but 6 thingies are enough

loop1:
;mov dx,si
;shr dx,2            ;0..3
shrd dx,si,18
inc dx
imul ax,dx,320        ;moving sideways destroys visibility
add word[bp+40+si],ax ;move

mov ch,byte[bp+si+120] ;1 or -1
add byte[bp+si],ch     ;change color
jnz okay               ;color 0?
neg ch                 ;make 1 to -1 or -1 to 1
mov byte[bp+si+120],ch ;save it (same size as neg)
add byte[bp+si],ch     ;make color < > 0

cmp ch,-1              ;only change values when faded out
je okay

in al,40h             ;keep a bit of randomness
adc word[bp+40+si],ax ;change pos
sbb word[bp+80+si],ax ;change loops/steps

okay:
mov cl,byte[bp+80+si+1];loops
                       ;consider slow downs as part of the art ;)
draw:
mov ch,byte[bp+80+si]  ;steps
                       ;using e.g. 255 makes only objects up to
                       ;their full color ---> no foggy ones in the
                       ;distance
oki:
mov di,word[bp+40+si]  ;start/center of blueprint
loop0:
add ax,si              ;change for creating look
sub dx,si              ;bound to the # of the object
mul dh                 ;this makes the difference
                       ;between uglies and blueprints
add bl,al              ;bh = 0 here; always!
shr bl,6               ;0..3
shl bl,1               ;double because of word
add di,word[cs:way+bx] ;get way of movement

cmp ch,byte[bp+si]     ;only draw to maximum color
jae nope               ;but work with full steps
cmp byte[ds:di],ch     ;give it shading
jae nope               ;and correct behaviour
mov byte[ds:di],ch     ;draw

nope:
dec ch
jnz loop0           ;all steps done?
loop draw           ;next loop
dec si
dec si
jnz loop1           ;work with all blueprints


;### many bytes left so design time ###
;si = 0
;cx = 0
;bx = 0..6 / you will not notice those little differences each frame
mov ax,320 ;saving some bytes below
mov cl,201;164      ;size of triangle for design
triangle1:
sub bx,cx
triangle:
movzx dx,byte[ds:si+bx+64] ;plus making dh = 0
add dx,cx
add dx,bx
cmp dh,ch  ;ch = 0
je fine    ;not over 255
mov dl,255
fine:
mov byte[ds:si+bx+64],dl
inc bx
jnz triangle
sub si,ax       ;320
loop triangle1
;cmp si,-320*201 ;test
;je breaker

;si = 1216 (-320*201)
;cx = 0
;bx = 0
mov ch,0ah ;320*8 = 0a00h so save 2 bytes below
;this is for the pos/movement of the side bar elements
add word[bp],ax ;320
cmp word[bp],cx ;320*8 reset every 8 frames
jnae hohoho
mov word[bp],bx ;0
hohoho:

;moving design
;si = 1216 (-320*201)
;bx = 0
sub bx,word[bp]
upupup:
mov di,321*6
next:
mov byte[ds:bx+di+20+60],bh
sub di,321
jnz next
sub bx,cx                   ;-320*8
cmp bx,cx
jnbe upupup                 ;ends somewhere between 0 and 320*8

;vertical lines
;di = 0
lines:
mov word[ds:bx+14+64],di ;left fat
mov byte[ds:bx+25+64],cl ;right
mov byte[ds:bx+12+64],cl ;left
add bx,ax             ;320
jnz lines             ;will reach 0 because of above
                      ;sub bx(0),word[bp] with bp 320 ... 320*7

;slow it down
mov dx, 3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;flip to screen
mov di,320*11
flip:
mov ax,0a10h        ;background stripes
xchg ax,word[ds:di] ;grab vscreen
stosw               ;includes inc di
cmp di,320*188
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on
breaker:
         mov ax,03h            ;keep it clean :)
         int 10h
         ret

way dw 1,-1,320,-320