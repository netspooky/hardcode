        TITLE   SpaceWORM (256 byte game)
;==========================================================================
;                SpaceWORM Copyright 1995 by David S. Issel
;                          all rights reserved.
;
;                      Written using Turbo Assembler
;
;                     To assemble use:  TASM SW
;                     To link use:      TLINK /x/t SW
;
;               To run SpaceWORM (in normal mode) use:  SW
;               To run SpaceWORM (in quiet mode) use:   SW Q
;==========================================================================
        .MODEL  TINY
        .CODE
CODE    SEGMENT BYTE PUBLIC 'CODE'
        ASSUME  CS:CODE,DS:CODE
;--------------------------------------------------------------------------
;                       ACTUAL PROGRAM BEGINS HERE
;
; On entry, DOS will set up the following registers:
;   AX=0000  BX=0000  CX=0100  DX=0000  SP=FFFE  BP=0000  SI=0000  DI=0000  
;   DS=xxxx  ES=xxxx  SS=xxxx  CS=xxxx  IP=0100   NV UP EI PL NZ NA PO NC 
;--------------------------------------------------------------------------
        ORG     0100H
START:                                  ; Remember, AH already has 0 in it
        MOV     AL,40H                  ; Setup ES register for use later
        MOV     ES,AX
        
        MOV     AL,03H                  ; Reset to video mode 03
        INT     10H                     ;   and clear the screen
        
        MOV     AH,1                    ; Turn cursor off
        MOV     CH,10H                  ;   CL already has 0 in it
        INT     10H
        
        MOV     AX,0E07H                ; Use BIOS to beep speaker which
        INT     10H                     ;   will setup the default tone
                                        ;   for background sound effects
;--------------------------------------------------------------------------
;                             MAIN GAME LOOP
;--------------------------------------------------------------------------
GAME:
        MOV     AL,[BYTE PTR ES:0017H]  ; Get shift key status
        
        MOV     DX,0628H                ; Load worm loc (line 6 column 40)
WRMLOC  EQU     $-2                     ; Self modifying code (worm loc)        
        TEST    AL,1                    ; Right SHIFT key pressed?
        JZ      TRYLFT                  ;    No...Try left shift
        CMP     DL,77                   ;    Yes..Move worm right 1 space
        JNL     TRYLFT
        INC     DX
TRYLFT: TEST    AL,2                    ; Left SHIFT key pressed?
        JZ      KEYEND                  ;    No...done checking keys
        DEC     DL                      ;    Yes..move worm left 1 space
        JNZ     KEYEND
        INC     DX
KEYEND: MOV     [BYTE PTR DS:WRMLOC],DL ; Save new worm location
        
        CALL    DISP1                   ; Display left side of worm
        INC     DX                      ; Point to next screen location
        CALL    DISP1                   ; Display right side of worm
        
        CALL    PSCORE                  ; Display Score (sets CX to 0)

        CALL    GORAND                  ; On return, CX = 1, BL (color) = 7
        SAR     DL,1                    ; Move LSB of DX into Carry Flag
        ADC     BL,0                    ; Add Carry Flag to BL (color)
        INT     10H                     ; Print the background star

        TEST    BP,3                    ; Display GOOD areas
        JNZ     SKIP1                   ;   on every fourth line
        MOV     AX,0904H                ; AH gets trashed in INT 10 above
        MOV     BL,14                   ;   on some older BIOS versions
        INT     10H                     ;   (this was tough to find!)
        IN      AL,61H                  ; Turn off speaker
        AND     AL,0FCH                 ;
        OUT     61H,AL                  ;
SKIP1:  TEST    BP,1                    ; Display BAD areas
        JZ      SKIP2                   ;   on every other line
        CALL    GORAND                  ; On return, CX = 2, BL (color) = 7
        MOV     AL,0DBH
        INT     10H
SKIP2:
        MOV     CL,7                    ; CX is delay invertical retraces
DTIME   EQU     $-1                     ; Self modifying code (retraces)
DELAY:  MOV     DX,03DAH
HERE:   IN      AL,DX                   ; Wait for 1 full vertical retrace
        TEST    AL,8
        JNE     HERE
HERE2:  IN      AL,DX
        TEST    AL,8
        JE      HERE2
        LOOP    DELAY                   ; Go wait for another until CX=0

        MOV     AX,0E0AH                ; Scroll screen up 1 line
        INT     10H                     ;  (cursor already on bottom line)
        INC     BP                      ; Count number of lines printed

        TEST    BP,511                  ; Increase game speed on 512 lines
        JNZ     GO                      ; GAME is too far away for rel jump
        DEC     [BYTE PTR DTIME]        ; Make delay loop shorter
        JNZ     GO                      ; If delay loop went down to zero 
        INC     [BYTE PTR DTIME]        ;   make delay loop minimum of 1
GO:     JMP     GAME                    ; Go do everything again!
;--------------------------------------------------------------------------
;                              EXIT TO DOS
;
; On entry, BH must be 0 because we will be falling through to PSCORE
; On exit, we will be at the DOS prompt
;--------------------------------------------------------------------------
XIT:    MOV     AX,0003H                ; Reset video mode 03, this clears 
        INT     10H                     ;  the screen & turns cursor on.
        IN      AL,61H                  ; Turn off speaker
        AND     AL,0FCH                 ;
        OUT     61H,AL                  ;
        ; Now fall through and print the score
        ; Since this is a .COM file the RET at
        ; the end of the PSCORE procedure will
        ; return all the way out to DOS!
;--------------------------------------------------------------------------
;       PRINT THE SCORE IN THE UPPER LEFT CORNER OF THE SCREEN
;
; On entry, BH must be 0, CX must be 1
; On exit, CX will be set to 0 and BH will remain 0
;--------------------------------------------------------------------------
PSCORE: XOR     DX,DX                   ; GOTOXY 0,0
        MOV     AH,2
        INT     10H
        MOV     BL,10                   ; Print score in base 10 (decimal)
        DEC     CX                      ; This will set CX to 0
        MOV     AX,0000H                ; Load current score into AX
SCORE   EQU     $-2                     ; Self modifying code (score)
NON_Z:  XOR     DX,DX                   ; Push each digit onto stack
        DIV     BX                      ;   Divide our number by 10
        PUSH    DX                      ;   Save remainder to stack
        INC     CX                      ;   Count digits on stack
        OR      AX,AX                   ;   Are we done yet?
        JNE     NON_Z                   ;     No...Process next digit
SHODIG: POP     AX                      ; Pop and display each digit
        ADD     AX,0E30H                ;   Convert AL to ASCII and
        INT     10H                     ;   Move 0EH into AH
        LOOP    SHODIG
        RET
;--------------------------------------------------------------------------
;   PUT CURSOR ON A "RANDOM" LOCATION ON THE BOTTOM LINE OF THE SCREEN
;
; On entry, BH must be 0
; On exit, AX will be 092EH, BX will be 0007H, CX will be incremented by 1,
;          DH will be 24 and DL will be set to the column number (0-77)
;--------------------------------------------------------------------------
GORAND: IN      AL,40H                  ; Read "random" value fm timer port
        INC     AX                      ; Here is my vain attempt to make
        XOR     AX,BP                   ;  that value _more_ random
        MOV     BL,78
        DIV     BL                      ; Divide it by 78
        MOV     DL,AH                   ;   and keep the remainder (column)
        MOV     DH,24                   ;   25th line of display   (row)
        MOV     AH,2
        INT     10H
        INC     CX                      ; Get ready to use INT 10 after RET
        MOV     BL,07H                  ;   default screen color 7
        MOV     AX,092EH                ;   default function 9 data 2EH "."
        RET
;--------------------------------------------------------------------------
;                DISPLAY ONE SECTION OF THE WORMS HEAD
;
; On entry, BH must be 0, DH must be set to the screen column and DL to 6
; On exit, CX=1, AX=09DBH, BX=0006H, DX still has screen location
;--------------------------------------------------------------------------
DISP1:  MOV     AH,2                    ; Goto screen location DH,DL
        INT     10H
        MOV     AH,8                    ; Read character under cursor
        INT     10H
        MOV     CX,1                    ; We will be printing 1 block below
        CMP     AL,4                    ; - Is it a yellow diamond?
        JNZ     DISP2                   ;     No... go check for crash
        INC     [WORD PTR DS:SCORE]     ;     Yes.. increment score
        CMP     [BYTE PTR DS:005DH],20H ;       Should I turn speaker on?
        JNZ     DISP3                   ;         No... we're in Quiet mode
        IN      AL,61H                  ;         Yes.. turn speaker on
        OR      AL,3                    ;
        OUT     61H,AL                  ;         then fall through, but...
        INC     AX                      ;         make sure AL <> 219
DISP2:  CMP     AL,219                  ; - Is it an asteroid?
        JNZ     DISP3                   ;     No... go display worm
        POP     AX                      ;     Yes.. get rid of return addr
        JMP     SHORT XIT               ;           go exit to DOS
DISP3:  MOV     AX,09DBH                ; CX is already 1 (from above)
        MOV     BL,06H                  ; Even in space, worms are brown
        INT     10H                     ; Print it.
        RET
;--------------------------------------------------------------------------
;  End of Code Segment
;--------------------------------------------------------------------------
CODE    ENDS

        END     START
