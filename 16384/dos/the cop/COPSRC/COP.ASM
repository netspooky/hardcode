; ------------------------------ COP.ASM --------------------------------
; Bye Jare of VangeliSTeam. Want more comments? Write'em. O:-)
; -----------------------------------------------------------------------
;   Slightly inspired (that is, absolutely copied) from the by now famous
; "vertical copper" seen  in Surprise! Productions' Copper demo. It's one
; of the best ideas for years, Rick!
; -----------------------------------------------------------------------
;   Do anything you want with this source, but NEVER say it's yours. That
; would be a lie, so there you are. If you use it please DO credit me. If
; you write another version DO credit Rick. If  you like it, write to us;
; it would be nice to know.
; -----------------------------------------------------------------------

; ----- Configuration of the execution. ---------
TRACE   = 0
COPH    = 200
BOTCOPH =  60
TEXTH   = 200-(COPH+BOTCOPH)/2


ANGLEDIVISOR = 6
ANGLEINC = 1 SHL (ANGLEDIVISOR - 3)

        .MODEL SMALL
        .STACK 400
        .286
        DOSSEG
        LOCALS

        INCLUDE VGASM.INC

        .DATA

; ------------ Cosinus table, and Sin() and Cos() neat macros. ----------

CosTbl LABEL WORD
        INCLUDE COSTBL.INC

Cos MACRO dest
        SHR     BX,ANGLEDIVISOR-1
        AND     BX,7FEh
        MOV     &dest,[CosTbl+BX]
ENDM

Sin MACRO dest
        ADD     BH,(1 SHL ANGLEDIVISOR)
        Cos     &dest
ENDM

        UDATASEG

DOSPal  DB 768 DUP (?)
WorkPal DB 768 DUP (?)

OldInt9OFF DW ?
OldInt9SEG DW ?

VPoss   DW 2*COPH DUP (?)

        .DATA

DisplayStart DW 0

Wave1   DW 6434
Wave2   DW 23
Wave3   DW 1245
Wave4   DW 8674

BarPal LABEL BYTE
        DB 43, 43, 43
        DB 53, 53, 53
        DB 63, 63, 63
        DB 53, 53, 53
        DB 43, 43, 43
        DB 33, 33, 33
        DB 23, 23, 23
        DB 13, 13, 13

        DB  0, 43,  0
        DB  0, 63,  0
        DB  0, 33,  0
        DB  0, 13,  0
        DB  0,  0, 57
        DB  0, 16, 63
        DB  0,  0, 53
        DB  0,  0, 43

        DB 15*3 DUP (0)

NormPal LABEL BYTE
        INCLUDE NORMPAL.INC

 ; --------- Text data --------------------

FontBytes LABEL BYTE
        INCLUDE FONT.DB

TextData LABEL BYTE
        INCLUDE TEXTDATA.DB
TextPos DW OFFSET TextData
TextCount DB 0
TextWait  DW 1
BarIndex  DB 208


 ; ---------- Nifty nonVGA msg. Perhaps nobody I will ever see it. ----

VgaMsg  DB '   Ooohhhhh.... I''m sorry, you need at least a VGA card to run COP.', 13, 10
        DB 'Go buy one, COP is worth the ca$h. ;-)', 13, 10, 10

 ; ------------------  And the greetings!!! -------------------

ByeMsg LABEL BYTE
        INCLUDE COPGRT.INC
ByeMsgLng = $-OFFSET ByeMsg


;=======================================================================
;=======================================================================

        .CODE
        .STARTUP
                                                   ; VGA card detection
        XOR     BX,BX
        MOV     AX,01A00h
        INT     10h
        CMP     BL,7
        JC      @@novga
        CMP     BL,0Dh
        JC      SetupVideo
    @@novga:
        MOV     DX,OFFSET VgaMsg
ErrorExit:
        MOV     AH,9
        INT     21h
        MOV     AX,4C01h
        INT     21h
