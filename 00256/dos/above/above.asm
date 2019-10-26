;above [a new sun]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: break my fucking sky - sunrise

;no story prod this time. only happy colors :)

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen
         pop fs
         push 08000h ;buffer screen for clouds
         pop gs
         mov al,13h
         int 10h

;assuming:
;cx = 255

fninit ;safety what the heck got the 2b

;clean screen where clouds gonna be saved
;xor si,si
cls:
mov byte[gs:si],ch;0
inc si
jnz cls

;storing clouds on buffer screen to increase speed
;si = 0 here
loop2:
xor dx,dx              ;size of circle
loop1:
mov word[bp],dx        ;load size of circle

fild word[grad]        ;load degrees

fsincos                ;cos sin

fimul word[bp]         ;cos*x/y sin
fistp word[bp+6]       ;new x + pop

fimul word[bp]         ;sin*x/y
fmul dword[shrink]     ;looks better
fistp word[bp+8]       ;new y + pop (fpu stack is clean)

;set 2d pixel
imul di,word[bp+8],320
add di,word[bp+6]      ;y*320+x = pos pixel
add di,word[pos+si]    ;add pos of circle/part of cloud
mov byte[gs:di],cl     ;saving clouds ;cl = 255

inc word[grad]
cmp word[grad],360
jnae loop1
mov word[grad],si;0 works well without visual errors
                  ;could also use bx by assuming 0

inc dx
cmp dx,34         ;fixed size, variations eat bytes and visuals don't benefit at all
jne loop1

inc si
inc si
cmp si,16 ;all sets of data done? a.k.a. cloud complete
jne loop2


main:

;draw layers of clouds including parallax scrolling
xor bx,bx ;number of layers
loop3:

xor di,di ;for grabbing buffer screen with clouds
dupe:
cmp byte[gs:di],cl;255;color of clouds on buffer screen
jne nope              ;no cloud so skip everything

imul si,bx,320*6    ;create vertical position of layers
mov ax,bx
shr ax,1            ;create color for each layer
;shrd ax,bx,17        ;same size

add al,58;83        ;smooth
add si,di           ;add the correct position of original cloud
add si,word[bse+bx] ;add base for different position each layer

mov byte[fs:si],al  ;set copied cloud to layer in created color

nope:
inc di
jnz dupe            ;check whole screen to grab from

mov ax,bx           ;get layer number
shr ax,1            ;create parallax scrolling
                    ;so initial values of bse+bx have no meaning
inc ax              ;if 0 allowed layer in background doesn't move
add word[bse+bx],ax ;add to base
cmp word[bse+bx],319;no movement up!
jna okay
;sub word[bse+bx],320;stay on height no movement up!
mov word[bse+bx],di ;works well since parallax does not care and di = 0 and -2b
                    ;this whole bse thing creates "jumping" of clouds ... but ... well ...
okay:
inc bx
inc bx
cmp bx,20;16  adding more layers on the fly
jne loop3    ;all layers done?

;add some rays
;yes from below. fuck realism
;di = 0 here
rays:
mov bp,di ;size of rays
inc bp ;0 would cause error
inc bp ;1 would make ray on layer in the background too thin
fett:
mov si,word[bse+di] ;base of ray on layers

line:
mov ax,di
shr ax,1             ;create color for each layer
add al,58            ;to check if ray reached border of cloud or not
cmp byte[fs:bp+si],al;only draw outside of cloud color
ja noray

mov byte[fs:bp+si],90 ;draw the beautiful ray!

noray:
add si,319      ;move drawing position up!
cmp si,64000    ;check if we reached the not visible area between 64000 and 0ffffh
jna line        ;make ray

dec bp          ;make fat ray
jnz fett

inc di
inc di
cmp di,20;16    ;adding more layers on the fly
jne rays        ;rays on all layers done?


;create same everywhere using vsync
;since optimizing for speed made it too fast
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
mov di,320*30       ;bar area above
flip:
mov al,57           ;background color
xchg al,byte[fs:di] ;grab vscreen
stosb               ;drop it including inc di
cmp di,320*169      ;bar area below
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

shrink dd 0.84 ;make circle not egg

;mem   0       2          4          6           8           10          12          14          |for extra layers
pos dw 320*89, 320*68+50, 320*81+92, 320*78+130, 320*88+170, 320*95+205, 320*80+240, 320*75+286
bse dw ?,              ?,         ?,          ?,          ?,          ?,          ?,          ?,   ?,  ?,  ?
;                                                                                                 16  18  20
grad dw ?     ;in worst case 1st frame fucked up