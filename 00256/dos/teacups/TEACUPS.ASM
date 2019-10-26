;TEACUPS by TomCat/Abaddon
;256b intro for the @party

;recursive teacups idea comes from Andrew Glassner
;www.glassner.com/portfolio/processing-for-visual-artists

;thanks for the music notes for ern0
;and sorry for the dirty exit...

RESX EQU 320
RESY EQU 200
SPEED EQU 4

CNT EQU 0
SX EQU 4
SY EQU 6
C0X EQU 8
C0Y EQU 10
AMP EQU 12
C1X EQU 16
C1Y EQU 18

ORG 256
 ADD    AL,13H
 INT    10H

 MOV    GS,BX
 MOV    BH,0A0H
 MOV    FS,BX
 MOV    DX,3C8H
 SALC
 OUT    DX,AL
 INC    DX
l1:
 MOV    BP,RESX+3
l2:
 MOV    AL,[BP-RESX+SI-256+Pal-1]
 ADD    AL,BH
 CBW
 XOR    AL,AH
 SHR    AL,1
 OUT    DX,AL
 DEC    BP
 JPE    l2
 SUB    BX,160
 JNZ    l1

 MOV    AL,0B6H
 OUT    43H,AL

nextpixel:
 PUSH   WORD [SI+CNT]
 PUSH   DI
 MOV    CL,1
 MOV    AH,8
 CWD
 XCHG   AX,DI
 CMP    AL,-1*SPEED
 JNE    nosound
 MOV    [SI-256+BP-RESX+turn-1],AL

 PUSH   AX
 MOV    AX,[GS:046CH]
 SUB    DI,AX
 XCHG   AL,AH
 TEST   AL,24
 JZ     skip
 OR     AL,8
 TEST   AL,7
 JZ     drum
skip:
 NEG    BYTE [SI-256+BP-RESX+turn-1]
 TEST   AX,AX
 JS     silent
 AND    AX,15
 XCHG   AX,DI
 SHR    AX,8+5
 INC    AX
 OUT    40H,AL                  ; IRQ0 speedup (faster timer tick)
;OUT    40H,AL
 MOV    AL,16
 MUL    BYTE [DI+BP-RESX+Notes]

drum:
 OUT    42H,AL
 MOV    AL,AH
 OUT    42H,AL
 STC
silent:
 SALC
 OUT    61H,AL
 POP    AX

nosound:
 MOV    DI,SY+256
 DIV    BP
 MOV    [SI+SX],DX
 STOSW
 MOV    AL,RESX/2
 STOSW
 MOV    AL,RESY/2
 STOSW
 MOV    AL,32
 MOV    [DI],AX
 CWD
 MOV    BL,115                  ; RADIUS
nextcircle:
 PUSH   BX
 XCHG   AX,BX
 MUL    AL
 MOV    [BP+SI],AX

 FILD   WORD [SI+CNT]
 FIDIV  WORD [SI-256+BP-RESX+DIVIDER]
 FSINCOS

twice:
 DEC    SI
 DEC    SI
 FIMUL  WORD [DI]
 FIADD  WORD [SI+C0Y+2]
 FIST   WORD [SI+C1Y+2]
 FISUBR WORD [SI+SY+2]
 FMUL   ST0,ST0
 FISTP  WORD [SI]
 JPO    twice

 LODSW
 XCHG   AX,BX
 LODSW
 ADD    AX,BX
 POP    BX
 SUB    [BP+SI],AX
 JBE    outside

 FILD   WORD [BP+SI]
 FSQRT
 FISTP  WORD [BP+SI]
 ADD    DX,[BP+SI]

 MOV    CL,4
 IMUL   AX,BX,6
 SHR    AX,CL
 CMP    AL,6
 JC     maxlevel
 XCHG   AX,BX
 SUB    AX,BX
 MOV    [DI],AX
 NEG    WORD [SI+CNT]
 FILD   DWORD [SI+C1X]
 FISTP  DWORD [SI+C0X]
outside:
 ADD    WORD [SI+CNT],341       ; 2PI/3
 LOOP   nextcircle
maxlevel:
 POP    DI
 POP    WORD [SI+CNT]
 MOV    [FS:DI],DL
 INC    DI
nextframe:
 JNZ    nextpixel
 ADD    WORD [SI+CNT],SPEED
turn:
 IN     AL,60H
 DEC    AL
 JNZ    nextframe
 OUT    61H,AL
;OUT    40H,AL
;OUT    40H,AL
;MOV    AX,3
;INT    10H
RETN

Notes:
 DB 143,126,120,126,120,143,126,143

DIVIDER:
 DW 163 ; 1024/163 -> 2PI

 DB 143,160,143,190,240,190

Pal:
 DB 192-128,225-128,205-128
