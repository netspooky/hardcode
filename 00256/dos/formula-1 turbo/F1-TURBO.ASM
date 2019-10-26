        TITLE   FormulaONE TURBO (256 byte game)
;==========================================================================
;      FormulaONE TURBO Copyright 1995, 1996, 1998 by David S. Issel
;                          all rights reserved.
;
;                      Written using Turbo Assembler
;
;                     To assemble use:  TASM F1-TURBO
;                         To link use:  TLINK /x/t F1-TURBO
;
; For Microsoft Macro Assembler 6.0 use:  ML /AT F1-TURBO.ASM
;
;
;               To run FormulaONE use:  F1-TURBO
;     To run FormulaONE without sound:  F1-TURBO Q
;
;  Use left and right shift keys to control your car                  __,        
;  at bottom of screen.  Try not to run into anything       _ _.--'-n_/          
;  for as long as you can.                                -(_)------(_)=         
;==========================================================================
        .MODEL  TINY
        .CODE
CODE    SEGMENT BYTE PUBLIC 'CODE'
        ASSUME  CS:CODE,DS:CODE
        ORG     0100H                   ; This will be a COM file
;--------------------------------------------------------------------------
;                       ACTUAL PROGRAM BEGINS HERE
;--------------------------------------------------------------------------
START:
        MOV     BP,AX                   ; Reset score to 0 (=MOV BP,0)
        MOV     AH,06H                  ; Clear Screen and home the cursor
        CALL    SCROLL
;--------------------------------------------------------------------------
;                             MAIN GAME LOOP
;--------------------------------------------------------------------------
GAME:
        MOV     DX,1629H                ; Load CAR loc (LINE 16H, COL 29H)
CARLOC  EQU     $-2                     ; Self modifying code (CAR loc)

        CALL    MOVEIT                  ; Move cursor to DH,DL (car loc)
;--------------------------------------------------------------------------
;  Erase the car at old screen location
;--------------------------------------------------------------------------
        MOV     AL,20H                  ; Print 5 spaces
        PUSH    AX
        OUT     61H,AL                  ;   Turn off speaker (AL=00100000b)
        MOV     BL,70H                                                ;^^
        MOV     CL,5
        INT     10H

        MOV     AX,0E0AH                ; Move cursor to next line
        INT     10H

        POP     AX                      ; Print 5 more spaces
        INT     10H
;--------------------------------------------------------------------------
;  Move to new car location based on shift key status
;--------------------------------------------------------------------------
        MOV     CL,40H                  ; Get shift key status
        MOV     ES,CX                   ;   (=MOV ES,0040H)
        MOV     AL,[BYTE PTR ES:0017H]

        TEST    AL,1                    ; Right SHIFT key pressed?
        JZ      TRYLFT                  ;    No...Try left shift
        INC     DX                      ;    Yes..move car right 1 space
TRYLFT: TEST    AL,2                    ; Left SHIFT key pressed?
        JZ      KEYEND                  ;    No...done checking keys
        DEC     DX                      ;    Yes..move car left 1 space
KEYEND: MOV     [WORD PTR DS:CARLOC],DX ; Save new car location in memory
                                        ; (That is the self-modifying part)
        PUSH    DX                      ; Save car location on stack also
;--------------------------------------------------------------------------
;  Scroll the track down one line
;--------------------------------------------------------------------------
        MOV     AX,0701H                ; Scroll screen down 1 line
        CALL    SCROLL                  ;   this also sets BH=0 and BL=2
                                        ;   and homes the cursor

        MOV     CL,40                   ; Print left side of track
LMARGN  EQU     $-1                     ;   (Pointer to Left Margin)
        INT     10H

        MOV     DX,CX                   ; Find right side of track position
        ADD     DX,26                   ;   (Starting track width = 26)
TRKWID  EQU     $-1                     ;   (Pointer to Track Width)
        MOV     CL,80
        SUB     CX,DX
        CALL    MOVEIT                  ; Move cursor to right side of track
        INT     10H                     ; Print grass on right side of track
