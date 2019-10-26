;
;  FLAMES IN 175 BYTES
;  WRITEN BY A.DMITRIY (aka ADW)
;
;  HOME-PAGE:
;    HTTP://MYTOOLS.NAROD.RU/
;  MAIL:
;    ADW@NM.RU
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
;    PUSH CS
;    POP DS
    PUSH 0A000H
    POP ES
;    MOV AX, 013H
;    MOV CL, AH
;    MOV BH, AH
    MOV AL, 013H
    INT 010H
;    CLD
@PART_1:
    MOV BL, CL
    CMP CL, 35
    JL @PART_2
    ADD BH, 3
@PART_2:
    MOV DX, 03C8h
    MOV AL, CL
    OUT DX, AL
    INC DX
    MOV AL, CL
    OUT DX, AL
    MOV AL, BH
    OUT DX, AL
    MOV AL, CH
    OUT DX, AL
    INC CL
    CMP CL, 63
    JBE @PART_1
@DRAW_FLAMES:
    MOV SI, OFFSET FBUF+17919-640+1
    MOV CX, 320
@FILL_IT:
    XOR DX, 0AA55H
    SHL DX, 1
    ADC DX, 1
    XOR AL, AL
    CMP DH, 80
    JNB @LIGHT
    DEC AL
@LIGHT:
    MOV [SI], AL
    MOV [SI+320], AL
    INC SI
    LOOP @FILL_IT
    MOV SI, OFFSET FBUF+320+1
@3:
    MOV AX, [SI-1]
    INC SI
    ADD AL, AH
    ADD AL, [SI]
    ADD AL, [SI+319]
    SHR AL, 2
    MOV [SI-321], AL
    CMP SI, OFFSET FBUF+320+1+17920-640-1
    JNZ @3
    MOV DX, 03DAH
@WAIT_SCREEN:
    IN AL, DX
    AND AX, 8
    JZ @WAIT_SCREEN
    MOV SI, OFFSET FBUF+1
    MOV DI, 320
    MOV BX, 64000-320
@1:
    MOV CX, 160           ; 320 / 2
@2:
    MOV DX, [SI+320]
    LODSW
    MOV ES:[DI+BX-640], AX
    STOSW
    ADD AX, DX
    SHR AX, 1 
    AND AX, 07F7FH
    MOV ES:[DI+318], AX 
    MOV ES:[DI+BX-962], AX  
    LOOP @2
    ADD DI, 320
    SUB BX, 1280
    JA @1
    MOV AH, 01H
    INT 016H
    JZ @DRAW_FLAMES
    MOV AX, 03H
    INT 010H

FBUF:
    RET

    ENDS MP

    END LETSGO
