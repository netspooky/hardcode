;creeper in the box (variation of xenos)
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: sabled sun - signals iv

;concept changed for fun, skipped some things due size.
;and yes: coder colors on the box.

;assuming:
;bx = 0
;cx = 255
;si = 0100h

;variables:
;bp+0 size of elements
;bp+1 for color/size changing
;bp+40 ... 79 pos
;bp+80 ... 119 shape data
;bp+120 randomiz0r

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;original screen
         pop fs
         mov al,13h
         int 10h
;inc cx ;ch = 1 cl = 0
;mov byte[bp],1    ;set to 1 for color/movement on last loop (si = 1)
;mov byte[bp+1],0 ;size / fading bl = 0
mov word[bp],si;0100h

;mov di,21955 ;test if frame will be fucked up when di <> 0 at 1st frame
main:

;draw the sides and the top of the box
xor di,di
xor ax,ax
do_box:
;hole where lurker lurks
mov si,word[set0+di]
l1:
mov cx,word[set0+di+2]
l2:
mov bx,cx
add bx,word[set0+di+8]
mov word[fs:si+bx+320*10+30],ax
mov word[fs:si+bx+320*10+32],ax

sub cx,word[set0+di+4]
jnz l2
sub si,word[set0+di+6]
jnz l1
add di,10
add ax,0101h ;change color
cmp di,40
jne do_box

;mov si,2                     ;because data at bp and bp+1 is in other use
                              ;also si will provide color data later on
inc si
inc si

mov word[bp+40+si],320*88+130 ;center position of lurker
;mov word[bp+40+si],320*116+108+77 ;center position of lurker
                              ;= pos of 1st part of tentacle

;create + draw the whole tentacle + shadow
loop1:

mov dx,word[bp+80+si];make sure ax and dx are ALWAYS the same
                     ;to build everything from
mov ax,word[bp+120]  ;this one is only changed when tentacle is
                     ;inside the hole (if [bp+1] = 1)

;mov cx,dx            ;use data from the shapes
;shr cx,14            ;0...3 to create thickness/complexity
;inc cx               ;1...4 of the creature
                     ;using higher values makes movement too fast
                     ;so it is less fun to watch
                     ;still not too fast if values end up at 65000+
mov cl,2             ;cl = loops, limiting it makes it better

draw:
mov ch,byte[bp] ;step lenght every loop
                ;can't be 0 at this point ( = 1 at 1st run)

oki:
mov di,word[bp+40+si] ;start/center of thingie
loop0:
add ax,si           ;change for creating thingies look
add dx,si           ;using si makes sure that 0 is not possible
mul dx              ;on the long run

adc bx,ax           ;include previous bl
shr bx,14           ;0..3
shl bl,1            ;double because of word
add di,word[way+bx] ;get way of movement

fine:
;mov bx,si
;shr bl,1                  ;make 0 ... 15
shrd bx,si,17
add bl,16                 ;use 16 ... 31 / bh = 0
mov byte[fs:di],bl        ;draw tentacle

dec ch
jnz loop0                 ;all steps/full length done?

loop draw                 ;do the next loop

inc si
inc si                    ;go to the next segment of tentacle
mov word[bp+40+si],di     ;next segment begins where last one ended
cmp si,32                 ;restricted because of colors
jne loop1                 ;work with all segments

;change of size from min to max and max to min
mov cl,byte[bp+1]  ;will be 1 or -1 all the time
add byte[bp],cl    ;change size
jnz skippie        ;size = 0?

neg cl              ;make 1 to -1 or -1 to 1
mov byte[bp+1],cl   ;save it
add byte[bp],cl     ;make size <> 0 for next run
cmp cl,1            ;smallest size? (1 means size will go up
                    ;during the next frames)
jne skippie         ;change all data if so

;change shapes of all parts
;si = 32 from above
newshapes:
add word[bp+80+si],si ;change shape / make things evolve slowly
dec si
jnz newshapes
in al,40h            ;at least 1x in this intro ;)
add word[bp+120],ax  ;staying below 127 saves 1b

skippie:

;slooooooow things doooooooown
;since it is way tooooooo fast
mov cl,4
again0:
mov dx, 3dah
vsync1:
in al,dx
test al,8
jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2
loop again0

;flip
;cx = 0
mov di,cx
flip:
mov ax,585ah
xchg ax,word[fs:di] ;grab vscreen
stosw               ;incl inc di
cmp di,cx
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret
nop ;256

way dw 1,-1,320,-320

set0 dw 321*34, 318*22, 318, 321, 320*51+106
set1 dw 320*45, 318*22, 318, 320, 320*85+140
set2 dw 320*46, -321*33, -321, 320, 320*108+95
set3 dw -322*20, 318*23, 318, -322, 320*53+109