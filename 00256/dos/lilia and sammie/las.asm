;lilia and sammie // their great escape
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: solar fields - until we meet the sky

;every day was the same. waking up, going to work, coming home and going to bed.
;there was no room for other things, no room for thoughts. they were sheep like
;everyone else, only a part of this system, this mass without a face and without
;hope ... until they managed to take a day off to listen to some vinyl. this was
;the day when those two friends decided to escape this prison called life.

;they knew how to fly a spaceship and they also knew how to sneak into the
;hangar. so they took their chance at dawn reaching for freedom knowing that
;their plan won't be unnoticed. but everything was better than this life - even
;death.

;adrenaline rushed through their veins when the engine started and the feeling of
;escaping gravity gave them goosebumps and butterflies in their bellies. they
;laughed and screamed full of happiness and joy. this was their day.

;lilia looked into sammies eyes. this was the best day of their life.

;only a few minuted later the military started to hunt them.

;will the girls make it?

;# #  #    #     #      #       #        #         #          #           #            #

;I had the idea of some spaceship (actually a zeppelin) based intro for quite some time.
;While coding on "above" I realized that something like that did not fit into that
;intro since it is not a very dynamic one.

;The godrays from below at "above" also look like beams of energy so it was not that hard
;to come up with some spaceship theme (playing Thunderforce IV on my Mega Drive from time
;to time made it even more easy). Adding the enemies from the story was a bit hard since
;the first attempt blew the code over 280b. Not that nice since I also needed vsync to slow
;things down.

;This time no cycling is used for the clouds. After leaving the screen a new cloud is created
;with its new length (which also defines the speed of the movement to get parallax scrolling).
;The enemies chasing after Lilia and Sammie get their positions from the stack. Every enemy is
;moved according to his number in the data set.

;There was the question: Move the ship of Lilia and Sammie or not? I decided to give it a fixed
;position for having the focus on them. All the moving clouds and the 8 enemies create enough
;motion.

;For users without XP: About 60.000 cycles at DosBox are fine. And as usual the experience under
;XP is different (especially because of the positions of the clouds).

;well, that's all folks :)

;# #  #    #     #      #       #        #         #          #           #            #

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen
         pop ds      ;using ds saves bytes at flip otherwise no benefit because
         mov al,13h  ;vars have to be accessed via cs
         int 10h

;assuming: cx = 255
main:
mov si,334                  ;number of clouds * 2 because accessing word
cloudie:
mov di,word[cs:cloudpos+si]    ;get pos (random at 1st run)
movzx bx,byte[cs:cloudsize+si] ;bx <> 0 after flipping of screen
again:
add bl,20                   ;minimum size
jz again                    ;no 0 a.k.a. fugly error dammit!
mov ax,bx                   ;save length for later use

draw_cloud:
mov cl,25                   ;stay bright to keep a not so negative feeling
mov dx,bx                   ;save length of cloud since bx is changed at help0r
help0r:
mov byte[ds:di+bx],cl       ;set pixel
add bx,318                  ;above 320 looks more polished but boring
inc cx                      ;change color
cmp cl,32                   ;reached brightest color of gray/white segment of palette?
jne help0r

mov bx,dx                   ;please restore the pos of the cloud
dec bx                      ;for the next pixel
jnz draw_cloud              ;until whole length has been drawn

;use lenght of cloud for movement so smaller clouds are slower
shr ax,5                    ;ah = 0
inc ax                      ;never 0
imul dx,ax,321              ;create movement
add word[cs:cloudpos+si],dx ;move
;cmp word[cloudpos+si],64000  ;outside of screen?
;jnae allright                 ;if so create new data for the cloud
jnc allright

in al,40h                   ;make new cloud size kinda random
xor ax,si                   ;random a bit more
adc word[cs:cloudpos+si],ax ;make the pos of the cloud a bit more more random next time
shr al,2                    ;please not that big
mov byte[cs:cloudsize+si],al;save length

allright:
dec si
dec si
jnz cloudie                 ;set at pos 0 not used

;draw the ship of lilia and sammie
;plus the ones that are after them!
;si = 0 here
ship:
mov di,si                   ;get number of set
shr di,1                    ;new calculation each set to have di availiable below at enemies
mov bx,word[cs:ship_pos+si]    ;get stuff ... obviously
mov al,byte[cs:ship_color+di]
mov ah,al                   ;set word for spaceship to save bytes
movzx cx,byte[cs:ship_size+di] ;length of element of the ship
draw_ship:
mov word[ds:bx],ax          ;draw element
add bx,321                  ;move to create line
mov dx,bx                   ;save pos in element for using it at drawing the enemies

dec ax                      ;enemies got different color
xor di,di                   ;clear di which is the number inside the sets of enemies
draw_enemy:
mov bx,dx                   ;get pos of element of ship
add bx,word[bp+di]          ;add pos of the enemy itself
mov byte[ds:bx],al          ;draw
mov byte[ds:bx+1],al        ;draw (word makes error because of overflow at 0ffffh
cmp al,43                   ;is the element the energy ray of enemies ship?
jne noray                   ;nope
draw_ray:
mov byte[ds:bx],al          ;draw the energy ray
;mov byte[ds:bx+1],al ;cut this out to have different thickness of rays
add bx,321                  ;move pos of ray
;cmp bx,64000
;jna draw_ray
jnc draw_ray                ;rays will be cut off when ship jumps over 0fffh
                            ;but who cares ...
noray:
inc di
inc di
cmp di,16                   ;number of enemies*2
jne draw_enemy              ;all enemies done?
inc ax                      ;restore color for next run

mov bx,dx                   ;restore pos of element of ship for next run
loop draw_ship

inc si
inc si
cmp si,16                   ;ship has 8 parts
jne ship                    ;all sets done?

;move the enemies
;si = 16
move_enemies:
shrd di,si,18               ;copy and div 2
imul ax,di,320              ;create moving step
inc ax                      ;not 0 please
cmp si,10                   ;make half of enemies move into another direction
jb okee
neg ax                      ;make them move the other way
okee:
sub word[bp+si],ax          ;save please
dec si
dec si
cmp si,16                   ;number of enemies*2
jb move_enemies             ;all sets done? if 0 - 2 then si above 16, sure

;needed to slow it down
mov dx, 3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;black bars fo shizzle
mov di,320*40
flip:
mov al,57;79;65           ;background color
xchg al,byte[ds:di]       ;grab and clear screen
stosb;mov byte[es:di],al        ;drop to vga
cmp di,320*157
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

;            cockpit    |     body of ship    |  weapons    |     body of ship    | ray of nrg | body of ship
ship_pos dw 320*80+120, 320*79+117, 320*82+124, 320*87+124, 320*86+130, 320*85+131, 320*94+134,  320*86+126
ship_size db        6,         16,         10,          6,          5,          4,         102,           8
ship_color db       1,         30,         29,          4,         27,         28,          44,          31

cloudpos dw 500 dup ?
cloudsize dw 500 dup ?