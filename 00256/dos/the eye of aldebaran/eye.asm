;the eye of aldebaran // the black knight orb
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: thomas körner - daikan

;#################################################################################
;In 2o48 The Black Knight Satellite suddenly disappeared.
;Only a few hours later an unknown object was discovered
;- in the orbit of the moon

;name:                 - black knight orb
;size:                 - diameter changes of unknown reason
;                      - minimum of 350 centimetres
;                      - maximum of 730 centimetres
;weight:               - incalculable
;rotation:             - about 20/min
;chemical structure:   - indefinable due constant changes
;other specifications: - emitting temperatures between -261.75 degrees
;                        and +197.51 degrees
;                      - emitting all kinds of rays known to this date
;                        in small (non lethal) amounts
;                      - emitted rays contain no detectable pattern
;                      - disappears when an object is near than 1380.784 metres
;                        and appears on different spot in the orbit of the moon
;                      - no detectable pattern/system in (di)sappear behaviour

;Up to this day no one knows where The Black Knight Orb come from. Also the
;reason of its existence remains unknown. Several conspirary theories state that
;its origin lies somewhere on the "dark side" of aldebaran and it is here to
;announce the upcoming arrival of a higher nameless existence. They call the orb
;"The Eye Of Aldebaran".

;It's the 3rd May of 21o7. I woke up and there is a strange feeling to this day.
;#################################################################################

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen
         pop fs
         mov al,13h
         int 10h

;vars:
;bx, cx, si: calculation of orb

;unfortunately it is very slow at dosbox

main:
mov byte[ring],5 ;above 3 creates gap around ring

xor ax,ax ;safety first since al = ?
;mov di,320*101
;fill:
;mov byte[fs:di],al ;al = 0 after first run
;cmp di,320*86-1
;jne black
;mov al,102
;black:
;inc di
;cmp di,320*101
;jne fill

xor di,di ;safety first!
          ;di = 0 after 1st frame but display junk may appear
          ;so fuck those b
fill:
mov byte[fs:di+320*101],al ;al = 0 after first run
cmp di,320*190-65
jne black
mov al,103
black:
inc di
jnz fill

loop2:                   ;calculation of the amplitude(s)
mov ax,bx                ;to create the behaviour of the orb
dec cx  ;orb calc
jz nope
xor dx,dx
div cx
nope:
or dx,si
mul dx
add al,bh                ;let the eye grow slowly
xor ah,ah
shr al,3
add al,22                ;size up!
cmp byte[ring],1         ;rings?
je noring                ;nope
mov al,byte[ring]        ;create outer ring + black inside
shl al,1                 ;size up
add al,55                ;size up
noring:
mov word[bp],ax          ;save amplitude

loop1:
fild word [grad]         ;pi
fidiv word [for_rad]     ;pi*grad
fsincos
fimul word [bp]          ;sin*amplitude
fistp word [bp+6]        ;x
fimul word [bp]          ;cos*amplitude
fmul dword[shrink]       ;since 320*200 is not square
fistp word [bp+2]        ;y

fild word [grad2]        ;pi
fidiv word [for_rad]     ;pi*grad
fsin
fimul word [bp+6]        ;sin*x
fistp word [bp+4]        ;new x

imul di,word[bp+2],320   ;create pos of pixel on the screen
add di,word[bp+4]

mov ax,word[grad2]       ;create surface pattern of orb
add ax,word[grad]
cmp word[bp],38          ;core of orb?
ja no_invert             ;nope
neg ax                   ;invert colors so core is different
no_invert:               ;done because bytes left
add ax,bx                ;make orb spin ;)
shr al,4                 ;only use shades of grey
add al,16                ;so no pal gen needed

cmp byte[ring],1         ;draw the orb inside the ring ?
je noring2               ;yes, draw orb
cmp byte[ring],3         ;3 = border of ring / 2 = empty inside of ring
sete al
imul ax,ax,102           ;color of border / black inside of ring
noring2:
mov byte[fs:di+320*93+220],al ;draw to vscreen

;this makes the single vertical slices of the orb from left to right
dec word [grad2]         ;only 90 - 270 for correct display
cmp word [grad2],90      ;since only these angles are in "front" of viewer
jne loop1                ;360-90 are on the "back" so it would create
mov word [grad2],270     ;errors on the colors and so on the shade of the orb

;this makes the single vertical slices of the orb from bottom to the top
dec word [grad]          ;      360 - 90
cmp word [grad],90       ;    middle of orb
jne loop2                ;      90 - 270
mov word [grad],270      ;       viewer

add bx,3 ;orb calc also defines speed of color rotation

dec byte[ring]           ;draw border of ring, clear inside of ring
jnz loop2                ;and draw orb into ring

inc si                   ;orb calc

;flip
xor di,di
flip:
mov ax,word[fs:di] ;grab vscreen
stosw;mov byte [es:di],al ;drop to screen
cmp di,0;inc di
jne flip;jnz flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on
         mov ax,03h            ;keep it clean :)
         int 10h
         ret
         nop ;256

for_rad dw 57  ;pi*grad/180 = grad/57 (180/3.14... = 57,...)
grad dw 270
grad2 dw 270
shrink dd 0.80
ring db ?