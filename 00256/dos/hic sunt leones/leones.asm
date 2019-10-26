;hic sunt leones // at edge of the world (release / non looping version)
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: rachel grimes — earthly heaven

;### about ####################################################################

;this intro was inspired by the short movie "the cathedral" (2002)  directed by
;Tomasz Baginski and  somehow  by  the video game  "limbo" (2010)  by Playdead.

;for users of dosbox: about 130000 cycles should do their job. and yes you will
;need some patience (=

;this intro went through some stages. the original version was in grayscale and
;looped.  but i was not happy with that so i decided to drop the looping.  this
;way the viewer will stay at the scene after the death of the protagonist until
;ESC is pressed.  the bytes saved by dropping the looping behaviour went into a
;loader bar. first of all: why not ;) but its meaning is also to avoid that the
;viewer is forced into the scene right after starting the intro.  sure,  a  bit
;more patience is needed that way but i was more happy with that decision. then
;i  optimized this second version because i had the feeling that there are some
;bytes left  i could save  within my limited skills  and changed the loader bar
;into a fat one  -  this way it made more sense to me design-wise. because this
;third version assumes ax = 0 i decided to make a version that does not.  after
;a few days  i decided out of nowhere to change some colors in the intro making
;it simpler - at least i think so. this way the loader bar changed and also the
;color of  the ground  made  size of the  intro a bit  bigger even  if  i could
;optimize a bit further.  i decided  to include all versions  as bonus for  the
;sake of  completeness because  it makes no sense just to have  them on my hd -
;i did not want to delete them somehow.

;leones  - release version that assumes ax = 0 (253)

;leones1 - original version that loops (251)
;leones2 - changed version (256)
;leones3 - more optimized + changed version (250)
;leones4 - same as edge3 but does not assume ax = 0 (252)

;a lot of space is used by all those cmp and jumps even after optimizing to get
;it into 256b. i tried to tell a little story and there minimalism came in very
;handy  that's  why it looks that simple.  i also found myself writing a little
;story around the scene itself.  some feeling told me to do so.  you might take
;your time to read it below  -  maybe searching the  listening song from  above
;and starting it first ...

;### story ####################################################################

;our  little  protagonist is  searching for  an answer:  what is the meaning of
;life? he can't find it in his daily environment, not in his dreams, not in his
;creativity,  not in  natures beauty  and not in relationships to other people.
;he feels like a  wanderer between silence and blindness always trapped between
;euphoria and apathy.

;one day he stumbles upon a myth about the edge of the world.  somehow he hopes
;to find his answer at this unknown place or at least some hint where to search
;for the truth. he has to hope and to believe because he feels so tired inside;
;like decaying. he feels like an empty shell, like someone who can only wait to
;get older; there is nothing more to expect.

;traveling old paths he almost can't see uncertainy walks by his side like some
;loyal friend. he does not know what lies ahead and with every step he takes he
;asks himself about his expectations and the possible concequences of this long
;walk.

;after marching through uncounted days  and  nights he notices the smell of the
;sea  mixed  with the odour of flowers and humid soil from giant ancient woods.
;the light of this new dawn finally is guiding him to the edge of the world. so
;he  walks towards  this long  desired place exhausted and also  very doubtful.
;will there be an answer? will his life become more than a cage?

;and then he  arrives at  this furthest  point,  at the end, at the edge of the
;world. above  him the clear sky kissed by the  colors of the dawn, in front of
;him  everything  vanishing in the distance while the ocean of chaos lies below
;the cliff; it is the ocean of chaos where everything we know came from.

;but there is nothing.  only the sound of the wind, the beautiful smell and the
;warm light of the  rising sun on his skin.  only loneliness dwells at this old
;place.  no hope for a new life, no answer, no love.  so our little protagonist
;makes a decision  instead  of going back to  his gray life fill of depression,
;tears and self-hate:  he closes his eyes,  takes a deep  breath and flies like
;an eagle in  the mind's eye  while  his body sinks  into the  open arms of the
;ocean of chaos - where everything started and everything will end.

