;hic sunt dracones // how the gods carve the world
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: solar fields - in motion

;#######################################

;beyond the edges of the world we know
;hidden in the ancient seas below
;lies the secret of mother natures quest
;and the cause why dreamers never rest

;#######################################

org 100h
use16

start:   push 0a000h
         pop es
         push 09000h
         pop ds
         mov al,13h
         int 10h

        mov dx,0x3C9
        inc cx
pal:    mov ax,cx
        shr al,3
        out dx,al ;r
        out dx,al ;g
        shl al,1
        out dx,al ;b
        inc cl
        jnz pal

main:
cmp di,64000    ;feed invisible area with new data
jna nobase      ;stuff below messes with data
inc byte[ds:di] ;so this is enough for some change
nobase:

mov si,di       ;get current position of pixel to work with

;mov cl,byte[fs:di];grab current pixel
;cmp cl,0          ;don't work with black (natural break)
;je drop

xor cx,cx         ;-1b compared to code above
add cl,byte[ds:di]
jz drop

;check rules on the "grid" + change position
;create "grid" on the fly
;with rules for each pixel to shape the map of the world
add ax,di ;won't stay 0
sub dx,si ;won't stay 0
mul dx
shr al,6  ;256/64 [creates map]

jnz gate1
add si,320 ;move down
gate1:
cmp al,1
jne gate2
dec si     ;move left
gate2:
cmp al,2
jne gate3
inc si     ;move right
gate3:
cmp al,3
jne gate4
sub si,320 ;move up
gate4:

inc cx              ;rise color for shades (0 will be natural break)
mov byte[ds:si],cl  ;set new pixel
drop:

;bars
cmp si,320*180
jae drop2
cmp si,320*19
jb drop2
jmp drop3
drop2:
;inc cl   ;cut off the map
shr cl,1

;flip vscreen to screen on the fly saving some bytes
;mov al,byte [fs:di]
;mov byte [es:di],al ;stosb is somehow sloooow
drop3:
mov byte [es:si],cl  ;putting this above drop: makes only
                     ;flip pixels > 0 = massive speed up.

dec di
jnz main            ;work with full screen


         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main            ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret