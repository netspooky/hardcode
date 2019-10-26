
; JBounce - Jay's 256-byte "game"

IDEAL
P386
MODEL TINY

DATASEG

batw equ 32
bath equ 1   ;height of centre of bat above bottom of screen
oldx dw ?
oldv dw ?
oldvabs dw ?

x dw 160*16  ; } x & y coords of ball, in 16th of pixel resolution
y dw 180*16  ;/

xmax equ 319*16  ; } limits, ie. 0 <= x < xmax & 0 <= y < ymax
ymax equ 199*16  ;/
oldaddr dw ?  ;screen addr of last ball draw

CODESEG
STARTUPCODE

cld  ;probably vital

xor bp,bp  ;acting for vx
mov si,-50  ;acting for vy

mov bh,0A0h  ;assume bl=0 - int 33h init will change this
mov es,bx

;assume ax=0
int 33h
;inc ax
;jnz quit

mov ax,7
xor cx,cx  ;assume cx=0
mov dx,320-batw
int 33h

mov ax,13h
int 10h


lpb:  ;NB this label serves double purpose
mov dx,3DAh
in al,dx
and al,8
jz lpb

mov ax,3  ;mov al?
int 33h
cmp bl,0
jnz quit

mov bx,[oldx]
sub bx,cx
mov [oldv],bx  ;shouldn't affect carry flag
mov [oldvabs],bx
jnc okd

neg bx
mov [oldvabs],bx
neg bx

okd:
mov dx,cx
mov [oldx],dx

call movebat
call moveball

jmp lpb


qquit:
pop ax
quit:
mov ax,02
int 10h
ret


movebat:  ;wipes whole bat region of screen
          ;zaps eax,cx,di
mov di,0FA00h-140h*bath
mov cx,50h
xor eax,eax
rep stosd

drawbat:  ;at x=dx
          ;zaps al,cx,di

mov di,0FA00h-140h*bath
add di,dx
mov cl,batw/2  ;ch=0 from the movebat part
mov al,020h
lpa:
stosb
stosb
inc al
loop lpa
ret


moveball:

add [x],bp
js okg
cmp [x],xmax
jb okh
okg:
  neg bp

okh:
add [y],si
js okf
cmp [y],ymax-16*bath
jb oke
  mov ax,[x]
  shr ax,4
  sub ax,[oldx]
  jc qquit
  cmp ax,batw
  jae qquit
cmp si,16
jb qquit
mov ax,[oldv]
shl ax,2
sub bp,ax
mov ax,[oldvabs]
shl ax,1
add si,ax
mov ax,si
sar ax,4
sub si,ax

okf:
neg si

oke:
inc si

;moveball:  ;from last posn
           ;zaps ax,di
mov di,[oldaddr]
xor ax,ax
stosw
add di,318
stosw

drawball:  ;at [x],[y]
           ;zaps ax,dx,di
mov di,[x]
shr di,4
mov dx,[y]
shr dx,4
shl dx,6
add di,dx
shl dx,2
add di,dx
mov [oldaddr],di
mov ax,0E0Eh
stosw
add di,318
stosw
ret


END

