;╔═════════════════════════════════════╗
;║   Spinception - by HellMood^DESiRE  ║
;║         256b intro - MsDos          ║
;║      released @ Function 2016       ║
;╠═════════════════════════════════════╣
;║  needs a FAST computer / real DOS   ║
;║      uses VESA Mode 800 x 600       ║
;╠═════════════════════════════════════╣
;║         :: greets go to ::          ║
;║     rrrola,Sensenstahl,p01,Elias    ║
;║  frag,Optimus,Trixter,igor,Kuemmel  ║
;║  VileR,Whizart,g0blinish,Rudi,ryg   ║
;║        Orby,homecoded,wysiwtf       ║
;║          all DESiRE members         ║
;╠═════════════════════════════════════╣
;║     https://youtu.be/pVfsIUZNf6A    ║
;║         http://goo.gl/N3WmC6        ║
;╚═══════════════════════════╦═════════╣
org 100h                    ;║         ║
%define w 800               ;║    ■    ║
%define h 409               ;║         ║
mov ax,0x4F02               ;╠═════════╣
mov bx,0x103                ;║         ║
int 0x10                    ;║    ■    ║
X:mov cx,255                ;║         ║
mov dx,0x3c9                ;╠═════════╣
xor al,al                   ;║         ║
out dx,al                   ;║    ■    ║
out dx,al                   ;║         ║
out dx,al                   ;╠═════════╣
P:imul ax,[bp+si], byte 3   ;║         ║
call d                      ;║    ■    ║
imul ax,[bp+si], byte 11    ;║         ║
call d                      ;╠═════════╣
imul ax,[bp+si], byte 5     ;║         ║
call d                      ;║    ■    ║
loop P                      ;║         ║
fild word [bp+si]           ;╠═════════╣
fidiv word [X]              ;║         ║
fsin                        ;║    ■    ║
fsincos                     ;║         ║
mov dx,h-1                  ;╠═════════╣
T:mov cx,w-1                ;║         ║
L:xor bx,bx                 ;║    ■    ║
push dx                     ;║         ║
mov ax,w                    ;╠═════════╣
mul dx                      ;║         ║
add ax,cx                   ;║    ■    ║
adc dl,4                    ;║         ║
shl dx,12                   ;╠═════════╣
mov es,dx                   ;║         ║
xchg di,ax                  ;║    ■    ║
pop dx                      ;║         ║
pusha                       ;╠═════════╣
sub dx,h/2                  ;║         ║
sub cx,w/2                  ;║    ■    ║
pusha                       ;║         ║
fld st1                     ;╠═════════╣
fld st1                     ;║         ║
fld st1                     ;║    ■    ║
fld st1                     ;║         ║
fimul word [bx-24]          ;╠═════════╣
fxch                        ;║         ║
fimul word [bx-22]          ;║    ■    ║
faddp                       ;║         ║
fistp word [bx-20]          ;╠═════════╣
fimul word [bx-22]          ;║         ║
fxch                        ;║    ■    ║
fimul word [bx-24]          ;║         ║
fsubrp                      ;╠═════════╣
fistp word [bx-24]          ;║         ║
popa                        ;║    ■    ║
xchg cx,ax                  ;║         ║
add dx,h/2                  ;╠═════════╣
add cx,w/2                  ;║         ║
mov ax,w                    ;║    ■    ║
mul dx                      ;║         ║
xchg dx,ax                  ;╠═════════╣
aam 5                       ;║         ║
xchg dx,ax                  ;║    ■    ║
add ax,cx                   ;║         ║
add dl,4                    ;╠═════════╣
shl dx,12                   ;║         ║
mov gs,dx                   ;║    ■    ║
xchg si,ax                  ;║         ║
gs lodsb                    ;╠═════════╣
add al,[es:di]              ;║         ║
rcr al,1                    ;║    ■    ║
inc ax                      ;║         ║
stosb                       ;╠═════════╣
popa                        ;║         ║
dec cx                      ;║    ■    ║
jns L                       ;║         ║
dec dx                      ;╠═════════╣
jns T                       ;║         ║
inc cx                      ;║    ■    ║
mov dx,0x3DA                ;║         ║
v:in al,dx                  ;╠═════════╣
and al,8                    ;║         ║
jz v                        ;║    ■    ║
mov dx,1                    ;║         ║
push 0xa004                 ;╠═════════╣
pop es                      ;║         ║
mov ch,0x40                 ;║    ■    ║
M:mov gs,cx                 ;║         ║
mov ax,0x4F05               ;╠═════════╣
int 0x10                    ;║         ║
xor si,si                   ;║    ■    ║
xor di,di                   ;║         ║
m:gs movsw                  ;╠═════════╣
test di,di                  ;║         ║
jnz m                       ;║    ■    ║
add ch,0x10                 ;║         ║
inc dx                      ;╠═════════╣
cmp dl,6                    ;║         ║
jnz M                       ;║    ■    ║
fcompp                      ;║         ║
inc word [bp+si]            ;╠═════════╣
in al,0x60                  ;║         ║
dec al                      ;║    ■    ║
jnz X                       ;║         ║
int 0x10                    ;╠═════════╣
int 0x20                    ;║         ║
d:shr ax,4                  ;║    ■    ║
mov [bx],cx                 ;║         ║
add [bx],ax                 ;╠═════════╣
fild word [bx]              ;║         ║
fdiv dword [c-2]            ;║    ■    ║
fsin                        ;║         ║
fimul word [C]              ;╠═════════╣
fistp word [bx]             ;║         ║
mov ax,[bx]                 ;║    ■    ║
add al,31                   ;║         ║
out dx,al                   ;╠═════════╣
ret                         ;║         ║
c:dw 0x4223                 ;║    ■    ║
C:dw 20                     ;║         ║
;╔═══════╦═════════╦═════════╬═════════╣
;║       ║         ║         ║         ║
;║   ■   ║    ■    ║    ■    ║    ■    ║
;║       ║         ║         ║         ║
;╚═══════╩═════════╩═════════╩═════════╝