; FIRE COMPO => WHO WRITES THE BEST FIRE EFFECT IN 256 BYTES ?
;                         
; Shows a very nice fire with watermirror and horizontal smoothing
; in MCGA 320x200x256. Use your left to exit (press esc)...
; Coded by T‚eM the Cat in May 10.1996. 13:00-22:00.
; Optimized: AMD5x86-P75-133MHZ, S3TRIO64
;                                
;                            Contact me at
;                         TEEM@LUDENS.ELTE.HU
;                     or visit T‚eM's Bungalow at
;                  HTTP://AUGUSTA.INF.ELTE.HU/~TEEM/
;   /\/\,/""\                                             /\/\,/""\
;  ( @.@) (  )                                           (-.- ) (  )
;   O O,,;O,,',,,,'                                       O^O,,;O,,;,,,,,
;                                
; note: this proggy uses the first 64KB of your PC's memory to
;       generate random effects...
;                          ( from 0000H:0000H to 0000H:FFFFH )
.386                             
TITLE	COM                      
CODE    SEGMENT USE16            
	ASSUME	DS:CODE, CS:CODE, ES:CODE
	ORG	100H             
                                 
INIT:                            
DONE:                            
                                 
  ; MAIN_HEAD                    
                                 
        MOV AX,13H               
        INT 10H                  
        CLD                      
                                 
        MOV CX,8000H    ; init backscreen 0 lines 0..132
        MOV ES,CX         
        XOR DI,DI                
        MOV DS,DI                
        MOV SI,DI       ; DS,SI,DI:=0
        MOV AL,(132*320)/256
        XCHG AL,CH        
        REP STOSB                
        MOV CX,320      ; init fire-source (line 133)
     @0:                         
        LODSB                    
        AND AL,31                
        ADD AL,192               
        STOSB                    
        LOOP @0                  
                          
                        ; init RGB palette
        MOV DX,3C8H       
     @1:                  
        MOV AL,CL       ; init palette 0..63
        SHR AL,1        ; set color CL to (CL/2,CL/4,0)
        OUT DX,AL         
        SHR AL,1          
        OUT DX,AL         
        XOR AL,AL         
        OUT DX,AL         
        MOV DL,0C9H       
        INC CL            
        CMP CL,64         
        JNE @1            
     @2:                ; init palette 64..255
        MOV CL,CH	; set color CH+64 to (CH/8+32,CH/4+16,CH/8)
        SHR CL,2          
        MOV AH,CL         
        SHR AH,1          
                          
        MOV AL,AH         
        ADD AL,32         
        OUT DX,AL         
                          
        MOV AL,CL           
        ADD AL,16         
        OUT DX,AL         
                          
        MOV AL,AH         
        OUT DX,AL         
        INC CH            
        CMP CH,192        
        JNE @2            
                          
 ; MAIN_BODY            ; ES -> seg0, DS -> backscreen0
 @MAIN_CYCLE:             
        XOR DX,DX                    
        MOV SI,DX                    
        MOV ES,DX	; ES:=0000H  
        MOV DH,80H                   
        MOV DS,DX	; DS:=8000H  
                                     
        XOR BH,BH           ; SHOWTIME: do flamming ! :)
        MOV CX,133*320               
        PUSH CX                      
        MOV DI,FS    ; load random counter
     @3:                             
        LODSB                        
        MOV AH,ES:[DI]       ; = [0000:DI]
	MOV BL,AH                    
        AND AH,4                     
        INC AH                       
        SUB AL,AH                    
        JNC short @LIVING            
                                     
        XOR AL,AL                    
     @LIVING:                        
	AND BL,1                     
        MOV DS:[SI+BX-321],AL        
        INC DI                       
        LOOP @3                      
        MOV FS,DI                    
                                     
        MOV DH,90H      ; do horizontal smoothing (backscreen0 => backscreen1)
        MOV ES,DX	; ES:=9000H  
        XOR SI,SI                    
        MOV DI,SI                    
        POP CX          ; CX:=133*320
        LODSB               
        MOV AH,AL           
        SHR AH,1            
     @6:                    
        LODSB               
        SHR AL,1            
        XCHG AL,AH          
        ADD AL,AH           
        STOSB               
        LOOP @6             
                            
        XOR SI,SI            ; create waterface , SI:=0
        MOV DI,199*320      
        MOV DS,DX	     ; DS:=9000H
        MOV DL,67           
        MOV BX,7F7FH        
     @4:                    
        MOV CL,160          
     @5:                    
        LODSW               
        SHR AX,1            
        AND AX,BX           
        STOSW               
        LOOP @5             
        SUB DI,640          
        ADD SI,320          
        DEC DL              
        JNZ @4 
               
                        ; display (backscreen1 => videomemory)
        MOV DH,0A0H
        MOV ES,DX
        MOV CH,125      ; CX:=32000
	XOR SI,SI
	MOV DI,SI
        REP MOVSW
             
        MOV DX,60H      ; keyboard check
        IN AL,DX
        DEC AL
        JNZ @MAIN_CYCLE ; esc ?
             
 ; MAIN_FOOT 
             
        MOV AX,3
        INT 10H
	INT 20H
        
CODE	ENDS
        END INIT
;
;           !
;  /\/\     !
; ( @.@)/""\!  are you still reading ??
;  ',^   (  )
;    )) ' )/   bye:TM.
;    OO  OO                                                     CATS RULE!
