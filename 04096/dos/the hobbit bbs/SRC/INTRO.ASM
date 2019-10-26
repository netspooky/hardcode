; The Hobbit intro #1
; by Master of Darkness/DeathStar (AKA Lelio della Pietra)

.MODEL SMALL

MAXSTARS        EQU     80
BOXCOLOR        EQU     15
FONTCOLOR       EQU     15
SINOFFSET       EQU     189
SINAMPLI        EQU     64
SINSPEED        EQU     4
SCROLLSPEED     EQU     2
POINTCOLOR      EQU     50
CHARSNO         EQU     40
LINE1           EQU     155
LINE2           EQU     239
BASECOL         EQU     LINE1

CODE_SEG        SEGMENT
                ASSUME  CS:CODE_SEG,CS:CODE_SEG

                ORG     100h

START:          MOV     AX,1A00h
                INT     10h
                CMP     AL,1Ah
                JNZ     NO_VGA  ; No VGA ?!? Ahiahiahiahiahi !
                CMP     BL,7
                JB      NO_VGA  ; No VGA ?!? Ahiahiahiahiahi !
                CALL    INTRO
NO_VGA:         LEA     DX,OUTMSG
                MOV     AH,9
                INT     21h
                MOV     AX,4C00h
                INT     21h

OUTMSG          DB      'Intro by The Master of Darkness/DeathStar',0Dh,0Ah
                DB      'Fonts & Vector by Asavaris/DeathStar',0Dh,0Ah,24h
TEXT            DB      'CALL THE HOBBIT BBS      DEATHSTAR WHQ      39.81.5563352    FIDO 2:335/244            ',0
CRTCData        DB      0E3h
                DW      05F00h,04F01h,05002h,08203h,05404h,08005h
                DW      00D06h,03E07h,0EA10h,08C11h,0DF12h,0E715h
                DW      00616h,04109h,00014h,0E317h,00000h
MASK1           DB      00h,08h,0Ch,0Eh
MASK2           DB      00h,01h,03h,07h
MASK3           DB      00h,00h,04h,02h
RAINBTBL        DB      81h,84h,01h,82h,04h,81h,00h
TEXTPTR         DW      TEXT
SINPTR          DW      SIN2
STARSNO         DB      0
SEED1           DW      INTRO
SEED2           DB      0A5h
ANGLE           DB      0
ANGLE2          DB      0
TIMER           DB      50
SCROLLNO        DB      0
VIDEOCOUNT      DB      0
OLDINT1         DW      0
OLDINT2         DW      0
POINTCOUNT      DB      1


INTRO:          LEA     BX,SIN+63
                LEA     DI,SIN+64
                MOV     CX,64
FILLSIN1LOOP:   MOV     AL,[BX]
                DEC     BX
                STOSB
                LOOP    FILLSIN1LOOP
                LEA     DI,SIN2
                MOV     CL,-128
FILLSIN2LOOP:   MOV     AX,SINAMPLI/2
                CALL    SINMULT
                ADD     AX,SINOFFSET
                STOSB
                INC     CL
                CMP     CL,128
                JNZ     FILLSIN2LOOP
                MOV     AL,0FFh
                STOSB
                LEA     DI,SCROLLBUFFER
                XOR     AX,AX
                MOV     CX,336*8
            REP STOSW
                LEA     SI,FONTS
                LEA     DI,FONTSBUFFER
                MOV     CX,CHARSNO*32
EXPLODEFONTS0:  PUSH    CX
                LODSB
                MOV     AH,AL
                MOV     CX,8
EXPLODEFONTS1:  SHL     AH,1
                JC      SET1
                XOR     AL,AL
                JMP     SET2
SET1:           MOV     AL,FONTCOLOR
SET2:           STOSB
                LOOP    EXPLODEFONTS1
                POP     CX
                LOOP    EXPLODEFONTS0
                CALL    SET_MODEX
                MOV     DX,3C8h
                MOV     BX,1001h
COLORLP0:       MOV     AL,BL
                OUT     DX,AL
                INC     DX
                MOV     AL,BH
                OUT     DX,AL
                OUT     DX,AL
                OUT     DX,AL
                DEC     DX
                ADD     BX,0C01h
                CMP     BL,04h
                JNZ     COLORLP0