SetupVideo:
        CALL    SetupVideoMode

        CLI
        IN      AL,21h
        PUSH    AX
        OR      AL,11111101b    ; No interrupts but keyboard.
        OUT     21h,AL
        CLI
        XOR     AX,AX
        MOV     ES,AX
        MOV     AX,ES:[9*4]
        MOV     [OldInt9OFF],AX
        MOV     AX,ES:[9*4+2]
        MOV     [OldInt9SEG],AX
        MOV     AX,OFFSET MyInt9
        MOV     ES:[9*4],AX
        MOV     ES:[9*4+2],CS
        STI                     

        VSync
MainLoop:

        CALL    CalcCopper

        MOV     AX,0A000h
        MOV     ES,AX
        MOV     DI,[DisplayStart]
        XOR     AX,AX
        MOV     CX,160
        REP STOSW

        SetBorder 0, 0, 0

        WaitForRetrace
        MOV     DX,3D4h
        MOV     AX,013h                 ; Logical scan width = 0.
        OUT     DX,AX 
        SetBorder 0, 0, 63

        CALL    SetHRasterPal

        CALL    ShowCopper
        CALL    ShowBottomCopper
        SetBorder 0, 63, 0
        CALL    DoText

        SetBorder 63, 63, 0

        CMP     CS:[ESCPressed],0
        JNZ     Exit
        JMP     MainLoop
Exit:
        XOR     AX,AX
        MOV     ES,AX
        CLI
        MOV     AX,[OldInt9OFF]
        MOV     ES:[9*4],AX
        MOV     AX,[OldInt9SEG]
        MOV     ES:[9*4+2],AX
        POP     AX              ; Restore PIC mask.
        OUT     21h,AL
        STI

        CALL    GreetGoodBye

        MOV     AX,4C00h
        INT     21h

;=======================================================================

ESCPressed DB 0

MyInt9:
        PUSH    AX
        IN      AL,60h
        CMP     AL,1
        JNZ     @@nok
         MOV    CS:[ESCPressed],1
    @@nok:
        IN      AL,61h
        MOV     AH,AL
        OR      AL,80h
        OUT     61h,AL
        MOV     AL,AH
        OUT     61h,AL
        MOV     AL,20h         ; Signal EOI.
        OUT     20h,AL
        POP     AX
        IRET

;=======================================================================

SetupVideoMode:
        CLD
        XOR     AL,AL
        MOV     CX,256
        MOV     DI,OFFSET DOSPal
        CALL    GetPalette
        MOV     DI,OFFSET WorkPal
        MOV     SI,OFFSET DOSPal
        MOV     CX,768/2
        REP MOVSW

        MOV     DX,4000h
      @@l1:
        MOV     DI,OFFSET WorkPal
        MOV     CX,256
        DEC     DH
        PUSH    DX
        CALL    FadeCol
        OR      AH,AH
        JNZ     @@c1
        VSync
        MOV     SI,OFFSET WorkPal
        MOV     CX,128
        XOR     AL,AL
        CALL    DumpPalette
        VSync
        MOV     SI,OFFSET WorkPal+128*3
        MOV     CX,128
        MOV     AL,CL
        CALL    DumpPalette
        POP     DX
        JMP     @@l1 
      @@c1:
        POP     DX

        MOV     AX,13h
        INT     10h
        CALL    ZeroPalette

        MOV     AX,0A000h
        MOV     ES,AX
        MOV     DH,TEXTH
        XOR     DI,DI
     @@l2:
         MOV    AL,207
         SUB    AL,[BarIndex]
         MOV    AH,AL
         MOV    CX,160
         REP STOSW
         INC    [BarIndex]
         JNZ    @@c2
          MOV   [BarIndex],208
      @@c2:
         DEC    DH
         JNZ    @@l2

        MOV     AL,1
        MOV     CX,207
        MOV     SI,OFFSET BarPal
        JMP     DumpPalette

;=======================================================================

