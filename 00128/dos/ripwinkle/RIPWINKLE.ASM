
 ORG 100h

 PALLET = 003C8h
 VTRACE = 003DAh
 RANDOM = 0004Dh
 KEYBRD = 00060h
 VIDMEM = 0A000h
 TXTMEM = 0B800h
 BUFFER = 07D00h
 VIDSIZ = 0FA00h

 INIT:;MOV   BX,0A000h
      PUSH  VIDMEM
      POP   ES
      PUSH  BUFFER
      POP   DS
      PUSH  BUFFER
      POP   SS
      ;MOV   ES,BX
      ;MOV   DS,BX
      ;MOV   SS,BX
      MOV   AL,13h
      INT   10h

      MOV   DX,PALLET
      XOR   AX,AX
      OUT   DX,AL
      INC   DX
 COLR:PUSH  AX
      SHL   AX,1
      OUT   DX,AL
      SHR   AX,1
      OUT   DX,AL
      SHL   AX,1
      OUT   DX,AL
      POP   AX
      INC   AX
      JNZ   COLR

      XOR   SP,SP
      MOV   CX,VIDSIZ/2
 PLOT:IN    AL,RANDOM
      ADD   AX,SP
      PUSH  AX
      LOOP  PLOT

 MAIN:XOR   DI,DI
      XOR   SI,SI
      MOV   CX,VIDSIZ/4
      MOV   DX,VTRACE

 SYNC:IN    AL,DX
      TEST  AL,08h
      JZ    SYNC
      REP   MOVSD

      XOR   SP,SP
      MOV   CX,VIDSIZ/2
 DRAW:LODSW
      INC   AH
      INC   AL
      PUSH  AX
      LOOP  DRAW

 EXIT:IN    AL,KEYBRD
      DEC   AL
      JNZ   MAIN
      INT   20h