COLORLP1:       MOV     AL,BL
                OUT     DX,AL
                INC     DX
                MOV     AL,0FFh
                OUT     DX,AL
                OUT     DX,AL
                OUT     DX,AL
                DEC     DX
                INC     BL
                CMP     BL,32
                JNZ     COLORLP1
                MOV     AL,POINTCOLOR
                OUT     DX,AL
                INC     DX
                MOV     AL,0FFh
                OUT     DX,AL
                INC     AL
                OUT     DX,AL
                OUT     DX,AL
                CALL    RAINBOW
                CALL    SET_INT

MAINLOOP:       MOV     AL,TIMER
                OR      AL,AL
                JZ      DEC_ANGLE
                DEC     AL
                MOV     TIMER,AL
                JMP     NO_DEC_AL
DEC_ANGLE:      MOV     AL,ANGLE
                MOV     CX,2
ANGLELOOP:      INC     AL
                MOV     AH,AL
                AND     AH,7Fh
                JNZ     ANGLENOZERO
                INC     AL
ANGLENOZERO:    LOOP    ANGLELOOP
                MOV     ANGLE,AL
                MOV     AL,ANGLE2
                INC     AL
                TEST    AL,7Fh
                JNZ     ANGLE2NOZERO
                INC     AL
ANGLE2NOZERO:   MOV     ANGLE2,AL

NO_DEC_AL:      MOV     AL,VIDEOCOUNT
                CMP     AL,2
                JL      NO_DEC_AL
                XOR     AL,AL
                MOV     VIDEOCOUNT,AL
                CALL    FLIP_PAGE
                CALL    CLEAR_PAGE


IFNDEF    FINAL
        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        out     dx,al
        out     dx,al
        dec     al
        out     dx,al
ENDIF



                CALL    DRAW_STARS
                CALL    DRAW_VECTOR
                CALL    MOVE_TEXT
                CALL    DRAW_BUFFER
                CALL    DRAW_POINTS

IFNDEF    FINAL        
        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        out     dx,al
        out     dx,al
        out     dx,al
ENDIF
                MOV     AH,1
                INT     16h
                JZ      MAINLOOP
                XOR     AH,AH
                INT     16h
                CALL    RESET_INT
                MOV     AX,0003
                INT     10h
                RET

DRAW_POINTS:    MOV     CL,POINTCOUNT
                INC     CL
                AND     CL,3
                MOV     POINTCOUNT,CL
                PUSH    CX
                MOV     AX,0102h
                SHL     AH,CL
                MOV     DX,3C4h
                MOV     DI,LINE1*80
                CALL    DRAWPTS
                POP     CX
                MOV     AX,0802h
                SHR     AH,CL
                MOV     DI,LINE2*80
DRAWPTS:        OUT     DX,AX
                MOV     AX,POINTCOLOR*256+POINTCOLOR
                MOV     CX,40
            REP STOSW
                RET

                MOV     AX,0102h
                AND     CL,3
                SHL     AH,CL
                MOV     DX,3C4h
                OUT     DX,AX
                MOV     AX,SI
                MOV     ES:[BX],AH
                RET


MOVE_TEXT:      PUSH    ES
                PUSH    DS
                POP     ES
                LEA     DI,SCROLLBUFFER
                MOV     SI,DI
                ADD     SI,SCROLLSPEED
                MOV     CX,(336*8)
            REP MOVSW
                MOV     AL,SCROLLNO
                OR      AL,AL
                JNZ     NO_CHAR
                CALL    PUTLETTER
                MOV     AL,16
NO_CHAR:        SUB     AL,SCROLLSPEED
                MOV     SCROLLNO,AL
                POP     ES
                RET

PUTLETTER:      MOV     SI,TEXTPTR
                LEA     DI,SCROLLBUFFER+320
                LODSB
                OR      AL,AL
                JNZ     PUTNOEND
                LEA     SI,TEXT
                LODSB
PUTNOEND:       MOV     TEXTPTR,SI
                CMP     AL,' '
                JZ      PUTSPACE
                MOV     AH,AL
                LEA     BX,FONTSBUFFER
                LEA     SI,FONTSTABLE
