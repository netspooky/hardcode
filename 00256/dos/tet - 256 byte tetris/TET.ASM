;-----------------------------------------------------------------------------
;
;  []                       TET - 256 byte Tetris                  [][][]
;  [][]                                                            []
;  []                                by                                  []
;                []                                         []           []
;        [][][]  [][]        James David Chapman            [][]  [][]   []
;  [][][][]  []    []                                       []  [][]     []
;-----------------------------------------------------------------------------
;
;  Here is a 256 byte version of of the all time classic game Tetris...
;
;  To play, use the left and right SHIFT keys to move the current block, and
; the ALT key to rotate it.  Press CONTROL to exit.
;
;  I have not had the amount of time that I would have liked to write this
;program, so am sure that there is some optimization still left to be done. If
;you find a saving somewhere along the line, do let me know.
;
;  Another idea for a 256 compo? -  256 scramble.  Could be fun.
;
;                                                 James David Chapman 1999.
;-----------------------------------------------------------------------------
;Features:
;       Cool looking blocks             Almost as good as graphics mode ones.
;       Random shape                    Taken from the timer.
;       Random colours                  Also taken from timer.
;       Rotatable shape                 I hated writing this bit, as expected.
;       Block stop check                Stops blocks when they hit another one
;       Solidity                        Prevent sideways crashing into blocks.
;       Dual loop timing                Allows for multiple input per advance.
;       End of game effect              More of a useful side effect really!
;       Full lines removed              A quickly cobbled together routine.
;       Frame                           Sets a maximum 10 block width for game.
;       End program key                 Better than using Control-C etc.
;No space for:
;       Scoring                         +2 for a line, +4 if the bottom line..
;       Beeps                           a simple beep on line removal...
;       Speedup                         should increase in speed over time...
;       Graphics mode                   I had a lovely graphics version, and
;       Nice enlarge effect             a cool block effect which was too big.
;-----------------------------------------------------------------------------
        ;assembler startup              ;assembled with:
        .MODEL TINY                     ;TASM TET.ASM /m2 /uM520 /t >errors
        MASM51                          ;TLINK TET.OBJ /3 /x /t
        QUIRKS                          
        .386                            ;uses pusha/popa (286+)   
        .CODE                           ;uses fs segment register (386+)  
        .STARTUP                           
;-----------------------------------------------------------------------------
        ;setup segs and vars            
        MOV AX,1                        ;set colour screen mode 40 cols
        INT 10H                         ;call BIOS
        PUSH 040H                       ;set segment for keyboard flags
        POP FS                                                                                                             
        PUSH 0B800H                     ;colour text segment
        POP ES                          ;set ES to colour text segment 
        PUSH DS                         ;store data segment
        PUSH ES                         
        POP DS                          ;set DS to colour text segment
;-----------------------------------------------------------------------------                                         
        ;get a new random coloured tile
        NEWBLOCK:
        XOR AX,AX                       ;clear AX
        IN AL,40H                       ;get a random number from timer
        MOV BP,AX                       ;use top bits to select block shape
        SHR BP,5
        JZ NEWBLOCK                     ;only 7 shapes so redo if 0
        MOV BP,[BP+OFFSET SHAPETABLE-1] ;BP assumes SS, which saves segment
        SHL BP,4                        ; override here.
        AND BP,0FF0H                    ;convert data byte into word
        AND AL,0111B                    ;use bottom bits for colour
        OR AL,1000B                     ;make colours bright
        MOV AH,AL                       ;store colour
        MOV DI,-60                      ;set inital print position
;-----------------------------------------------------------------------------
        ;increase current block's row position
        @@:
        ADD DI,80                       ;advance block down screen

        ;do mainloop
        MOV BX,4                        ;do main game loop 4 times per
MAINLOOP:                               ; block advance, to allow for more
        DEC BX                          ; than one rotation/move per advance
        JZ @B                           
;-----------------------------------------------------------------------------        
        ;print game board frame, and clear any full lines
        PUSHA                           ;store all general purpose registers
        MOV SI,80*25+2                  ;set SI/DI to bottom left of board
        MOV DI,SI
        BOARDLOOP:
        XOR DX,DX                       ;zero block counter
        MOV CL,10                       ;each line is 10 blocks wide
        CHECKLINE:
        LODSW
        CMP AH,7                        ;check attribute of character to copy
        JBE @F
        INC DX                          ;count the number of consecutive blox
        @@:
        STOSW                           ;print the character/attribute
        LOOP CHECKLINE
        LODSW                           ;smaller form of add si,2
        MOV AX,09B1H                    ;print right hand column
        STOSW
        CMP DX,10                       ;check to see if there was a row of 10
        JB @F      
        ADD DI,80                       ;if there was, force di to skip a row
        @@:        
        SUB DI,80+24                    ;update di for next row
        SUB SI,80+24                    ;update si for next row
        STOSW                           ;print left hand column
        LODSW                           ;smaller form of add si,2
        JNC BOARDLOOP                   ;if sub causes si to cross 0 then end
        POPA                            ;restore general purpose registers
