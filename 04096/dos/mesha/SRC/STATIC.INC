segconst

global LANG StaticConst:NEAR
StaticConst:
;------------------------------------------------------------------------------

Consts:

; fixed size InterPolar3 in code ! (13)
Const_InterPolar3 db  20h,01h,71h     ; AC,A,AB,0(D)
                  db  20h,22h,75h     ; AC,BC,C,0(D)
                  db  22h,10h,73h     ; BC,AB,B,0(D)
                  db  22h,20h,10h,87h ; BC,AC,AB,0(D),end
Const_InterPolar4 db  22h,30h,31h     ; BC,AD,A,B
                  db  30h,22h,75h     ; AD,BC,C,D
                                      ; next 4bit must >= 8, OK
Const_CalcNormal db   0EAh,0DBh,0DCh,0FAh,0FBh,0ECh

Const_FontVertex db   10h,98h
Const_FontFace   db   00h,08h*2  ,09h*2  ,01h*2  ,00h*2
                 db   00h,00h*2+1,01h*2+1,09h*2+1,08h*2+1
                 db   11h,09h*2  ,09h*2+1,01h*2+1,01h*2
                 db   0Fh,08h*2+1,08h*2  ,00h*2  ,00h*2+1
                 db   18h,08h*2+1,09h*2+1,09h*2  ,08h*2
                 db   08h,00h*2  ,01h*2  ,01h*2+1,00h*2+1

Const_CallData  dw    s o _CalcTo
                dw    s o _DrawFace
                dw    s o _DrawTriangle
                dw    s o _CalcDelta
                dw    s o _ReadS8Bit
                dw    s o _Random
                dw    s o _Read4Bit
                dw    s o _Text_Avg
                dw    s o _TF_Avg
                dw    s o _Text_Wood
                dw    s o _CN_SubVector
                dw    s o _ReadS4Bit

Const_Clip      dw    200,320
Const_Screen    dw    120,100,144,160

Const_Fract     db    10,100
                db    05,50
                db    02,10
                db    01,5

label RandomSeed dword
Const_PalData   db    050h,050h,050h       ; Black->Gray
                db    03Ah,03Ah,03Ah       ; Gray->White
                db    0BAh,0DDh,0BAh       ; LightGreen->DarkGreen
                db    020h,0F7h,070h       ; Green->Blue
                db    036h,044h,0FEh       ; Blue->White
                db    044h,022h,0E4h       ; Blue->Brown
                db    0AFh,02Ah,040h       ; Orange->Green
                db    0FCh,0FBh,0B8h

                db    060h,050h,050h       ;
                db    02Bh,03Ah,03Ah       ;
                db    0F8h,0F8h,0E6h       ;
                db    09Fh,0AEh,0CCh       ;

                db    02Ah,045h,070h       ; Brown->White (Adjust colors)
                db    0CCh,0CAh,0C8h       ; White->Brown (Adjust colors)
                db    0E7h,0E5h,000h       ; Brown->Brown

                db    038h,046h,042h       ;

ifndef __DEBUG
include "scene.inc"
else
label Const_Model byte
  db    1024 dup (0)
label Const_Object byte
  db    1024 dup (0)
label Const_Code byte
  db    1024 dup (0)
endif

CSFix           dd    2*5340353            ; X*100000h/Pi
Fix16           dd    01B000h              ; CalcNormal -> Light
AniProcess      dd    o Process + size tProcess

PMODE_DATA
ends

segdata
IFDEF __DEBUG                              ; OPTI! not only WATCOM version!
                ALIGN 4
ENDIF
;------------------------------------------------------------------------------
; VARIABLE ORDER IS IMPORTANT ! (*)
;------------------------------------------------------------------------------

VGAPal          db      300h dup (@0)            ;* before CharMap (768bytes)
CharMap         db      1000h dup (@0)
Matrix          dd      32 dup (@0)              ;-4 byte used too! (CalcMatrix)

IFDEF __DEBUG
VCount          dd      @0
FCount          dd      @0
ENDIF
StackPos:

ifndef __DEBUG
                org     10000h                   ; must leave space for stack!
endif
                                                 ;  64K code & data before
Buffer          db              50000h dup (@0)  ;* 320K must be at 10000h!
Temp            db              1000h dup (@0)   ;  4K
Objects         tObject         100h dup (<>)    ;* 32K (128*256)
ObjectsDraw     tObject         100h dup (<>)    ;* 32K (128*256)
Models          tModel          100h dup (<>)    ;  4K  (16*256)
AniFade         db    @0
AniClock        db    @0
Process         tProcess        MAX_PROCESS+1 dup (<>) ; 4K

Code32End:
ends