PUTFIND:        LODSB
                OR      AL,AL
                JZ      PUTSPACE
                CMP     AH,AL
                JZ      PUTFOUND
                ADD     BX,256
                JMP     PUTFIND
PUTFOUND:       MOV     CX,16
                MOV     SI,BX
PUTLOOP0:       PUSH    CX
                MOV     CX,8
            REP MOVSW
                POP     CX
                ADD     DI,320
                LOOP    PUTLOOP0
                RET
PUTSPACE:       MOV     CX,16
                XOR     AX,AX
PUTLOOP1:       PUSH    CX
                MOV     CX,8
            REP STOSW
                POP     CX
                ADD     DI,320
                LOOP    PUTLOOP1
                RET


DRAW_BUFFER:    MOV     SI,SINPTR
                XOR     CX,CX
DRAW_BUFLOOP:   LODSB
                CMP     AL,0FFh
                JNZ     NO_SINOVL0
                LEA     SI,SIN2
                LODSB
NO_SINOVL0:     PUSH    CX
                PUSH    SI
                CALL    DRAW_SECTOR
                POP     SI
                POP     CX
                INC     CX
                INC     CX
                CMP     CX,320
                JNZ     DRAW_BUFLOOP
                MOV     SI,SINPTR
                MOV     CX,SINSPEED
SIN_INCR:       INC     SI
                MOV     AL,DS:[SI]
                CMP     AL,0FFh
                JNZ     NO_SINOVL1
                LEA     SI,SIN2
NO_SINOVL1:     LOOP    SIN_INCR
                MOV     SINPTR,SI
                RET

DRAW_SECTOR:    LEA     SI,SCROLLBUFFER
                MOV     BL,AL
                PUSH    CX
                MOV     CX,80
                XOR     AH,AH
                MUL     CX
                MOV     DI,AX
                POP     CX
                ADD     SI,CX
                MOV     AX,CX
                SHR     AX,2
                ADD     DI,AX
                MOV     AX,0102h
                AND     CL,3
                SHL     AH,CL
                MOV     DX,3C4h
                OUT     DX,AX
                PUSH    AX
                PUSH    BX
                PUSH    DX
                PUSH    SI
                PUSH    DI
                CALL    LINEIT
                POP     DI
                POP     SI
                POP     DX
                POP     BX
                POP     AX
                INC     SI
                SHL     AH,1
                OUT     DX,AX
LINEIT:         MOV     CX,16
LINELOOP:       LODSB
                OR      AL,AL
                JZ      TRASPARENT
                MOV     AL,BL
                STOSB
                JMP     NOTRASPARENT
TRASPARENT:     INC     DI
NOTRASPARENT:   ADD     SI,335
                ADD     DI,79
                INC     BL
                LOOP    LINELOOP
                RET

DRAW_VECTOR:    LEA     SI,VECTOR
DRAW_LOOP:      LODSW
                CMP     AX,0FFFFh
                JZ      DRAWN
                MOV     CL,ANGLE
                CALL    COSMULT
                ADD     AX,160
                PUSH    AX
                LODSB
                MOV     DL,AL
                LODSW
                MOV     CL,ANGLE
                CALL    COSMULT
                ADD     AX,160
                MOV     BX,AX
                LODSB
                MOV     CH,AL
                MOV     CL,DL
                POP     AX
                PUSH    SI
                CALL    DRAW_BOX
                POP     SI
                JMP     DRAW_LOOP
DRAWN:          RET

DRAW_BOX:       ; (AX,CL -> BX,CH)
                CMP     CL,CH
                JC      DRAW_BOX0
                XCHG    CH,CL
DRAW_BOX0:      CMP     AX,BX
                JC      DRAW_BOX1
                XCHG    AX,BX
DRAW_BOX1:      SUB     BX,AX
                INC     BX
                MOV     SI,CX
                PUSH    AX
                XOR     CH,CH
                MOV     AX,80
                MUL     CX
                MOV     DI,AX
                POP     AX
                MOV     DX,AX
                SHR     AX,2
                ADD     DI,AX
                MOV     CX,SI
                SUB     CH,CL
                INC     CH
                NEG     DL
                AND     DX,3
                JZ      NOFIRSTBOX
                CMP     BX,DX
                JNC     NOLASTBOX
                CMP     BX,1
                JNZ     NOUNIQUE0
                PUSH    BX
                MOV     BX,DX
                MOV     AH,[MASK3+BX]
                POP     BX
                JMP     LASTBOX2