;-----------------------------------------------------------------------------
        ;get keyboard input
        XOR CX,CX                       ;clear cx -  allows cl usage*3 later
        MOV SI,DI                       ;store old position - possible restore
        PUSH BP                         ;store old rotation - possible restore
        MOV CL,FS:[17H]                 ;get keyboard flags
        RCR CL,1                        ;split on set bits
        JNC @F                          ;right shift-move block right          
        INC DI                          ;add 2 to position variable
        INC DI
        @@:
        RCR CL,1
        JNC @F                          ;left shift-move block left  
        DEC DI                          ;sub 2 from position variable
        DEC DI
        @@:
        RCR CL,1   
        JNC @F                          ;control-escape
        POP BP                          ;reset stack
        POP DS                          ;restore data segment
        RET                             ;end program
        @@:       
        RCR CL,1
        JNC @F                          ;alt-rotate block
;-----------------------------------------------------------------------------
;90 degree rotate function:
;
;ABCD EFGH IJKL MNOP     ABCD    =>     DHLP CGKO BFJN AEIM   DHLP
;                        EFGH                                 CGKO
;    -->  Displayed as:  IJKL              ->  Displayed as:  BFJN 
;                        MNOP                                 AEIM
;
;-----------------------------------------------------------------------------
        MOV CL,16                       ;create 16 bits in DX output
        MOV DX,0EEEEH                   ;set bits where no ROR is to be done
        RLOOP:                 
        ROL BP,4                        ;rotate bp, carry=last bit rotated
        RCL DX,1                        ;carry into dx, high dx into carry
        JC SKIPROR                      ;skip ROR for preset bits in dx
        ROR BP,1                        ;adjust bp back 1 every 4 bits
        SKIPROR:
        LOOP RLOOP
        MOV BP,DX                       ;store rotated value back into bp
        @@:
;-----------------------------------------------------------------------------
        ;check plot
        XOR DX,DX                       ;zero dl to supress ploting
        CALL PLOTBLOCK                  ;check if plot would cover a block
        JZ @F
        POP BP                          ;use old value for rotate
        MOV DI,SI                       ;use old value for position
        PUSH DX                         ;set stack so reset is ok
        @@:                             
        POP DX                          ;reset stack

        ;plot the current block
        MOV DX,BX                       ;set flag for normal plot block
        CALL PLOTBLOCK                  ;bx just used as a non zero number

        ;should block stop?
        JNZ NEWBLOCK                    ;there is a block below so do newblock
;-----------------------------------------------------------------------------
        ;wait for vertical retrace
        PUSH AX
        MOV CL,4                        ;do vertwait 6 times per gameloop
        VERTWAIT:                       ;this slows down the keyboard entry
        MOV DX,3DAH                     ;VGA status register
        @@:
        IN AL,DX
        TEST AL,8
        JZ @B                           ;wait for vertical retrace to start
        @@:          
        IN AL,DX      
        TEST AL,8      
        JNZ @B                          ;wait for vertical retrace to end
        LOOP VERTWAIT                   ;loop 6 times
;-----------------------------------------------------------------------------
        ;erase block
        XOR AX,AX                       ;clear colour
        CALL PLOTBLOCK                  ;print block again, this time with
        POP AX                          ;zero (black) attribute.
        JMP MAINLOOP                    ;restart game loop
;-----------------------------------------------------------------------------
PLOTBLOCK:
        ;write a 4*4 block to the screen
        PUSHA                           ;store registers
        MOV CX,16                       ;4*4=16
        MOV AL,8                        ;ascii 8 is the block we use, it
        PLOTLOOP:                       ;is also used for test below.
        TEST CX,11B                     ;every 4 prints...
        JNZ @F
        ADD DI,72                       ;change print position to next line
        @@:
        ROL BP,1                        ;test bp bits without disturbing bp
        JC @F                           ;if no carry, then no block is to
        SKIP:                           ;be printed here so skip over it.
        INC DI
        INC DI
        JMP SHORT NEXTPLOT
        @@:

        ;check overwrite
        OR DL,DL                        ;if in overwrite checking mode,
        JNZ @F                          ;do not print, report back on
        OR DH,[DI+1]                    ;what you will be printing over,
        JMP SHORT SKIP                  ;and skip printing.
        @@:

        ;check below block              ;if there is a block below this one
        OR DH,[DI+81]                   ;then newblock will need to be run
        CMP DI,80*24                    ;check for end of screen
        JB NOSTOP
        OR DH,AL                        ;force newblock if end of screen
        NOSTOP:

        STOSW                           ;print part of the block here
        NEXTPLOT:
        LOOP PLOTLOOP                   ;do 16 of these
        TEST DH,AL                      ;pass result of checks as zero flag
        POPA                            ;for gameloop to interpret
        RET
;-----------------------------------------------------------------------------
        ;data 
        ;OOO.  OO.   .OO  .O..  OOOO  .OO.  OOO.
        ;..O.  .OO.  OO.  OOO.  ....  .OO.  O...

        SHAPETABLE LABEL BYTE           ;the 7 tetris shapes used in the game
        DB 11100010B                    ;setbit=print a block at this position
        DB 11000110B                    ;loaded as words, cleared back to 
        DB 01101100B                    ;bytes and then shifted by a 4 bits to 
        DB 01001110B                    ;create blank top and bottom rows.
        DB 11110000B                    ;..as it turns out not much of a 
        DB 01100110B                    ;saving.
        DB 11101000B
;-----------------------------------------------------------------------------
        END                             ;end of tetris game, phew.
;-----------------------------------------------------------------------------
        ;(c) JDC 1999.
        ;jchap@globalnet.co.uk
        ;http://www.users.globalnet.co.uk/~jchap/
;-----------------------------------------------------------------------------
