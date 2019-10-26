;hic sunt leones // at edge of the world
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;#############################################################################

;save version that does not assume that ax = 0 at beginning

;#############################################################################

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen2 (flames/waves of the ocean of chaos)
         pop fs
         push 08000h ;vscreen (ground + pixel man)
         pop ds
         mov al,13h
         int 10h

;assuming:
;cx = 255
;bx = 0
        mov dx,0x3C9
        ;inc cx ;[ result works for me, xp and dos-box ;) ]
pal2:   shrd ax,cx,18 ;first i only had shr 1 and grayscale
        out dx,al ;r  ;but then i decided to invest 4b into
        shr al,1      ;a better palette which has more warmth
        out dx,al ;g  ;and a better visibility of our little
        xor al,al     ;protagonist
        out dx,al ;b
        loop pal2

;clear vscreen2 at startup to avoid flames in the sky
;also same flames/speed of pixel man at every run
clrscr:
mov byte[fs:bx],cl ;cl = 0 here
dec bx
jnz clrscr

;loader bar and "introduction"
;cx = 0 here
mov bx,319
loader:
mov dx, 3dah ;wait for vsync for constant speed
vsync1:
in al,dx
test al,8
jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

mov cl,29 ;make the bar fat along the upcoming way of pixel man
mov di,bx
fat:
sub byte[es:di+320*11],dl ;smooth color
add di,320
loop fat

dec bx
jnz loader

;setup of used vars
;bx = 0 here
;cx = 0 here
;dx = 03dah here
mov bx,320*39            ;where pixel man is
mov word[bp],320         ;size (width) of the ground

xor dl,dl                ;clear for movement; still saves 1b by setting a word instead of 2 bytes
mov word[bp+2],dx;ch      ;0 = no movement of ground ;1 = movement of ground
;mov byte[bp+3],dh        ;counting steps for moving of ground
                         ;gets set to 5 below so save 1b here by using dh (03h)
                         ;using e.g. cl would make 255 loops ---> too long!

main:

;flames/waves at the edge of the world
;borrowed from hic sunt dracones because i just love that effect
;but i changed it here and there for the needs and in appearence

cmp di,64000       ;feed invisible area with new data (don't care about design bars)
jna nobase         ;no feed
sub byte[fs:di],dh ;firestarter (add kills glitchy appearence compared to inc)
                   ;must not be 0 on first run --> dh = 03h at first run
nobase:

mov si,di       ;get current position of pixel to work with

xor cx,cx
add cl,byte[fs:di]
mov byte[ds:si],cl  ;drop on vscreen where ground + pixel man will be added
                    ;to avoid glitches by not working with 0 because there is
                    ;no other clearing of vscreen
jz drop             ;don't work if 0

adc ax,di ;not 0 (in most cases)
dec dx    ;not 0 (in most cases)
mul dx
shr al,6  ;256/64 = 4
          ;work with 0,1 and 2 but not above so sometimes pos will stay
          ;use al below for movement so shr needed
          ;0 = move up / 1 = move left / 2 = move right / 3 = stay

jnz gate1
sub si,320 ;move up
gate1:
cmp al,1
jne gate2
dec si     ;move left
gate2:
cmp al,2
jne gate3
inc si     ;move right
gate3:

dec cx              ;change color for shades
mov byte[fs:si],cl  ;set new pixel on background vscreen2
mov byte[fs:si-1],cl;do the fake swirl! only needed here and not on vscreen
drop:

dec di
jnz main            ;work with full bg screen
;end of recyled code

;use remaining al for movement of pixel man to get some sort of random speed
;cmp al,0         ;move little pixel man not too fast because he is a bit unconfident
;jne break2       ;should slow down on every machine (?)
;cmp byte[bp+4],0 ;no ground move
;jne break2       ;there is ground move so don't move pixel man
add al,byte[bp+2]
jnz break2

inc bx            ;move pixel man
cmp bx,320*39+319 ;pixel man reached edge?
sete byte[bp+2]   ;standing on the edge so make ground move byte setting 1
break2:

cmp word[bp],di    ;don't work code for ground after death of pixel man
je nothing         ;di = 0 here so save 1b

;draw gound
ground:
;ch = 0 here
mov cl,150 ;top of ground
fill:
mov ax,word[bp] ;set width
fill2:
imul si,cx,320
add si,ax
mov byte[ds:si+320*39-1],240 ;-1 adjust because of width (jnz)
dec ax
jnz fill2
loop fill       ;next row


mov byte[ds:bx],128     ;draw pixel mans body (different color than body gives personality!)
dec byte[ds:bx-320]     ;head ;dec because color = 0 here so make it 255 (black)

;check if movement of the ground in enabled ( 0 = off / 1 = on )
cmp byte[bp+2],1
jne nothing

;ground movement; note: pixel man will be dead when [bp] = 0
dec byte[bp+3]   ;move not too fast! only 1 time at 5 frames
jnz nothing
mov byte[bp+3],5 ;reset counter (frames)
cmp word[bp],70  ;ground reached the magic point?
ja weiter        ;not reached yet so pixel man will stay on the ground
add bx,640       ;oh noooooo! pixel man is falling!

weiter:
cmp word[bp],71 ;make him jump from the edge by not moving him at 71
setne dl        ;1 at 71 else 0
sub bl,dl       ;move pixel man when staying on edge and when falling
dec word[bp]    ;change width of ground
;end of movement of the ground

nothing:

;cx = 0 here
dec cx ;0ffffh ;prepare for flip and also save 1b at bars by using cl

;add black bars for the purposes of design
mov si,320*26+256
flip2:
mov byte[ds:si-320*16+63],cl ;255
dec si
jnz flip2

;si = 0 here
;di = 0 here
;flip:
;mov al,byte[ds:si]   ;get vscreen
;mov byte[es:si],al   ;drop to screen
;inc si
;jnz flip

;flip:
;movsb ;ds:si ---> es:di including +/- si and di
;loop flip

;dec cx ;made above pixel man drawing
rep movsb ;ds:si ---> es:di including +/- si and di until cx = 0


         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret