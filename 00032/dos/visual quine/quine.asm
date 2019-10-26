; Visual quine - Preacher/Traction

; Yeah, it's stupid.. but show me a 32b prod that isn't.
; I guess this belongs to the category "for geeky coders who are easily
; amused only"

; And hey, it has exit support and switches back to textmode ;)

.model tiny
.data
.code

org 100h

START:
  mov al, 13h
  int 10h
  les cx, [bx]

@mainloop:

  @ruutu:
    lodsb
    cmp si, offset loppu
    jb no_skip
      lea si, start
    no_skip:
    stosb
    jnz @ruutu

  nop           ; the place of this nop changes the outlook... radically >:)

  mov ah, 01
  int 16h
  jz @mainloop

  mov ax, 3h
  int 10h

  ret

loppu:

END START
