;forgotten cathedral [realm of the water shadows]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: lanterna - b minor

;inspired by the 32b intros by fsqrt (=

;i got stuck around forever at 68b and then at 66b. i did not
;want to skip the "bars" nor the black-cyan-black palette.
;but then i reached 64b. sure, nothing special but i'm happy (=

;########################################
;in this forgotten cathedral i lie
;watching the sun dancing on the water
;while butterflies lovely kissing flowers
;that grow in windows colorful light
;########################################

org 100h
use16

start:   ;push 0a000h
         ;pop es       ;4b

         les bp,[bx]   ;2b

         mov al,13h
         int 10h

;first version of pal gen
;        mov dx,0x3C9
;        inc cx;xor cx,cx
;pal:    shrd ax,cx,17
;        out dx,al ;r
;        out dx,al ;g
;        out dx,al ;b
;        inc cl
;        cmp cl,127
;        jne pal
;pal2:   shrd ax,cx,17
;        out dx,al ;r
;        out dx,al ;g
;        out dx,al ;b
;        dec cl
;        jnz pal2

;second version (saves 7b compared to 1st)
;        mov dx,0x3C9
;        inc cx ;ch = 1
;pal:    xor al,al
;        out dx,al ;r
;        shrd ax,cx,17 ;mov ax,cx ;shr al,1; = same size
;        out dx,al ;g
;        out dx,al ;b
;        add cl,ch
;        jz main
;        cmp cl,127
;        jne pal
;        neg ch ;-1
;        jmp pal

;third version (saves 2b compared to 2nd)
        mov dx,0x3C9
        inc cx ;ch = 1 cl = 0
pal:    xor al,al
        out dx,al ;r
        shrd ax,cx,17 ;mov ax,cx ;shr al,1; = same size
        out dx,al ;g
        out dx,al ;b
        cmp cl,127
        jne okay
        neg ch ;-1
okay:   add cl,ch
        jnz pal

main:
mov bx,320
reset:
mov cx,64000-320*30-1 ;screen - (upper + lower bar) - adjust (at lower bar)

water:
mov di,cx ;make even
mov ax,di ;get (last) value
xor dx,dx ;init for div otherwise error 8(dx:ax / bx)
div bx
or ax,dx  ;make floor of flooded cathedral; remove to have "pipes"
mul dx    ;using si will pimp the visual variation but kills the calm mood )=

add ax,di ;pos

mov al,ah ;new col

add ax,si ;movement

mov byte[es:di+320*15+16],al ;includes adjusting because of les bp,[bx]

loop water ;loop causes 1 missing pixel at left upper corner ... but well ;)

dec si ;mover

jmp main ;2b

;         mov ah,01h            ;read keyboard
;         int 16h               ;read, dammit!
;         jz main               ;nothing so go on 7b

;         mov ax,03h            ;keep it clean :)
;         int 10h               ;5b
;         ret                    ;1b