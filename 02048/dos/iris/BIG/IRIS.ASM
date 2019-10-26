; ------------------------------ IRIS.ASM ------------------------------
; Bye Jare of VangeliSTeam. Want more comments? Write'em. O:-)


        .MODEL SMALL
        .STACK 400
        DOSSEG
        LOCALS

PAL_DIVIDER = 2

        .DATA

CosTable LABEL BYTE
        INCLUDE COSTBL.INC

ByeMsg  LABEL BYTE
        INCLUDE IRISTXT.INC
ByeMsgLng = $-ByeMsg

Palette LABEL BYTE
        i = 0
        REPT 128 SHR PAL_DIVIDER
                DB      63, i, 63-i
                i = i+ (1 SHL (PAL_DIVIDER-1))
        ENDM
        i = 0
        REPT 128 SHR PAL_DIVIDER
                DB      63-i, 63, i
                i = i+ (1 SHL (PAL_DIVIDER-1))
        ENDM
        i = 0
        REPT 128 SHR PAL_DIVIDER
                DB      0, 63-i, 63
                i = i+ (1 SHL (PAL_DIVIDER-1))
        ENDM
        i = 0
        REPT 128 SHR PAL_DIVIDER
                DB      i, 0, 63
                i = i+ (1 SHL (PAL_DIVIDER-1))
        ENDM


VTime1  DB 2                            ; Waves' speeds.
VTime2  DB 1
VTime3  DB 3
VTime4  DB 4

        UDATASEG

PlasmaPal DB (256 SHR (PAL_DIVIDER-1))*3 DUP (?)

Time1    DB ?                           ; Waves' positions. Random, eh? ;-)
Time2    DB ?
Time3    DB ?
Time4    DB ?

        .CODE
        .STARTUP

        CLD
        MOV     AX,13h
        INT     10h
        CLI
        MOV     DX,3c4h
        MOV     AX,604h                 ; "Unchain my heart". And my VGA...
        OUT     DX,AX
        MOV     AX,0F02h                ; All planes
        OUT     DX,AX

        MOV     DX,3D4h
        MOV     AX,14h                  ; Disable dword mode
        OUT     DX,AX
        MOV     AX,0E317h               ; Enable byte mode.
        OUT     DX,AX
        MOV     AL,9
        OUT     DX,AL
        INC     DX
        IN      AL,DX
        AND     AL,0E0h                 ; Duplicate each scan 8 times.
        ADD     AL,7
        OUT     DX,AL
        MOV     DX,3c8h                 ; Setup palette.
        MOV     AL,256-(256 SHR (PAL_DIVIDER-1))
        OUT     DX,AL
        INC     DX
        MOV     CX,(256 SHR (PAL_DIVIDER-1))*3
        MOV     SI,OFFSET Palette       ; Prestored...
@@pl1:
         LODSB
         OUT    DX,AL
         LOOP   @@pl1

        MOV     AX,0A000h
        MOV     ES,AX
        
        MOV     SI,OFFSET CosTable
MainLoop:
        MOV     DX,3DAh                 ; Retrace sync.
@@vs1:
        IN      AL,DX
        TEST    AL,8
        JZ      @@vs1
@@vs2:
        IN      AL,DX
        TEST    AL,8
        JNZ     @@vs2
        XOR     DI,DI

        MOV     AH,50                   ; 50 lines.
        MOV     CL,Time3                ; Vertical Wave #1 position.
        MOV     CH,Time4                ; Vertical Wave #2 position.
   @@lv:
        PUSH    AX
        MOV     AH,80                   ; 80 columns. I like this mode. ;-)
        MOV     DL,Time1                ; Horizontal Wave #1 position.
        MOV     DH,Time2                ; Horizontal Wave #2 position.
   @@lh:
        MOV     BX,BP                   ; Global displacement.
        MOV     AL,BL
;        ADD     AL,AH                  ; Could make for more perturbations.
        XOR     BH,BH
        MOV     BL,DL
        ADD     AL,[SI+BX]              ; Add waves.
        MOV     BL,DH
        ADD     AL,[SI+BX]
        MOV     BL,CL
        ADD     AL,[SI+BX]
        MOV     BL,CH
        ADD     AL,[SI+BX]
      IFDIF %PAL_DIVIDER,<1>
        OR      AL, (0FFh SHL (9-PAL_DIVIDER)) AND 0FFh
      ENDIF
        STOSB                           ; Draw it.

        ADD     DL,1                    ; Trace the HWaves.
        ADD     DH,3

        DEC     AH
        JNZ     @@lh                    ; Trace the VWaves.
        ADD     CL,2
        ADD     CH,1
        POP     AX
        DEC     AH
        JNZ     @@lv


        DEC     BP                              ; Get a (reasonably) random.
        MOV     BX,BP
        XOR     BL,BH
        XOR     BL,-1[DI]
        XOR     BL,CL
        XOR     BL,DL
        ADD     BL,CH
        ADD     BL,DH

        XOR     BH,BH                           ; Choose a speed to INC or DEC.
        MOV     Di,OFFSET VTime1
        TEST    BL,8
        JNZ     @@dec
        AND     BL,3
        CMP     BYTE PTR [DI+BX],3
        JG      @@sum
        INC     BYTE PTR [DI+BX]
        JMP     @@sum
      @@dec:
        AND     BL,3
        CMP     BYTE PTR [DI+BX],-3
        JL      @@sum
        DEC     BYTE PTR [DI+BX]
      @@sum:

        MOV     DL,VTime1                       ; Move waves.
        MOV     DH,VTime2
        MOV     CL,VTime3
        MOV     CH,VTime4

        ADD     Time1,DL
        SUB     Time2,DH
        ADD     Time3,CL
        SUB     Time4,CH

        MOV     AH,1
        INT     16h
        JNZ     Bye
        JMP     MainLoop
Bye:
        XOR     AH,AH
        INT     16h
        MOV     AX,3
        INT     10h
        XOR     BH,BH
        MOV     DX,1700h
        MOV     AH,2
        INT     10h

        MOV     AX,0B800h
        MOV     ES,AX
        MOV     SI,OFFSET ByeMsg
        XOR     DI,DI
        MOV     CX,ByeMsgLng/2
        REP     MOVSW

        MOV     AX,4C00h
        INT     21h

        END
; ------------------------------ End of IRIS.ASM ---------------------------

