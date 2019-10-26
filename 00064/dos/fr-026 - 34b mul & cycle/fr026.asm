; fr-026: 34b mul+cycle (uc 6.22 size optimizing compo entry)
; 1st place
; code: ryg (original concept) & kb (additional opcode crunching)
;
; rules were to write a "colorcycling" (no real colorcycling was
; required, only colorcycling-like animation) effect that display
; a x * y-ish pattern somewhere on the screen. the palette was
; required to look like the original version.

  org  256

  mov  al, 13h			; ...load al with 13h (mode number)
  int  10h				; set mode 13h

  mov  bp, 320			; screen is 320 pixels wide
  
x les  ax, [bx]			; es = end of mem (9fffh), ax = 20cdh
  cwd					; => dx = 0 (for idiv)
  mov  ax, di			; get dest address
  idiv bp				; div by width => ax=y coord, dx=x coord
  imul dx				; mul x by y
  stosb					; store color in vram
  mov  dx, 3c9h			; dac data
  bt   cx, 6			; bit 6 of cx => carry flag
  salc					; set al from carry flag
  xor  ax, cx			; => all this is functionally equivalent to something like
  						; "test al, 64" / "jz skip" / "not al" / "skip: blah"
                        ; which should be somewhat easier understandable, but bigger.
  out  dx, al			; write grayscale pixel values
  out  dx, al
  out  dx, al
  loop x				; pixel loop.
  loop x				; skip cx = 0 to get the cycling effect!
  
; that's all there is to it.
; this is the 7th (or 8th) version; the first try was
; 49 bytes, from then on we successively made it smaller.