;################################################### the story has about 2k ###

org 100h
use16

;assuming:
;cx = 255
;bx = ax = 0

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen2 (flames/waves of the ocean of chaos)
         pop fs
         push 08000h ;vscreen (ground + pixel man)
         pop ds
         mov al,13h
         int 10h

         mov word[bp+2],ax ;setup [bp+2] = 13h [bp+3] = 0

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
dec byte[es:bx];= 255 ;mov byte[es:bx],255 ;cl = 0 here ;fill vga black
dec bx
jnz clrscr

;loader bar and "introduction" 34b
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
inc byte[es:di+320*11]; = 0 ;mov byte[es:di+320*11],1 ;sub byte[es:di+320*11],dl ;the way of pixel man approaches
add di,320
loop fat

dec bx
jnz loader

;### setup of used vars ################
;bx = 0 here
;cx = 0 here
;dx = 03dah here
mov bx,320*39            ;where pixel man is at the beginning
mov word[bp],320         ;size (width) of the ground

;setup above @ start
;mov byte[bp+2],dh      ;counting steps for moving of ground
                       ;gets set to 5 below so save 1b here by using dh (03h)
                       ;using e.g. cl would make 255 loops ---> too long!
;mov byte[bp+3],ch      ;0 = no movement of ground ;1 = movement of ground

main:

;flames/waves at the edge of the world
;borrowed from hic sunt dracones because i just love that effect
;but i changed it here and there for the needs and in appearence

cmp di,64000-320*8 ;feed invisible area with new data (don't care about design bars)
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
mov byte[fs:si-2],cl;do the fake swirl! only needed here and not on vscreen
drop:

dec di
jnz main            ;work with full bg screen
;end of recyled code

;use remaining al for movement of pixel man to get some sort of random speed
;cmp al,0         ;move little pixel man not too fast because he is a bit unconfident
;jne break2       ;should slow down on every machine (?)
;cmp byte[bp+3],0 ;no ground move
;jne break2       ;there is ground move so don't move pixel man
add al,byte[bp+3]
jnz break2

inc bx            ;move pixel man
cmp bx,320*39+319 ;pixel man reached edge?
sete byte[bp+3]   ;standing on the edge so make ground move byte setting 1
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
mov byte[ds:si+320*39-1],255 ;240 ;-1 adjust because of width (jnz)
dec ax
jnz fill2
loop fill       ;next row


mov byte[ds:bx],128     ;draw pixel mans body (different color than body gives personality!)
dec byte[ds:bx-320]     ;head ;dec because color = 0 here so make it 255 (black)

;check if movement of the ground in enabled ( 0 = off / 1 = on )
cmp byte[bp+3],1
jne nothing

;ground movement; note: pixel man will be dead when [bp] = 0
dec byte[bp+2]   ;move not too fast! only 1 time at 5 frames
jnz nothing
mov byte[bp+2],5 ;reset counter (frames)
cmp word[bp],70  ;ground reached the magic point?
ja weiter        ;not reached yet so pixel man will stay on the ground
add bx,640       ;oh noooooo! pixel man is falling!

weiter:
cmp word[bp],71 ;make him jump from the edge by not moving him at 71
setne dl        ;0 at 71 else 1
sub bl,dl       ;move pixel man when staying on edge and when falling
dec word[bp]    ;change width of ground
;end of movement of the ground

nothing:

;cx = 0 here
dec cx ;0ffffh ;prepare for flip and also save 1b at bars by using cl

;add black bars for the purposes of design
mov si,320*26+256
bars:
mov byte[ds:si-320*16+63],cl ;255
dec si
jnz bars

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

;dec cx ;made below pixel man drawing (label nothing)
rep movsb ;ds:si ---> es:di including +/- si and di until cx = 0


         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret