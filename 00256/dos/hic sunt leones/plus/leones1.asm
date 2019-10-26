;;hic sunt leones // at edge of the world (original looping version)
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;#############################################################################

;this is the original version in grayscale.

;#############################################################################

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen2 (flames)
         pop fs
         push 08000h ;vscreen (foreground; ground + pixel man)
         pop ds
         mov al,13h
         int 10h

        mov dx,0x3C9
        ;inc cx ;result works [for me] ;)
pal2:   shrd ax,cx,18 ;grayscale does fine
        out dx,al ;r
        out dx,al ;g
        out dx,al ;b
        loop pal2

;clear vscreen2 at startup to avoid flames in the sky
;assuming bx > 320*40
clrscr:
mov byte[fs:bx],cl ;cl = 0
dec bx
jnz clrscr

;setup of used vars
;ch = 0 here, always
again:
mov bx,320*39            ;where pixel man is
mov word[bp],320         ;size (width) of the ground
mov byte[bp+2],bh        ;counting steps for moving of ground
                         ;gets set to 5 below so save 1b here by using bh (30h)
mov byte[bp+4],ch        ;0 = no movement of ground ;1 = movement of ground
mov word[bp+6],320*200-1 ;for restoring ground; -1 corrects missing pixel

main:

;flames at the edge of the world
;shameless borrowed from hic sunt dracones because i just love that effect (=

cmp di,64000    ;feed invisible area with new data
jna nobase      ;stuff below messes with data
inc byte[fs:di] ;firestarter
nobase:

mov si,di       ;get current position of pixel to work with

xor cx,cx
add cl,byte[fs:di]
mov byte[ds:si],cl  ;also on vscreen where ground + pixel man will be added
                    ;to avoid glitches by not working with 0
jz drop           ;don't work if white (0)

adc ax,di ;not 0 (in most cases)
dec dx    ;not 0 (in most cases)
mul dx
shr al,5  ;256/32

jnz gate1
dec si     ;move left
gate1:
cmp al,1
jne gate2
sub si,320 ;move up
gate2:
cmp al,2
jne gate3
inc si     ;move right
gate3:

dec cx              ;change color for shades
drop:
mov byte[fs:si],cl  ;set new pixel on background vscreen2

dec di
jnz main            ;work with full bg screen
;end of recyled code


;cmp al,0         ;move little pixel man not too fast because he is a bit unconfident
;jne break2       ;should slow down on every machine (?)
;cmp byte[bp+4],0 ;no ground move
;jne break2       ;there is ground move so don't move pixel man
add al,byte[bp+4] ;shorter code than above
jnz break2

inc bx
cmp bx,320*39+319 ;reached edge?
sete byte[bp+4]   ;standing on the edge so make ground move byte setting 1
break2:

;restoring ground to create loop in visuals
cmp word[bp],0      ;don't work code for ground after death of pixel man
jne ground
xor bx,bx           ;restore ground by abusing pixel mans position
looper:
mov byte[ds:bx],240
dec bx
cmp bx,word[bp+6]   ;reached desired row?
jnbe looper

sub word[bp+6],320      ;next row on next frame
cmp word[bp+6],320*40-1 ;ground completely restored? -1 is correcting (see used vars)
je again                ;yes, so restore all other values too
jmp nothing             ;no, so continue restoring of the ground

;draw gound
ground:
;ch = 0 here
mov cl,150 ;top of ground
fill:
xor ax,ax
fill2:
imul si,cx,320
add si,ax
mov byte[ds:si+320*39],240
inc ax
cmp ax,word[bp]
jne fill2
loop fill

;mov si,bx
mov byte[ds:bx],175     ;draw pixel mans body
mov byte[ds:bx-320],215 ;head

;check if movement of the ground in enabled ( 0 = off / 1 = on )
cmp byte[bp+4],1
jne nothing

;ground movement
move:
dec byte[bp+2]   ;move not too fast! only 1 time at 5 frames
jnz nothing
mov byte[bp+2],5 ;reset counter (frames)
cmp word[bp],70 ;ground reached the magic point?
ja weiter
add bx,640      ;oh noooooo! pixel man is falling!

weiter:
cmp word[bp],71 ;make him jump from the edge by not moving him at 71
setne dl        ;1 at 71 else 0
sub bl,dl       ;move pixel man when staying on edge and when falling
dec word[bp]    ;change width of ground
;end of movement of the ground

nothing:

;add black bars for the purposes of design
mov si,320*26+256
flip2:
mov byte[ds:si-320*16+63],255
dec si
jnz flip2

;si = 0 here
flip:
mov al,byte[ds:si]   ;get vscreen
mov byte[es:si],al   ;drop to screen
inc si
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main            ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret