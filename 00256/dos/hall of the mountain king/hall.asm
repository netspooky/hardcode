;- Hall of the mountain king ! - a 256 byte intro by Kuemmel & sensenstahl
;assembled with flat assembler 1.71.58
;DOSBox version, sound synced to 50000 cycles and vsync

org 100h
use16

mov al,13h
int 10h                  ;init screen mode and change palette

;---print devildude
mov ah,09h               ;print string to vga
mov dx,devildude         ;ds needs to be unchanged
int 21h                  ;so change afterwards

;---set buffers
push 08000h              ;backbuffer
pop ds
push 07000h              ;backbuffer 2 with devildude
pop fs
push 0a000h
pop es                   ;change now since text is already plotted


;---copy devildude to backbuffer
;bx is zero
devildude_copy:
  mov al,byte[es:bx]            ;grab
  mov byte[fs:bx+320*85+100],al ;set
  inc bx
jnz devildude_copy

;---main looping routine
main_loop:


;---arcade
;di is zero
mov bx,320
arcade_loop:
  mov ax,di          ;init divident with dx=0:ax=di
  mov dx,si
  add al,dl
  xor dx,dx          ;clear dx
  div bx             ;div dx:ax by 319 =>  dx = x | ax = y
  xchg ax,dx         ;ax = x (0..319), dx = y (0...199)
  and al,63          ;63 or 31 and  or to skip the cmp => 62
  sub al,32          ;32 or 16
  jns no_change      ;capture center column error overflow, so we have a range of -31...31
    inc ax
  no_change:
  imul al            ;ax = al*al (0...961)
  shr ax,3           ;2 or 3
  cmp dl,70
  ja nooo            ;or nzero:
    sub al,dl
    add al,70        ;or 78...but so it looks like a lamp or something in the window
  nooo:
  ;and al,11110000b     ;or skip this
  ;shr al,1             ;and this
  ;jz skip

;    shr al,4
;    add al,16

    shr al,4          ;color management
;    neg al
    add al,20

  mov byte[ds:di],al  ;draw
  skip:
  inc di
jnz arcade_loop

copy_dude:
xor dx,dx
  add dl,byte[fs:di]
  jz nope
  mov byte[ds:di],al
  nope:
  inc di
  jnz copy_dude

;---walkway by sensenstahl
mov bx,320*100+64
;mov al,20 ; ^_^
walkway:
mov di,60
dec ax
cmp al,15
jne walkway2
  mov al,19
walkway2:
;test bl,0;2 		;not completely filled for optical reasons
;jnz ok
  mov bp,bx
down:
  mov byte[ds:bp],ah
  mov byte[ds:bp-1],ah ;railin'
  add bp,321
jnc down
ok:
  push bx					;---new: backup by kuemmel
  and bx,1111111111111000b	;---new: stairs :-)
  mov byte[ds:di+bx],al
  pop bx					;---new: restore
  dec di
jnz walkway2
  add bx,322
jnc walkway

;---vsync
mov dx,3dah
vsync:
 in al,dx
 test al,8
jz vsync

;adding some depth
mov di,40
pile:
mov bx,215
pile2:
cmp byte[ds:bx+di],20 ;stairway?
jb nopey              ;yes so don't draw
mov byte[ds:bx+di],ch ;this pile in the background
nopey:
mov byte[ds:bx+di-50],ch ;pile in foreground
add bx,320
jnc pile2
dec di
jnz pile


;---screencopy
;cx is zero

copy_screen_loop:
  mov al,byte[ds:di]
  stosb
loop copy_screen_loop

;---music
mov bp,tune            ;overall shorter as I can use 'ds' overall
mov dx,0x331
mov al,0x3F
out dx,al              ;change to UART mode
dec dx                 ;dec to data address
mov bx,si
test bl,11b            ;trigger sound from counter
jne dont_play
  mov al,10010000b     ;note on
  out dx,al
  shr bx,2             ;take away trigger bits...has to fit to the test bl,...
  and bx,11111b	       ;mask 32 notes
  add bp,bx
  mov al,byte[bp]      ;overall shorter as I can use 'ds' overall
;  cmp al,0            ;need that...playing note '0' causes a low buzz...
;  je dont_play        ;but saving the 4b adds a lot of creepy/mysterious atmosphere :D
  out dx,al
  mov al,01111111b     ;velocity max
  out dx,al
dont_play:

;---timer
;inc si               ;inc global timer for music
dec si                ;inc global timer for music


;---check keyboard
in al,0x60            ;check for ESC
dec ax                ;save 1b instead using dec al
jnz main_loop
ret

devildude   db 148,10,8,8,234,'$'
tune	    db   0,0,72,69,65,69, 72, 74,69,65, 69,67,65,64, 62
      	    db 0,67,63,67,0,68,64,68, 0,69,65,69,67, 65, 64, 62 ;tune
