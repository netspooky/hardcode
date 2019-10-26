; twist by unlord / xylem
;     256b intro for
;   Function 2017 Party
;
; nasm twist.asm -o twist.com

%define WIDTH (320)
%define HEIGHT (200)
%define OUT_RAD (0.6)
%define RAD (0.25)
%define FACES (4)

;%define SHOW_PALETTE
%define USE_SUBPIXEL
%define HAS_PENTIUM      ; comment this to work in dosbox (adds 6 bytes)
%define RESET_FPU
%define WAIT_VSYNC
%define OVERLAP_CONST

  bits 16
  org 0x100

segment .text
  push 0xa000
  pop es

  jmp end_data
%ifdef OVERLAP_CONST
  lamb: db 0xf3, 0x04, 0x35
  step: db 0xbf, 0x0f, 0xc9, 0x3f
%else
   lamb: dd -0.707106781186548 ; -1.0/sqrt(2*(1 - cos(2*PI/FACES)))
   step: dd 1.57079632679490   ; 2*PI/FACES
%endif
%ifdef USE_SUBPIXEL
  color: dw 33, 39
    rad: dw 53
out_rad: dw 127
%else
out_rad: dw 60                 ; OUT_RAD*HEIGHT/2
    rad: dw 25                 ; RAD*HEIGHT/2
  color: dw 33, 39, 53, 127
%endif
end_data:

  ; assume ax = 0
  mov al, 0x13
  int 0x10

  ; orange:   0-127 = 128
  ;  green: 128-181 = 54
  ; purple: 182-221 = 40
  ;   blue: 222-255 = 34
  xor cx, cx
palette:
  mov dx, 0x3C8
  mov al, cl
  out dx, al
  inc dx
  mul al
  xchg al, ah
  out dx, al
  shr al, 1
  out dx, al
  shr al, 1
  out dx, al
  loop palette

  ; assume bx = cx = 0, si = 0x100, sp = 0xfffe
  mov bp, -66            ; just as twist is straight
main:
  xor di, di
  mov cl, HEIGHT
row:
  mov dx, WIDTH
col:

%ifdef SHOW_PALETTE
  mov ax, WIDTH
  sub ax, dx
%else
  xor ax, ax
%endif

  push cx
  push dx

%ifdef USE_SUBPIXEL
  ; y = (2*v - HEIGHT + 1)
  shl cx, 1
  sub cx, (HEIGHT + 1)

  ; x = (2*u - WIDTH + 1)
  shl dx, 1
  sub dx, (WIDTH + 1)
%else
  sub cx, (HEIGHT/2)
  jnz no_line_fix
  inc cx
no_line_fix:
  sub dx, (WIDTH/2)
%endif

  pusha

  fild word [bx-0x12]    ; frames
  fidiv word [si+0x11]   ; t = frames/51

  ; st = t

  fld st0                ; t
  fadd dword [si+0x9]    ; t + pi/2
  fldpi                  ; pi
  fdivp                  ; (t + pi/2)/pi
  push ax
  fistp word [bx-0x18]   ; floor((t + pi/2)/pi + 0.5)
  pop ax
  test al, 2             ; test even
  fldz                   ; d = 0
  jnz no_move
  fstp st0
  fld st0                ; t
  fcos                   ; d = cos(t)
  fld1                   ; 1
  faddp                  ; d = cos(t) + 1
  fmul st0, st0          ; d = (cos(t) + 1)^2
  fimul word [si+0x7]    ; d = ((cos(t) + 1)^2)*LARGE_CONST
no_move:

  ; st = d, t

  fild word [bx-0xa]     ; y
  fild word [bx-0xc]     ; x
  fadd st0, st2          ; x + d
  fpatan                 ; a = atan2(y, x)

  ; st = a, d, t

  fild word [bx-0xa]     ; y
  fld st1                ; a
  fsin                   ; sin(a)
  fdivp st1              ; r = y/sin(a)
  fsub st0, st2          ; r = y/sin(a) - d
  fisub word [si+0x13]   ; r = y/sin(a) - OUT_RAD*HEIGHT
  fidiv word [si+0x11]   ; r = (y/sin(a) - OUT_RAD*HEIGHT)/(RAD*HEIGHT)

  ; st = r, a, d, t

  fld st1                ; a
  fsin                   ; sin(a)
  fld st4                ; t
  fsin                   ; sin(t)
  fldpi                  ; pi
  fmulp                  ; a' = sin(t)*pi
  fmulp                  ; a' = sin(a)*sin(t)*pi
  fadd st0, st2          ; a' = a + sin(a)*sin(t)*pi
  fadd st0, st4          ; a' = a + t + sin(a)*sin(t)*pi

  ; st = a', r, a, d, t

  xor dx, dx
  mov bp, (FACES - 1)*2
  fld st0                ; a
  fsin                   ; x0 = sin(a)
  fxch st0, st1          ; b = a

  ; st = a', x0, r, a, d, t

face:
  fadd dword [si+0x9]    ; b = b + (2*pi/FACES)
  fld st0                ; b
  fsin                   ; x1 = sin(b)

  ; st = x1, a', x0, r, a, d, t

%ifdef HAS_PENTIUM
  fcomi st0, st3
%else
  fcom st0, st3
  fnstsw ax
  sahf
%endif
  fxch st0, st2
  jb skip                ; r <= x1

  ; st = x0, a', x1, r, a, d, t

%ifdef HAS_PENTIUM
  fcomi st0, st3
%else
  fcom st0, st3
  fnstsw ax
  sahf
%endif
  ja skip                ; x0 <= r

  ; st = x0, a', x1, r, a, d, t

  fsub st0, st2          ; w = x0 - x1
  fimul word [bp+si+0xd] ; v = w*color
  fmul dword [si+0x6]    ; v = w*color*LAMBERT
  fist word [bx-0x8]     ; ax = floor(v + 0.5)
  add word [bx-0x8], dx  ; ax = v + color_start

  ; st = v, a', x1, r, a, d, t

skip:
  fstp st0
  add dx, [bp+si+0xd]
  inc dx
  dec bp
  dec bp
  jns face

  ; st = a', x1, r, a, d, t

%ifdef RESET_FPU
  fninit
%else
  fstp st0
  fstp st0
  fstp st0
  fstp st0
  fstp st0
  fstp st0
%endif

  popa                   ; write stack values back into registers

  stosb

  pop dx
  pop cx

  dec dx
  jnz col

  dec cx
  jnz row

  inc bp

%ifdef WAIT_VSYNC
  mov dx, 0x3da
virt:
  in al, dx
  test al, 8
  jnz virt
no_virt:
  in al, dx
  test al, 8
  jz no_virt
%endif

  mov ah, 1
  int 0x16
  jz main

  mov ax, 0x3
  int 0x10

  ret

