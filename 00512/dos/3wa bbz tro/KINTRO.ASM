.386
jumps
code segment use16
assume cs:code,ds:code
org 100h
start:

mov ax,13h
int 10h

mov si,offset logo
mov di,offset logo2
push di
mov cx,7
kalap:
push cx
mov cl,3*8
mov dl,1
kalap2:
ror dl,1
jnc nolodsb
lodsb
nolodsb:
test al,dl
push ax
setnz al
push cx
mov cl,10     ;320/40
rep stosb
pop cx
pop ax
loop kalap2
xor al,al
mov cl,320-(10*3*8)
rep stosb
pop cx
loop kalap

mov dx,offset szoveg
mov ah,9
int 21h

push 0a000h
pop ds
xor si,si
mov di,offset logohelye
mov cx,320*5*8
rep movsb
push cs
pop ds

mov cl,63
mov dx,3c8h
mov ax,1
out dx,al
inc dx
;mov al,64
cik1_setpal:
;dec al
mov al,cl
out dx,al
xor al,al
;xchg ah,al
out dx,al
out dx,al
;xchg ah,al
loop cik1_setpal

push 0a000h
pop es

xor di,di
mov al,1
dec cx
rep stosb
inc di
mov ebp,ycorner
mov cx,200
cik1_fractal:
push cx
mov esi,xcorner
mov cx,320
cik2_fractal:
push cx esi ebp
mov iter,0
;
cik3_fractal:
mov eax,esi
imul esi                ; x^2
shrd eax,edx,20
mov ecx,eax             ; ecx = x^2
xchg ebx,eax            ; ebx = x^2
mov eax,ebp
imul ebp
shrd eax,edx,20
add ecx,eax             ; ecx
sub ebx,eax
mov eax,esi
imul ebp
shrd eax,edx,19
add eax,ss:[esp]
mov ebp,eax
add ebx,ss:[esp][4]
mov esi,ebx
inc iter
cmp iter,62
ja vege_fractal
cmp ecx,400000h
jb cik3_fractal
;
vege_fractal:
mov al,iter
stosb
;
pop ebp esi cx
add esi,xgap
loop cik2_fractal
pop cx
add ebp,ygap
loop cik1_fractal

mov cl,7
;mov bp,offset logo2
pop bp
mov di,320*12+8
kalap3:
push cx
mov cl,25
kalap4:
mov si,bp
push cx
mov cx,320
kalap5:
lodsb
or al,al
jz noput
mov al,64
sub al,es:[di]
mov es:[di],al
noput:
inc di
loop kalap5
pop cx
loop kalap4
pop cx
add bp,320
loop kalap3

mov si,offset logohelye
mov di,320*8+ 319-12-8
mov cl,5*8
rot1:
push cx
mov cl,23*8
rot2:
lodsb
or al,al
jz noxor
xor byte ptr es:[di],63
noxor:
add di,320
loop rot2
add si,320-23*8
sub di,320*23*8+1
pop cx
loop rot1

xor ax,ax
int 16h
mov ax,3h
int 10h

mov dx,offset vege
mov ah,9
int 21h

retn

logo:
include logo.inc

include text.inc

iter db ?
xcorner = -00a000h
ycorner = -0dc000h
xsize =    018000h
ysize =    010000h
xgap = xsize / 320
ygap = ysize / 200

logohelye db 320*5*8 dup (?)

logo2:

code ends
end start