;dissasmebly by bushmansalad of "R'LYEH.COM" on around about the 17-August-95


code    SEGMENT PARA PUBLIC 'code'
	ASSUME cs:code, ds:code, es:code, ss:code
	org     100h
.386
start: 
        MOV     AX, 0A000h
        MOV     DS, AX
        MOV     AX, 0013h
        PUSH    AX
        INT     10h
        NOT     AX
        MOV     ES, AX
@010F:  MOV     AH, 12h
        INT     16h
        TEST    AL, 04h
        XCHG    CX, AX
        POP     AX
        JZ      @011B
        INC     AL
@011B:  TEST    CL, 08h
        JZ      @0122
        DEC     AL
@0122:  PUSH    AX
        TEST    CL, 03h
        JZ      @0150
        MOV     AH, AL
        MOV     BX, ES
        TEST    CL, 02h
        JZ      @0134
        XOR     AH, 80h
@0134:  TEST    AH, 40h
        PUSHF
        JZ      @013C
        XCHG    BH, BL
@013C:  AND     AH, 0C0h
        JPO     @0145
@0141:  DEC     BL
        JNZ     @0149
@0145:  INC     BL
        JZ      @0141
@0149:  POPF
        JZ      @014E
        XCHG    BH, BL
@014E:  MOV     ES, BX
@0150:  MOV     CX, 013Fh
        shl     ax, 3
        ADD     AX, 00B4h
@0159:  DEC     AX
        AND     AX, 07FFh
        JCXZ    @010F
        PUSH    AX
        MOV     SI, AX
        AND     SI, +3Ch
        shr     si, 2
        ADD     SI, 0100h
        SHR     AX, 1
        btr     ax, 9
        PUSHF
        NEG     AH
        JNZ     @0179
        XCHG    AH, AL
@0179:  POPF
        JNB     @017E
        NOT     AX
@017E:  XCHG    BX, AX
        MOV     AX, ES
        CALL    @01F4
        PUSH    AX
        MOV     AX, ES
        XCHG    AL, AH
        XCHG    BL, BH
        CALL    @01F4
        POP     BX
        ADD     BX, AX
        XOR     DX, DX
        shr     bx, 6
        JNZ     @0199
        INC     BX
@0199:  MOV     AX, 0FFFh
        DIV     BX
        INC     AX
        XCHG    BX, AX
        DEC     CX
        MOV     DI, CX
        XOR     DX, DX
        MOV     AX, 0064h
        SUB     AX, BX
        JG      @01AD
        XCHG    DX, AX
@01AD:  PUSH    CX
        PUSH    AX
        JLE     @01BC
        XCHG    CX, AX
@01B2:  MOV     BYTE PTR [DI], 04h
        ADD     DI, 0140h
        LOOP    @01B2
        XCHG    CX, AX
@01BC:  MOV     CX, BX
        ADD     CX, CX
        CMP     CX, 00C8h
        JB      @01C9
        MOV     CX, 00C7h
@01C9:  MOV     AX, CX
        SUB     AX, DX
        shl     ax, 3
        PUSH    DX
        XOR     DX, DX
        DIV     BX
        XCHG    BX, AX
        MOV     DL, cs:[BX+SI]
        MOV     [DI], DL
        XCHG    BX, AX
        ADD     DI, 0140h
        POP     DX
        LOOP    @01C9
        POP     CX
        JCXZ    @01EF
@01E6:  LAHF
        MOV     [DI], AH
        ADD     DI, 0140h
        LOOP    @01E6
@01EF:  POP     CX
        POP     AX
        JMP     @0159
@01F4:  SUB     AL, BL
        JNB     @01FA
        NOT     AL
@01FA:  SHR     AL, 1
        MUL     AL
        RET

   code    ENDS
END     start
