;
;  FLAMES IN 128 BYTES
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

; Initial setup

    PUSH 0A000H
    POP ES
    MOV BP, 320   ; temp
    
    MOV AL, 013H
    INT 010H

; Generate pallete

@PART_1:
    MOV DX, 03C8H ; dh = 3
    CMP CL, 32
    JL @PART_2
    ADD BH, DH    ; add 3
@PART_2:
    MOV AL, CL
    OUT DX, AL
    INC DX
    OUT DX, AL
    MOV AL, BH
    OUT DX, AL
    AAA ; make 0000xxxx in AL
    OUT DX, AL
    INC CL
    JNS @PART_1

; Main LOOP

@DRAW_FLAMES:

; Fill initial line

    MOV SI, OFFSET FBUF+17919-640+1
    MOV CX, BP ; 320
@FILL_IT:
    IN AX, 040H
    MOV [SI], AL
    INC SI
    LOOP @FILL_IT

; Process buffer

    MOV SI, OFFSET FBUF+320
    MOV CX, 17920-640-1
@3:
    LODSW
    ADD AL, AH
    ADD AL, [SI]
    DEC SI
    ADD AL, [SI+BP]
    SHR AL, 2
    MOV [SI-320], AL
    LOOP @3

; Waiting retrace

; In DH we have 03, so change DL

    MOV DL, 0DAH
@WAIT_SCREEN:
    IN AL, DX
    AND AL, 8
    JZ @WAIT_SCREEN

; Draw to screen

    MOV SI, OFFSET FBUF+1
    MOV DI, BP  ; 320
    MOV BX, 64000-320-640
@1:
    MOV CX, BP           ; 320
@2:
    MOV DL, [SI+BP] ; 320
    LODSB
    MOV ES:[DI+BX], AL

    ADD DL, AL
    SHR DL, 1
    MOV ES:[DI+BP], DL
    MOV ES:[DI+BX-320], DL

    STOSB

    LOOP @2
    ADD DI, BP ; 320
    SUB BX, 1280
    JA @1


    MOV AH, 01H
    INT 16H
    JZ @DRAW_FLAMES
    MOV AX, 3
    INT 10H
    RET


  ;  JMP @DRAW_FLAMES
FBUF:

    ENDS MP

    END LETSGO
