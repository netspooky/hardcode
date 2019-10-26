;kaneda // ions of zen
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: carbon based lifeforms - interlooper

;this intro was (heavily) inspired by one of my all time
;favs: "instant zen" by synesthetics (2oo5), the cloud
;scene(s) to be exact.

;it started a bit different (and way slower) but became
;this intro. somehow the famous scene in "sunshine"
;popped up in my mind, where kaneda dies. what did he
;see? who knows. but that's where 1/2 of the title comes
;from. and again, i spent a lot of time into tweaking
;the visual side to cover up my lack of coding skills ;)

;enjoy!

;ps: first i wanted to call it "instant sen" but then i
;thought that would be more than silly. silly me. or is
;it a blazing golden chocobo in hyper speed mode?

;dosbox: core=dynamic, cycles=max
;runs smooth on my old xp machine + under freedos on my
;fast one.

org 100h
use16

maxie equ 127*4 ;this is fine enough
                ;number of elements
                ;512 / 2 (dec si dec si) = 256 elements

;assuming: ax = bx = 0
;          cx = 255

start:   push 09000h ;vscreen
         pop ds      ;this kills dos/freedos after hitting ESC
         push 0a000h ;vga
         pop es
         mov al,13h
         int 10h

        mov dx,0x3C9 ;create ze colors
        inc cx ;ch = 1

;mov si,maxie
;init_stars:
;mov byte[s_z+si],ch ;cheat a bit
                    ;to avoid having crashing values for x and y
;dec si
;jnz init_stars

pal:    shrd ax,cx,18
        out dx,al ;r
        out dx,al ;g
        cmp cl,bl ;bl = 0
                  ;keep black for bars/design
        je drop   ;leave the black alone!
        mov al,47;63
                  ;there will be a glimpse of yellow by
                  ;using a lower value. but blueish shades
                  ;will still be present. adds a lot compared
                  ;to only white ---> blue.
        drop:
        out dx,al ;b
        shld si,cx,17 ;256 * 2 = maxie
        mov byte[cs:s_z+si],1 ;cheat a bit
                           ;-1b compared to code above
                           ;only byte since only byte will be changed
                           ;for moving on z-axis
        loop pal


main:

mov si,maxie  ;set up loop to work with all elements
malen:

dec byte[cs:s_z+si]      ;move towards viewer
jnz okee              ;not reached your screen
;ah = ?
triz:;-------create z-values--------
xor ax,ax ;zero it because word will be grabbed for calculations
          ;skipping it will save 2b but will make a triagle stay on screen :\
in al,40h
;shl al,1
inc ax  ;1..255 ... 256(ah = 1)
jz triz ;don't div by 0 ... you know
mov word[cs:s_z+si],ax ;save
trix:;-------create x-values--------
in al,40h ;ah = 0 or 1 here
          ;in al makes it a bit more random for 2b
;xor ah,ah;not needed, in worst case values are off screen
          ;but there is no real difference to see
;shl ax,1
sub ax,127;255 ;when shl ax,1 enabled
mov word[cs:s_x+si],ax ;save
triy:;-------create y-values--------
mul si
xor ah,ah
sub ax,127 ;range -127 ... 128
mov word[cs:s_y+si],ax ;save


okee:
;mov cx,255 ;scaling is not that effective a.k.a. wasted bytes
;mov ax,word[s_z+si] ;1..255
;sub cl,al
;shr cl,2
;;jnz well
;inc cl

;cx = 0 here
well:
mov cl,60        ;x
loops1:
mov bp,cx        ;y
                 ;have a nice triangle
                 ;fixed values will make a rectangle, you know :)
loops2:
mov ax,96        ;word viewx ;nx:=(viewx*x div (z+cnz)) + cnx;
                 ;from my borland times back in the 90s ;)
imul word[cs:s_x+si];fine tuning on x value

idiv word[cs:s_z+si];3d
add ax,130       ;adjust pos based on visual behaviour
add ax,cx        ;give it the thickness
mov bx,ax        ;save calculated 2d value for x

mov ax,cx        ;20;word viewy ;ny:=(viewy*y div (z+cnz)) + cny;
                 ;cx does the magic
                 ;adding e.g. 20 will "spread" triangles a bit more
                 ;on the screen but the effect will be destroyed
imul word[cs:s_y+si];fine tuning on y value

idiv word[cs:s_z+si];3d
add ax,115       ;adjust again
sub ax,bp        ;cx will give you a lot of lines
                 ;sub switches top with bottom

imul di,ax,320   ;calculate true y value for the screen
add di,bx        ;add x

cmp bx,319       ;please no mess on the screen
ja nix           ;includes values < 0
cmp ax,199
ja nix

;ax bx dx are free to use from now on

;;shrd ax,si,16+5   ;make color based on # of object
mov bl,byte[ds:di];-321 for example distords nicely but makes clean style well ... crispy
                  ;only works if vscreen is emptied. otherwise errors will occur on top/bottom

;sub bl,8;al         ;le blendement
;cmp bl,8;20         ;no jumping in colors by jumping from 0 ---> 255
;jae ook
;mov bl,8;20         ;set nice fixed color based on watching and running the intro
                  ;looking for errors

cmp bl,7          ;-2b
jbe ook           ;7 looks smoother than 8 and stronger than 6
sub bl,7

ook:

mov byte[ds:di],bl;set the pixel

nix:

dec bp            ;next y
jnz loops2
loop loops1       ;next x

dec si
dec si
jnz malen         ;work with all elements

mov dx,320;= 0140h dl = 64 for using below
;set ze bright lines
mov bx,dx
lines:
mov byte[ds:bx+320*45-1],dh  ;top
mov byte[ds:bx+320*153-1],dh ;bottom
mov di,bx ;well, saves 2b compared to shld di,bx,16+1
          ;when adding both below
mov byte[ds:bx+di+320*148-1],dl;stripes
dec bx
jnz lines


mov cl,42           ;size of triangle for design

;make brighter bars
mov bx,320*43-1
bar:
add byte[ds:bx],cl
;sub byte[ds:bx],32
dec bx
cmp bx,320*155-1
jne bar

;si = 0 ch = 0
corner1:
mov bx,cx
;si=0
mov word[ds:si+bx-257-320*32],bp ;left lower corner line
corner:
;shld ax,cx,19
imul ax,cx,5 ;-1b
sub ax,bx
mov byte[ds:si+bx-257-320*31],al;al;cl ;left lower corner
mov di,si
neg di
sub di,bx
mov byte[ds:di+320+320*24],ch    ;right upper corner
dec bx
jnz corner
sub si,dx
loop corner1

;copy only a part to the video memory
;to create black bars at top and bottom
;on the fly
mov di,320*25
flip:
mov ax,0b0bah+0505h;b4=180 ; make it a bit interesting
;mov ax,0e0eah;b4=180 ; make it a bit interesting
xchg ax,word[ds:di]  ;grab vscreen
stosw;mov word[es:di],ax  ;drop to screen
cmp di,320*173
jne flip

         in al,60h ;read keyboard
         dec al    ;check it, dammit!
         jnz main  ;nothing so go on
breaker: ;label for testing since i don't use a debugger
;         mov ax,03h            ;keep it clean :)
;         int 10h               ;or sacrifice for 5b
         ret

;-------- data ------------
s_x dw 2048 dup ? ;x
s_y dw 2048 dup ? ;y
s_z dw 2048 dup ? ;z