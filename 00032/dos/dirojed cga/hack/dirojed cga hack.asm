; Dirojed 32b
; 32 byte intro
; original by T$, optimized 52->32 by Rrrola <rrrola@gmail.com>
; Greets to every x86 coder!

; CGA Hack by HellMood <storrryteller@hotmail.com>

org 100h          ; assumes: ah=0 bx=0 cl>0 di=0FFFEh si=0100h

mov  al,04h       ; (2)
int  10h          ; (2)
mov bh,0xb8		  ; (2)	
mov ds,bx		  ; (2)

M:
cmp  [bx],cl      ; (2)
adc  [bx],ah      ; (2) if ([bx] < cl) [bx]++ (first pass increases)
imul bx,byte 0xE5 ; (3) pseudorandom generator: bx = S*bx-1 (works if S%4==1)
mov  cl,[bx]      ; (2) we don't decrease bx yet
add  cl,[bx+di]   ; (2)
add  cl,[bx-81]   ; (3)
add  cl,[bx+si+63]; (3) cl = ([bx+1]+[bx-1]+[bx-320]+[bx+320]) & 0FFh
dec  bx           ; (1)

in   al,60h       ; (2) standard ESC check
dec  ax           ; (1)
jnz  M            ; (2)
ret               ; (1)
