;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°Wyrmer!!°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°---------------------------------------------------------°°°°
;°°°°°°°°°°°°°°°°Made by Gnome for the 256 Bytes Worm Game Competition '97°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                                                            
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Controls:°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°Red worm°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°A = Left°°°°(This goes for QWERTY keyboards only°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°D = Right°°°°for AZERTY it'll be q,d,z & s i think°°°°°°°
;°°°°°°°°°°°°°°°°°°°°W = Up°°°°°°°DVORAK: figure it out youself!       )°°°°°°
;°°°°°°°°°°°°°°°°°°°°S = Down°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°Blue worm°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°Arrows°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°'Esc' is quit... surprise, eh?°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                                                              
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Instuctions:°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°With your worms acceleratsing you should stay alive longer°°
;°°°°°°°°°°°°°°°°°°than your opponent! Eating them green dots slow you down!°°
;°°°°°°°°°°°°°°°°°°When one of you dies the game quits, and the upper left°°°°
;°°°°°°°°°°°°°°°°°°corner shows the color of the winner!°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°° 
                                                                              
                                                                              
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Initialize the usual crap°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                                                           
.MODEL Tiny                                                                
                .Code                                                      
                .386                                                       
                org 100h                                                   
                                                                           
                                                                           
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Set Video Mode and add border°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                                                           
        INIT:   MOV     AX,0A000h     ;DS and ES to VGA-mem            
                MOV     DS,AX                                              
                MOV     ES,AX                                              
                                                                       
                MOV     AX,13h                                             
                INT     10h           ;Mode 13h: 320x200, 256 colors       
                                                                           
                MOV     AL,11h        ;Color of playground (near black)                                     
                MOV     DI,321        ;OFFSET
                MOV     BX,198        ;Number of lines to be drawn          
                                                                           
        Border: MOV     CX,319        ;Length of black line                
                REP                                                        
                STOSB                 ;Fill the line                       
