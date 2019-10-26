;=-=-=-=-=-=-=-=-=-=-=-=-=;
;  256 byte Boulder Dazz  ;
;  By Klorf (Ari Jouppi)  ;
;-=-=-=-=-=-=-=-=-=-=-=-=-;

CHAR_GEM        EQU     0x0B02
CHAR_ROCK       EQU     0x0403
CHAR_PLAYER     EQU     0x0904
CHAR_SAND       EQU     0x6805

                SECTION .text
                ORG     0x0100
                BITS    16

                ; set video mode 0x00
                INT     0x10

                ; initialize own 8x8 fonts
                MOV     AX,0x1110
                MOV     BH,0x08
                MOV     CL,4
                MOV     DX,2
                MOV     BP,char_tbl
                INT     0x10

                PUSH    WORD 0xB800
                POP     ES
                PUSH    ES
                POP     DS

                new_level:
                ; randomize => BP = seed
                MOV     AH,0x2C
                INT     0x21
                MOV     BP,DX

                ; fill screen with sand
                XOR     DI,DI
                MOV     CH,0x7F;51*40
                MOV     AX,CHAR_SAND
                REP     STOSW

                MOV     BX,50*40-2
                ; gems
                MOV     SI,CHAR_GEM
                MOV     CL,100
                CALL    set_blocks
                ; rocks
                MOV     SI,CHAR_ROCK
                MOV     CH,2            ; MOV CX,512
                PUSH    WORD cont1
                set_blocks:
                  ; generate random number
                  ; BX = max => DX = random
                  IMUL    AX,BP,9821
                  XCHG    AX,BP
                  INC     BP
                  XOR     DX,DX
                  DIV     BX

                  LEA     DI,[2*EDX+2]
                  CMP     BYTE [DI],CHAR_SAND & 0xFF
                  JNE     SHORT set_blocks
                    MOV     [DI],SI
                LOOP    set_blocks
                RETN
                cont1:

                XOR     DI,DI
                main_s1:
                  MOV     SI,[DI-80]
                  MOV     WORD [DI],CHAR_PLAYER

                  ; update area - drop rocks and gems
                  update:
                  INC     CX
                  MOV     BX,55*40*2-2
                  MOV     DX,55*40-1 - 512
                  .u1:
                  DEC     DX
                  JS      SHORT new_level
                  MOV     AX,[BX]
                  TEST    AL,(CHAR_GEM & 0xFF) & (CHAR_ROCK & 0xFF)
                  JZ      SHORT .u3
                    INC     DX
                    TEST    BYTE [BX+80],(CHAR_PLAYER & 0xFF) & (CHAR_SAND & 0xFF)
                    JNZ     SHORT .u3
                    CMP     BYTE [BX+80],0
                    JNE     SHORT .u2
                      XCHG    AX,[BX+80]
                    .u2:
                    MOV     BP,[BX-2]
                    OR      BP,[BX+78]
                    JNZ     SHORT .u4
                      XCHG    AX,[BX+78]
                    .u4:
                    MOV     BP,[BX+2]
                    OR      BP,[BX+82]
                    JNZ     SHORT .u5
                      XCHG    AX,[BX+82]
                    .u5:
                    CMP     AX,[BX]
                    JE      SHORT .u3
                      MOV     [BX],AX
                      XOR     CX,CX
                  .u3:
                  DEC     BX
                  DEC     BX
                  JNS     SHORT .u1
                  JCXZ    update
                  DEC     CX

                  ; is there a rock on your head?
                  CMP     SI,[DI-80]
                  JNE     SHORT exit

                  ; move player
                  CBW                   ; XOR AH,AH
                  INT     0x16
                  ROR     AL,1
                  JC      SHORT exit

                  CBW                   ; XOR AH,AH
                  MOV     BX,AX
                  MOVSX   BX,BYTE [CS:BX+directions-('2'>>1)]
                  MOV     WORD [DI],CX
                  ADD     DI,BX
                  MOV     SI,CHAR_ROCK
                  CMP     WORD [DI],SI
                  JNE     SHORT main_s1
                    DEC     AX
                    JP      SHORT m1
                      ; moved horizontaly with the rock
                      CMP     BYTE [DI+BX],CL
                      JNE     SHORT m1
                        ADD     DI,BX
                    m1:
                    MOV     WORD [DI],SI
                    SUB     DI,BX
                JMP    SHORT main_s1

                exit:
                MOV     AX,3
                INT     0x10
                INT     0x20


directions      DB      80, -2, 2, -80

char_tbl        DB      00000000b
                DB      00010000b
                DB      00111000b
                DB      01010100b
                DB      11111110b
                DB      01010100b
                DB      00111000b
                DB      00010000b

                DB      00011100b
                DB      01101110b
                DB      01111011b
                DB      10110110b
                DB      11111011b
                DB      10111111b
                DB      01101100b
                DB      00111000b

                DB      00100100b
                DB      01011010b
                DB      01011010b
                DB      00111100b
                DB      01111110b
                DB      00011000b
                DB      00111100b
                DB      01100110b

                DB      01010000b
                DB      11000100b
                DB      10010110b
                DB      00000100b
                DB      00100000b
                DB      01010110b
                DB      01000011b
                DB      00001000b
