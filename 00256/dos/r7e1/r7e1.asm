;r:7e1 // revision 2o17 invitro
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: dimaa - one more time

;i was not sure if i should let this become an invitro. is it early? yes.
;but time flies! so i thought sticking to the idea is a good plan.
;well, here is the result; an early-bird-tro so to speak.

;this intro uses advanced shameless reuse
;of many parts of my intro "scrollingham palace" since the basic idea
;did not change. and i did not come up with a better solution. but is has
;colors. like easter eggs.

;this one was inspired by the fabulous 64k "frameskool" by equinox (2oo7).
;obviously. if you haven't seen it - check it out :)

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

         push 08000h     ;vscreen + greets to hellmood^DESIRE
         pop ds

;assuming: bx = 0 ch = 0 cl = 255

;make the printed string disappear
;0a000h:0000h ... 0a000h:0ffffh is always 0 after setting videomode
;so only the string won't be 0 (7 under xp, 15 under dosbox)
mov si,320*10 ;area to be checked + amout of data flooding to the stack
cls:
sbb word[bp+si],si ;create "random" initial values (dosbox needs them)
cmp byte[es:si],ch ;found pixel of the string?
je noblacken       ;nope, go on
mov byte[es:si],cl ;blacken letters so no one sees them :>
noblacken:
dec si
jnz cls

;letter grabbing engine. the letters are made on the fly by using the
;previously hidden string.

;letters 8 pixels high, 7 pixels wide + 1 pixel space in between = 8x8
; 01234567
;0 xxxx
;1  xx
;2  xx
;3  xx
;4  xx
;5  xx
;6  xx
;7 xxxx

;1. check for a pixel
;2. get it's coordinates
;3. rotate around y (center)
;4. draw
;5. go to 1 until all pixels of the string done
;6. profit

main:

;cx = number(s) of letter(s)
;cx = always 0 here after 1st run
;xor cx,cx
grabbement1:
xor bx,bx ;height
grabbement3:
xor dx,dx ;width
grabbement2:
;shld si,cx,16+3 ;1b bigger than following imul
imul si,cx,8    ;basic index on the screen (0:0 on each letter)
                ;based on number of letter (left upper corner)

imul di,bx,320        ;row on screen (0 .. 7)
add di,dx             ;add column on screen (0 .. 7)
add di,si             ;add basic index to jump to correct letter
cmp byte[es:di],ch;16 ;normal 7 under xp, 15 under dosbox
je skip               ;no pixel of a letter found ---> next one

;visible:           ;enable to see the grabbed string
;in al,40h          ;enable to see the grabbed string
;inc al             ;enable to see the grabbed string
;jz visible         ;enable to see the grabbed string
;mov byte[es:di],al ;enable to see the grabbed string

deep:
mov word[bp],dx ;x
;sub word[bp],3 ;center; no center means movement to the sides a.k.a. swing emulation :)
;fninit ;what?
fild word[bp+si];degrees
fidiv word[cs:103];fine enough instead of 57/2
fsincos
fimul word[bp]
fistp word[bp+2]
mov word[bp],cx
fimul word[bp]    ;cos from above * constant value
fistp word[bp+4]  ;to create constant cos

;calculate y pos on screen for each letter
imul ax,cx,2       ; :)
add ax,bx          ;add y value (letter)

imul di,ax,320    ;make y for the letter
add di,word[bp+2] ;add rotated x
add di,si         ;add base (#letter*8)

;add di,320*64+82  ;adjust pos on the screen

imul ax,word[bp+4],320 ;add y movement for bungee effect
add ax,320*68+82  ;adjust pos on the screen
                  ;using ax saves 1b
add di,ax
;sbb di,word[bp+4]     ;add x movement

mov ax,cx                  ;every letter has its own color
add al,47                  ;colour me beautiful
mov byte[ds:di],al         ;letter
mov byte[ds:di+320*2+3],ah ;fancy shadow

cmp dx,3                   ;bungee rope in about the middle
jne skip
stringie:
cmp byte[ds:di],al         ;letter?
je neiiin                  ;yes, so don't draw over it dammit!
mov byte[ds:di],101        ;the bungee rope
neiiin:
;mov byte[ds:di+320*2+3],ch; looks better without shadow
sub di,320                 ;move op
jnc stringie               ;till you drop

skip:
inc dx
cmp dx,8                   ;0..7
jne grabbement2            ;width

inc bx
cmp bx,dx;8                   ;0..7
jne grabbement3            ;height

dec word[bp+si]            ;change rotation for every letter

imul di,word[bp+4],321    ;make some advanced flying dust particles
add di,word[bp+si]        ;so shiny
mov byte[ds:di],67        ;in the light

;bx = 0 here
;god rays for the visual side
imul di,word[bp+4],2;reuse x
liny:
sub word[ds:di+bx+320*34-50],0101h ;plus one is fat
add bx,321                   ;move
jnc liny                     ;till you can't move anymore

inc cx
cmp cl,maxement
jne grabbement1              ;all letters done?
                             ;loop jump out of range

;brighter bar in the middle of the screen to make it more appealing to the eye
imul di,di,-160 ;-320 = big trick to make ! in string not at the same level as glass
                ;-160 to make di/2 since at rays mul 2 ---> would be error
mov bx,320*83
glass:
mov al,byte[ds:di+bx+641]
dec ax
mov byte[ds:di+bx],al
inc bx
cmp bh,96h;cmp bx,320*120;9600h
jne glass

mov dx, 3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;flip
;cx = 0 here
mov di,320*52
;mov cx,320*100 ; =7d00h
;mov cx,320*80 ; =6400h
;mov cx,320*60 ; =4b00h
mov cx,320*100;64h
flip:
mov al,79
xchg al,byte[ds:di] ;grab vscreen
stosb              ;drop + inc di
loop flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on
breaker:
;         mov ax,03h            ;keep it clean :)
;         int 10h
         ret                  ;use the ret at rotate

;        0        1         2         3         4         5
;        12345678901234567890123456789012345678901234567890
text db ' GOtoREViSI',02h,'n2',03h,'17&pArtY!$'
        ;empty space at beginning to avoid static 1st letter