GreetGoodBye:
        CALL    ZeroPalette
        MOV     AX,3
        INT     10h
        CALL    ZeroPalette
        MOV     AX,DS
        MOV     ES,AX
        MOV     DI,OFFSET WorkPal
        MOV     CX,768/2
        XOR     AX,AX
        REP STOSW

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

        MOV     DH,40h
      @@l1:
        MOV     DI,OFFSET WorkPal
        MOV     SI,OFFSET DOSPal
        MOV     CX,256
        DEC     DH
        PUSH    DX
        CALL    FadePal
        OR      AH,AH
        JNZ     @@c1
        VSync
        MOV     SI,OFFSET WorkPal
        MOV     CX,128
        XOR     AL,AL
        CALL    DumpPalette
        VSync
        MOV     SI,OFFSET WorkPal+128*3
        MOV     CX,128
        MOV     AL,CL
        CALL    DumpPalette
        POP     DX
        JMP     @@l1 
      @@c1:                   
        POP     DX
        RET

;=======================================================================

DoText:
        MOV     CX,[TextWait]
        DEC     CX
        JZ      @@doscr
         MOV    [TextWait],CX
         RET
     @@doscr:
        MOV     AL,[TextCount]
        XOR     AH,AH
        SHL     AX,4
        ADD     AX,OFFSET FontBytes
        MOV     SI,AX
        MOV     BX,[TextPos]
        MOV     CL,20
        MOV     AX,0A000h
        MOV     ES,AX
        MOV     DI,[DisplayStart]
        MOV     DL,207
        SUB     DL,[BarIndex]
     @@l1:
         PUSH   SI
         MOV    AL,[BX]
         INC    BX
         CMP    AL,'a'
         JC     @@nolet
         CMP    AL,'z'+1
         JNC    @@nolet
         SUB    AL,'a'
         MOV    AH,AL
         JMP    @@oksp
     @@nolet:
         MOV    AH,26
         CMP    AL,'S'
         JZ     @@oksp
         INC    AH
         CMP    AL,'T'
         JZ     @@oksp
         INC    AH
         CMP    AL,':'
         JZ     @@oksp
         INC    AH
         CMP    AL,'-'
         JZ     @@oksp
         INC    AH
         CMP    AL,'_'
         JZ     @@oksp
         INC    AH
         CMP    AL,')'
         JZ     @@oksp
         INC    AH
         CMP    AL,'.'
         JZ     @@oksp
         INC    AH
         CMP    AL,','
         JZ     @@oksp
         INC    AH
         CMP    AL,''''
         JZ     @@oksp
         INC    AH
         CMP    AL,'!'
         JZ     @@oksp
         INC    AH
         CMP    AL,'('
         JZ     @@oksp
         INC    AH
       @@oksp:
         XOR    AL,AL
         ADD    SI,AX
         REPT 8
            LOCAL @@c1, @@c2
            LODSW
            OR     AL,AL
            JNZ    @@c1
             MOV   AL,DL
          @@c1:
            OR     AH,AH
            JNZ    @@c2
             MOV   AH,DL
          @@c2:
            MOV    ES:[DI+TEXTH*320],AX
            STOSW
         ENDM
         POP    SI
         DEC    CL
         JZ     @@endd
         JMP   @@l1
     @@endd:
        MOV     AL,[TextCount]
        INC     AL
        AND     AL,15
        MOV     [TextCount],AL
        JNZ     @@advd
         MOV    AL,[BX]
         INC    BX
         MOV    [TextPos],BX
         OR     AL,AL
         JZ     @@advd
         INC    AL
         JNZ    @@wait
          MOV   [TextPos],OFFSET TextData
          MOV   [TextWait],1
          JMP   @@advd
     @@wait:
         XOR    AH,AH
         ADD    AX,AX
         MOV    [TextWait],AX

     @@advd:
        INC     [BarIndex]
        JNZ     @@c0
         MOV    [BarIndex],208
     @@c0:
        MOV     CX,[DisplayStart]
        ADD     CX,320
        CMP     CX,320*TEXTH
        JC      @@c1
         XOR    CX,CX
     @@c1:
        MOV     [DisplayStart],CX
        SHR     CX,2
        MOV     DX,3D4h
        MOV     AL,0Ch
        MOV     AH,CH
        OUT     DX,AX
        INC     AL
        MOV     AH,CL
        OUT     DX,AX
        RET

;=======================================================================
;=======================================================================

SetHRasterPal:
        MOV     AL,[BarIndex]
        MOV     CX,256
        XOR     AH,AH
        SUB     CX,AX
        MOV     SI,OFFSET BarPal-3
        ADD     SI,AX
        ADD     SI,AX
        ADD     SI,AX
        MOV     AL,208
        CALL    DumpPalette
        MOV     CL,[BarIndex]
        SUB     CL,208
        JZ      @@bye
        MOV     AL,CL
        XOR     CH,CH
        NEG     AL
        MOV     SI,OFFSET BarPal+3*207
        CALL    DumpPalette
    @@bye:
        RET

;=======================================================================

CalcCopper:
        MOV     BP,[DisplayStart]
        ADD     BP,160+20
CalcCopper1:
        MOV     DI,OFFSET VPoss
        MOV     CX,COPH
        MOV     SI,[Wave1]
        MOV     DX,[Wave2]
    @@l1:
         PUSH   CX
         MOV    BX,SI
         Cos    CX
         SAR    CX,1
         MOV    BX,DX
         Cos    AX
         SAR    AX,2
         ADD    AX,CX
         MOV    AL,AH
         CBW
         ADD    AX,BP 
         MOV    [DI],AX
         ADD    DI,4
         ADD    SI,1*347
         ADD    DX,1*275
         POP    CX
         LOOP   @@l1
        ADD     [Wave1],11*100
        ADD     [Wave2],9*100

        MOV     BP,[DisplayStart]
        ADD     BP,160-16
CalcCopper2:
        MOV     DI,OFFSET VPoss+2
        MOV     CX,COPH
        MOV     SI,[Wave3]
        MOV     DX,[Wave4]
    @@l1:
         PUSH   CX
         MOV    BX,SI
         Cos    CX
         SAR    CX,1
         MOV    BX,DX
         Cos    AX
         SAR    AX,3
         ADD    AX,CX
         MOV    AL,AH
         CBW
         ADD    AX,BP
         MOV    [DI],AX
         ADD    DI,4
         ADD    SI,1*247
         ADD    DX,1*575
         POP    CX
         LOOP   @@l1
        ADD     [Wave3],743
        ADD     [Wave4],913
        RET

;=======================================================================

ShowCopper:
        MOV     SI,OFFSET VPoss
        MOV     AX,DS
        MOV     ES,AX
        MOV     AX,0A000h
        MOV     DS,AX
        MOV     CX,2
        MOV     BP,COPH
        MOV     DX,3DAh
    @@l1:
        MOV     DI,ES:[SI]
        MOV     WORD PTR [DI],201h
        MOV     WORD PTR [DI+2],403h
        MOV     WORD PTR [DI+4],605h
        MOV     WORD PTR [DI+6],807h
        ADD     SI,CX
        MOV     DI,ES:[SI]
        MOV     WORD PTR [DI],0A09h
        MOV     WORD PTR [DI+2],0C0Bh
        MOV     WORD PTR [DI+8],0E0Dh
        MOV     WORD PTR [DI+10],100Fh
        ADD     SI,CX

    @@wr1:
        IN      AL,DX
        TEST    AL,1
        JNZ     @@wr1
    @@wr2:
        IN      AL,DX
        TEST    AL,1
        JZ      @@wr2

        DEC     BP
        JNZ     @@l1
        
        MOV     AX,ES
        MOV     DS,AX
        RET

;=======================================================================

ShowBottomCopper:
        MOV     DX,3DAh
        MOV     CX,BOTCOPH
     @@l1:
    @@wr1:
        IN      AL,DX
        TEST    AL,1
        JNZ     @@wr1
    @@wr2:
        IN      AL,DX
        TEST    AL,1
        JZ      @@wr2          
        LOOP    @@l1

        MOV     DX,3D4h
        MOV     AX,2813h
        OUT     DX,AX
        MOV     DX,3DAh
    @@wr3:
        IN      AL,DX
        TEST    AL,1
        JZ      @@wr3
    @@wr4:
        IN      AL,DX
        TEST    AL,1
        JNZ     @@wr4
    @@wr5:
        IN      AL,DX
        TEST    AL,1
        JZ      @@wr5
        RET

;=======================================================================



        END
; ------------------------------ End of COP.ASM ---------------------------

