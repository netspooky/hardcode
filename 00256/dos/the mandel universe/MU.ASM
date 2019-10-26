; Mandel Universe - TomCat/Abaddon

ORG 100H

start:
MOV AL,13H
INT 10H

.1:
MOV AL,88
.2:
SUB AL,16
JC .1
XCHG AX,BP
MOV SI,Scale-2
LODSW
MOV ES,AX
FNINIT
FLD     DWORD [SI+4]    ; is

.4:
INC BX
CALL rajzol
FMUL    DWORD [SI]      ; is*Scale
TEST BL,BL
JNE .4

.5:
CALL NEAR rajzol
FDIV    DWORD [SI]      ; is/Scale
DEC BX
JNZ .5

XOR BYTE [BP+SI+15],128

XCHG AX,SI
INT 16H
XCHG AX,BP
JZ .2
MOV AL,3
INT 10H
;RETN

rajzol:

FILD    WORD [SI-1]     ; scrx/2  is
FMUL    ST0,ST1         ; scrx/2*is  is
FSUBR   QWORD [BP+SI]   ; ar-scrx/2*is  is
FILD    WORD [SI-3]     ; scry/2  ar-scrx/2*is  is
FMUL    ST0,ST2         ; scry/2*is  ar-scrx/2*is  is
FSUBR   QWORD [BP+SI+8] ; ai-scry/2*is  ar-scrx/2*is  is

MOV DX,3DAH
SUB DI,DI
.3:
IN AL,DX
AND AL,8
JNZ .3
.3b:
IN AL,DX
AND AL,8
JZ .3b

loopy:
MOV CX,320
;br = ar
FLD     ST1             ; ar  ai  br  is

loopx:
Plus4:
MOV DX,4
.1:
;zr,zi,r2,i2 = 0
FLDZ                    ; i2  r2  zi  zr  ar  ai  br  is
DEC DX
JNZ .1

iter:
;zi = 2*zr*zi+ai
;zr = r2-i2+ar
FSUBP   ST1,ST0         ; r2-i2  zi  zr  ar  ai  br  is
FADD    ST0,ST3         ; r2-i2+ar  zi  zr  ar  ai  br  is
FXCH    ST2             ; zr  zi  r2-i2+ar  ar  ai  br  is
FMULP   ST1,ST0         ; zi*zr  r2-i2+ar  ar  ai  br  is
FADD    ST0,ST0         ; 2*zi*zr  r2-i2+ar  ar  ai  br  is
FADD    ST0,ST3         ; zi  zr  ar  ai  br  is
;r2 = zr*zr
FLD     ST1             ; zr  zi  zr  ar  ai  br  is
FMUL    ST0,ST0         ; r2  zi  zr  ar  ai  br  is
;i2 = zi*zi
FLD     ST1             ; zi  r2  zi  zr  ar  ai  br  is
FMUL    ST0,ST0         ; i2  r2  zi  zr  ar  ai  br  is
;i2+r2 < 4.0
FADD    ST0,ST1         ; i2+r2  r2  zi  zr  ar  ai  br  is
FICOM   WORD [Plus4+1]
FNSTSW AX
FSUB    ST0,ST1         ; i2  r2  zi  zr  ar  ai  br  is

MOV AL,DL
AND AL,127              ;maxcolor-1

SAHF
JA iter2

INC DX
CMP DX,BX
JNA iter
MOV AL,-32              ;nulcolor

iter2:
ADD AL,32               ;fstcolor
STOSB

FUCOMPP                 ; zi  zr  ar  ai  br  is
FUCOMPP                 ; ar  ai  br  is
FADD    ST0,ST3         ; ar+is  ai  br  is
LOOP loopx

FSTP    ST0             ; ai  ar  is
FADD    ST0,ST2         ; ai+is  ar  is

CMP DI,64000
JB loopy

FUCOMPP                 ; is
RETN

scry DW 200/2
scrx DB 320/2
Scale DD 0.875

is DD 1041972376
DD 1777951603,3217300744,1797946099,1072803291
DD 3677522781,3219601606,4290228492,1070690675
DD 2285109696,3220046661,1129126912,3218362276
DD 3967254334,3220447057,1923264592,3216919010
DD 2099533446,1070989970,2906300790,1072065402

;is DQ 0.015
;ar DQ -0.5
;ai DQ 0.0
