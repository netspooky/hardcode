; SNOW IN < 256 BYTES
; REWRITEN BY A.DMITRIY (aka ADW)
; HOME-PAGE: WWW.ADW.NM.RU
; TO COMPILE:
; TASM SNF.ASM
; TLINK /TDC SNF.OBJ
; P.S. NOT OPTIMIZED...

.286

MP  SEGMENT PARA 'Code'
    ASSUME CS:MP,DS:MP,SS:MP
    ORG 100H

LETSGO:

MAIN PROC NEAR

    PUSH DS
    MOV AX, 13H
    INT 10H
    MOV AX, 0A000H
    MOV ES, AX
    MOV DS, AX
    
    MOV SI, 64000
    MOV DX, 111H
L6: XOR DX, 0AA55H
    SHL DX, 1
    ADC DX, 118H
    ADD [SI+2], DX
    MOV AL, DH
    SHL AX, 8
    MOV CL, AH
    MOV [SI+1], AH
    MOV AL, DL
    MUL CL
    MOV [SI], AH
    ADD SI, 4
    JNC L6     ; ...
    PUSH BX
    MOV BX, 320
L5: MOV DX, 3DAH
L3: IN AL, DX
    AND AX, 8
    JZ L3
    POP DX
    MOV SI, 64000
L0: XOR DX, 0AA55H
    SHL DX, 1
    ADC DX, 118H
    MOV DI, [SI+2]

    CALL DRAW

    CMP DL, [SI] 
    JNC L1
    INC DI
L1: MOV AH, [SI+1]
    CMP DH, AH
    JNC L2
    ADD DI, BX
L2: MOV [SI+2], DI
    SHR AH, 5               
    ADD AH, 12H

    MOV AL, AH
    ADD AH, 12H
    SHR AH, 1

    CMP DI, 63680
    JNB X0
    CMP DI, BX
    JB X0
 
    MOV [DI], AL
    MOV [DI-320], AH
    MOV [DI+320], AH
    MOV [DI-1], AH
    MOV [DI+1], AH
    ADD AL, 0EH
    SHR AL, 1
    CALL DRW2

X0:

    ADD SI, 4
    JNC L0    ; ...
    PUSH DX
    MOV AX, 100H
    INT 16H
    JZ L5
    POP AX
    MOV AX, 3
    INT 10H

    POP DS

    MOV DX, 0B1CH
    MOV AH, 2
    XOR BH, BH
    INT 10H

    MOV AH, 9
    LEA DX, MESSAGE
    INT 21H
    
    RET

MAIN ENDP

DRAW PROC NEAR

    XOR AL, AL

    CMP DI, 63680
    JNB X1
    CMP DI, BX
    JB X1

    MOV [DI], AL
    MOV [DI-320], AL
    MOV [DI+320], AL
    MOV [DI-1], AL
    MOV [DI+1], AL

DRW2:
    MOV [DI-321], AL
    MOV [DI+321], AL
    MOV [DI-319], AL
    MOV [DI+319], AL
X1:
    RET

DRAW ENDP

MESSAGE DB 'Happy new year, Marina!', '$'
     DB 0

     ENDS MP
    
     END LETSGO
