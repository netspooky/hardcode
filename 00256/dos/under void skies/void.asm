;under void skies // reality cold spot
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: we are ghosts - secret transmissions

;(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((

;I could not find any sleep in that night. I just stared into the
;darkness for far too long before I decided to take a walk. I
;thought the clean air of that quiet night might help me to fall
;asleep. I was tired - very tired - but somehow my body did not
;want to rest. Maybe my subconscious mind knew about what I was
;going to see ...

;I walked, took a turn, followed this street and another alley
;and finally reached that little hill where I can look at the
;skyline of the city. In this night the sky was foggy and somehow
;illuminated. I thought: Maybe there are 100 moons hiding behind
;the fog. The sky was bright enough to make the shape if the
;skyline visible. I walked to the bench under that giant iron
;umbrella and sat down. I leaned back and took a deep breath.

;I opened my eyes and looked to the skyscrapers. Suddenly
;the lights in the rooms near the roofs began to flicker as if
;they where influenced by some radiation. In the next second I
;saw strange shapes covering the firmament. Or was the world
;turning upside down with the sky breaking apart?

;Now I'm back in my room. And I don't know how I got here. But I
;know that I had a look  b e h i n d  the construction we call
;reality. I don't feel it. I  k n o w  it. I wonder why. Will
;something happen? Will the great architects come for me to
;correct their fault? And why me?

;Dawn woke up the world. I'm still sitting here. I can hear the
;birds in the trees in front of my apartment. It is a quiet
;morning. No cars in the streets, no people yelling and talking.
;For one moment I thought it was a normal sunday but then I
;realized that it isn't. W h e r e  is everybody? Or where am I?

;)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

;assuming: cx = 255

org 100h
use16

         inc cx ;for 1st run at pal gen; cl = 0

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen
         pop fs
         mov al,13h
         int 10h
reset:
        xor si,si
pal:    mov dx,0x3C9
        mov al,cl;shrd ax,cx,17
        out dx,al ;r
        out dx,al ;g
        xor al,al
        out dx,al ;b

        in al,40h ;init data
        mul ax
        mul si
        mov word[pos+si],ax
        shr ax,14
        inc ax ;no 0
        mov word[speed+si],ax
        inc si
        inc si

        inc cl
        jnz pal


;mov byte[pos],bl ;will be 0 because of mul si beginning at si = 0

main:

mov si,120 ;number of rays

skies:
mov di,word[pos+si]
mov ax,word[speed+si]
sub di,ax              ;move

imul dx,ax,321         ;calculate how many steps down
add di,dx              ;move down
mov word[pos+si],di    ;save new pos

mov ax,di                ;save start pos
imul cx,word[speed+si],5 ;width
void2:
mov di,ax                ;saved pos is base
add di,cx                ;width
mov bx,bp                ;add global movement

cmp byte[pos],127        ;2nd scene?
jb nothing3              ;no
mov bx,cx                ;yes!
nothing3:

;mov ax,si                ;get length
;shl ax,1                 ;double
shld dx,si,17             ;same size but less instruction
void:
add byte[fs:di+bx],8
and byte[fs:di+bx],dl
add bx,320;321               ;move

cmp byte[pos],127        ;2nd scene?
jb nothing2
sub bx,640 ;bx = 320
nothing2:

dec dx                   ;counting length
jnz void
loop void2                ;do whole width

dec si
dec si
jnz skies


;taken from of mysteries & fireflies and changed; lazy lazy lazy

;dx = 0 here;xor dx,dx              ;needs to be same every run to make same result
;si = 0 here           ;si = left upper corner of building
frame:
add dx,si              ;change height of building
cmp dx,98
ja frame               ;too high ---> so again

mov cx,40              ;width of the buildings
skyline:
imul bx,dx,320         ;create height of building
houses:
mov di,320*204         ;base
sub di,si              ;next building
sub di,cx
sub di,bx

cmp byte[pos],127         ;2nd scene?
jb nothing                ;nope
neg di                    ;yes so put buildings on top
nothing:

mov word[fs:di],0000h     ;window : space between windows
mov word[fs:di-320],0000h ;space between floors/level of building
add ax,bx                 ;change ax
mul cl                    ;for pseudo random ---> don't destroy dx!
cmp al,80
ja okay                   ;no light in window
mov byte[fs:di],al        ;light the window up!
okay:
sub bx,320*2              ;move up
jnc houses                ;whole building drawn?
in al,40h                 ;random for window color if light in on
mul al                    ;less "pattern"
dec cx                    ;cx has to be decreased by 2 each loop
loop skyline

add si,20                 ;next set of buildings (16)
cmp si,320*2              ;*2 makes buildings looking better
jne frame                 ;and more looking like a skyline


sub bp,321*3              ;change global movement of sky (963)
jnc nothing4
add byte[pos],30          ;change scene helper every 68 frames (ffff/963)
jc reset                  ;change random sky after hitting 256/0 border
nothing4:

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
;cx = 0 here
xor di,di ;di = 320*2 ... so who cares
flip:
xor al,al
xchg al,byte[fs:di] ;grab vscreen
stosb               ;drop it including inc di
cmp di,cx
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

pos dw 1000 dup ?
speed dw 1000 dup ?