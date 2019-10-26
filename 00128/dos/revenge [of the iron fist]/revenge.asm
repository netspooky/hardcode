;revenge [of the iron fist]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: grizmatik - my people

;this time no need for many comments :D just a bunch of mov
;and that's it. i wanted to do a story prod and thought:
;why not comic style. so here it is the very simple way.
;and my first procedural graphic ;)

;i thought about a loader bar and some tv noise effect to fill
;it up but that would have been kinda stupid. okay it is
;very simple but who cares. i don't :)

org 100h
use16

start:   push 0a000h
         pop ds
         mov al,13h
         int 10h

;assuming: bx = 0
mov di,320*80 ;make screen
cls:
mov byte[ds:di],15
inc di
cmp di,320*110
jne cls

lines1:
mov word[ds:di+319],bx ;border left+right
mov word[ds:di+45],bx  ;borders in between
mov word[ds:di+44*2],bx
mov word[ds:di+43*3],bx
mov word[ds:di+42*4],bx
mov word[ds:di+41*5],bx
mov word[ds:di+40*6],bx
sub di,320
jnz lines1

mov di,320
lines2:
mov byte[ds:di+320*99],bh ;ground
dec di
jnz lines2

;pink  /girl    0ch
;blue /dude     09h
;black/evil man 00h
mov ax,090ch
mov word[ds:320*98+10],ax

mov word[ds:320*98+62],ax
mov byte[ds:320*98+83],bh

mov word[ds:320*98+122],0c00h
mov byte[ds:320*100+115],ah

mov byte[ds:320*98+165],ah

mov byte[ds:320*98+186],ah
mov byte[ds:320*98+188],bh
mov byte[ds:320*98+196],al

mov byte[ds:320*98+227],ah
mov byte[ds:320*100+224],bh
mov byte[ds:320*98+230],al

mov word[ds:320*98+302],ax

nop ;128
main:

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;key pressed so exit

         mov ax,03h           ;keep it clean :)
         int 10h
         ret        