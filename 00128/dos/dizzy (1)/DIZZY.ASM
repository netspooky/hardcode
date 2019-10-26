
      ORG   100h

      PALLET = 003C8h
      VTRACE = 003DAh
      RANDOM = 00049h
      KEYBRD = 00060h
      VIDMEM = 0A000h
      TXTMEM = 0B800h
      BUFFER = 07D00h
      VIDSIZ = 0FA00h

 INIT:PUSH   0A000h
      POP    ES
      MOV    AL,13h
      INT    10h

      XCHG   AX,DX
      MOV    DX,PALLET
      OUT    DX,AL
      INC    DX
 COLR:PUSH   AX
      ROL    AX,1
      OUT    DX,AL
      OUT    DX,AL
      ROR    AL,1
      OUT    DX,AL
      POP    AX
      INC    AX
      JNZ    COLR

 MAIN:XOR    DI,DI
      INC    BX
      MOV    DL,0C8h

 FORY:MOV    [020Ah],DX
      MOV    CX,0140h

 FORX:MOV    [0208h],CX

      FILD   [CENY]
      FISUB  WORD [020Ah]
      FILD   [CENX]
      FISUB  WORD [0208h]

      FLD    ST1
      FLD    ST1
      FMUL   ST0,ST0
      FXCH   ST1
      FMUL   ST0,ST0
      FADDP  ST1,ST0
      FSQRT
      FIDIVR [DEEP]
      FISTP  WORD [020Ch]
      FPATAN
      FIMUL  [CENY]
      FMUL   [ANGL]
      FISTP  WORD [020Eh]

 DRAW:MOV    AX,BX
      SBB    AX,[020Ch]
      SBB    AX,[020Eh]
      AND    AX,CX
      STOSB

 NEXT:LOOP   FORX
      DEC    DX
      JNZ    FORY

 EXIT:IN     AX,KEYBRD
      DEC    AX
      JNZ    MAIN
      RET

 CENX DW 000A0h
 CENY DW 00064h
 DEEP DW 01600h
 ANGL DD 0.306
