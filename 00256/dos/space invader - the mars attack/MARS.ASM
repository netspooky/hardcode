;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*;
; Title    : Space Invader - The Mars Attack                            ;
; Date     : 28 February 1998                                           ;
; Author   : Ang Chin Keong, 16+ years old student, from Malaysia.      ;
; E-mail   : chinkeog@tm.net.my                                         ;
; Homepage : http://www.geocities.com/SiliconValley/Haven/1234/         ;
; Purpose  : Written for The 256 bytes Space Invaders Competition       ;
;            http://www.daimi.aau.dk/~u972780/                          ;
; Compile  : Type "TASM MARS" and "TLINK /t MARS"                       ;
; Note     : This is my first game written in Assembly Language.        ;
;          : I wrote it on my 486DX2-66 using TASM 2.0 + TLINK 3.0      ;
;            It is the hardest program i ever write in ASM language     ;
;            and i learned a lot while writing this game.               ;
; Special thanks to Kaare Fiedler Christiansen                          ;
;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*;
;Keys :
;Press ESC to quit game.
;Press RIGHT SHIFT to fire.
;Press LELT ARROW KEY or RIGHT ARROW KEY to move.
;Press PAUSE to pause and any other key to continue.

TITLE SPACE INVADERS! - THE MARS ATTACK! BY ANG CHIN KEONG FEBRUARY 1998
.MODEL TINY
.CODE
.386

;----------------- CONSTANT DATA -------------------;

;***** KEYS CODE *****
ESC_KEY   EQU   01H           ; ESCAPE KEY
LEFT_KEY  EQU   4BH           ; LEFT ARROW KEY
RIGHT_KEY EQU   4DH           ; RIGHT ARROW KEY
FIRE_KEY  EQU   39H           ; SPACE BAR

;***** SCREEN CONSTANT *****
VIDEO_SEG EQU   0B800H        ; SCREEN SEGMENT FOR DIRECT WRITE
MAX_X     EQU   40*2          ; MAX X IN SCREEN OFFSET (40*(CHAR+COLOUR))

;***** BITSMAP CONSTANT *****
ENEMY     EQU   0A0FH         ; 0A = LIGHT GREEN    DB = SHAPE
FIGHTER   EQU   0F18H         ; FIGHTER'S BITSMAP
F_BULLET  EQU   0C1EH         ; FIGHTER'S BULLET
E_COLOUR  EQU   0AH           ; ENEMY'S COLOUR
E_SHAPE   EQU   0FH           ; ENEMY'S SHAPE
F_COLOUR  EQU   0FH           ; FIGHTER'S COLOUR
FB_COLOUR EQU   0CH           ; FIGHTER'S BULLET'S COLOUR

;--------------------- VARIABLE --------------------;
; USE PSP TO STORE VARIABLE :-)
;****** DELAY CONTER ********
            ORG   7CH
DELAY_COUNT LABEL BYTE          ; DELAY COUNTER

DELAY_COUNT_FB_FLYING LABEL WORD

;****** BULLET COUNTER ******
            ORG   7DH
FB_FLYING   LABEL BYTE          ; TOTAL FIGHTER'S BULLET FLYING ON SCREEN
MAX_FB      EQU   02H           ; MAXIMUM BULLET CAN FLY ON SCREEN

;**** ENEMY MOVING SPEED ****
            ORG   7EH
ENEMY_SPEED LABEL BYTE          ; DELAY BEFORE ENEMY'S NEXT MOVE
START_SPEED EQU   4             ; ENEMY'S STARTING SPEED

;------------------ PROGRAM START ------------------;
          ORG   100H
START:
          ;-------- SETUP SCREEN --------
          MOV   AL,1         ; MOV AX,0001H
          INT   10H          ; SET MODE TO 40X25
          PUSH  VIDEO_SEG    ; MOV AX,0B800H
          POP   ES           ; MOV ES,AX     - ES = VIDEO SEGMENT SAVE 1 BYTE
          PUSH  0            ; FS = 0
          POP   FS           ; FS IS USE TO GET THE TIMER TICKS


          ;-------- DRAW ENEMIES -------
          MOV   BL,MAX_X+4   ; START DRAW ENEMIES AT X=2 Y=1
          MOV   CL,60        ; DRAW 60 ENEMIES ( INSTEAD OF MOV CX,60 )
DRAW_ENEMY:                  ; DRAW ENEMIES' LOOP
          MOV   WORD PTR ES:[BX],ENEMY
          ADD   BX,08H       ; CALCULAT NEXT ENEMY'S SCREEN LOCATION
          INC   AH           ; ENEMY TO DRAW BEFORE NEXT LINE
          CMP   AH,10        ; 10 ENEMY DRAWN ?
          JNE   SHORT NONEXTLINE ; NO, SKIP.
          XOR   AX,AX        ; RESET COUNTER
          ADD   BX,MAX_X     ; NEXT LINE
NONEXTLINE:
          LOOP  DRAW_ENEMY

          ;------- DRAW FIGHTER --------
          MOV   BX,MAX_X*22+(20*2)      ; SCREEN LOCATION
          MOV   WORD PTR ES:[BX],FIGHTER

;          MOV   ENEMY_SPEED,START_SPEED  ; NO NEED STILL NEVER MIND

;-------------- MAIN LOOP START HERE ---------------;
MAIN_LOOP:

;--------------- OBJECT MOVING LOOP ----------------;

          MOV   CX,40*25             ; CHECK EACH CHARACTER ON SCREEN
          XOR   BX,BX                ; BX=FIRST CHAR'S SCREEN OFFSET

          MOV   AL,0                 ; AL = COUNT HOW MANY ENEMY STILL ALIVE

          MOV   DL,ENEMY_SPEED
          CMP   DELAY_COUNT,DL       ; TIMER DELAY DONE ?
          JBE   SHORT MOVE_OBJECT    ; NO, SKIP
;          MOV   DELAY_COUNT,0       ; RESET COUNTER
;          MOV   FB_FLYING,0         ; BULLET FLYING ON SCREEN = 0
          MOV   DELAY_COUNT_FB_FLYING,0

MOVE_OBJECT:
          MOV   DX,WORD PTR ES:[BX]  ; COPY SCREEN DATA TO DX

          MOV   WORD PTR ES:[BX],0   ; ERASE OLD OBJECT

         ;***** FIGHTER *****
          CMP   DH,F_COLOUR          ; IS IT OUR FIGHTER ?
          JNE   SHORT NEXT_OBJCHK1   ; NO, NEXT CHECK.

          ;------ MOVE--------
          CMP   AH,RIGHT_KEY         ; AH=KEY, MOVE RIGHT ?
          JNE   SHORT SAVE_BX        ; NO, SKIP CALCULATION
          INC   BX                   ; CALCULATE NEW SCREEN OFFSET FOR FIGHTER
          INC   BX                   ; NEW SCREEN OFFSET = BX+2
SAVE_BX:
          PUSH  BX                   ; SAVE SCREEN OFFSET OF NEXT CHARACTER
NEXT_FMOVE:
          CMP   AH,LEFT_KEY          ; AH=KEY,MOVE LEFT ?
          JNE   SHORT DRAW_FIGHTER   ; NO, GOTO DRAW FIGHTER
          DEC   BX                   ; CALCULATE NEW SCREEN OFFSET FOR FIGHTER
          DEC   BX                   ; NEW SCREEN OFFSET = BX-2

DRAW_FIGHTER:
          MOV   WORD PTR ES:[BX],FIGHTER ; DRAW FIGHTER
          ;------- FIRE ------
FIGHTER_FIRE:
          TEST  BYTE PTR FS:[417H],1H  ; RIGHT SHIFT PRESSED ?
          JZ    SHORT END_FMOVE        ; NO
          CMP   FB_FLYING,MAX_FB       ; CHECK IF TOO MANY BULLET
          JGE   SHORT END_FMOVE        ; YES, DON'T LET HIM FIRE

          MOV   WORD PTR ES:[BX-MAX_X],F_BULLET
