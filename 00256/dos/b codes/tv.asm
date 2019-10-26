;tv creature // the noise configurat0r
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: nothing

org 100h
use16

start:   push 09000h
         pop es
         push 08000h
         pop fs
         push 0a000h
         pop gs
         mov al,13h
         int 10h

;mov ah,02h      ;set cursor
;;mov dh,10 ;0ah
;;mov dl,25 ;19h
;mov dx,0a06h
;int	10h

mov ah,09h      ;print string
mov dx,text
int	21h

xor bx,bx ;safety
loading:
in al,40h
sub ah,al
cmp ax,3
ja loading
mov byte[gs:bx+320*15],89

mov byte[tentacle+bx],bh;0 ;init tentacle values
inc bl
jnz loading

cls:
mov byte[fs:bx],31 ;0
dec bx
jnz cls


main:

mov word[hlp],4
mov word[hlp2],0 ;di = 0 here
nextie:
in al,40h
mul ax
add dx,ax
shr dx,11 ;12 ;0...15 ;get number of segment that's going to be changed
          ;use 0 ... 31 for fewer movements = slowdown

imul bp,word[hlp],16
mov si,16 ;number of segments
mov bx,320*90+160 ;origin
draw:
movzx di,byte[tentacle+bp+si] ;get direction
shl di,1 ;word
mov ax,word[dirs+di] ;get value of movement/direction
mov di,ax
mov cx,6+1            ;length of segment
tenta:
mov word[es:bx],6666h  ;draw ;103 =67h
add bx,di           ;move into direction
loop tenta          ;do full length of segment

cmp si,dx
jne ok
in al,40h
mul bp
shr al,5
mov byte[tentacle+bp+si],al

ok:
inc word[hlp2]
dec si
jnz draw

;bx = last pos
mov cl,5+1+1 ;height
;mov word[es:bx],2a2ah ;set pixel 40 = 28h
square:
mov di,5+1+1 ; width
s2:
mov byte[fs:bx+di],16 ;set pixel
dec di
jnz s2

add bx,320 ;move down
loop square

dec word[hlp]
jnz nextie


;di=0

fader:
cmp byte[fs:di],31
jae skipz
inc byte[fs:di]
skipz:
inc di
jnz fader

;slow it down for the cost of 8b
mov dx, 3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2


;di = 0
flip:
mov al,byte[fs:di] ;get background
xchg al,byte[es:di]  ;grab screen + set background
mov byte[gs:di],al  ;drop to screen
inc di
jnz flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on
breaker:
         mov ax,03h            ;keep it clean :)
         int 10h
         ret
;       0  1   2   3

dirs dw 1,-1,-320,320,321,-321,319,-319      
text db 'slowing down tv noise creature',254,254,254,'$'
tentacle db 500 dup ?
hlp dw ?
hlp2 dw ?