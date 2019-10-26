;POKEBALL by TomCat/Abaddon
;FAST code / FASM source

RESX EQU 640
RESY EQU 480
CELL EQU 256
RADIUS EQU 90
VAR EQU MAXCOL
COLORW EQU 00CH
COLORB EQU 018H

ORG 256
 PUSH   0A000H
 POP    ES
 MOV    BX,121H
video:
 MOV    AX,4F02H
 INT    10H
 MOV    BL,12H
 CMP    AH,BH
 JE     video

 SUB    BX,BX                   ; BX:0
 FNINIT                         ; -
 MOV    SI,VAR-2
nextframe:
 ADD    AL,7
 PUSH   AX
 CWD
 MOV    CX,RESY*3
 MOV    DI,SP
nextline:
 MOV    BP,RESX*4
nextpixel:
 SUB    DI,SP
 JNZ    nobank
 MOV    AX,4F05H
 INT    10H
 INC    DX
nobank:
 FLDZ                           ; 0
 FLD1                           ; 1 0
 FSUBR  ST0,ST1                 ; -1 0
 PUSHA
 CMP    CX,88
 JNC    nomirror
 NOT    CX
 ADD    CL,180
nomirror:
 MOV    AX,[BX-4]
 CBW
 XOR    AL,AH
 MOV    AH,1
 ADD    CX,AX
 XCHG   AX,BP                   ; BP:01xxH AX:SX
;NEG    AX
 CMP    AL,128
 SBB    AH,DH
 FISTP  DWORD [SI-VAR+2+COLOR2+COLORW]
 FIST   DWORD [SI-VAR+2+COLOR2+COLORB]
nextaxis:
;AND    AL,CELL-1
 MOV    [SI+BP],AH
 CBW
 MOV    [SI+BP+1],AX
 IMUL   AL
 INC    SI
 XCHG   AX,CX
 FIADD  WORD [SI+BP]            ; DX+DY
 JPO    nextaxis
 ADD    CX,AX                   ; CX:DX2+DY2
 MOV    AX,RADIUS*RADIUS
 CALL   iiii

back:
 FISTP  WORD [SI+BP]            ; N.H
 FLD    DWORD [SI-VAR+Shine-2]  ; Shine N.H
VideoPtr:
 MOV    AX,[SI+BP]              ; Intensity
 NOT    AH                      ; Shadow test
 AND    AL,AH                   ; Diffuse
 ADD    AL,37                   ; Diffuse+Ambient
 MUL    BYTE [BX+SI-VAR+COLOR2] ; Color*(Diffuse+Ambient)
 FCOMI  ST0,ST1                 ; Shine N.H
 SALC                           ; Highlight test
 OR     AL,AH                   ; Color*(Diffuse+Ambient)+Specular
 STOSB
 INC    BX
 JPO    VideoPtr

 POPA
 FUCOMPP                        ; -
 ADD    BP,SP
 JNZ    nextpixel
 DEC    CX
 DEC    CX
 LOOP   nextline
 IN     AL,60H
 DEC    AX
 POP    AX
 JNE    nextframe
;MOV    AL,3
;INT    10H

iiii:
 SUB    AX,CX
 JNC    intersection
 FSUB   ST0,ST0
 FILD   WORD [SI-VAR+MAXCOL]
 FISUB  WORD [BX-8]             ; background intensity
great:
 MOV    BL,COLOR0-COLOR2        ; background color
RETN                            ; :)

intersection:
 XCHG   [SI+BP],AX
 FILD   WORD [SI+BP]            ; DZ2 DX+DY
 FSQRT                          ; DZ DX+DY
;MOV    WORD [SI+BP],RADIUS
 FADD   ST1,ST0                 ; DZ N.S
 FADD   ST0,ST1                 ; N.H N.S
;FIDIV  WORD [SI+BP]            ; N.H/R N.S
 FXCH   ST1                     ; N.S N.H/R
;FIDIV  WORD [SI+BP]            ; N.S/R N.H
 FMUL   DWORD [SI-VAR+MAXCOL]   ; Intensity N.H
 XCHG   AX,CX
 CMP    AX,190
 JNA    white
 CMP    AX,273
 JNA    black
 CMP    AX,633
 JNA    white
 CMP    AX,1392
 JNA    black
 XCHG   AX,CX
 CWD
 XOR    DX,AX
 XCHG   AX,DX
 CMP    AL,11
 JNA    black
 TEST   DX,DX
 JS     white
 CMP    WORD [BP+SI-2],507H
 JNE    solid
 CMP    CX,2784
 JNA    great
 MOV    AX,[BX-16]
 CBW
 XOR    AL,AH
;SUB    AL,AH
 CBW
 SUB    AX,DX
 CWD
 XOR    AX,DX
;SUB    AX,DX
 CMP    AL,15
 JA     great
solid:
RETN
white:
 MOV    BL,COLORW               ; white color
RETN

Shine:  DB 91;,67

COLOR2  DB 67,28,236            ; B,G,R - pokeball

black:
 MOV    BL,COLORB               ; black color
RETN

COLOR0: DB 255;,20,0            ; B,G,R - background
MAXCOL  DB 120,0,178,63
