;
;  SNOW IN 255 BYTES
;  REWRITEN BY A.DMITRIY (aka ADW)
;
;  HOME-PAGE:
;    WWW.ADW.NM.RU
;
;  TO COMPILE:
;    TASM SNF.ASM
;    TLINK /TDC SNF.OBJ
;

.286

MP  SEGMENT PARA 'Code'
    ASSUME CS:MP,DS:MP,SS:MP
    ORG 100H

LETSGO:

    MOV AL, 13H
    INT 10H

    XOR BP, BP

    PUSH 0A000H
    POP DS

    MOV SI, 64000

    MOV DX, 111H
L6: CALL ARIFM
    ADD [SI], DX
    MOV AX, DX
    MOV CL, DH
    MUL CL
    MOV CH, AH
    MOV [SI+2], CX
    ADD SI, 4
    JNC L6     ; Buffer from 64000 to The End

    PUSH BX

    MOV BX, 320

L5: MOV DX, 3DAH
L3: IN AL, DX
    AND AL, 8
    JZ L3

    CMP BP, DX     ; CMP with 3DAH
    JNB NOMESSAGE
    INC BP

    PUSHA
    PUSH DS
    PUSH CS
    POP DS

    MOV DX, 0A09H
    MOV BP, OFFSET MESSAGE

    CALL CURSOR

    MOV DX, 0D0BH
    MOV BP, OFFSET MESSAGE2

    CALL CURSOR

    POP DS
    POPA

NOMESSAGE:

    POP DX

    MOV SI, 64000

L0: CALL ARIFM
    MOV DI, [SI]

    XOR AX, AX

    CLC
    CALL DRAW

    CMP DL, [SI+3]
    ADC DI, AX
    MOV AH, [SI+2]
    CMP DH, AH
    JNC L2
    ADD DI, BX
L2: MOV [SI], DI
    SHR AH, 5
    ADD AH, 12H

    MOV AL, AH
    ADD AH, 12H
    SHR AH, 1

    STC
    CALL DRAW

    ADD SI, 4
    JNC L0    ; See above

    PUSH DX

    MOV AH, 01H
    INT 16H
    JZ L5

    POP AX

    MOV AX, 3
    INT 10H

ARIFM:

    XOR DX, 0AA55H
    ADD DX, DX
    ADC DX, 0118H
    RET              ; Exit from subroutine and from Whole program

DRAW:

    PUSHF

    CMP DI, 63680
    JNB X1
    CMP DI, BX
    JBE X1

    MOV [DI-320], AH

    MOV [DI-1], AH
    MOV [DI], AX

    POPF
    PUSHF
    JNC DRW2
    ADD AL, 0EH
    SHR AL, 1

DRW2:

    MOV [DI-321], AL
    MOV [DI+BX+1], AL
    MOV [DI-319], AL

    MOV [DI+BX-1], AX

X1:
    POPF
    RET

CURSOR:
    PUSH BP
    MOV AH, 2
    XOR BH, BH
    INT 10H
    MOV AH, 9
    POP DX
    INT 21H
    RET

MESSAGE  DB 'Happy new Year, Marina!$'
MESSAGE2 DB   'Don''t forget me ;)$'

    ENDS MP

    END LETSGO
