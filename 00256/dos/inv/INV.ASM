                ;    ú                ú          .        ú     ;
                ;        "Space Invaders" in 256 bytes          ;
                ;                     ú       .                 ;
                ;   ú        .       by                ú        ; 
                ;        .              ú                       ;
                ;            James David Chapman   .       .    ;  
                ;    .            .         ú                   ;
                                                                

        ;assembler startup              ;Heh heh, all this just to get it   
        .MODEL TINY                     ;to make a COM file.  Pah.
        MASM51                          ;Give me "debug" any day. "a 100" :D
        QUIRKS                          ;
        .386                            ;Actually assembled with TASM.
        .CODE                           ; TASM INV.ASM /m2 /uM520 /t >errors
        .STARTUP                        ; TLINK INV.OBJ /3 /x /t                          
                                         
        ;setup segs and vars
        PUSH 040H                       ;segment offset to keyboard flags
        POP FS
        PUSH 0B800H                     ;colour text screen segment
        POP ES                          ;the second byte of the data in the
                                        ;above instruction, initially 0, is
                                        ;used as the DIRECTION flag byte.                                        
        CALL CLS                        ;cls done at start and end of game
        MOV BP,160*24+80                ;space ship position
        XOR BX,BX                       ;sidewinder invaders offset
        XOR DX,DX                       ;fire sprite position

MAINLOOP:
	;get key and split
        MOV AL,FS:[17H]                 ;get keyboard flags
        RCR AL,1                        ;split on set bits
        JNC @F                          ;right - bit 0 - right shift                               
        INC BP                          ;ADD BP,2 mov ship across
        INC BP                          ;ADD=3 bytes, 2 INCs = 2 bytes
        @@:
        RCR AL,1
        JNC @F                          ;left - bit 1 - left shift
        DEC BP                          ;SUB BP,2
        DEC BP
        @@:
        RCR AL,1   
        JNC @F                          ;esc - bit 2 - control
CLS:
        MOV AX,3                        ;cls and end, or cls and return
        INT 10H
        RET                             
	@@:
        RCR AL,1
        JNC @F                          ;fire - bit 3 - alt
        CMP DX,0                        ;no fire if fire in progress
        JNE @F                          
        MOV DX,BP                       ;move ship pos into fire sprite pos
	@@:

	;plot fire
        SUB DX,160                      ;decrease fire offset by one line
        MOV DI,DX                       
        MOV WORD PTR ES:[DI+4],0E21H    ;print "!"
        MOV BYTE PTR ES:[DI+164],20H    ;print " " (would have prefered 0720H) 
        JNC @F
        XOR DX,DX                       ;no fire sprite
        @@:         
        NOFIRE:
        PUSH DX

	;plot space ship
        MOV SI,OFFSET SPSH              ;load offset to space ship data
        MOV DI,BP                       ;(this offset is used for the others)
        PUSH BP                         ;store ship position
        MOV BP,88H                      ;BP now hitarray held in command line
        CALL PLOTSPR                    ;call plot subroutine        
        INC BP

	;plot ufo
        UFOPOS:                         ;label for self modifying code 
        MOV DI,0                        ; (invaders position variable) 
        CALL PLOTSPR            
        INC BP                          
        
        ;get invaders position          
        MOV DI,BX
        TEST BYTE PTR DS:[105H],80H     ;work out which way they are going
        JZ @F                           ; (from direction flag byte)
        NEG DI                          ;sidewind adjust invaders pos
        ADD DI,32                 
        @@:         
        INVPOS:                         ;label for self modifying varible
        DB 81H,0C7H                     ;ADD DI,0052H (long form of addition)
        DB 52H,00H                      ;(invaders line offset var) 
        SHL DI,1

        ;plot invaders        
        MOV DL,5                        ;number of lines down of invaders
        DLOOP:                          ; (^-was = invader1, ie lines=colour) 
        MOV DH,6                        ;number of invaders per line
        LINELOOP:                       ; (di+224 must be adjusted too)
        PUSH SI
        CALL PLOTSPR                    ;big savings if you replace this sub
        POP SI                          ;with a simple single char plot         
        INC BP                          ;increase position in invaders flags         
        STOSW                           ;plot space between invaders
        STOSW                           ; [shorter than add di,4]
        DEC DH
        JNZ LINELOOP                    ;next invader on line
        ADD DI,224
        DEC DL
        JNZ DLOOP                       ;next line of invaders
	POP BP

	;move invaders
        INC BX                          ;invaders sidewinder counter
        AND BL,11111B                   ;count from 0-31
        JNZ @F
        ;XOR WORD PTR invader1+2,101H   ;this would animate the invaders, but
                                        ;costs too many bytes.   
        NOT BYTE PTR DS:[105H]          ;on 0, reverse direction and           
        ADD WORD PTR [INVPOS+2],80      ;mov invaders down one line
        @@:                             

	;move ufo
        ADD WORD PTR [UFOPOS+1],2       ;self modifying variable        

        ;wait for vertical retrace and set game speed
        MOV CL,DS:[80H]                 
        INC CX                          ;get speed from commandline length+1
