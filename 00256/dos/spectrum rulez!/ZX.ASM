; Spectrum rulez! by TomCat/Abaddon [BUGFIXED]
; 256b entry for Chaos Constructions 2016

Radius EQU 44
LineLen EQU 320
Lines EQU 200
Pattern EQU 10
LastColor EQU 65-25
AddColor EQU 72
PhongColor EQU 31

ORG 100H
 MOV    AL,13H
 INT    10H
;FNINIT
 FLD1                   ; 1
 FLDZ                   ; XP1 1
 FLDZ                   ; YP1 XP1 1
 MOV    BP,LineLen
Sphere:
 MOV    DI,03DAH
 PUSH   DI
 MOV    CX,2*Radius
.1:
 MOV    BL,2*Radius
.2:
 MOV    AL,-1*Radius
.0:
 ADD    AL,CL
 IMUL   AL
 XCHG   AX,SI
 LEA    AX,[BYTE BX+(-1*Radius)]
 IMUL   AX
 XCHG   AX,DX
 ADD    SI,DX
 CMP    SI,Radius*Radius
 JA     .6
 CMP    SI,24
 JA     .3
 MOV    BYTE [DI-Radius*Radius*2+Radius+1],0DAH
.3:
 MOV    [DI],CX         ; X
 FLDPI                  ; PI 1
 FIMUL  WORD [DI]       ; X*PI 1
 FIDIV  WORD [BYTE BP+Sphere.1-2-LineLen] ; X*PI/2R 1
 FSIN                   ; SIN(X*PI/2R) 1
 DW     Lines/2-Radius  ; OFFSET 320 ->RY
 FSUBR  ST0,ST3         ; 1-SIN(X*PI/2R) 1
 FIMUL  WORD [BYTE BP+Sphere.4-LineLen] ; R-R*SIN(X*PI/2R) 1
 DB     81H,2DH         ; hardcoded SUB WORD [DI],Radius; X-R
.4:
 DW     Radius
 JS     .5
 FCHS                   ; -1*(R-R*SIN(X*PI/2R))
.5:                     ; SIGN(X-R)*(R-R*SIN(X*PI/2R))
 FISUB  WORD [DI]       ; SIGN(X-R)*(R-R*SIN(X*PI/2R))-(X-R)
 FISTP  WORD [DI]       ; -
 IMUL   BP
 SUB    AX,[DI]
 XCHG   CX,BX           ; change axis
 NEG    DI              ; loop 2x
 JS     .3
.6:
 STOSW
 DEC    BX
 JNZ    .2
 LOOP   .1
 POP    DX              ; 03DAH->DX
 XCHG   AX,DI           ; 0->DI
;----------------------------------------------------------------------
Main:
 PUSH   07000H
 POP    ES
 MOV    BL,Lines/Pattern
.1:
 MOV    BH,Pattern
.2:
 MOV    SI,LineLen/Pattern
.3:
 LEA    AX,[BX+SI+LastColor-10]
 MOV    CL,Pattern
 SUB    CL,BH
 REP    STOSB
.4:
 TEST   BYTE [BYTE BP+Sphere+2-LineLen],DH
 JZ     .5
 ADD    AL,BH
.5:
 MOV    CL,BH
 REP    STOSB
 DEC    SI
 JNZ    .3
 DEC    BH
 JNZ    .2
 DEC    BX
 JNZ    .1
 DEC    WORD [BYTE BP+Sphere+1-LineLen]
 JNS    .6
 MOV    BH,080H
 CALL   Copy1
.6:
 IN     AL,DX
 AND    AL,8
 JZ     .6
 CALL   Copy
 FLDPI                  ; PI YP1 XP1 1
 FIDIV  WORD [BYTE BP+Sphere.0-1-LineLen]
 FADD   ST2,ST0         ; step YP1 XP1+step 1
;FADD   ST0,ST0         ; step*2 YP1 XP1+step 1
 FADD   ST1,ST0         ; step*2 YP1+step*2 XP1+step 1
 FADDP  ST2,ST0         ; YP1+step*2 XP1+step*3 1
 IN     AL,60H
 CBW
 DEC    AX
 JNZ    Main
;FUCOMPP                ; 1
;MOV    AL,3
 INT    10H
;RETN
;----------------------------------------------------------------------
Copy:
 MOV    BH,0A0H
Copy0:
 FXCH   ST0,ST1         ; eXchange the SINUS pointers
Copy1:
 FLD    ST0             ; YP1 YP1 XP1 1
 FSIN                   ; SIN(YP1) YP1 XP1 1
 FADD   ST0,ST3         ; SIN(YP1)+1 YP1 XP1 1
 FIMUL  WORD [BP+SI]    ; RY*(SIN(YP1)+1) YP1 XP1 1
 FISTP  WORD [DI]       ; YP1 XP1 1
 IMUL   CX,BP
 ADD    CX,[DI]
 XOR    BYTE [BP+SI],(LineLen/2-Radius)^(Lines/2-Radius)
 JPE    Copy0
 PUSH   ES
 POP    DS
 MOV    ES,BX
 SUB    DI,DI
 CALL   Copy2
 MOV    SI,DX
 MOV    CL,Radius*2
.1:
 PUSH   CX
 MOV    CL,Radius*2
.2:
 CS LODSW
 XCHG   AX,BX
 MOV    AL,PhongColor
 CMP    BH,DL
 JE     .3
 MOV    AL,[BX+DI]
 OR     BX,BX
 JZ     .3
 ADD    AL,AddColor
.3:
 STOSB
 LOOP   .2
.4:
 MOV    CL,LineLen-Radius*2
 PUSH   SI
 CALL   Copy2
 POP    SI
 POP    CX
 LOOP   .1
 SUB    CX,DI
Copy2:
 MOV    SI,DI
 REP    MOVSB
RETN
