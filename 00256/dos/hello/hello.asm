;hello <3 // look who's in the grass
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: emi meyer - blue room


;          xxx                                       xxx
;         xxxxx                                     xxxxx
;        xxx xxx                                   xxx xxx
;       xxx   xxx                                 xxx   xxx
;      xxx     xxx                               xxx     xxx
;     xxx       xxx                             xxx       xxx
;    xxx         xxx                           xxx         xxx
;   xxx           xxx                         xxx           xxx










;                     XXXXXXXXXXXXXXXXXXXXXXX

;No animation but also no graphic without motion. But I consider this
;as procedural gfx since it is :D

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;here goes the original data
         pop fs
         push 08000h ;here is the drawn copy of original data
         pop gs
         mov al,13h
         int 10h

;screens are cleared at first flip of screen to vga
main:

;draw the datasets (simple filled rectangles
xor si,si ;for accessing data
xor di,di ;for accessing data
draw:
xor bx,bx ;for outer loop
looping2:
mov cl,byte[sizex+di] ;xor cx,cx ;for inner loop
looping1:
imul bp,bx,320        ;make y
add bp,cx             ;add x
add bp,word[posxy+si] ;add origin
mov al,byte[color+di] ;color
mov byte[fs:bp],al    ;set

;inc cx
;cmp cl,byte[sizex+di]
;jna looping1
loop looping1 ;instead of code above + xor cx,cx above this does not draw pos x0,y0
              ;but thats a small price for 3b

inc bx                ;2x in so the areas are not filled completely
inc bx
cmp bl,byte[sizey+di] ;done whole thingie?
jna looping2

inc di ;next data (byte)

inc si ;next data (word)
inc si
cmp si,28
jne draw              ;repeat until all sets are used


;mirror saves about 45% of data @ datasets
;cx = 0 here
mov cl,150 ;whole height
mirror2:
mov bx,130 ;x value of area to be mirrored
xor bp,bp
mirror1:
imul di,cx,320
mov al,byte[fs:di+bx+50+50*320]     ;get left side
mov byte[fs:di+bp+50+134+50*320],al ;set rigt side
inc bp                       ;move pos of mirrored half
dec bx                       ;move pos of half to be mirrored
jnz mirror1
loop mirror2


;### childish engine ;) ###

;create corners of the paper + transform everything into childish style
;cx = 0 here
mov bx,319 ;bottom + top
border1:
mov byte[fs:bx],cl       ;corner
dec bx
cmp bx,64000-320
jne border1

border2: ;left + right
mov word[fs:bx-1],cx ;-1 because word
sub bx,320
jnz border2

;do the crayon strokes
;bx = 0 here
crayon:
cmp byte[fs:bx],80 ;no action with background color
je skip

in al,40h ;make pseudo random lenght of strokes
mul bx    ;bla
sbb dx,ax ;bla
shr dx,13 ;allow 0 to give other colors a chance
jz skip   ;so if 0 skip drawing

imul di,dx,319 ;length of stroke

mov si,bx ;base where black is
sub si,di ;sub lenght to make start point
add di,bx ;make end point

line:
mov al,byte[fs:bx] ;get color
mov byte[gs:si],al ;draw to vscreen
add si,319         ;move
cmp si,di          ;reached maximum length?
jne line           ;nope so go on

skip:
dec bx
jnz crayon         ;do it with whole screen

;no black bars this time \:D/
;bx = 0 here
flip:
mov al,80           ;background color
mov byte[fs:bx],al  ;clean original data screen
xchg al,byte[gs:bx] ;grab and clear drawn data screen
mov byte[es:bx],al  ;drop to vga
inc bx
jnz flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

;datasets; each set takes 5b

sizex db 100 ;head
db 20        ;left eye
db 24        ;nose
db 4         ;left iris
db 8        ;mouth
db 16        ;left ear part 1
db 30        ;left ear part 2
db 70        ;left beard bottom
db 60        ;left beard middle
db 60        ;left beard top
db 200        ;grass 1
db 200        ;grass 2
db 30        ;sun
db 180        ;cloud

sizey db 80  ;head
db 16        ;left eye
db 3         ;nose
db 4         ;left iris
db 1         ;mouth
db 80        ;left ear part 1
db 42        ;left ear part 2
db 3         ;left beard bottom
db 1         ;left beard middle
db 2         ;left beard top
db 1         ;grass 1
db 1         ;grass 2
db 25         ;sun
db 8         ;cloud

posxy dw 320*110+90  ;head
dw 320*130+118        ;left eye
dw 320*150+168        ;nose
dw 320*135+130        ;left iris
dw 320*182+174        ;mouth
dw 320*46+120         ;left ear part 1
dw 320*50+114         ;left ear part 2
dw 320*174+34         ;left beard bottom
dw 320*160+40         ;left beard middle
dw 320*148+46         ;left beard top
dw 320*195+5          ;grass 1
dw 320*194+5          ;grass 2
dw 320*18+50          ;sun
dw 320*25+20          ;cloud

color db 7   ;head
db 15        ;left eye
db 0         ;nose
db 0         ;left iris
db 0         ;mouth
db 7         ;left ear part 1
db 7         ;left ear part 2
db 20        ;left beard bottom
db 20        ;left beard middle
db 20        ;left beard top
db 2         ;grass 1
db 10        ;grass 2
db 14        ;sun
db 15        ;cloud