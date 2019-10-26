.286c
ILE_KLAWISZY    EQU     8
UP_KEY          EQU     72
DOWN_KEY        EQU     80
HOME_KEY        EQU     71
END_KEY	        EQU     79
PGDOWN_KEY      EQU     81
PGUP_KEY        EQU     73
ESC_KEY         EQU     27

SEG_A   SEGMENT BYTE PUBLIC
        ASSUME	CS:SEG_A, DS:SEG_A, ES:SEG_A, SS:SEG_A
        ORG     100h

START:
        JMP     SHORT REALLY_START
ABOUT   DB      ' TXT View 1.00 '
REALLY_START:
        LEA     DI,LINIA
        XOR     AX,AX
        MOV     CX,30270
        REP     STOSW
        MOV     SI,82H
        ADD     CL,BYTE PTR [SI-02H]
        JNZ     SHORT JEST_PARAMETR
FILE_ERROR:
        MOV     AH,09H
        LEA     DX,NO_PARAM
        INT     21H
        RET
JEST_PARAMETR:
        DEC     CX
        MOV     BYTE PTR [NAZWA_LEN],CL
        LEA     DI,NAZWA
        MOV     DX,DI
        REP     MOVSB
        MOV     AX,0D00H
        STOSW
        MOV     AH,3DH
        INT     21H
        JC      SHORT FILE_ERROR
        XCHG    AX,BX
        MOV     CX,50000
        MOV     AH,3FH
        LEA     DX,PLIK
        INT     21H
        OR      AX,AX
        JZ      SHORT FILE_ERROR
        MOV     CX,AX
        MOV     DI,DX
        ADD     DI,AX
        MOV     AL,0DH
        STOSB
        MOV     AH,3EH
        INT     21H
        MOV     WORD PTR [LINIE],DX
        XOR     BP,BP
        XOR     BX,BX
        MOV     DI,DX
        MOV     AL,0DH
LICZ_LINIE:
        REPNE   SCASB
        JCXZ    SHORT KONIEC_LICZENIA
        INC     BX
        MOV     SI,BX
        SHL     SI,01H
        INC     DI
        MOV     WORD PTR [SI+LINIE],DI
        DEC     DI
        JMP     SHORT LICZ_LINIE
KONIEC_LICZENIA:
        MOV     WORD PTR [ILE_LINII],BX
        CALL    VIDEO_INIT
        MOV     AH,01H
        MOV     CH,20H
        INT     10H
        MOV     AX,71B0H
        MOV     ES,WORD PTR [VIDEO_MEMORY]
        XOR     DI,DI
        MOV     CX,1920
        REP     STOSW
        MOV     AL,20H
        MOV     CL,80
        REP     STOSW
        MOV     AH,70H
        LEA     SI,DOWN_LINE
        INC     CX
        MOV     DL,24
        CALL    WRITE_LINE
        LEA     SI,NIC
        MOV     CL,40
        MOV     AL,BYTE PTR [NAZWA_LEN]
        SHR     AL,01H
        SUB     CL,AL
        MOV     DL,01H
        MOV     AH,1FH
        CALL    WRITE_LINE
RYSUJ_TEXT:
        MOV     DX,03DAH
SYNCHRO:
        IN      AL,DX
        AND     AL,08H
        JZ      SYNCHRO
        MOV     CX,4C01H
        MOV     DX,1402H
        PUSH    CX
        PUSH    DX
        MOV     AL,80
        MUL     DL
        XOR     CH,CH
        ADD     AX,CX
        SHL     AX,01H
        XCHG    AX,DI
        POP     DX
        POP     CX
        MOV     AX,0FC9H
        MOV     ES,WORD PTR [VIDEO_MEMORY]
        STOSW
        SHR     CX,08H
        SHR     DX,08H
        PUSH    CX
        MOV     BX,CX
        SHL     BX,01H
        MOV     AL,205
        REP     STOSW
        MOV     AL,187
        STOSW
        POP     CX
DRAW_LINE_1:
        ADD     DI,156
        SUB     DI,BX
        DEC     DX
        JZ      SHORT DRAW_LINE_2
        PUSH    CX
        MOV     AL,186
        STOSW
        MOV     AL,20H
        REP     STOSW
        MOV     AL,186
        STOSW
        POP     CX
        JMP     SHORT DRAW_LINE_1
DRAW_LINE_2:
        MOV     AL,200
        STOSW
        MOV     AL,205
        REP     STOSW
        MOV     AL,188
        STOSW
        MOV     WORD PTR [TERAZ_LINIA],CX
PISZ:
        MOV     BX,BP
        ADD     BX,WORD PTR [TERAZ_LINIA]
        SHL     BX,01H
        MOV     SI,WORD PTR [LINIE+BX]
        PUSH    CS
        POP     ES
        LEA     DI,LINIA
        XOR     DX,DX
ROZSZERZAJ:
        LODSB
        CMP     AL,0DH
        JE      SHORT KONIEC_ROZSZERZANIA
        INC     DX
        CMP     AL,09H
        JNE     SHORT NIE_TABULACJA
        MOV     CX,DX
        MOV     BL,08H
