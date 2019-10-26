;Evoke Jarig by Harekiet

cpu 386
org	0100h

;Setup video mode
or al, 13h
int	10h

;Create a fire palette
mov dx, 3c8h
xor ax, ax
out dx, al
xchg cx, ax
inc dx

setter:

mov al, cl
cmp al, 63
jb skipred
mov al, 63
skipred:
out dx, al

mov al, cl
sub al, 64
ja skipgreen
mov al, 0
skipgreen:
shr al, 2
out dx, al
mov al, 0
skipblue:
out dx,al

inc cl
jnz setter

restart:

pusha

;Draw string
xor bx,bx

textrows:

xor si,si
textchars:

push bx
;get font information
;Font in es:bp
mov ax, 0x1130
mov bh, 3h
int 10h
pop bx

;si+bx * 5

lea edi,[esi + ebx * 4]
add di, bx
movzx ax, byte [cs:name + di]
shl ax, 3
add bp, ax
;es:bp now point to the font data

xor dx,dx
charLines:

mov cl, 8
charPixels:

;Calculate location to plot pixel
imul di, dx, 320 * 3
imul ax, bx, 320 * 32
add di,ax

;Counter on the stack
push cs
pop ds
mov ax, bx
shl ax, 5
add ax,[0xfff6]
mov [bx],ax
fild word [bx]
fmul dword [pimul]
fsin
fimul word [scaler]
fistp word [bx]
add di, [bx]

imul ax,si,32
add di, ax
lea edi,[edi+ecx*4]
add di, 320*60+80
;Calculate the x position

;temporary buffer
push 0x9000
pop ds

mov al, [es:bp]
shl al, cl
jnc skipwrite
salc
movsx eax, al
or [di], eax
or [di+320], eax
or [di+640], eax
skipwrite:

dec cl
jns charPixels

inc bp

inc dx
cmp dl, 8
jb charLines

inc si
cmp si, 5
jb textchars
inc bx
jnp textrows

;Copy the buffer and perform fire effect
;set video segment
push 0xa000
pop es
xor di,di
nextpixel:

movzx ax, byte [di]
stosb
;This increases di
mov bl,[di]
add ax,bx
mov bl,[di-2]
add ax,bx
;mov bl,[di-320]
;add ax,bx
mov bl,[di+319]
add ax,bx
;Make the result and store it
shr al, 2
mov [di-321], al

cmp di, 320* 200
jb nextpixel

;Wait till retrace starts
mov	dx, 03dah
wait_on:
in	al,dx
test al,8
jz	wait_on

popa

;Should go onto the stack in the next loop
inc bx

jmp restart
;Standard keyboard loop
;mov	ah,1			;Check for keypress
;int	16h
;jz restart

;retn	

name:
db 'EVOKE'
db 'JARIG'
db '20-20'

pimul:
dd 0.0314159
scaler:
dw 50
