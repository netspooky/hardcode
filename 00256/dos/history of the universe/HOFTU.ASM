code    segment public
        assume  cs:code
        org     100h
.386
start:

        MOV     AX, 0013h
        INT     10h
        MOV     DX, 03C2h
        MOV     AL, 0E3h
        OUT     DX, AL
        push    09000h
        pop     es
        xor     di, di
        xor     ax, ax
        MOV     CX, 08000h
        REPZ
        STOSW
        MOV     DL, 0C8h
        OUT     DX, AL
        INC     DX
@011C:  MOV     AL, CL
        OUT     DX, AL
        OUT     DX, AL
        SHR     AL, 1h
        OUT     DX, AL
        INC     CL
        JNZ     @011C
@0127:  push    09000h
        pop     es
        mov     ch, 0fah
@012D:  MOV     AL, byte ptr es:[DI]
        imul    ax, 0000fh
        shr     ax, 4h
        stosb
        LOOP    @012D
        MOV     BH, 01h
@013B:  LODSB
        CBW
        MOV     word ptr ds:@@0200, AX
        LODSB
        CBW
        MOV     word ptr ds:@@0202, AX
        LODSB
        CBW
        DEC     SI
        MOV     word ptr ds:@@0204, AX
        MOV     DI, offset ds:@@0200
        CALL    @01C5
        MOV     DI, offset ds:@@0204
        CALL    @01C5
        MOV     AX, offset ds:[DI]
        CBW
        ADD     AX, 0190h
        MOV     CX, AX
        MOV     AH, byte ptr ds:@@0200
        CWD
        IDIV    CX
        imul    di, ax, 0140h
        mov     ah, byte ptr ds:[si]
        cwd
        IDIV    CX
        ADD     DI, AX
        MOV     byte ptr es:[DI+07DA0h], CL
        DEC     BX
        JNZ     @013B
        INC     WORD PTR ds:@@01FE
        MOV     AX, 0FFFFh
        MOV     DI, 0F906h
        MOV     CX, 0041Dh
        REPZ
        STOSW
        PUSH    ES
        push    0a000h
        pop     es
        pop     ds
        XOR     SI, SI
        XOR     DI, DI
        MOV     CX, 08000h
        REPZ
        MOVSW
        PUSH    CS
        PUSH    CS
        POP     DS
        POP     ES
        MOV     BP, offset ds:@@01F5
        MOV     DX, 01801h
        MOV     BX, 000FFh
        MOV     CX, 00007h
        MOV     AX, 01300h
        INT     10h
        IN      AL, 60h
        DEC     AL
        jne     @0127
        MOV     AX, 0003h
        INT     10h
        RET
@01BA:  FILD    word ptr ds:@@01FE
        FILD    word ptr ds:@@01FC
        FDIVP   ST(1), ST
        RET
@01C5:  MOV     SI, offset ds:@@0202
        CALL    @01BA
        fcos
        FILD    word ptr ds:[DI]
        FMULP   ST(1), ST
        CALL    @01BA
        fcos
        FILD    WORD PTR ds:[SI]
        FMULP   ST(1), ST
        FADDP   ST(1), ST
        CALL    @01BA
        fcos
        FILD    WORD PTR ds:[DI]
        FMULP   ST(1), ST
        CALL    @01BA
        fsin
        FILD    WORD PTR ds:[SI]
        FMULP   ST(1), ST
        FSUBP   ST(1), ST
        FISTP   WORD PTR ds:[SI]
        FISTP   WORD PTR ds:[DI]
        RET
@@01F5  db "dave/sb"
@@01FC  db      0c8h, 000h
@@01FE  db      02Ch, 001h
@@0200  dw      ?
@@0202  dw      ?
@@0204  dw      ?
   code   ends
end       start
                                                        