END_FMOVE:
          POP   BX                     ; BX = SCREEN OFFSET OF NEXT CHARACTER

          ;**** ENEMY/ALIEN ****
NEXT_OBJCHK1:
          CMP   DH,E_COLOUR            ; IS IT AN ENEMY ?
          JNE   SHORT NEXT_OBJCHK2     ; NO, NEXT CHECK.
          INC   AL                     ; INCREASE COUNTER FOR ALIVE ENEMY
          CMP   DELAY_COUNT,0          ; TIME TO MOVE ENEMY ?
          JNE   SHORT E_NOTMOVE        ; NO, DELAY.
          INC   BX                     ; CALCULAT NEW LOCATION
          INC   BX
E_NOTMOVE:
          MOV   WORD PTR ES:[BX],ENEMY ; DRAW ENEMY

          ;**** FIGHTER'S BULLET ****
NEXT_OBJCHK2:
          CMP   DH,FB_COLOUR              ; FIGHTER'S BULLET ?
          JNE   SHORT END_MOVE            ; NO, GOTO END LOOP
          PUSH  BX                        ; BX ARE GOING TO BE MODIFY
          SUB   BX,MAX_X                  ; BX = NEW SCREEN OFFSET
          MOV   DX,F_BULLET               ; DX = FIGHTER'S BULLET
          CMP   BYTE PTR ES:[BX],E_SHAPE  ; HIT ENEMY ?
          JNE   SHORT B_NOTHIT            ; NO, HIT NOTHING
          XOR   DX,DX                     ; YES, ERASE BULLET.
B_NOTHIT:
          MOV   WORD PTR ES:[BX],DX       ; DRAW BULLET AT NEW LOCATION
          INC   FB_FLYING                 ; BULLET FLYING ON SCREEN = +1
          POP   BX                        ; RESTORE BX
END_MOVE:
          INC   BX                        ; CALCULAT
          INC   BX                        ; SCREEN OFFSET FOR NEXT CHARACTER
          LOOP  MOVE_OBJECT

;------------ ENEMY'S SPEED CONTROLER --------------;

          MOV   AH,START_SPEED            ; AH = STARTING_SPEED
          CMP   AL,45                     ; 45 ENEMY LEFT ?
          JG    SHORT SET_SPEED           ; NO
          DEC   AH                        ; YES, MOVE FASTER
          CMP   AL,30
          JG    SHORT SET_SPEED
          DEC   AH
          CMP   AL,20
          JG    SHORT SET_SPEED
          DEC   AH
          CMP   AL,05
          JG    SHORT SET_SPEED
          DEC   AH
SET_SPEED:
          MOV   ENEMY_SPEED,AH            ; ENEMY'S NEW SPEED = AH

;------------------- CHECK KEY ---------------------;
CHECK_KEY:
          MOV   AH,01H
          INT   16H                ; ANY KEY PRESSED ?
          MOV   AH,0
          JZ    SHORT NOKEYPRESSED ; NO, GOTO END OF CHECK KEY
          INT   16H                ; READ THE NEW KEY. AH = KEY
          CMP   AH,ESC_KEY         ; ESC PRESSED ?
          JE    SHORT EXIT         ; YES, EXIT PROGRAM.
NOKEYPRESSED:
;------------------ TIMER DELAY --------------------;
          MOV   CX,FS:[046CH]      ; GET TIMER ( USE AX SAVE 1 BYTES )
TIMER_CHECK:
          CMP   CX,FS:[046CH]      ; DELAY ENDED ?
          JE    SHORT TIMER_CHECK  ; NO, KEEP DELAY.
          INC   DELAY_COUNT        ; INCREASE DELAY COUNTER
          JMP   MAIN_LOOP          ; DELAY ENDED. BACK TO MAIN LOOP

;-------------------- EXIT HERE --------------------;
EXIT:
          MOV   AX,3
          INT   10H                ; SET SCREEN MODE BACK TO 80X25
          RET                      ; RETURN TO DOS (1 BYTE)
DB        'CHINKEONG'              ; MY SIGNATURE :-)
END       START
