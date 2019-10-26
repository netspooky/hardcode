; plazmusy kosmosy
; neon / hpz^cnnnnb squad

Locals
.386
.387

 ;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл;

CODE SEGMENT USE16
ASSUME  CS : CODE, DS : CODE, ES : CODE, SS : CODe
org 100h

 d equ dword ptr
 w equ word ptr
 o equ offset

 @Start:

  mov    AX, 013h
  int    10h

  push   0A000h
  pop    ES

  xor    AX, AX
  mov    DX, 03C8h
  out    DX, AL
  inc    DX
  mov    CX, 64
 @LongGrayPalLoop:
  push   CX
  mov    CX, 4 * 3
 @InnerGrayPalLoop:
  out    DX, AL
  loop  @InnerGrayPalLoop
  inc    AL
  pop    CX
  loop  @LongGrayPalLoop

 @MainLoop:
  mov    DX, 3DAh
  in     AL, DX
  test   AL, 08h
  jnz    $-5
  in     AL, DX
  test   AL, 08h
  jz     $-5

  fldz
  fldz

  mov     [y], -100
  xor     DI, DI

  mov     CX, 200
 @VerticalKosmosLoop:
  push    CX
  mov     W [x], -160
  mov     CX, 320

 @HorizontalKosmosLoop:
  mov     AX, [x]
  imul    AX
  mov     BX, AX

  mov     AX, [y]
  imul    AX
  add     BX, AX
  mov     [transport2], BX
  fild    D O [transport2]
  fsqrt

  fmul    ST(0), ST(1) ;D [deltax]
  fmul    ST(0), ST(2) ;D [deltay]
  fmul    D [degtorad]
  fsin
  fimul   W [accurancy]
  fistp   W [transport2]

  mov     AX, [transport2]
  test    AX, AX
  jge    @okej
  xor     AX, AX ;, AX
 @okej:
  and     AX, 255
  stosb

  fld     [addx]
  faddp   ST(1), ST(0)
  inc     [x]
  loop   @HorizontalKosmosLoop

  ffree   ST(0)
  fincstp
  fldz
  fld     [addy]
  faddp   ST(2), ST(0)
  inc     [y]
  pop     CX
  dec     CX
  jnz    @VerticalKosmosLoop

  ffree   ST(0)
  ffree   ST(1)

  fld     [addy]
  fadd    [hemp]
  fstp    [addy]

  in      AL, 060h
  cmp     AL, 1
  jnz    @MainLoop

  mov     AX, 03h
  int     10h
  ret

  x              DW -160
  y              DW -100

  deltax         DD 0.0000
  deltay         DD 0.00
  addx           DD 0.0251
  addy           DD 0.28

  hemp           DD 0.003

  DegToRad       DD 03BC90FDBh
  Accurancy      DW 255           ; accurance
  transport2     DW ?
  transport2zero DW 0

; transport4     DD ?

CODE ENDS

 ;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл;

END @start