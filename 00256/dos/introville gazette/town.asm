;introville gazette
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;i wanted to make something using text only. well, here it is ^^

;somehow it reminds me on the skyline of a city. maybe some reporter running around
;chasing new and hot stories for the newspaper: the introville gazette.

;dosbox does not emulate the 8x8 bios font correct. i never was aware of that but i realized
;it while coding on this one. but well, that is part of the game, isn't it?

;important: ESC works! but is is connected to the screen and only works if ah = 0
;           so keep pressing it if you wanna quit or simply keep holding it down

;assuming: ax = bx = 0 / cx = 255

org 100h
use16

start:   push 0a000h     ;vga
         pop es
         mov al,13h
         int 10h

         mov ah,09h      ;print string to vga
         mov dx,text     ;ds needs to be unchanged
         int 21h         ;so change afterwards

         push 08000h
         pop fs

;scan whole vga screen which is 0 after setting video mode
;except the printed string
getdta:
cmp byte[es:bx],ch;0
je fine                ;no pixel of string found
mov byte[es:bx],cl;255 ;hide it but keep it accessable (255 = 0 = black)
fine:
inc bx
jnz getdta

main:

xor bp,bp ;access the right data sets

again:
xor si,si   ;y coordinates to scan string
printdta2:
xor cx,cx   ;x coordinates to scan string
printdta1:
imul di,si,320     ;check hidden string
add di,cx          ;on the fly
cmp byte[es:di],ch ;0
je nope            ;no pixel found

shld di,bp,16+1     ;word access
mov di,word[pos+di] ;grab the pos from data set

mov al,byte[size1+bp]
mul cl
add di,ax           ;x

movzx ax,byte[size2+bp]
mul si              ;makes dx = 0
imul ax,ax,320      ;y

add di,ax           ;this is the upper left pos of sized up pixel/
                    ;rectangle to be drawn
;dx = bx = 0 here
mov dl,byte[size2+bp]        ;y of rectangle
square2:
mov bl,byte[size2+bp]        ;x of rectangle
square1:
mov al,byte[col+bp]          ;grab the color
mov byte[fs:di+bx],al        ;draw
dec bx
jnz square1
add di,320
dec dx
jnz square2

nope:
inc cx
cmp cx,8*4
jne printdta1 ;all x of string done?
inc si
cmp si,8
jna printdta2 ;all y of string done?

inc bp
cmp bp,4
jne again ;all data sets done?

;si = 9 here
dec word[hlp]      ;for movement of strings
cmp word[hlp],si;9
jna ok
mov word[hlp],si;0
ok:

;draw 2 moving lines with strings
imul di,word[hlp],321
movement2:
xor bx,bx
movement1:
cmp byte[es:bx],ch;0
je nope2 ;no pixel found
mov byte[fs:di+bx-80],98
neg di
mov byte[fs:di+bx],ch ;draw the inverted one
neg di
nope2:
inc bx
cmp bh,0ah;bx,320*8
jne movement1
add di,321*10
jnc movement2

;draw some flying strings
inc si ;=10
flies:
;mov bx,320*8;=0a00h
mov bh,0ah;
flies2:
cmp byte[es:bx],ch;0
je nope3            ;no pixel found
mov di,word[start+si];grab pos of element
                     ;simply using the code
                     ;for always the same values
                     ;at start
imul ax,si,320/2    ;pseudo trickery
mov byte[fs:di+bx],ch
nope3:
dec bx
jnz flies2
sub word[start+si],ax;change pos
dec si
dec si
jnz flies            ;all flying strings done?

mov dx, 3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2


mov di,320*30
;mov cx,320*136/2
mov ch,55h ;fuck that little error ;)
           ;it is hidden anyways
flip:
mov ax,4f4eh;mov al,79
xchg ax,word[fs:di];xchg al,byte[ds:di] ;grab vscreen
stosw               ;drop + inc di
loop flip

         in al,60h            ;read keyboard buffer
         dec ax;cmp al,1             ;ESC?
         jnz main;jne main               ;nothing so go on
breaker:
;         mov ax,03h            ;keep it clean :)
;         int 10h
         ret                  ;use the ret at rotate


;        0        1         2         3         4         5
;        12345678901234567890123456789012345678901234567890
text db '0FFh$' ;looks way better than 256B

size1 db 10,        8,       4,         2
size2 db 14,       10,       4,         2
pos   dw 320*69+4+1,320*97-1,320*41+25,320*55+170
col   db 54,        0,      66,         4

hlp dw ?