;--------------------------------------------------------------------------
;  Print the score in the lower right corner of the screen
;--------------------------------------------------------------------------
        MOV     DX,184EH                ; Screen loc 77,25 bottom right
        CALL    MOVEIT                  ; Move cursor to score location
        MOV     AX,BP                   ; Move Score to AX
        MOV     CL,8                    ; Shift score right 8 bits
        SAR     AX,CL                   ; (This makes it hard to get to Z!)
        ADD     AX,0E00H+65             ; MOV AH,0Eh & Convert score to A-Z 
        INT     10H                     ; Print the score on the screen
;--------------------------------------------------------------------------
;  Check for a collision
;--------------------------------------------------------------------------
        POP     DX                      ; Restore car location from stack
        CALL    MOVEIT                  ; Move cursor under left front tire
        JNZ     PCAR                    ; Hit something? Yes... Print our
                                        ;   red car and exit the game
        PUSH    DX                      ; Save left tire position to stack
        ADD     DL,4                    ; Move cursor under right front tire
        CALL    MOVEIT                  ; Check to see if we hit something
        POP     DX                      ;    Restore our car position
        JNZ     PCAR                    ; Hit something? Yes... Print our
                                        ;   red car and exit the game
        PUSH    DX                      ; Save car position to stack
;--------------------------------------------------------------------------
;  No collision, go ahead and print our car (red)
;--------------------------------------------------------------------------
        CALL    PCAR                    ; Print our red car (CX=8)
;--------------------------------------------------------------------------
;  Slow game down by waiting for 3 vertical retraces and play sound effects
;--------------------------------------------------------------------------
        MOV     CL,3                    ; CX is delay invertical retraces
DELAY:  MOV     DX,03DAH                ; Video screen port
HERE:   IN      AL,DX                   ; Get current video status
        TEST    AL,8                    ; Check vertical retrace bit
        JNE     HERE                    ; Wait for 1 full vertical retrace
HERE2:                                  ; Turn on and off speaker...
        ADD     AL,[BYTE PTR DS:005DH]  ;   (Check command line for Q)
        DEC     AX                      ;   (which is for Quiet mode.)
        OUT     61H,AL                  ; while waiting for screen refresh
        IN      AL,DX
        TEST    AL,8
        JE      HERE2
        LOOP    DELAY                   ; Go wait for another until CX=0
;--------------------------------------------------------------------------
;  Keep track of our current score
;--------------------------------------------------------------------------
        INC     BP                      ; Count lines printed so far (score)
;--------------------------------------------------------------------------
;  Adjust size and placement of track
;--------------------------------------------------------------------------
        POP     DX                      ; Restore our car position fm stack
        MOV     AX,BP                   ; TEST AL=2 bytes, TEST BP=4 bytes

        TEST    AL,255                  ; Make track smaller each 256 lines
        JNZ     NOCHG                   ;   Go around if not time for change
        DEC     [BYTE PTR DS:TRKWID]    ;   Change width (Self-mod code!)
NOCHG:

        TEST    AL,9                    ; Make track wavy every so often
        JNZ     ENEMY                   ;  Time to go straight
        TEST    AL,128                  ;  Left or right?
        JZ      LEFT
        ADD     [BYTE PTR DS:LMARGN],2  ; -Move right 2 spaces (Self-mod!)
;        INC     DX                      ;    Make sure that enemy car
;        INC     DX                      ;      stays ON the track. (TAI)
LEFT:   DEC     [BYTE PTR DS:LMARGN]    ; -Move left 1 space   (Self-mod!)
;        DEC     DX                      ;    Make sure that enemy car
                                        ;      stays ON the track. (TAI)
