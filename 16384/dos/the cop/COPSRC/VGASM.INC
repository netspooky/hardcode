; ------------------------- VGASM.INC -------------------------

  ; --- This is the best profiler ever written, if you know what I mean. ---

SetBorder MACRO r,g,b
  IF TRACE
        MOV     DX,3C8h
        XOR     AL,AL
        OUT     DX,AL
        INC     DX
      IFDIF <&r>,<0>
        MOV     AL,&r
      ENDIF
        OUT     DX,AL
      IFDIF <&g>,<&r>
        MOV     AL,&g
      ENDIF
        OUT     DX,AL
      IFDIF <&b>,<&g>
        MOV     AL,&b
      ENDIF
        OUT     DX,AL
  ENDIF
ENDM

WaitForDisplay MACRO
     LOCAL @@vs1
        MOV     DX,3DAh                 ; Retrace sync.
@@vs1:
        IN      AL,DX
        TEST    AL,8
        JNZ     @@vs1                   ; While not in display do.
ENDM

WaitForRetrace MACRO
     LOCAL @@vs1
        MOV     DX,3DAh                 ; Retrace sync.
@@vs1:
        IN      AL,DX
        TEST    AL,8
        JZ      @@vs1                   ; While in display do.
ENDM

VSync MACRO
     LOCAL @@vs1, @@vs2
        MOV     DX,3DAh                 ; Retrace sync.
@@vs1:
        IN      AL,DX
        TEST    AL,8
        JNZ     @@vs1                   ; While not in display do.
@@vs2:
        IN      AL,DX
        TEST    AL,8
        JZ      @@vs2                   ; While in display do.
ENDM

        .CODE
; ==========================================================

GetPalette:
        MOV     DX,DS
        MOV     ES,DX
        MOV     DX,3c7h                 ; Get palette.
        OUT     DX,AL
        ADD     DX,2
@@pl1:
         INSB
         INSB
         INSB
         LOOP   @@pl1
        RET

; ==========================================================

DumpPalette:
        MOV     DX,3c8h                 ; Setup palette.
        OUT     DX,AL
        INC     DX
@@pl1:
         OUTSB
         OUTSB
         OUTSB
         LOOP   @@pl1
        RET

; ==========================================================

ZeroPalette:
        MOV     DX,3c8h                 ; Palette = all 0's.
        XOR     AL,AL
        OUT     DX,AL
        INC     DX
        MOV     CX,256
@@pl1:
         OUT    DX,AL
         OUT    DX,AL
         OUT    DX,AL
         LOOP   @@pl1
        RET


; ==========================================================

FadePal:
        MOV     AH,1
        MOV     BX,CX
        ADD     CX,CX
        ADD     CX,BX
     @@l:
        MOV     AL,[DI]
        MOV     DL,[SI]
        SUB     DL,AL
        JZ      @@nx
         JNC    @@i
          DEC   AL
          JMP   @@put
     @@i:
         CMP    DL,DH
         JBE    @@nput
         INC    AL
     @@put:
         MOV    [DI],AL
     @@nput:
         XOR    AH,AH
    @@nx:
        INC    DI
        INC    SI
        LOOP    @@l
        RET

; ==========================================================

ScanPal:
        MOV     BX,CX
        ADD     CX,CX
        ADD     CX,BX
        XOR     DH,DH
     @@l:
        MOV     AL,[DI]
        MOV     DL,[SI]
        SUB     DL,AL
        JNC     @@c1
         NEG    DL
    @@c1:
        CMP     DL,DH
        JC      @@nx
         MOV     DH,DL
    @@nx:
        INC    DI
        INC    SI
        LOOP    @@l
        RET

; ==========================================================

FadeCol:
        MOV     AH,1
        MOV     BX,CX
        ADD     CX,CX
        ADD     CX,BX
        MOV     BL,DL
     @@l:
        MOV     AL,[DI]
        MOV     DL,BL
        SUB     DL,AL
        JZ      @@nx
         JNC    @@i
          DEC   AL
          JMP   @@put
     @@i:
         CMP    DL,DH
         JC     @@nput
         INC    AL
     @@put:
         MOV    [DI],AL
     @@nput:
         XOR    AH,AH
    @@nx:
        INC    DI
        LOOP    @@l
        RET

; ==========================================================

ScanCol:
        MOV     BX,CX
        ADD     CX,CX
        ADD     CX,BX
        XOR     DH,DH
        MOV     BL,DL
     @@l:
        MOV     AL,[DI]
        MOV     DL,BL
        SUB     DL,AL
        JNC     @@c1
         NEG    DL
    @@c1:
        CMP     DL,DH
        JC      @@nx
         MOV     DH,DL
    @@nx:
        INC    DI
        LOOP    @@l
        RET

; ------------------------- End of VGASM.INC -------------------------

