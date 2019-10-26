;revenge [of the iron fist] first version
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

org 100h
use16

start:   push 0a000h
         pop ds
         mov al,13h
         int 10h

;it is a procedural gfx :D
xor di,di
loader:
mov dx, 3dah ;wait for vsync for constant speed
vsync1:
in al,dx
test al,8
jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

mov bl,15
mov byte[ds:di+320*80],bl
mov byte[ds:di+320*81],bl
mov byte[ds:di+320*82],bl
mov byte[ds:di+320*83],bl
mov byte[ds:di+320*84],bl
mov byte[ds:di+320*85],bl
mov byte[ds:di+320*86],bl
mov byte[ds:di+320*87],bl

inc di
cmp di,320
jne loader

mov bx,320*180
cls:
mov byte[ds:bx+320*10-1],15
dec bx
jnz cls

mov ax,090ch
mov bx,320*199
lines1:
mov dword[ds:bx+318],0
mov dword[ds:bx+140],0
mov word[ds:bx+260],0
sub bx,320
jnz lines1

mov bl,140
lines2:
mov byte[ds:bx+320*70],ch
mov byte[ds:bx+320*71],ch
mov byte[ds:bx+320*72],ch
mov byte[ds:bx+320*60],ch
mov word[ds:320*59+20],ax

mov byte[ds:bx+320*150],ch
mov byte[ds:bx+320*151],ch
mov byte[ds:bx+320*152],ch
mov byte[ds:bx+320*121],ch
mov word[ds:320*120+70],ax
mov byte[ds:320*120+120],ch

mov byte[ds:bx+320*172],ch

mov word[ds:320*171+130],0c00h
mov byte[ds:320*173+95],ah
dec bx
jnz lines2

mov bl,121
lines3:
mov byte[ds:bx+320*40+140],ch
mov byte[ds:bx+320*41+140],ch

mov byte[ds:bx+320*32+140],ch
mov byte[ds:320*31+240],ah

mov byte[ds:bx+320*113+140],ch
mov byte[ds:bx+320*114+140],ch

mov byte[ds:bx+320*95+140],ch
mov byte[ds:320*94+200],ah
mov byte[ds:320*94+202],ch
mov byte[ds:320*94+212],al

mov byte[ds:bx+320*175+140],ch
mov byte[ds:320*174+204],ah
mov byte[ds:320*176+202],ch
mov byte[ds:320*174+209],al

dec bx
jnz lines3

mov bl,60
lines4:
mov byte[ds:bx+320*160+260],0
mov word[ds:320*159+305],ax

dec bx
jnz lines4

main:

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;key pressed so exit

         mov ax,03h            ;keep it clean :)
         int 10h
         ret