;amber // reflections from the past
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: frei.wild - ich bleib daheim

org 100h
use16

start:   push 0a000h ;les bp,[bx] but keep it clean here
         pop es      
         push 09000h
         pop fs      ;vscreen
         push 08000h
         pop ds      ;vscreen2
         mov al,13h
         int 10h

;vars used:
;bp    = amplitude
;bp+2  = degrees
;bp+6  = new coordinate after sin*bp
;bp+10 = for calc sinus
;bp+12 = counter for change in movement
;cx    = for movement

        mov dx,0x3C9
        inc cx ;cl=0 ch=1
pal2:   mov ax,cx
        shr al,2
        out dx,al ;r
        shr al,1
        out dx,al ;g
        shr al,2
        out dx,al ;b
        loop pal2

;still smaller than using variables (bytes saved at usage)
mov word[bp+12],2800 ;init changer
mov word[bp+10],57 ;pi*grad/180 = grad/57 (180/3.14... = 57,...)

; :D
; inspired by "pixel town" by digimind (2oo7)
mov di,256
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
neg di
inc byte[es:di+48000-33];sub word[es:di+48000-33],di
neg di
dec di
jnz loader

main:

;### start ### shameless re-use from my intro "when the clouds [rise from the sea]"
;for some dynamic background

;add di,dx        ;not needed
mov byte[ds:di],1 ;needed for dosbox (drop a cloud)

;si = 0 here
grid:
mov di,si          ;set position of pixel on vscreen2

xor bx,bx
add bl,byte[ds:si] ;don't work with black
jz drop

;create "grid" with rules on the fly
gate0:
sub ax,si  ;don't stay 0
add dx,ax  ;don't stay 0
mul dx
shr al,5   ;256/32

jnz gate1
add di,320 ;move down
gate1:
cmp al,1   ;move left
jne gate2
dec di
gate2:
cmp al,2   ;move right
jne gate3
inc di
gate3:
cmp al,3   ;move up
jne gate4
sub di,320
gate4:

inc bx              ;rise color for shades
stay:
mov byte[ds:di],bl  ;set new pixel

drop:
dec si
jnz grid            ;work with full screen
;### end ### shameless re-use from my intro "when the clouds [rise from the sea]"


mov word[bp],-100 ;amplitude
loop1:

;degrees/bp+2     = y
;amplitude/bp     = x

imul di,word[bp+2],320 ;grab texture (0..180/degrees) from vscreen2
add di,word[bp]        ;set column

cmp word[bp+12],1400   ;change to second scene?
ja nomove
add di,cx              ;add movement

nomove:
mov al,byte[ds:di]     ;get pixel
sub di,word[bp]        ;restore original di; still smaller than new calulation

fild word[bp+2]         ;pi
fidiv word[bp+10]       ;pi*grad
fsin
fimul word[bp]          ;sin*x
fistp word[bp+6]        ;save new x + push ---> no finit

;calc pos
;imul di,word[grad],320
add di,word[bp+6]             ;correct di comes from above

mov byte[fs:di+160+320*10],al ;vscreen
sub di,cx                     ;make things move
neg al                        ;proved color adjustment
shr di,1                      ;shrink
mov byte[ds:di],al            ;1st half on texture = reflection
mov byte[ds:di+65535/2],al    ;2nd half on texture = reflection

dec word[bp+2]                ;change degrees
jnz loop1
mov word[bp+2],179

inc word[bp]                  ;change amplitude
cmp word[bp],100
jne loop1

add cx,321                    ;for movement

dec word[bp+12]               ;changer
jnz weiter
mov word[bp+12],2800
weiter:

;add black bars for the purposes of design
mov si,320*26+256
flip2:
mov byte[fs:si-320*16+63],0
dec si
jnz flip2

;flip
;si = 0 here
flip:
mov al,byte[ds:si]   ;tricky ;)
xchg al,byte[fs:si]  ;
mov byte[es:si],al   ;drop to screen
inc si
jnz flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret