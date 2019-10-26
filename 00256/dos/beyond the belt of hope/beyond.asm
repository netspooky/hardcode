;beyond the belt of hope // the enemy within
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: solar fields - february

;---------------------------------------------------------------------------

;after lilia and sammie my second spaceship based intro - but this time with
;laz0rz and unlimited kills instead of a story.

;the vertical yellow rays of  hit'n'destroy  add a nice extra to the visuals
;that would have been missing by using some horizontal lines / some  boxes /
;random putted pixels.  also 1 frame is enough to display lasers and rays of
;destruction. all hits are real hits. the only random element about them  is
;the question: does a spaceship shoot  a laser or not.  not every laser hits
;because of the order things are drawn to the screen a.k.a. near miss (which
;can happen while flying full speed!  also no little story  this time  since
;the title says it all :)     who is friend and who is foe?   you decide ...

;finished about 3 days after revision 2o15 which was quite motivating.  also
;no hitbox on the ships through   "pixel accurate hit detection engine (tm)"
;---------------------------------------------------------------------------

;DosBox: About 20.000 cycles are fine. More not needed since vsync is used.
;        Please restart the intro after the 1st run without leaving DosBox
;        to get the stars into a nice order how it is supposed to be.
;        As always this intro was coded under XP.

;assuming: ch = bl = 0

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen
         pop fs
         mov al,13h
         int 10h

mov bh,0eh ;bx,3600; = 0e10h
initstuff:
in al,40h
mul bx
sbb word[stars_pos+bx],ax   ;including ships_pos

shr ax,12
inc ax                      ;no 0 speed
mov word[ships_speed+bx],ax
shr ax,1
mov word[stars_speed+bx],ax

dec bx
dec bx
jnz initstuff

main:

mov si,1750  ;number of star * 2 (at least in theory)
parallax:
mov di,word[stars_pos+si]
mov ax,word[stars_speed+si]
add ax,322                   ;even if 0 is saved it will move
sub word[stars_pos+si],ax    ;move
mov byte[fs:di],al           ;use what's in al since it looks neat
xor byte[fs:di+1],al         ;add some fake but fancy motion blur
dec si
dec si
jnz parallax ;all stars done?

;ch = 0 here
mov bp,46 ;number of ships * 2
again:

;laser section
;laser will be seen only 1 frame but that is enough
mov si,word[ships_pos+bp] ;origin of laser = is origin of the ship
in al,40h ;this is random enough
cmp al,4 ;will there be laser?
ja noshot ;no shot 'cos they still chargin da laz0rz!

sega_mega_drive_blast_processing:
mov byte[fs:si],50 ;draw photon

inc si             ;move photon to make laser
xor dx,dx          ;prepare to check if reaching border of screen
mov bx,320
mov ax,si          ;pos of photon (after moving but it is so faaast!)
div bx
cmp dx,cx;0           ;clean 320?
jne sega_mega_drive_blast_processing ;nope, so not at border

noshot:

xor di,di
xor si,si
draw_ships:
mov bx,word[ship_element_pos+si]   ;part of ship

add bx,word[ships_pos+bp]          ;add location of actual ship

mov cl,byte[ship_element_size+di]  ;for making a line

draw:
cmp byte[fs:bx],50 ;ship hit by laser? no hitbox ;)
jne k

cmp byte[es:bx],ch ;check if outside of displayed area (cx = 0 here)
je k               ;only destruction within visible area

mov ax,320         ;saves 2b below at add/sub
mov dx,bx          ;save pos to use bx

prep:              ;move down to bottom area
add bx,ax
cmp bh,0fah;bx,64000
jna prep
explode:
mov byte[fs:bx],14;draw up to top for explotion ray
sub bx,ax
;cmp bx,64000
jnc explode;jb explode

mov word[ships_pos+bp],bx ;simply use end of explosion ray as location of new ship

mov bx,dx ;restore pos

k:
mov al,byte[ship_element_color+di] ;color of element
mov byte[fs:bx],al                 ;draw pixel of element
inc bx                             ;move to right
loop draw                          ;draw whole element

inc di                             ;next element
inc si                             ;next element
inc si                             ;next element
cmp si,12                          ;all 6 parts of ship done?
jne draw_ships

;moving the ships
imul dx,word[ships_speed+bp],321 ;create movement from speed
cmp bp,24                        ;move half of the armada in the opposite direction
ja notbackwards
neg dx
notbackwards:
add word[ships_pos+bp],dx        ;move ship

dec bp                           ;moving to the next ship
dec bp
jnz again                        ;and repeat until all ships are done

;create same speed everywhere using vsync
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
mov di,320*34       ;upper bar slightly thinner
flip:               ;looks better with classic bars
mov al,200          ;black is boring
xchg al,byte[fs:di] ;grab + clear vscreen
stosb               ;drop it including inc di
cmp di,320*165      ;bar area below
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

nop ;255
nop ;256

; -320*2-9 to make origin of ship right in front of weapon system to get laser fired from the right place
;                                                                                               this 'cos
;                                                                                               4b left
ship_element_pos dw   2-320*2-9,  10-320*2-9, 320+1-320*2-9, 320*2+4-320*2-9, -320*1+3-320*2-9, 5-320*2-9
ship_element_size db         10,           4,            14,               5,                4,         2
ship_element_color db        28,          55,            29,              64,               31,        25

stars_pos dw 3000 dup ?
ships_pos dw 3000 dup ?

stars_speed dw 6000 dup ? ;double because of init stuff to save 4b at positions
ships_speed dw 6000 dup ?