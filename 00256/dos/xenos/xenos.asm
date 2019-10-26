;xenos // lurker in the box
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: cryo camber collaboration - azathoth 2

;This one is the 3rd installment of "breed" reuse because those
;creatures where great :D So I combined them to make a tentacle. The
;tentacle moves and bumps into the walls of that box. Pixel precise
;hit detection plus realtime shadows included! And a changing tentacle.

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
         pop ds
         mov al,13h
         int 10h
;inc cx ;ch = 1 cl = 0
;mov byte[bp],1    ;set to 1 for color/movement on last loop (si = 1)
;mov byte[bp+1],0 ;size / fading bl = 0
mov word[bp],si;0100h

;mov di,21955 ;test if frame will be fucked up when di <> 0 at 1st frame
main:

mov cl,0fh

;top (shadow + wall) + bottom (wall) of box
;di = 0 here after 1st frame (assumed 0fffeh at 1st frame)
line3:
mov byte[ds:di-1536+320*2],ch ;ch = 0
mov byte[ds:di+320*180-11],cl ;cl = 15
inc di
cmp di,320*20+1536
jne line3

;left (shadow + wall) and right (wall) border of box
mov bx,320*179
line2:
mov si,22
line4:
mov byte[ds:si+bx-1],ch  ;shadow
mov byte[ds:si+bx+297],cl ;wall
dec si
jnz line4
sub bx,320
jnc line2

;hole where lurker lurks
mov di,321*48
l1:
mov bx,319*48
l2:
;mov word[ds:di+bx+320*52+95],si ;si = 0 here
mov word[ds:di+bx+320*23+72],0f0fh;si ;si = 0 here

mov word[ds:di+bx+320*71+120],si;0f0fh
;mov word[ds:di+bx+320*52+224],0f0fh
;mov word[ds:di+bx+320*93+259],0f0fh
sub bx,319
jnz l2
sub di,321
jnz l1

;mov si,2                     ;because data at bp and bp+1 is in other use
                              ;also si will provide color data later on
inc si
inc si

mov word[bp+40+si],320*116+120;95 ;center position of lurker
;mov word[bp+40+si],320*116+108+77 ;center position of lurker
                              ;= pos of 1st part of tentacle

;create + draw the whole tentacle + shadow
loop1:

mov dx,word[bp+80+si];make sure ax and dx are ALWAYS the same
                     ;to build everything from
mov ax,word[bp+120]  ;this one is only changed when tentacle is
                     ;inside the hole (if [bp+1] = 1)

mov cx,dx            ;use data from the shapes
shr cx,14            ;0...3 to create thickness/complexity
inc cx               ;1...4 of the creature
                     ;using higher values makes movement too fast
                     ;so it is less fun to watch
                     ;still not too fast if values end up at 65000+
;mov cl,4             ;cl = loops, limiting it makes it better


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
add di,word[cs:way+bx] ;get way of movement

cmp byte[ds:di],15     ;check for border
jne fine               ;no border, go on
sub di,word[cs:way+bx] ;border found so undo movement
jmp loop0              ;try next movement (save 2b by skipping next try)

fine:
;mov bx,si
;shr bl,1                  ;make 0 ... 15
shrd bx,si,17
add bl,16                 ;use 16 ... 31 / bh = 0
mov byte[ds:di],bl        ;draw tentacle

cmp byte[ds:di+321*22],15 ;check for border
je no                     ;border found so no shadow
mov byte[ds:di+321*22],bh ;draw ze shadow
no:
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
;skip 3 frames
mov cl,3
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
mov ax,504fh ;+(0a0ah) ;+(1717h)
xchg ax,word[ds:di] ;grab vscreen
stosw               ;incl inc di
cmp di,cx
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

way dw 1,-1,320,-320           ;different order makes it ... well, different