DO_MNOGOSCI_8:
        MOV     AX,DX
        DIV     BL
        OR      AH,AH
        JZ      JEST_MNOGOSC_8
        INC     DX
        JMP     SHORT DO_MNOGOSCI_8
JEST_MNOGOSC_8:
        PUSH    DX
        SUB     DX,CX
        MOV     CX,DX
        POP     DX
        MOV     AL,20H
        REP     STOSB
NIE_TABULACJA:
        STOSB
        JMP     SHORT ROZSZERZAJ
KONIEC_ROZSZERZANIA:
        STOSB
        MOV     DX,WORD PTR [TERAZ_LINIA]
        MOV     CL,03H
        ADD     DL,CL
        LEA     SI,LINIA
        MOV     AH,0FH
        CALL    WRITE_LINE
        INC     WORD PTR [TERAZ_LINIA]
        MOV     AX,WORD PTR [ILE_LINII]
        CMP     WORD PTR [TERAZ_LINIA],AX
        JA      SHORT CZEKAJ_NA_KLAWISZ
        MOV     AX,WORD PTR [TERAZ_LINIA]
        MOV     CL,19
        DIV     CL
        OR      AH,AH
        JNZ     SHORT PISZ
CZEKAJ_NA_KLAWISZ:
        MOV     AH,07H
        INT     21H
        CLI
        CMP     AL,ESC_KEY
        JE      SHORT ZAKONCZ
        CMP     AL,UP_KEY
        JNE     @@2
        OR      BP,BP
        JZ      SHORT CZEKAJ_NA_KLAWISZ
        DEC     BP
SKOK:
        JMP     RYSUJ_TEXT
@@2:
        CMP     AL,DOWN_KEY
        JNE     @@3
        MOV     AX,BP
        ADD     AX,WORD PTR [TERAZ_LINIA]
        DEC     AX
        CMP     AX,WORD PTR [ILE_LINII]
        JAE     SHORT CZEKAJ_NA_KLAWISZ
        INC     BP
        JMP     SHORT SKOK
@@3:
        CMP     AL,HOME_KEY
        JNE     @@4
@@33:
        XOR     BP,BP
        JMP     SHORT SKOK
@@4:
        CMP     AL,END_KEY
        JNE     @@5
@@44:
        MOV     AX,WORD PTR [ILE_LINII]
        CMP     AX,CX
@@444:
        JBE     SHORT CZEKAJ_NA_KLAWISZ
WIECEJ_NIZ_19:
        PUSH    AX
        XOR     DX,DX
        DIV     CX
        POP     BP
        SUB     BP,18
        JMP     SHORT SKOK
@@5:
        CMP     AL,PGDOWN_KEY
        JNE     @@6
        MOV     AX,WORD PTR [ILE_LINII]
        MOV     BX,BP
        ADD     BX,CX
        SUB     AX,BX
        JC      @@444
@@55:
        CMP     AX,CX
        JBE     @@44
        ADD     BP,CX
        JMP     SHORT SKOK
@@6:
        CMP     AL,PGUP_KEY
        JNE     SHORT CZEKAJ_NA_KLAWISZ
        CMP     BP,CX
        JBE     @@33
        SUB     BP,CX
        JMP     SHORT SKOK
ZAKONCZ:
VIDEO_INIT      PROC
        MOV     AH,0FH
        INT     10H
        CMP     AL,03H
        JE      SHORT VIDEO_INIT_1
        SUB     WORD PTR [VIDEO_MEMORY],800H
VIDEO_INIT_1:
        XOR     AH,AH
        INT     10H
        RET
VIDEO_INIT      ENDP
WRITE_LINE      PROC
        PUSH    AX
        MOV     AL,80
        MUL     DL
        XOR     CH,CH
        ADD     AX,CX
        SHL     AX,01H
        XCHG    AX,DI
        POP     AX
        MOV     ES,WORD PTR [VIDEO_MEMORY]
        MOV     CX,74
WRITE_LINE_1:
        LODSB
        CMP     AL,0DH
        JE      SHORT WRITE_LINE_2
        STOSW
        LOOP    WRITE_LINE_1
WRITE_LINE_2:
        PUSH    CS
        POP     ES
        RET
WRITE_LINE      ENDP

NO_PARAM        DB      'Podaj poprawn¥ nazw© pliku jako parametr!$'
DOWN_LINE       DB      24,44,32,25,', PageDown, PageUp, Home, End  '
                DB      'Przesuwanie textu  Esc Wyjd«',0Dh
VIDEO_MEMORY    DW      0B800H
NAZWA_LEN       DB      ?
LINIA           DB      350 DUP (?)
NIC             DB      ?
NAZWA           DB      160 DUP (?)
ILE_LINII       DW      ?
TERAZ_LINIA     DW      ?
LINIE           DW      5000 DUP (?)
PLIK            DB      50000 DUP (?)


SEG_A   ENDS
END     START