NOUNIQUE0:      MOV     AH,06h
                JMP     LASTBOX2
NOLASTBOX:      SUB     BX,DX
                PUSH    BX
                PUSH    CX
                MOV     BX,DX
                MOV     AH,[MASK1+BX]
                MOV     CL,1
                CALL    DRAWIT
                POP     CX
                POP     BX
NOFIRSTBOX:     MOV     AH,0Fh
                CMP     BX,4
                JC      LASTBOX
                XOR     CL,CL
NOFIRSTLOOP:    SUB     BX,4
                INC     CL
                CMP     BX,4
                JNC     NOFIRSTLOOP
                PUSH    BX
                PUSH    CX
                CALL    DRAWIT
                POP     CX
                POP     BX
                OR      BX,BX
                JZ      LASTBOXBYE
LASTBOX:        MOV     AH,[MASK2+BX]
LASTBOX2:       MOV     CL,1
                CALL    DRAWIT
LASTBOXBYE:     RET

DRAWIT:         MOV     AL,2
                MOV     DX,3C4h
                OUT     DX,AX
                MOV     BX,CX
                MOV     AX,80
                SUB     AL,CL
                MOV     SI,AX
                MOV     AL,BOXCOLOR
                PUSH    BX
                PUSH    DI
DRAWLP1:        MOV     CL,BL
                XOR     CH,CH
            REP STOSB
                ADD     DI,SI
                DEC     BH
                JNZ     DRAWLP1
                POP     DI
                POP     BX
                XOR     BH,BH
                ADD     DI,BX
                RET

DRAW_STARS:     MOV     AL,STARSNO
                MOV     DI,AX
                XOR     AH,AH
                MOV     CX,3
                MUL     CX
                LEA     BX,STARS
                ADD     AX,BX
                MOV     DX,DI
                CMP     DL,MAXSTARS
                JZ      DRAW_STARS0
                MOV     DX,ES
                CMP     DH,0A0h
                JZ      DRAW_STARS0
                PUSH    AX
                MOV     BX,AX
                CALL    MAKE_STAR
                MOV     AL,STARSNO
                INC     AL
                MOV     STARSNO,AL
                POP     AX
                ADD     AX,3
DRAW_STARS0:    LEA     BX,STARS
                MOV     DI,AX
                LEA     SI,SIN
DRAW_STARS1:    PUSH    DI
                MOV     CL,[BX+2]
                MOV     AL,ANGLE2
                ADD     CL,AL
                MOV     AX,[BX]
                MOV     DI,AX
                INC     AX
                MOV     [BX],AX
                CALL    COSMULT
                PUSH    AX
                MOV     AX,DI
                CALL    SINMULT
                POP     CX
                ADD     CX,160
                ADD     AX,120
                CMP     CX,0
                JLE     DRAW_STARS3
                CMP     CX,320
                JGE     DRAW_STARS3
                CMP     AX,0
                JLE     DRAW_STARS3
                CMP     AX,240
                JL      DRAW_STARS2
DRAW_STARS3:    PUSH    BX
                CALL    MAKE_STAR
                POP     BX
                MOV     CX,160
                MOV     AX,120
                MOV     DI,0
DRAW_STARS2:    PUSH    BX
                PUSH    SI
                PUSH    CX
                MOV     DX,DI
                MOV     CX,4
                SHR     DX,CL
                POP     CX
                MOV     BX,CX
                MOV     AH,DL
                CALL    SET_PIXEL
                POP     SI
                POP     BX
                POP     DI
                ADD     BX,3
                CMP     BX,DI
                JNZ     DRAW_STARS1
                RET

MAKE_STAR:      MOV     Word Ptr [BX],0
                PUSH    BX
                MOV     BX,SEED1
                MOV     AL,[BX]
                INC     BX
                CMP     BX,OFFSET ENDCODE
                JNZ     MAKE_NOOUT
                LEA     BX,INTRO
MAKE_NOOUT:     MOV     SEED1,BX
                POP     BX
                MOV     AH,SEED2
                MOV     SEED2,AL
                XOR     AL,AH
                MOV     Byte Ptr [BX+2],AL
                RET

                ; AX,CL

