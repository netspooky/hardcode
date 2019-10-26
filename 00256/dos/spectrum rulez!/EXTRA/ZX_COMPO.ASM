; Spectrum rulez! by TomCat/Abaddon
; 256b entry for Chaos Constructions 2016

;%define PHONG

Radius EQU 44
LineLen EQU 320
Lines EQU 200
Pattern EQU 10
LastColor EQU 65-25
AddColor EQU 72
PhongColor EQU 31

ORG 100H
RY:     DW Lines/2-Radius
 MOV    AL,13H
 INT    10H
 MOV    BP,LineLen
Sphere:
 MOV    DI,03DAH
 PUSH   DI
 MOV    CL,2*Radius
.1:
 MOV    BL,2*Radius
.2:
%ifdef PHONG
 MOV    AL,-3*Radius/2
 ADD    AL,CL
 IMUL   AL
 MOV    SI,AX
 LEA    AX,[BYTE BX+(-1*Radius/2)]
 IMUL   AL
 ADD    AX,SI
 CMP    AX,24
 MOV    AH,80H          ; Phong marker
 JC    .6
%endif
 MOV    SI,Radius*Radius
 MOV    AL,-1*Radius
 ADD    AL,CL
 IMUL   AL
 SUB    SI,AX
 LEA    AX,[BYTE BX+(-1*Radius)]
 IMUL   AX
 XCHG   AX,DX
 SUB    SI,DX
 JS     .6
.3:
 MOV    [DI],CX         ; X
 FILD   WORD [BYTE BP+Sphere.4+2-LineLen]
 FLDPI                  ; PI R
 FIMUL  WORD [DI]       ; X*PI R
 FLD    ST1             ; R X*PI R
 FADD   ST0,ST0         ; 2R X*PI R
 FDIVP  ST1,ST0         ; X*PI/2R R
 FSIN                   ; SIN(X*PI/2R) R
 FMUL   ST0,ST1         ; R*SIN(X*PI/2R) R
 FSUBP  ST1,ST0         ; R-R*SIN(X*PI/2R)
.4:
 DB     81H,2DH,Radius,0;SUB WORD [DI],Radius; X-R
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
 FLDZ                   ; XP1
 FLDZ                   ; YP1 XP1
Main:
Background:
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
 ADD    AL,BH
 MOV    CL,BH
 REP    STOSB
 DEC    SI
 JNZ    .3
 DEC    BH
 JNZ    .2
 DEC    BX
 JNZ    .1
 INC    WORD [BP+SI]
 MOV    AX,[BP+SI]
 TEST   AX,0000011111111111B
 JNZ    .7
 XOR    [BYTE BP+Background.4-LineLen],BP
.7:
 CMP    AX,0D902H+610
 JB     .0
%ifdef PHONG
 CMP    AX,0D913H+2600
 JB     .9
 SAR    AX,2
 AAM    22
 CMP    AL,11
 JC     .8
 NEG    AL
 ADD    AL,22
.8:
 ADD    AL,LastColor-Pattern
 MOV    [BYTE BP+Background.3+2-LineLen],AL
.9:
%endif
 MOV    BH,080H
 CALL   Copy
.0:
 IN     AL,DX
 AND    AL,8
 JZ     .0
 MOV    BH,0A0H
 CALL   Copy
 FLDPI                  ; PI YP1 XP1
 FIDIV  WORD [BYTE BP+Sphere-2-LineLen]
 FADD   ST2,ST0         ; step YP1 XP1+step
 FADD   ST0,ST0         ; step*2 YP1 XP1+step
 FADD   ST1,ST0         ; step*2 YP1+step*2 XP1+step
 FADDP  ST2,ST0         ; YP1+step*2 XP1+step*3
 IN     AL,60H
 CBW
 DEC    AX
 JNZ    Main
%ifdef PHONG
 FUCOMPP                ; -
 MOV    AL,3
%endif
 INT    10H
 RETN
;----------------------------------------------------------------------
Copy0:
 FXCH   ST0,ST1         ; eXchange the SINUS pointers
Copy:
 FLD    ST0             ; YP1 YP1 XP1
 FSIN                   ; SIN(YP1) YP1 XP1
 FLD1                   ; 1 SIN(YP1) YP1 XP1
 FADDP  ST1,ST0         ; SIN(YP1)+1 YP1 XP1
 FIMUL  WORD [BYTE BP+RY-LineLen] ; RY*(SIN(YP1)+1) YP1 XP1
 FISTP  WORD [DI]       ; YP1 XP1
 IMUL   CX,BP
 ADD    CX,[DI]
 XOR    BYTE [BYTE BP+RY-LineLen],(LineLen/2-Radius)^(Lines/2-Radius)
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
%ifdef PHONG
 MOV    AX,PhongColor+8000H
 CMP    BX,AX
 JL     .3
%endif
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
