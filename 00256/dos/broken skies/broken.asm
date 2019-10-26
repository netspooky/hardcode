;broken skies [at the sea]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: mesu kasumai - highway signs

;first there was the 1st scene made down to 128b.
;while  working on that i played around and  came
;to the 2nd scene that i made to 127b. but then i
;had the problem to decide which intro to release
;and which to use as bonus. and then i thought it
;won't be the worst idea to combine them into one
;256b intro. this way i did not had to decide.  i
;had a lot of bytes left so i added some elements
;of  design  without trying to optimize. it might
;look rough but i did not want to change my first
;result. some mood stuff. anyway, the poems below
;belong to the two scenes.

;# # # # # # # # # # # # # # # # : : : S U N
;there was this moment
;when the sky was so blue
;peace within the shadows of the apple trees
;and in the grass on that wonderful day
;# # # # # # # # # # # # # # # # # # # # # #

;# # # # # # # # # # # : : : R A I N
;we've never been there
;listening to the storm and the sea
;but maybe one day
;we'll feel rain on our skin
;# # # # # # # # # # # # # # # # # #

org 0100h

start: push 09000h
       pop gs
       push 08000h
       pop ds
       push 0a000h
       pop es
       mov al,13h
       int 10h

;a thing between introduction and fake progress bar
;inspired by "pixel town" by digimind (2oo7)
;code copied from my intro "amber"
xor si,si
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
mov byte[es:si+320*12],80
neg si
mov byte[es:si+320*188-1],80
neg si
inc si
cmp si,321
jne loader

       mov bx,0100h ;init changer
start2:
       mov cx,bx    ;make cl correct every run

        mov dx,0x3C9
;        inc cx ;cl=0 ch=1
pal2:   shrd ax,cx,17
        out dx,al ;r
        out dx,al ;g
        cmp bh,1
        jne out1
        mov al,63 ;SUN
        out1:
        out dx,al ;b
        loop pal2

main:

rnd:     cmp si,64000        ;random area
         jb f_loop
         in al,40h
         mul al
         mov byte[ds:si], al

f_loop:  mov al,byte[ds:si]
         adc al,byte[ds:si+1]
         adc ah,0
         adc al,byte[ds:si-320]
         adc ah,0
         adc al,byte[ds:si-1]
         adc ah,0
         shr ax,2
         jz f01
         dec ax
f01:
         cmp bh,1
         jne out5
         mov byte[ds:si+320],al ;SUN
         jmp out6
         out5:
         mov byte[ds:si+322],al ;RAIN
         out6:
         dec si
         jnz rnd

;create map out of texture
;si = 0 here
;cx = 0 here
weiter:
;add cl,byte[ds:si] ;somehow there can be artefacts at the beginning at bottom
mov cl,byte[ds:si] ;get height without causing artefacts (?)
inc cl
jz breaker         ;get rid of trouble (?)

mov al,cl          ;save color
mov di,si          ;same pos

weiter2:
cmp bh,1
jne out3
mov byte[gs:di+320*76],al  ;SUN ;set including adjust on screen
sub di,320
jmp short out4

out3:
mov byte[gs:di+320*100],al  ;RAIN
add di,319                  ;RAIN

out4:
loop weiter2              ;worked full height (value of color)?

breaker:
inc si
cmp si,320*128            ;max scanned area
jna weiter                ;no so again


;design
mov si,320*12-1
bars:
mov byte[gs:si],bh ;)
dec si
cmp si,320*187-1
jne bars

mov si,320
line:
mov byte[gs:si+320*12-1],40
mov byte[gs:si+320*187-1],40
dec si
jnz line
;end

;flip
;si = 0 here
flip:
xor ax,ax
xchg al,byte [gs:si]  ;clear+copy
mov byte [es:si],al   ;drop to screen
inc si
jnz flip

;changer including clrscr
;si = 0 here
inc bl
jnz out2
neg bh
clear:
mov byte [es:si],cl   ;clear screen directly
inc si                ;to avoid scenes in wrong color on first run
jnz clear
jmp start2            ;change palette!
out2:


         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret