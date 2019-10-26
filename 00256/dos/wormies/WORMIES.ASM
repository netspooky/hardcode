.model tiny

_TEXT  SEGMENT WORD USE16 PUBLIC 'CODE'
ORG 100h
_TEXT ENDS

_TEXT SEGMENT
.486
LOCAL X1:WORD, Y1:BYTE, X2:WORD, Y2:BYTE
ASSUME CS:_TEXT

start:
restart:
  mov ah, 2
  mov dl, 7
  int 21h

  MOV X1, 107d         ; reset local variables
  MOV WORD PTR Y1, 100d
  MOV X2, 213d
  MOV WORD PTR Y2, 100d

  MOV AX, 13h         ;change mode/clear screen
  INT 10h

  MOV AX, 0A000h
  MOV DS, AX
  MOV ES, AX

  MOV AL, 0Fh
  XOR DI, DI
  MOV CX, 319d
  REP STOSB

  XOR DI, DI
  MOV CL, 199d

SIDES:
  STOSB
  ADD DI, 318
  STOSB
  LOOP SIDES

  MOV DI, 63680d
  MOV CX, 319d
  REP STOSB

  XOR BX, BX
  XOR CX, CX
  MOV DX, 0FFFFh
GAMELOOP:

  PUSH CX
  MOV CX, 0FFFFh
PAUSE:
  MUL CL
  MUL CL
  MUL CL
  MUL CL
  LOOP PAUSE
  POP CX

  MOV DI, WORD PTR Y1
  IMUL DI, 320
  ADD DI, X1
  MOV SI, DI

  LODSB
  CMP AL, 0
  JNZ short restart
  MOV AL, 1
  STOSB

  MOV DI, WORD PTR Y2
  IMUL DI, 320
  ADD DI, X2
  MOV SI, DI

  LODSB
  CMP AL, 0
  JNZ short restart
  MOV AL, 4
  STOSB


  MOV AH, 1
  INT 16h
  JZ NOCHARATALL

  XOR AX, AX
  INT 16h

  CMP AH, 11h   ; TEST FOR W
  JNZ short ATEST
  XOR BX, BX
  MOV DH, 0FFh

ATEST:
  CMP AH, 1Eh
  JNZ short STEST
  MOV BX, 0FFFFh
  SUB DH, DH

STEST:
  CMP AH, 1Fh
  JNZ short ZTEST
  MOV BX, 1
  SUB DH, DH

ZTEST:
  CMP AH, 2Ch
  JNZ short NOCHAR1
  XOR BX, BX
  MOV DH, 1
  
NOCHAR1:

  ADD X1, BX
  ADD Y1, DH
           

                      ; START TESTS FOR PLAYER 2--> ARROW KEYS
  CMP AH, 48h         ; TEST FOR UP
  JNZ short LTEST
  MOV DL, 0FFh
  XOR CX, CX

LTEST:
  CMP AH, 4Bh
  JNZ short RTEST
  SUB DL, DL
  MOV CX, 0FFFFh

RTEST:
  CMP AH, 4Dh
  JNZ short DTEST
  MOV CX, 1
  SUB DL, DL

DTEST:
  CMP AH, 50h
  JNZ short NOCHAR2
  XOR CX, CX
  MOV DL, 1
  JMP NOCHAR2    

NOCHARATALL:
  XOR AX, AX
  ADD X1, BX
  ADD Y1, DH


NOCHAR2:
  ADD X2, CX
  ADD Y2, DL

  CMP AH, 1h
  JNZ GAMELOOP

  MOV AX, 3h
  INT 10h

  MOV AH, 4Ch
  INT 21h

_TEXT ENDS
END start