;--------------------------------------------------------------------------
;  Draw an opponent car every 15 screen lines
;--------------------------------------------------------------------------
ENEMY:                                  ; Our car position is in DX register
        MOV     DH,0                    ; Make it into enemy position using
                                        ; True Artificial Intellegence (tm)
                                        ; ^    ^          ^  TAI :-)
        TEST    AL,15                   ; Every 15 lines print enemy car
        MOV     AX,OFFSET GAME          ;    Prepare for RET below
        PUSH    AX                      ;    Use RET as a jump to GAME loop
        JNZ     GOBACK                  ; Not time yet to print enemy car
;--------------------------------------------------------------------------
;                PRINT CAR AT SCREEN LOCATION "DX"
;
; On entry:  DH points to line, DL to column, CX to car graphic offset
;                                             (8 for red, 0 for blue car)
; On exit:  The proper car will be drawn.  Also, if we used CALL PCAR to
;           get here we will be returned into the program at that point.
;           If we used JNZ PCAR to get here we will be returned to the
;           DOS prompt (the game will end).
;--------------------------------------------------------------------------
PCAR:
        PUSH    BP                      ; Save our current score counter
        MOV     BP,OFFSET CAR2          ; Point to the car graphic
        ADD     BP,CX                   ;   Add offset to proper car
        SUB     BYTE PTR [BP+4],24      ; Print stripe on hood of car
        MOV     AX,1302H                ; Print the car to the screen
        PUSH    AX                      ;    AX may change in INT 10h call
        MOV     CL,5                    ;    Graphic is 5 characters wide
        PUSH    DS                      ;    It is located in the data seg
        POP     ES                      ;      but INT 10h needs that in ES
        INT     10H                     ; Print the first line of the car
        ADD     BYTE PTR [BP+4],24      ; Print cockpit and rear stripe
        POP     AX                      ; (=MOV AX,1302H)
        INC     DH                      ; Point to next line of the screen
        INT     10H                     ; Print the second line of the car
        POP     BP                      ; Restore current score counter
GOBACK: RET
CAR2:   
        DB      0DCH,70H,0DEH,71H,0D2H,1FH,0DDH,71H     ; Blue car graphic
        DB      0DCH,70H                                ;   Common tire
        DB      0DEH,74H,0D2H,4EH,0DDH,74H,0DCH,70H     ; Red car graphic
;--------------------------------------------------------------------------
;                     SCROLL SCREEN DOWN "AL" LINES
;                      (or if AH=6, clear screen)
;
; On entry:  AH must be 7, AL must be number of lines to scroll (1)
; On exit:   BH will be 0, BL will be 2 and we will fall through to
;            MOVEIT to home the cursor.             ^^^^^^^^^^^^
;--------------------------------------------------------------------------
SCROLL: 
        MOV     BH,70H                  ; Use Black on Gray (road color)
        XOR     CX,CX                   ;   From UL corner (=MOV CX,0)
        MOV     DX,184FH                ;   to LR corner
        INT     10H
        MOV     BX,02                   ; Set BH to 0 and BL to 2 for use
                                        ;   when we return.
        XOR     DX,DX                   ; Now, home the cursor  (=MOV DX,0)
;--------------------------------------------------------------------------
;                  MOVE CURSOR TO SCREEN LOCATION DH,DL
;               AND SEE IF THERE IS A SPACE (TRACK) THERE
;
; On entry:  DH is screen line, DL is screen column
; On exit:   Z flag will be set/reset if there is a space character
;            under the cursor and AH will be 9 and AL will be 0DBh
;--------------------------------------------------------------------------
MOVEIT: 
        MOV     AH,2                    ; Move cursor to DH,DL
        INT     10H
        MOV     AH,8                    ; Get the character under cursor
        INT     10H
        CMP     AL,20H                  ; Is it a space? (set Z flag)
        MOV     AX,09DBH                ; Set AH to 9 and AL to 0DBh for
        RET                             ;  use just after we return (don't
                                        ;  worry, Z flag will still be set)
CODE    ENDS

        END     START
