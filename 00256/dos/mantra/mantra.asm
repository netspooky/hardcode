;mantra
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: peia - blessed we are

;the core of this prod is taken from my intro "scrollingham palace"
;so if you want more comments please check out its source :)

;ESC is connected to the screendata so keep hitting if it won't work - it will work.
;this saved 1b so forgive me :D

org 100h
use16

maxement equ 25 ;max number of letters

start:   push 0a000h     ;vga
         pop es
         mov al,13h
         int 10h

         mov ah,09h      ;print string to vga
         mov dx,text     ;ds needs to be unchanged
         int 21h         ;so change afterwards

         push 08000h     ;vscreen
         pop ds

;assuming: bx = 0 ch = 0 cl = 255

;make the printed string disappear
;0a000h:0000h ... 0a000h:0ffffh is always 0 after setting videomode
;so only the string won't be 0 (7 under xp, 15 under dosbox)
mov si,320*10 ;area to be checked + amout of data flooding to the stack
dump:
mov al,byte[es:si]
mov byte[bp+30+si],al ;save data on the stack in a save area
;mov byte[bp+si],al ;works, leads to flicker at the 2 of 256 at some point for 1 frame
                   ;but saves 1b
dec si
jnz dump ;don't care about pixel at 0:0 since there is none

main:

;cx = number(s) of letter(s)
;ch always 0 here
mov cl,25
grabbement1:
xor bx,bx ;height
grabbement3:
xor dx,dx ;width
grabbement2:
imul si,cx,8    ;basic index on the screen (0:0 on each letter)
                ;based on number of letter (left upper corner)
                ;1b smaller than shld si,cx,16+3
imul di,bx,320        ;row in buffer (0 .. 7)
add di,dx             ;add column in buffer (0 .. 7)
add di,si             ;add basic index to jump to correct letter
cmp byte[bp+30+di-8],ch;16 ;normal 7 under xp, 15 under dosbox
                      ;-8 is adjusting the position of the data
                      ;because of loop ---> 1st letter would be missing
                      ;without adjusting
;cmp byte[bp+di],ch;works
je skip               ;no pixel of a letter found ---> next one

imul di,bx,322*5  ;y + scaling
;imul ax,dx,5      ;x + scaling
;add di,ax         ;add x
;imul ax,si,5      ;base + scaling
;add di,ax         ;add base (#letter*8)

mov ax,dx          ;-1b compared to code above
add ax,si
imul ax,ax,5
add di,ax

pusha             ;save all registers to make them availiable below

imul bx,si,-322   ;create y
add bx,si         ;space between letters
add bx,si         ;space between letters
imul ax,dx,321    ;make it kinda isometric
sub di,ax         ;make it isometric
add di,bx         ;add y value
add di,word[bp+20];add base

;each pixel of the string makes a block of 5x5x16 pixels (isometric)
mov dl,6 ;x ;dh = 0
block1:
mov cl,6 ;y ;ch = 0
block:
imul bx,cx,322 ;create x
add bx,dx      ;add y
mov al,15;16   ;height
block3:
;cmp word[bp+20],0ffffh/2
;ja version2

mov ah,31;32 ;v1 upside down
sub ah,al
;jmp weiter

;version2:
;mov ah,15 ;v2 downside up
;add ah,al

;weiter:
cmp byte[ds:di+bx],ah ;check if there is a pixel
jb skippz             ;it is, so don't make errors while
                      ;rendering high class
mov byte[ds:di+bx],ah ;draw
skippz:
sub bx,319            ;move up
dec al                ;whole height of the block-pixel done?
jnz block3            ;no so keep drawing

loop block            ;work all y

dec dx
jnz block1            ;and work all x

popa                  ;restore all registers

skip:
inc dx
cmp dx,8                   ;0..7
jne grabbement2            ;width

inc bx
cmp bx,dx;8                ;0..7
jne grabbement3            ;height

;inc cx
;cmp cl,maxement
;jne grabbement1              ;all letters done?
                             ;loop jump out of range
loop grabbement1

;make a glass bar
mov di,word[bp] ;moving base
glass:
mov bl,84;95 ;thickness
             ;bh = 0
glass2:
imul si,di,-1 ;bar in background
cmp byte[ds:bx+si],103 ;only draw on background
jne nonono
mov byte[ds:bx+si],78 ;niiiiiice color, maybe the best :)
;dec byte[ds:bx+si]
nonono:

mov al,byte[ds:bx+di]
cmp al,32
jb no_rainbow         ;don't draw on letters
shrd ax,bx,18         ;calculate the rainbow
add al,79;80          ;nice part of standard pal
no_rainbow:
inc ax                ;change color slightly even if no rainbow
                      ;to make the glass
mov byte[ds:bx+di-40-320*3],al
dec bx
jnz glass2            ;all thickness done?
add di,319            ;move down
jnc glass             ;draw the whole glass bar

add word[bp+20],322 ;basic movement
                    ;bp+20 not affected by pusha

inc word[bp]        ;move the glass bar
cmp word[bp],320
jnae ok
mov word[bp],bx ;0
ok:

;put classic black bars on top + bottom
;mov bx,320*20-1
mov bh,19h ;19h = 320*20
bars:
;shrd si,bx,15
;mov byte[ds:si-32+320*3],ch ;0
mov byte[ds:bx],ch ;0
dec bx
cmp bx,320*178-2 ;-2 to set 1 pixel in the lower right corner
jne bars

mov dx,3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;di = 0 .. 319 ---> maybe error at 1st (few) frame(s) on left upper corner
;cx = 0 here
xor di,di ;+2b for safety
flip:
;mov ax,di
;shr ax,13
;add al,97
mov al,103;78;103=67h
xchg al,byte[ds:di] ;grab vscreen
stosb              ;drop + inc di
loop flip

;         in al,60h            ;read keyboard buffer
;         cmp al,1             ;ESC?
;         jne main             ;no, so go on
         in al,60h
         dec ax          ;save 1b
         jnz main
breaker:
;         mov ax,03h            ;keep it clean :)
;         int 10h
         ret                  ;use the ret at rotate

;        0        1         2         3         4         5
;        12345678901234567890123456789012345678901234567890
text db '256B MORE THAN JUST CODE$'