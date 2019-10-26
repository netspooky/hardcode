;     @       @
;    @@@@ @ @ @ @@
;   @ @  @  @ @   @
;  @   @ @@@@  @@  @
; 256 bytes by Rrrola

; greets to the Function 2017 organizers for letting me resubmit this
; WHILE THE COMPO WAS ALREADY ON

; main idea: no FPU anywhere (rotation by oscillator, no perspective)

; TODO: rotation, background (blue spheres), use zbuffer for shadows

org 100h

  add  al,13h  ; al=13h, cf=0
  int  10h

  push 0a000h
  pop  es

;palette: six hues
  mov  dx,3c8h
  mov  al,1
  out  dx,al
  inc  dx
P out  dx,al
  adc  al,40h/3+80h ; first pass: cf=0
  jnz  P
Q out  dx,al
  adc  al,2*40h/3+0c0h
  loop Q        ; 255 times, cx=0

  mov  dh,80h
  mov  ds,dx    ; workscreen
  mov  dh,6Fh
  mov  gs,dx    ; z-buffer

  mov  bh,7     ; x0=y0=1792
  mov  si,bx

;main loop      ; si=x bx=y di=vx ax=vy
M:
  add  si,di    ; sincos = harmonic oscillators, roughly golden ratio
  push ax
  mov  ax,79
  imul si
  sub  di,dx
  pop  ax

  add  bx,ax
  push bx
  sar  bx,9
  sub  ax,bx
  pop  bx

  pusha         ; PUSH: ax cx dx bx[-10] sp bp[-14] si di

;wait for vertical retrace start
  mov  dx,3dah
V in   al,dx
  and  al,8
  jz   V      ; al=8 cf=0

;copy and clear ; cx=0: do 65536 bytes
  xor  di,di
C mov  byte[gs:di],-128 ; clear z-buffer
  mov  al,[di]    ; copy and clear workscreen
  mov  byte[di],0  ; TODO: find a 0
  stosb
  loop C

;draw five tetrahedra (6 edges)

  mov  ax,50<<5   ; ax=Z=50
  mov  cl,33      ; draw a line from of interpolated spheres
L:
T2:               ; do a weird reflection
  mov  dh,3
T3:               ; trigonal rotation: permute x,y,z = y,z,x
  pusha

  mov  dl,66+28   ; 66 will be background
T5:
  call S
  neg  ax         ; z = -z

;pentagonal rotation (clobber di,ax,dx, save dx for now)
  push dx
  mov  cl,3
T53:  ; si=x bx=y ax=z
  lea  di,[bx+si] ; compute (G*(y-z) + y + x) / 2 where G = 0.618034
  sar  di,1       ; di=(y+x)/2
  push ax
  sub  ax,bx      ; ax=z-y
  mov  dx,-20252  ; fixed-point[+0.15] -0.5 * 0.618034
  imul dx         ; dx=-G*(z-y)
  pop  ax
  add  di,dx
  push di         ; collect results on stack
  xchg ax,bx      ; permute
  xchg ax,si
  loop T53

  pop  si    ; newX = (G*(y-z) + y + x) / 2
  pop  bx    ; newY = (G*(z-x) + z + y) / 2
  pop  ax    ; newZ = (G*(x-y) + x + z) / 2

  pop  dx
  add  dl,28
  cmp  dl,66+28+28+28+28+28  ; TODO: this should be overflow or something
  jna  T5

  popa

  xchg ax,si
  xchg ax,bx
  dec  dh
  jnz  T3

  neg  si
  neg  ax
  js   T2

  mov  dx,[ss:di-16]
  sar  dx,4
  sub  si,dx          ; line interpolation: X

  mov  dx,[ss:di-10]
  sar  dx,4
  sub  bx,dx          ; line interpolation: Y

  loop L

;esc?
  in   al,60h
  cmp  al,1
  popa            ; POP
  jne  M
  ret

;subroutine - draw a 17*17 shaded sphere: si=x(-160..160 << 5), bx=y(-100..100 << 5), ax=z; dl=color
S pusha
  sar  bx,5
  sar  si,5
  shl  ax,8-5     ; ah = z
  imul bx,320
  lea  bx,[bx+si+320*(100-9)-160-9]
  mov  al,103     ; -(x*x + y*y) / 2, update by linear deltas
  mov  cl,17
Y mov  si,17
  push ax
X push ax
  sar  al,1
  jns  O

  push ax         ; test and update zbuffer
  sar  al,4
  add  al,ah
  cmp  al,[gs:bx+si]
  jl   Z
  mov  [gs:bx+si],al
Z pop  ax
  jl   O
  add  al,dl
  mov  [bx+si],al
O pop  ax

  add  ax,si
  sub  al,10
  dec  si
  jnz  X

  pop  ax
  add  bx,320
  add  al,cl
  sub  al,10
  loop Y
  popa
  ret
