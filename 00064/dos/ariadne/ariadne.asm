; "striped" maze in 63 bytes.
; Remove this part:
;   test cl, 40h
;   jnz next
; to generate full-width maze (with shitty looking artifacts).
; 
; Inspired by 'laby' by Ange Albertini: http://pouet.net/prod.php?which=61163
; 
; pk
; twitter.com/pa_kt
; gdtr.wordpress.com

bits 16

org 100h

MODE_320_200 equ 13h
INT_VIDEO equ 10h

VIDEOBUFFER equ 0A000h

BLACK equ 0
WHITE equ 15

TAPS  equ 0b400h

start:
; graphical mode initialization
  mov al, MODE_320_200
  int INT_VIDEO
  or al, 0ch  ;al=0fh

; point segments to video buffer
  push VIDEOBUFFER
  pop es
  push es
  pop ds
  
  ;mov dx, SEED
  ;xor di, di
  mov ebp, 2800002h
  ;call dfs
  ;ret

dfs:
  rol ebp, 16
; lfsr from wiki
rnd:
  shr dx, 1
  jnc no_xor
  xor dx, TAPS
  neg bp
no_xor:
; lfsr end
  
  mov bx, bp
check:
  cmp byte [di+bx], ah
  jnz next
  lea cx, [di+bx]
  test cl, 40h
  jnz next

connect:
  push di
  mov byte [di+bx], al
  sar bx, 1 
  mov byte [di+bx], al
  add di, bp
  call dfs
  pop di
next:
  dec dl
  jnz dfs
  ret

