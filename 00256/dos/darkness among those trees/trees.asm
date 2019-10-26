;darkness among those trees // where no hope dares to dwell
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: mortaur - it is happening again

org 100h
use16

start:   push 0a000h
         pop fs ;screen
         push 09000h
         pop es ;vscreen
         push 08000h
         pop gs ;texture
         mov al,13h
         int 10h

;global use
;bp   = x
;bp+2 = new x after fpu
;bx   = for rotation/movement
;dx   = degrees for sine

;assuming: di = 0 / cx = ? / dx <> 0

var:    mov dx,0x3C9
        xor cx,cx
pal:    mov ax,cx  ;moody original b/w palette
        shr al,3   ;grim, cold winter
        out dx,al  ;r
        out dx,al  ;g
;       out dx,al   ;b ;not needed
        inc cl
        jnz pal

;at this point i had to make a decision:
;on one hand b/w which is simple, cold, rough, and on the other hand
;dark shades of green which are more "realistic". even by using very
;dark shades - the price to pay for keeping the mood is a really bad
;visibility - my instinct tells me that b/w is the better choice; as
;a bonus  b/w is better to see. in the end it  is  nearly impossible
;to please everybody. if you want to give the  second palette  a try
;just compile by yourself. (+5b) but enough blah ...

;pal2:   xor ax,ax  ;more realistic green palette
;        out dx,al  ;r
;        mov ax,cx
;        shr al,4
;        out dx,al  ;g
;        xor ax,ax
;        out dx,al  ;b
;        inc cl
;        jnz pal2

;xor di,di
;create texture
;cx = 0 here
shape:
add si,cx
add bx,si
sar bl,6
add al,bl
add al,byte[gs:di+320]
shr al,1
mov byte[gs:di],al
dec di
loop shape

xor bx,bx ;has to be 0

main:
mov cl,200 ;draw every degree cx from 200 down to 1 / ch = 0 here

calc:
imul di,cx,320
add di,dx      ;degree=row of texture

;cmp byte[start+1],0 ; *___________* ---> ^___________________^
;je so_not_funny

sub di,bx           ;move/rotate by changing row

;so_not_funny:
cmp dx,180  ;left half? 180..360°
jb do               ;nope

add di,122-160-320  ;no clipping

do:
xor ah,ah           ;only 0..255 @ ax! otherwise calulation won't be correct
mov al,byte[gs:di]  ;get+save texture/color/shape

;mov bx,ax          ;work with bx to save color @ al
;shl bx,2           ;grow
;add bx,cx          ;larger at bottom
;mov word[bp],bx    ;save radius/tree shape = x
mov word[bp],ax     ;same size as code above but less instructions
shl word[bp],2
add word[bp],cx

mov word[bp+4],dx   ;make degrees usable

;calulate new x
fild word [bp+4]        ;load degrees
fidiv word [for_rad]    ;pi*grad/180 = grad/57
                        ;0         1         2         3
fsin                    ;sin
fmul [correct]          ;
fimul word [bp]         ;sin*x
fistp word [bp+2]       ;new x + clear fpu stack by popping

;make position
imul di,cx,320

add di,word [bp+2] ;new x
add di,bx          ;add movement sidewards

;                180°
;          270°        90°
;                0°
;
;              screen
;
;               0_o

cmp al,86          ;cut tree a bit / al = color
ja abort
cmp dx,180
ja ok              ;draw everything at 181° - 360°
cmp byte [es:di],0 ;check 1-180°
jne abort          ;there is something ---> don't draw

ok:
;some fine tuning in colors/height of trees + draw
stosb
add al,13
add di,75+320*28
stosb
sub al,5
add di,100-320*35
stosb

abort:
loop calc ;draw all the way to the top

;next step / changing degrees
inc dx
cmp dx,359
jne main
xor dx,dx ; 0=360

;rotate trees
add bx,word[help]
cmp bx,word[var+1] ;oh well ;)
jne go_on
neg word[help]
neg word[var+1]
;inc word[start+1]  ;oh well v2.0
go_on:

;opening
;cmp word[help2],64000
;ja finished
;mov si,word[help2]
;add word[help2],320
;flip3:
;mov byte [es:si],0
;inc si
;jnz flip3
;finished:

;add bars (they look good and are great to hide things!)
mov si,320*77+256
flip2:
mov byte [es:si-320*43+63],0
dec si
jnz flip2

;flip + clear complete vscreen
flip:
xor ax,ax
xchg al,byte [es:si]
mov byte [fs:si],al
dec si
jnz flip

         in al,60h
         cmp al,1
         jne main

         mov ax,03h
         int 10h
         ret

for_rad dw 57   ;pi*grad/180 = grad/57 (180/3.14... = 57,...)

correct dd 0.13  ;for scaling
help dw 1        ;for rotation
;help2 dw 0      ;for opening