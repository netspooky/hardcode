;
;                                                        __ggQQ
;                        ______________________        QQ==""lQl
;                        |                    /_____   lQl::  QQ
;                        |_                //.     !    QQl:::lQl
;                        __\                       :    lQSlllSQQ
;       QQgg__           |  ____________________________ QQSSSSlQl
;      lQl""==QQgg__     |  |   ___   |         |   ___  lQQQQQQQQ
;      QQ   ::lSQQQQQQ   |  |   \_    |    |    |   \_    QQQQQQQQl__ggQQ
;     lQl:::lQQQQQQQQQl  _\ | :. |      :. |      :. |    lQQQQQQQQQQQQlQl
;     QQSlllSQ  QQQQQQQ  |  |____|----|____|----|____|---- QQQQQQQQQQQQQQQ
;    lQQQSSSQQggQQQQlQl  !                         .       lQQQQQQQQ==""
;    QQQQQQQQQQQQQQjQP   :  . a n a l . r i d e .  !        QQ==""
;   lQQQQQQQQQQQQQQg  ______    ________________   |
;   QQQQQQQQQQgQQQQQL |___ |____|    |    _____|   |
;  lQQQQQQQQ':QQQQQQl:     |   ___        __|  |   |
;  QQQQQQQQl  QQQQQQQl :.    :.\_      :.      |   |
;    ""==QQ   QQQQQQQ: ----|____|----|____|----'  _|
;              ""==QQ    .                       /__
;                        ! //.      _______________|
;                f­tz/ipc|__________\
;
;
; AnalRide - 256 byte intro for Rush Hours 98 - source code.
; made by neon / the machines^fszistkiee odbyty ћwiata dizajn:)
; after compilation you must cut all zeros from the end of COM file...
; watch^learn... :)
;
;                                                          neon 02.04.98
;
; щ[neon][tms]-[piotr nierobisz][banachiewicza 4/3][41-818 zabrze]щ
;

.386
.387
ASSUME CS : CODE, DS : CODE, ES : CODE, FS : CODE, GS : CODE, SS : CODE

;ЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±Э some usefull equs Ю±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;ЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ

   _CenterXpos  EQU  _ScrSizeX / 2
   _CenterYpos  EQU  _ScrSizeY / 2
   _ScrSizeX    EQU  320
   _ScrSizeY    EQU  200
   O            EQU  offset
   B            EQU  byte ptr
   W            EQU  word ptr
   D            EQU  dword ptr

;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ

CODE SEGMENT USE16
ORG 100h

  @ProgramEntryPoint:

;ЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Э initialize Ю±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;ЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД tag ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

   stc                                 ; щ
   outsb                               ; n
   in     AL, DX                       ; м
   outsb                               ; n
   stc                                 ; щ

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДД allocate memory ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

   mov     AX, CS
   add     AX, 65536/16
   mov     GS, AX                      ; Getmem(GS, 65536)
   add     AX, 65536/16
   mov     FS, AX                      ; Getmem(FS, 65536)
   add     AX, 65536/16
   mov     BP, AX                      ; Getmem(BP, 65536)

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДД generate texture ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

   mov     ES, BP

   xor     SI, SI
   mov     CX, 65536/2
  @GenerateTexture:
   mov     AX, [seed]
   add     AX, 9248h
   ror     AX, 3
   mov     [seed], AX
   and     AX, 0001111100011111b      ; random numbers must be in range 0-63
   mov     [ES]:[SI], AX              ; save pixel to texture
   inc     SI
   inc     SI                         ; update index counter
   loop   @GenerateTexture

   finit                              ; initalize coprocessor (not necessary)

;ЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±Э generate tunnel Ю±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;ЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ

   mov     [Ry], -_CenterYPos
   mov     CX, _ScrSizeY
  @VerticalLoop:
   push    CX
   mov     [Rx], -_CenterXPos

   mov     CX, _ScrSizeX
  @HorizontalLoop:

   mov     EAX, [RX]
   imul    EAX, EAX                    ; EAX = RXэ

   mov     EBX, [RY]
   imul    EBX, EBX                    ; EBX = RYэ
   add     EAX, EBX                    ; EAX = RXэ + RYэ

   mov     [Transport4], EAX
   fild    [Transport4]
   fsqrt                               ; ST(0) = ыRXэ + RYэ
   fild    [PerspValue]                ; ST(0) = perspective; ST(1) = ыRXэ + RYэ
   fdiv    ST(0), ST(1)                ; ST(0) = perspective / ыRXэ + RYэ
   fistp   word ptr [FS]:[SI]          ; save tunnelMapXValue

   ffree   ST(0)                       ; Clear ST(0)

   fild    [Rx]                        ; ST(0) = Ry
   fild    [Ry]                        ; ST(0) = Rx; ST(1) = Ry
   fpatan                              ; ST(0) = ArcTg(Rx / Ry) = а

   fmul    [BDivPiMul2]                ; ST(0) = а * 256 / 2 * г
   fistp   word ptr [GS]:[SI]          ; save tunnelMapYValue

   ffree   ST(0)                       ; clear ST(0)

   inc     [Rx]                        ; RX = RX + 1
   inc     SI                          ; update index counter
   loop   @HorizontalLoop

   inc     [Ry]                        ; RY = RY + 1
   pop     CX
   loop   @VerticalLoop

;ЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Э vga init Ю±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;ЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД vga init ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

   push    word ptr 0A000h
   pop     ES                           ; ES = vga segment

   mov     AX, 013h
   int     10h                          ; mode13h

;ДДДДДДДДДДДДДДДДДДДДДДДДДД generate gray palette ДДДДДДДДДДДДДДДДДДДДДДДДДДДД

   xor     AX, AX
   mov     DX, 03C8h
   out     DX, AL
   inc     DX
   mov     CX, 64
  @ShortGrayPalLoop:
   out     DX, AL
   out     DX, AL
   out     DX, AL
   inc     AL
   loop   @ShortGrayPalLoop

;ЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±Э main program loop Ю±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;ЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ

  @MainProgramLoop:

;ДДДДДДДДДДДДДДДДДДДДДДДД wait for vertical retrace ДДДДДДДДДДДДДДДДДДДДДДДДДД

   mov     DX, 3DAh
   in      AL, DX
   test    AL, 08h
   jnz     $-5
   in      AL, DX
   test    AL, 08h
   jz      $-5

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД show tunnel ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

   push    DS
   mov     DS, BP                       ; segment with texture
   xor     SI, SI
   mov     CX, 64000                    ; full screen
  @PutTunnelOnScreen:
   mov     BL, B FS:[SI]                ; BH = X
   mov     BH, B GS:[SI]                ; BH = Y <=> BX = 256 * Y + X
   add     BX, W CS:[O Counter1]        ; BX = 256 * Y + X + Counter(s)
   mov     AL, [DS]:[BX]                ; AL = pixel from texture
   mov     ES:[SI], AL                  ; put pixel on screen
   inc     SI                           ; update index counter
   loop   @PutTunnelOnScreen
   pop     DS

   add     W [O Counter1], W 0102h      ; update tunnel counter
                                        ; counter1 = counter1 + 2 (x)
                                        ; counter2 = counter2 + 1 (z)

   in      AL, 060h
   dec     AX                           ; AH = 0 => dec AX
   jnz    @MainProgramLoop              ; wait for escape key

;ЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Э deinitialize Ю±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;ЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ

   mov     AL, 03h
   int     10h                          ; mode03h

   ret                                  ; movax4c00hint21h

;ЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬЬ
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±Э datas Ю±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;ЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯЯ

   PerspValue  DW   3500                ; tunnel perspective value
   BDivPiMul2  DD   04222F983h          ; const: 256 / г * 2

   Seed        DW   0                   ; random seed

   Transport2  DW   0                   ; word between regs and coprostack
   Transport4  DD   0                   ; dword between regs and coprostack

   Ry          DD   0                   ; RY variable
   Rx          DD   0                   ; RX variable

   Counter1    DB   0                   ; tunnel counter x
   Counter2    DB   0                   ; tunnel counter z

CODE ENDS

 ;ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ;

END @ProgramEntryPoint

