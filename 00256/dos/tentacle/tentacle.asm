;DiLA/2004
[ORG 100H]
       MOV     AL, 13H
       INT     10H
       MOV     CX, 320
MAIN   FLD     DWORD [RADZ]
       FADD    DWORD [RADI]
       FST     DWORD [RADZ]
       FSIN
       FMUL    DWORD [SCAL]
       FADD    DWORD [YPOS]
       FISTP   WORD [YPOD]
       MOV     AX, [YPOD]
       IMUL    AX, 320
       ADD     AX, CX
       MOV     DI, AX
       PUSH    WORD 0A000H
       POP     ES
       AND     AX, 7
       SHR     AL, 2
       MOV     [ES:DI], AL
       SHL     AL, 2
       PUSH    CX
       MOV     CX, 2
LINE   ADD     DI, 10
       MOV     [ES:DI], AL
       LOOP    LINE
       POP     CX
       LOOP    MAIN
CHEK   MOV     DX, 03DAH
       IN      AL, DX
       AND     AL, 08H
       JNZ     CHEK
TRCE   IN      AL, DX
       AND     AL, 08H
       JZ      TRCE
       MOV     DI, 0
       MOV     AL, 0
       MOV     CX, 64000
       REP     STOSB
       MOV     CX, 320
       MOV     AH, 01H
       INT     16H
       JZ      MAIN
       MOV     AX, 4CH
       INT     21H
       RET
RADZ   DD      0.0
RADI   DD      0.01
SCAL   DD      20.0
YPOS   DD      100.0
YPOD   DD      0.0