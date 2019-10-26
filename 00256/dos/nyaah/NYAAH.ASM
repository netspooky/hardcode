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

biteme equ code segment para public 'CODE'
gro equ org
mips equ .386
deny equ assume


biteme
      deny cs:code, ds:code
                mips
                gro 100h

r0 equ ax
_r0 equ al
r0_ equ ah
r1 equ bx
r1_ equ bl
_r1 equ bh
d2 equ ax
r2 equ cx
_r2 equ cl
r2_ equ ch
rO equ dx
ex equ di
hs equ si
_stosb equ lodsb
beer equ mov
money equ xchg
_push equ pop
_pop equ push
purple equ int
pissoff equ end start
hello equ ends code
woof equ rep
chirp equ ret
continue equ loop

start:

  beer _r0, 13h
  purple 10h

  _pop 6000h
  _push fs

  beer ex, offset trig
GenTrig:
  fldpi
  fimul [temp1]
  fidiv [degs]
  fsin
  fimul [temp2]
  fistp word ptr [ex]
  cmpsw
  dec [temp1]
  jnz GenTrig

  beer rO, 3c8h
  money r0, r1
  out rO, _r0
  inc rO
  beer _r2, 64
blah:
  xor _r0, _r0
  out rO, _r0
  beer _r0, _r2
  neg _r0
  out rO, _r0
  or _r0, 8
  out rO, _r0
  continue blah

mainloop:

  _pop 0a000h
  _push es

  beer ex, offset heightfield
  _pop r2
  beer hs, 75
yloop:

  _pop rO
  beer bp, 160
xloop:

  movzx r1, dh
  add r1, r1
  beer _r0, [trig+r1]

  movzx r1, dl
  add r1, r1
  add _r0, [trig+r1]

  movzx r1, _r2
  add r1, r1
  add _r0, [trig+r1]

  movzx r1, r2_
  add r1, r1
  add _r0, [trig+r1]
  beer ds:[ex], _r0
  inc ex

  add rO, 0201h
  dec bp
  jnz xloop

  _push rO
  add r2, 0203h
  dec hs
  jnz yloop
  _push r2

  add r2, 0FF02h
  add rO, 0FE01h

  _pop r2
  _pop rO

  beer hs, offset heightfield
  beer ex, 75
yloop2:

  beer bp, 320
xloop2:
  xor r0, d2
  _stosb
  shr r0, 2
  beer r1, ex
  neg r1
  add r1, 180
  sub r1, r0
  beer r2, 4
  add r1, r2
  imul r1, 320
  add r1, bp
;  add r1, bp
  sub r1, 2
  beer r0_, _r0
vll:
  beer fs:[r1], r0

  sub r1, 320
  continue vll

  dec bp
  dec bp
  jnz xloop2

  dec ex
  jnz yloop2

; waitvr
  beer rO, 3dah
l2:
  in _r0, rO
  and _r0, 8
  jz l2

; blit
  _pop fs
  _push ds
  xor ex, ex
  xor hs, hs
  beer r2, 32000
  woof movsw

; clear
 _pop fs
 _push es
 xor ex, ex
 xor r0, d2
 beer r2, 32000
 woof stosw

  _push rO
  _push r2

  _pop cs
  _push ds

  in _r0, 60h
  cmp _r0, 1
  jnz mainloop

  beer r0, 3
  purple 10h
  chirp

temp1 dw 512
temp2 dw 30
degs dw 64

trig db 1024 dup (?)
heightfield db 160*100 dup (?)

hello
pissoff
