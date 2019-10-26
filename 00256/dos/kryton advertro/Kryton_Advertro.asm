;
; --------------
; Kryton Advetro
; --------------
;
; by Rbraz ^ Gravity
; April 2006
;
; Fasm 1.65

org 100h

;-------------VGA mode X - 320x200x256k
mov al,13h
int 10h
push 0a000h ; Vga memory
pop es ;

;-------------Load Palette
mov cl,63
mov bl,126
.pal:
mov dx,3c8h
mov al,bl ;[ col ]
dec bl
out dx,al
inc dx
mov al,0 ;[ r ]
out dx,al
mov al,0 ;[ g ]
out dx,al
mov al,cl ;[ b ]
out dx,al
loop .pal

;-------------Write our text
mov ah,02h
mov bh,00h
mov dx,0308h
int 10h
mov ah,9
mov dx,text
int 21h

Main:

;-------------Wait for vertical retrace
mov dx,03DAh
.wait_for_retrace:
in al,dx
test al,8
jz .wait_for_retrace

;-------------Blur Screen
mov di,16000
mov cx,8000
.blur:
mov eax,[es:di]
cmp eax,40404040h
jle .noblur
sub eax,01010101h
.noblur:
stosd
loop .blur

;-------------Sine wave function
fld [angle]
fadd [one]
fst [angle]
fdiv [twopi]
fsin
fmul [mult]
fadd [ center ]
fistp [y]

.draw:

mov ax,word [y] ; ax = y
mov bx,[x] ; bx = x

;-------------WritePixelFast :)
; vgamemory[x + (y*320)] = color ; bx=x, ax=y, cl=color
imul ax,320
add ax,bx
mov di,ax
mov byte [es:di],126 ; color

;-------------Increments x pos
inc [x]
cmp [x],320
je .lp1
jmp .draw
.lp1:
mov [x],0
; mov [angle],0


;-------------Loop (While not key hit)
mov ah,01
int 16h
jz Main

;-------------Return to text mode
mov al,03h
int 10h

;-------------Exit to DOS
mov ax,4c00h
int 21h

;-------------Some variables
angle dd 0.0
one dd 0.25
mult dd 20.0
center dd 100.0
y dd 0.0
x dw 0
twopi dd 6.2830
text db 'Kryton >> Coming up soon!',24h