COSMULT:        PUSH    CX
                ADD     CL,64
                CALL    SINMULT
                POP     CX
                RET
SINMULT:        PUSH    SI
                PUSH    CX
                PUSH    DX
                LEA     SI,SIN
                XOR     CH,CH
                CMP     CL,128
                JNZ     NOZEROSIN
                XOR     CL,CL
                JMP     ZEROSIN
NOZEROSIN:      JNC     NEGSIN
ZEROSIN:        ADD     SI,CX
                MOV     CL,[SI]
                CMP     AX,0
                JGE     NEGARG1
                NEG     AX
                MUL     CL
                MOV     CL,6
                SHR     AX,CL
                NEG     AX
                JMP     SINOK
NEGARG1:        MUL     CL
                MOV     CL,6
                SHR     AX,CL
                JMP     SINOK
NEGSIN:         NEG     CL
                ADD     SI,CX
                MOV     CL,[SI]
                CMP     AX,0
                JGE     NEGARG2
                NEG     AX
                MUL     CL
                MOV     CL,6
                SHR     AX,CL
                JMP     SINOK
NEGARG2:        MUL     CL
                MOV     CL,6
                SHR     AX,CL
                NEG     AX
SINOK:          POP     DX
                POP     CX
                POP     SI
                RET

CLEAR_PAGE:     MOV     DX,3C4h
                MOV     AX,0F02h        ; Enable all planes
                OUT     DX,AX
                XOR     DI,DI
                XOR     AX,AX
                MOV     CX,320/8*240
            REP STOSW
                RET


FLIP_PAGE:      MOV     DX,3DAh
FLIP_WAIT1:     IN      AL,DX
                AND     AL,8
                JNZ     FLIP_WAIT1
                MOV     DX,03D4h
                MOV     AX,ES
                CMP     AX,0A000h
                JZ      FLIP_PAGE1
                MOV     AX,0A000h
                MOV     ES,AX
                MOV     AX,800Ch
                JMP     FLIP_PAGE2
FLIP_PAGE1:     MOV     AX,0A800h
                MOV     ES,AX
                MOV     AX,000Ch
FLIP_PAGE2:     OUT     DX,AX
                MOV     DX,3DAh
FLIP_WAIT2:     IN      AL,DX
                AND     AL,8
                JZ      FLIP_WAIT2
                RET

SET_PIXEL:      ;(BX,AL color AH)
                MOV     SI,AX
                XOR     AH,AH
                MOV     CX,80
                MUL     CX
                MOV     CL,BL
                SHR     BX,2
                ADD     BX,AX
                MOV     AX,0102h
                AND     CL,3
                SHL     AH,CL
                MOV     DX,3C4h
                OUT     DX,AX
                MOV     AX,SI
                MOV     ES:[BX],AH
                RET

INT8_ROUT:      PUSH    AX
                PUSH    DX
                
                
IFNDEF    FINAL
        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        out     dx,al
        dec     al
        out     dx,al
        inc     al
        out     dx,al

        mov     ax,0fh
lp:     nop
        nop
        nop
        dec     ax
        jnz     lp

        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        out     dx,al
        out     dx,al
        out     dx,al
ENDIF
                
                INC     CS:[VIDEOCOUNT]
                MOV     AL,20h
                OUT     20h,AL
                POP     DX
                POP     AX
                IRET

SET_INT:        MOV     CX,CS
                MOV     DX,OFFSET INT8_ROUT
                MOV     BX,19891
                CALL    INTROUT
                MOV     [OLDINT1],CX
                MOV     [OLDINT2],DX
                RET

RESET_INT:      MOV     CX,[OLDINT1]
                MOV     DX,[OLDINT2]
                XOR     BX,BX
INTROUT:        PUSH    ES
                XOR     AX,AX
                MOV     ES,AX
                CLI
                MOV     AX,ES:[32]
                PUSH    AX
                MOV     AX,ES:[34]
                PUSH    AX
                MOV     ES:[34],CX
                MOV     ES:[32],DX
                CALL    WAIT_RETRACE
                MOV     AL,36h
                OUT     43h,AL
                MOV     AL,BL
                OUT     40h,AL
                MOV     AL,BH
                OUT     40h,AL
                STI
                POP     CX
                POP     DX
                POP     ES
                RET