;                INC     DI                                                 
                INC     DI            ;Next line                           
                                                                           
                DEC     BX            ;Was that all?                                     
                JNE     Border        ;Nope! Jump back
                PUSH    CX            ;CX is zero                
                POP     GS            ;... and now GS is too           
                                                            
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Set the clock frequenzy°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                                            
                CALL timefreq         ;Initialize the frequenzy call
                INC  AX               ;AL is now 1
                OUT  40h,AL           ;The frequenzy is... well 18.2x65536...                                      
                STI                   ;Enable interrupts!                                      
                                                            
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Setup slow down dots°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                                            
                MOV    CX,50          ;50 green dots
                MOV    AL,47h         ;with color 47 (green)                      
        Temp4:                                              
                SUB    DI,1208        ;di is at end of playground
                STOSB                 ;set a dot at es:di                           
                LOOP   Temp4          ;50 times...                   
                                      
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Initialize the registers°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                                                           
                PUSH    CS            ;CS is... well the code segment u know? 
                POP     ES            ;and so is ES                                       
                MOV     SI,31840      ;Blue Offset  Middle of screen (approx.)
                MOV     DI,SI         ;Red  Offset = Blue Offset
                DEC     BX            ;Blue direction (-1=left )
                MOV     BP,1          ;Red  direction ( 1=right)
                MOV     CX,08080h     ;The speed is 80h for both worms
                                                                      
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Add the worms to the screen°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                                                           
        Draw:                                                        
                MOV     DX,AX         ;AX contains the current time... usually
                SHL     AX,7          ;If that is a multiplum of 1000000000b
                JNE     Ok                                           
                DEC     CL            ;then decrease the speed of both worms      
                DEC     CH                                           
        Ok:                           
                DEC     BYTE PTR CS:[Init];Counter for speed...stolen from code
                JNZ     Draw2         ;If not move yet try the other worm   
                MOV     BYTE PTR CS:[Init],CL;Reset the counter
                ADD     DI,BP         ;New blue offset                     
                                             
                CMP     BYTE PTR [DI],11h;Is this byte free
                JB      RedW          ;No? Blue is dead!   
                JE      JustMv        ;Is it special?
                                                     
                MOV     CL,80h        ;Yes... Reset speed!
                                                          
        JustMv: MOV     BYTE PTR [DI],1;Put blue byte
                                       
        Draw2:                                                         
                dec     BYTE PTR cs:[INIT+1];All this is just like the 
                jnz     repeat        ;blue worm
                MOV     BYTE PTR CS:[INIT+1],CH
                ADD     SI,BX                  
                CMP     BYTE PTR [SI],11h      
                JB      BlueW                  
                JE      JustM2                       
                                                     
                MOV     CH,80h                 
                                                     
        JustM2: MOV     BYTE PTR [SI],4
                                       
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Clear keyboard buffer, and read keys°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                                     
        Repeat: MOV     AX,0C00h      ;Code for clear the buffer!  
                INT     21h           ;Clear Keyb Buffer         
                IN      AL,60h        ;Get keypress scancode
                                               
                DEC     AL            ;Esc     
                JE      Escape        ;goon... quit if you will         
                                                               
                PUSH    DI            ;store registers                         
                PUSH    CX                                     
                MOV     DI,OFFSET Keys;the scancodes-1 are in the list keys
                                                               
                MOV     CX,9          ;check for 8 keys
                REPNE                 ;do until a key found
                SCASB                 ;scan on                         
                JCXZ    Nope          ; if not found: Go on!                         
                                                               
                TEST    DI,1          ;is it an even number?                         
                JZ      GoOn          ;Yes? Red worm! jump! Else it's blue!

                MOV     AX,CS:[DI+7]  ;AX contains direction
                PUSH    AX            ;store it                         
                ADD     AX,BP         ;is it the opposite direction?                         
                POP     AX            ;(restore it)                              
                JZ      NOPE          ;Yes? DONT MOVE!!!                         
                MOV     BP,AX         ;No! Go in new direction                         
                JMP     SHORT Nope    ;Go on!                         
                                              
        GoOn:   MOV     AX,CS:[DI+6]  ;It's blue allright! Otherwise, just       
                PUSH    AX            ;like red!                                    
                ADD     AX,BX                   
                POP     AX                      
                JE      Nope                    
                MOV     BX,AX                   

        Nope:   POP     CX            ;Restore registers used in keyscan! 
                POP     DI                                               
                                                                         
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Check for time limit (=Move worms)°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                   
                MOV     AX,GS:[046Ch] ;lower word of timer ticks
                CMP     AX,DX         ;did it change?                       
                JNE     Draw          ;Yes! Draw it now!!!!               
                JMP     SHORT Repeat  ;Continue the game...
                                                         
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Initialize colors (Why did the game quit)°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                     
        RedW:   MOV     BH,47h        ;Set color to red and quit
                JMP     SHORT Ende                         
                                                                
        BlueW:  CMP     DI,SI                              
                JE      Escape        ;If equal then noone wins
                                                           
                MOV     BH,17h        ;Set color to blue and quit
                JMP     SHORT Ende                            
                                                               
        Escape: MOV     BH,07h        ;Oh No! You pressed Escape! Set color to black
                                           
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°Clear text mode screen with color and quit°°°°°°°°°°°°°°°°°°°
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
                                                           
        Ende:   MOV     AX,0003h      
                INT     10h           ;Video mode 03h: 80x25, 16 cols 
                PUSH    0B800h            
                POP     DS            ;DS=B800, text mode offset
                MOV     DS:BYTE PTR [1],BH
                CALL    TimeFreq      ;Set the time freq
                OUT     40h,AL        ;the freq. is 18.2 times/sec.                       
                STI                                                
                INT     20h           ;Exit program...
        Keys    DB      47h,10h,4Ah,1Dh,4Fh,1Eh,4Ch,1Fh ;The scnacodes-1
                DW      -320,-1,320,1                   ;The directions                

        TimeFreq PROC   Near
                CLI                   ;a 'DO NOT DISTURB' sign!! ?!
                MOV     AL,00110110b  ;time register (0), write, mode 3
                OUT     43h,AL        ;to control register og timer
                MOV     AL,0          ;upper byte       
                OUT     40h,AL        ;time of day clock                                               
                RET                   ;get me out of here              
        TimeFreq ENDP                                    
                                                         
                END     INIT          ;THAT'S ALL FOLKS! 
 