VERTWAIT:   
        MOV DX,3DAH                     ;graphics card port address
        @@:
        IN AL,DX
        TEST AL,8                       ;wait for a vertical retrace to start
        JZ @B                           ;[I was very tempted to self modify
        @@:                             ; the jz to a jnz and save the second
        IN AL,DX                        ; loop, but without inserting a jmp,
        TEST AL,8                       ; the processor might fail to run it].
        JNZ @B                          ;wait for the vertical retrace to end  
        LOOP VERTWAIT                   ;slow game down for lamers.  :P
        POP DX

        ;check for restart              
        CMP DI,160*37                   ;are the invaders off the screen?
        JB @F                           
        INC BYTE PTR INVADER1           ;change their colour
        MOV WORD PTR [INVPOS+2],(-4*80)+2;start them off again
        @@:

        JMP MAINLOOP                    ;loop back, and flush processor so the
                                        ;code modifications don't trip it up.
 
PLOTSPR:
        ;XOR AX,AX                      ;[eek! I had to take this out to make
                                        ;some space...doesn't SEEM to matter]
        STOSW                           ;blank space to left of sprite
        LODSB                           ;get colour of sprite        
        MOV AH,AL                        
        MOV CL,4                        ;set char width of sprite
        PLOTLOOP:
        CMP BYTE PTR ES:[DI],"!"        ;check to see if sprite has been hit
        JNE @F
        MOV BYTE PTR [BP],07FH          ;flag the hit in the invaders array
        @@:                               
        LODSB                             
        CMP BYTE PTR [BP],07FH          ;if flaged, don't print the sprite
        JNE @F         
        MOV AL,20H                      ;no print         
        @@:
        STOSW                           ;print
        MOV BYTE PTR ES:[DI-162],20H    ;blank space above sprite.
        LOOP PLOTLOOP
        XOR AX,AX
        STOSW                           ;blank space to right of sprite
        RET
            
	;sprdata (30)
        SPSH     DB 04H," "          ;cool space ship, (for text mode)
        UFO      DB 05H," "          ;"hello, I'm an alien"
        INVADER1 DB 02H,""          ;so scary.
         
        END                              

                                                        
        ;  That's it.   No more.   End.   Finished.     ;  
        ;                                               ;
        ;   </INV>   Stop.           .        ú         ;
        ;                                               ;
        ;    .                 ú               .        ;    
        ; Talk to me:                                   ;   
        ;                                  .          ú ;   
        ; jchap@globalnet.co.uk                         ;   
        ; http://www.users.globalnet.co.uk/~jchap/      ;   
        ;                                               ;    
        ; Take care,   and,      .                      ;
        ;                                   .           ;
        ;   ú      .    Goodnight.              JDC'98  ;

