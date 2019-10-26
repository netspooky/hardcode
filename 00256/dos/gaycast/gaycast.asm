; GAYCAST: a really crappy 256 byte raycaster.
; now with projection!
; Copyright (C) 2002, Justin Frankel/Nullsoft
; public domain
; flies you through the first 64k of memory.
; assemble with nasm
; 256 bytes, though only about 216 if you take out all the padding

   
[org 100h]
[segment .text]

mov ax, 13h
int 10h

sub ax,ax ; not necessary, padding
mov dx, 03C8h
out dx, al ; not necessary, padding
inc dx
mov cx, 4
GPALLOOP:
  sub ax,ax
  sub bx,bx
  PALLOOP:
    inc ah
    mov ch, 3
    IPALLOOP:
      mov al,bl
      test cl, ah
      jz PALTEST
        sub al,al
      PALTEST:
      add ah, ah
      out dx, al
      dec ch
      jnz IPALLOOP
    inc bx
    cmp bl, 64
    jne PALLOOP
  loop GPALLOOP

fldz
fldz

FRAMELOOP:
  mov dx, SCREEN_W
  ; clear framebuffer
  push ds
  pop es
  mov cx, SCREEN_W*SCREEN_H/2
  sub ax, ax
  mov di, FBUF
  push cx ; save cx and di for copy, later
  push di
  rep stosw

  mov es, ax ; ax=0

  ; begin frame
  fadd dword [ADJ_VA]
  fld st0
  fld1
  mov bp, dx ; set bp to SCREEN_W
  faddp st3

  XLOOP:
    fadd dword [ADJ_VA]
    fld st0
    fsincos
    mov si, TEMP
    mov cx, 32*63
    fld st4
    fld st5
    CASTING:
      fadd st3
      fist dword [si]
      fxch

      fadd st2
      mov bx, [si]

      fist dword [si]

      fxch

      mov bl, [si+1]

      mov al, [es:bx]
      test al, 8
      jnz ENDCAST

      dec cx
      jnz CASTING
    ENDCAST:
    fstp st0
    neg cx
    fstp st0
    add cx, 32*63+16
    fstp st0
    mov word [si], cx
    fstp st0
    fld dword [SCALE]
    fild word [si]
    fdivp st1, st0
    lea di, [bp+FBUF+SCREEN_W*SCREEN_H/2-1] ; end of middle line
    and al, 0C0h

    fistp word [si]
    mov cx, [si]

    mov si,di

    cmp cx, 64
    jl CLIPHEIGHT
      mov cx, 63
    CLIPHEIGHT:

    or al, cl
    YLOOP:
      mov [si], al
      mov [di], al
      add si, dx
      sub di, dx
    loop YLOOP

    dec bp
    jnz XLOOP

  fstp st0

  ; vsync (thanks to rOn for reminding me this)
  ; not really necessary, but we had room

  mov dx, 3DAh
  VSync:
   in al, dx
   and al, 8
   jnz VSync

  ; copy framebuffer to screen
  pop si
  pop cx

  push word 0A000h
  pop es

  xor di, di
  rep movsw

  mov ah, 1
  int 16h
  jz near FRAMELOOP

mov ax, 3
int 10h

; padding
mov ah, 9
mov dx, MSG
int 21h

ret

; padding
MSG DB 'GAYCAST by Nullsoft.$'

; integer constants
SCREEN_W EQU 320
SCREEN_H EQU 200

; floating point constants 
ADJ_VA DD 0.003
SCALE DD 15000.0

; uninitialized data
TEMP ; 4 bytes of temporary space
FBUF EQU TEMP+4 ; framebuffer