RAINBOW:        MOV     SI,OFFSET RAINBTBL
                MOV     DX,3C8h
                MOV     AL,BASECOL
                OUT     DX,AL
                INC     DX
                MOV     DI,DX
                XOR     BX,BX
                DEC     BX
                MOV     CL,BH
                CALL    OUTEM
RAINBLP0:       LODSB
                OR      AL,AL
                JZ      RAINBOUT
                MOV     AH,AL
                CALL    RAINBIT
                JMP     RAINBLP0
RAINBOUT:       RET

; AH = Table, BL = r, BH = g, CL = b, CH = count, DX = adder

RAINBIT:        MOV     DX,0405h
                TEST    AH,80h
                JZ      RAINBNOSUB
                NEG     DH
                NEG     DL
RAINBNOSUB:     MOV     CH,14
RAINBLP1:       TEST    AH,4
                JZ      NOADD1
                ADD     BL,DL
NOADD1:         TEST    AH,2
                JZ      NOADD2
                ADD     BH,DL
NOADD2:         TEST    AH,1
                JZ      NOADD3
                ADD     CL,DL
NOADD3:         CALL    OUTEM
                XCHG    DL,DH
                DEC     CH
                JNZ     RAINBLP1
                RET

OUTEM:          XCHG    DI,DX
                MOV     AL,BL
                OUT     DX,AL
                MOV     AL,BH
                OUT     DX,AL
                MOV     AL,CL
                OUT     DX,AL
                XCHG    DI,DX
                RET

SET_MODEX:      MOV     AX,0013h                ; Sets VGA linear 320x200x256
                INT     10h
                LEA     SI,CRTCData
                MOV     DX,3C4h                 ; Disable Chain-Four
                MOV     AX,0604h
                OUT     DX,AX
                MOV     AX,0100h                ; Asyncronous sequencer reset
                OUT     DX,AX
                PUSH    DX
                MOV     DX,3C2h
                LODSB                           ; Reprogram timing/size
                OUT     DX,AL
                POP     DX
                MOV     AX,0300h                ; Restart Sequencer
                OUT     DX,AX
                MOV     DX,3D4h
                MOV     AL,11h                  ; Vert retrace end register
                OUT     DX,AL
                INC     DX
                IN      AL,DX
                AND     AL,7Fh                  ; Mask OUT WProtect bit
                OUT     DX,AL
                MOV     DX,3D4h
MODEX_LOOP:     LODSW
                OR      AX,AX
                JZ      MODEX_LOOP_OUT
                OUT     DX,AX
                JMP     MODEX_LOOP
MODEX_LOOP_OUT:
                MOV     AX,0A000h               ; Clear Display Memory
                MOV     ES,AX
                XOR     DI,DI
                XOR     AX,AX
                MOV     CX,8000h
            REP STOSW
                MOV     CX,5
MODEX_WAIT:     CALL    WAIT_RETRACE
                LOOP    MODEX_WAIT
                RET

WAIT_RETRACE:   MOV     DX,3DAh
WAIT_LOW:       IN      AL,DX
                AND     AL,8
                JNZ     WAIT_LOW
WAIT_HIGH:      IN      AL,DX
                AND     AL,8
                JZ      WAIT_HIGH
                RET

ENDCODE:

                INCLUDE FONTS.ASM
VECTOR:         INCLUDE VECTOR.ASM

SIN     DB    0,  2,  3,  5,  6,  8,  9, 11, 12, 14, 16, 17, 19, 20, 22, 23
        DB   24, 26, 27, 29, 30, 32, 33, 34, 36, 37, 38, 39, 41, 42, 43, 44
        DB   45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 56, 57, 58, 59
        DB   59, 60, 60, 61, 61, 62, 62, 62, 63, 63, 63, 64, 64, 64, 64, 64

THATSALLFOLKS:

SIN2            EQU     THATSALLFOLKS+100
STARS           EQU     THATSALLFOLKS+2000
SCROLLBUFFER    EQU     THATSALLFOLKS+3000
FONTSBUFFER     EQU     THATSALLFOLKS+16000

CODE_SEG        ENDS

                END START
