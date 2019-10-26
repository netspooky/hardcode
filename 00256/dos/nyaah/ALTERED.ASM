; some piece of crap by zoon.
; no i don't actually code like this.. it's just something i decided to do
; because i love you all so much.

; if you can actually be bothered to unravel all the stupid equs there
; then you have to figure out what it's actually doing.
; if you can do that, then you'll realise that it's unbelievably simple
; and therefore doesn't deserve to win.

; i don't want try to figure out an actual name for this effect, because
; it'd sound stupid.

; this really looks better with a blur filter over it..
; but i can't be bothered fitting one in here.. cause i've only got 5 bytes
; left and i'm completely sick of looking at it :)

; for anyone who doesn't read the next 40 or so lines, yes this DOES
; assemble properly... :)
;
; [PS. I took the the liberty to make the source a bit more understandable.]
; /Insomniac
code	SEGMENT
	ASSUME	cs:code, ds:code
	.386
	LOCALS

ORG	100h

start:	mov	al,13h
 int	10h

  push 6000h
  pop fs

  mov	di, offset trig
GenTrig:
  fldpi
  fimul [temp1]
  fidiv [degs]
  fsin
  fimul [temp2]
  fistp word ptr [di]
  cmpsw
  dec [temp1]
  jnz GenTrig

  mov dx, 3c8h
  xchg ax, bx
  out dx, al
  inc dx
  mov cl, 64
blah:
  xor al, al
  out dx, al
  mov al, cl
  neg al
  out dx, al
  or al, 8
  out dx, al
  loop blah

mainloop:

  push 0a000h
  pop es

  mov di, offset heightfield
  push cx
  mov si, 75
yloop:

  push dx
  mov bp, 160
xloop:

  movzx bx, dh
  add bx, bx
  mov al, [trig+bx]

  movzx bx, dl
  add bx, bx
  add al, [trig+bx]

  movzx bx, cl
  add bx, bx
  add al, [trig+bx]

  movzx bx, ch
  add bx, bx
  add al, [trig+bx]
  mov ds:[di], al
  inc di

  add dx, 0201h
  dec bp
  jnz xloop

  pop dx
  add cx, 0203h
  dec si
  jnz yloop
  pop cx

  add cx, 0FF02h
  add dx, 0FE01h

  push cx
  push dx

  mov si, offset heightfield
  mov di, 75
yloop2:

  mov bp, 320
xloop2:
  xor ax, ax
  lodsb
  shr ax, 2
  mov bx, di
  neg bx
  add bx, 180
  sub bx, ax
  mov cx, 4
  add bx, cx
  imul bx, 320
  add bx, bp
;  add bx, bp
  sub bx, 2
  mov ah, al
vll:
  mov fs:[bx], ax

  sub bx, 320
  loop vll

  dec bp
  dec bp
  jnz xloop2

  dec di
  jnz yloop2

; waitvr
  mov dx, 3dah
l2:
  in al, dx
  and al, 8
  jz l2

; blit
  push fs
  pop ds
  xor di, di
  xor si, si
  mov cx, 32000
  rep movsw

; clear
 push fs
 pop es
 xor di, di
 xor ax, ax
 mov cx, 32000
 rep stosw

  pop dx
  pop cx

  push cs
  pop ds

  in al, 60h
  cmp al, 1
  jnz mainloop

  mov ax, 3
  int 10h
  ret

temp1 dw 512
temp2 dw 30
degs dw 64

trig db 1024 dup (?)
heightfield db 160*100 dup (?)

code	ENDS
	END	Start