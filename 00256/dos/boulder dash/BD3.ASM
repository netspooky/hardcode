
;                         "Boulder Dash" in 256 bytes

;                                    by

;                            James David Chapman

                                                                
;-----------------------------------------------------------------------------
	;assembler startup              ;assembled with:
	.MODEL TINY                     ;TASM BD3.ASM /m2 /uM520 /t >errors
	MASM51                          ;TLINK BD3.OBJ /3 /x /t
	QUIRKS                          ;
	.286                            ;The code of this program is also used
	.CODE                           ;as the data for the level maps.  So
	.STARTUP                        ;any change in the order of the code
					;is *very* important
;-----------------------------------------------------------------------------
	;setup screen and vars
	MOV AX,1                        ;set screen mode 40*25
	INT 10H                         ;call BIOS set screen int
	PUSH 0B800H                     ;colour screen segment, change to
	POP ES                          ;B000 for mono graphics cards
	PUSH ES                         ;set/reset DS to CS
	POP DS
	XOR DX,DX                       ;clear level counter
NEXTLEVEL:
	INC DX                          ;increase level counter
RESTART:
	XOR DI,DI                       ;clear screen pointer
	MOV SI,100H                     ;set source to start of com file

	;make the screen map
	MAPLOOP:
	MOV AL,CS:[SI]                  ;load a byte of the program and use it
	INC SI                          ;as the mapdata for the level
	MOV CX,DX
	ROR AL,CL                       ;change map for next level by rotating
	MOV CL,AL                       ;no. increases, so the data is changed
	OR CL,CL
	JZ MAPLOOP
	CALL PRINT4                     ;each byte of the programs code gives
	CALL PRINT4                     ;4+4 blocks on the screen, 256*8=2048
	CMP DI,2000                     ;so the program is *just* able to
	JBE MAPLOOP                     ;produce enough data for the screen

	;print level number
	MOV AL,30H                      ;set print value to "0"
	ADD AL,DL                       ;add level number to "0"
	XOR DI,DI                       ;di points for sides (after level prn)
	STOSW

	;print the screen border
	XOR SI,SI                       ;si points for top/bottom row
	MOV AX,01DBH                    ;a blue block
	MOV CL,40                       ;40 blocks across, and 40 lines down
	@@:                             ;(+15 overspill is off the display)
	ADD DI,76
	STOSW                           ;print the left side
	STOSW                           ;print the left side
	MOV [SI+24*80],AX               ;print the bottom line
	INC SI
	INC SI
	MOV [SI],AX                     ;print the top line (put in after the
	LOOP @B                          
;-----------------------------------------------------------------------------
	;set man pos
	MOV DI,88+06                    ;set man position

	;plot finish square
	MOV WORD PTR DS:[956-320],0AE58H;plot a flashing X home square
;-----------------------------------------------------------------------------
MAINLOOP:
	;change key press into man offset
	MOV AH,8                        ;DOS keyboard interrupt, 8 allows
	INT 21H                         ;control-break to end game
	OR AL,AL                        ;if extended key press, go get it
	JZ MAINLOOP
	CMP AL," "                      ;if space bar, reset *current* level
	JE RESTART                      ;ie no increase of dx

	;clear man
	MOV BYTE PTR [DI],20H           ;in case man is to be moved, clear him

	;convert keys into man offset
	RCR AL,1                        ;convert al into offset in BX
	MOV BX,80                       ;assume offset is +80
	JNC @F
	SUB BX,78                       ;make offset +2
	@@:
	CMP AL,26H                      ;if key is right or down skip neg
	JAE @F
	NEG BX                          ;make offset -80 or -2
	@@:

	;check new man offset, if block or boulder, don't move
	TEST BYTE PTR DS:[DI+BX],1
	JNZ PLOTMAN                     ;no move so just plot man again
	ADD DI,BX                       ;update mans position

	;if exit go to next level
	CMP DI,956-320                  ;exit square is wired in as 956 though
	JNE @F                          ;could be set as bp for a few bytes
	JMP NEXTLEVEL                   ;restart game in new level
	@@:

	;plot man
	PLOTMAN:
	MOV [DI],0E02H                  ;print smiley face in yellow
;-----------------------------------------------------------------------------

	;update map: check every boulder position for movement
UPDATE:
	XOR SI,SI                       ;start from top left of screen
	MOV CX,1000                     ;check 1000 words of data
UPDATELOOP:
	LODSW                           ;load screen item
	DEC CX
	JZ MAINLOOP                     ;all done with no updates so return
	CMP AL,"O"                      ;if boulder then it might need to
	JNE UPDATELOOP                  ;to be moved

	;is the boulder now in mid air?
	CMP BYTE PTR [SI+78]," "        ;test screen pos below boulder
	JNE @F

	;make the boulder fall and change colour
	MOV BYTE PTR [SI-2]," "         ;clear old boulder pos
	FALLS:
	MOV [SI+78],074FH               ;print it in a darker shade 'cos we can

	;check to see if man below the falling boulder
	CMP BYTE PTR [SI+78+80],2       ;is man below falling boulder?
	JNE UPDATE
	MOV BYTE PTR [SI+78]," "        ;clear old boulder pos
	MOV BYTE PTR [SI+78+81],0CH     ;print a red bloody man
	MOV DI,DS                       ;fake dead man, by setting his pos
					;to somewhere off screen, ds encodes
					;this to only 2 bytes

	;is the boulder ontop of another boulder?
	@@:
	CMP BYTE PTR [SI+78],"O"
	JNE UPDATELOOP

	;should the boulder fall to the left?
	CMP BYTE PTR [SI-4]," "         ;no update, if held up
	JNE @F
	CMP BYTE PTR [SI+76]," "        ;no update, if held up
	JNE @F
	MOV BYTE PTR [SI-2]," "         ;clear boulder
	DEC SI                          ;patch si for loop back into FALLS
	DEC SI
	JMP SHORT FALLS
	@@:

	;should the boulder fall to the right?
	CMP BYTE PTR [SI]," "
	JNE UPDATELOOP                  ;no update, if held up
	CMP BYTE PTR [SI+80]," "
	JNE UPDATELOOP                  ;no update, if held up
	MOV BYTE PTR [SI-2]," "         ;clear boulder
	INC SI                          ;patch si for loop back into FALLS
	INC SI
	JMP SHORT FALLS
PRINT4:
	MOV AX,6B0H                     ;if bit not set, then print a block
	CALL PRINT1                     ;of earth to the screen
	MOV AL,20H
	CALL PRINT1                     ;print a space if bit not set
	MOV AX,0F4FH
	CALL PRINT1                     ;print a boulder
	JNS @F                          ;reduce the ratio of blocks by only
	MOV AX,1DBH                     ;doing them if sign flag set
	CALL PRINT1                     ;print a block if bit not set
	@@:
	RET
PRINT1:
	RCR CL,1                        ;test bit in carry flag
	JC @F
	STOSW                           ;print item to screen
	@@:
	RET
;-----------------------------------------------------------------------------
	END                             ; :)                         JDC1998.
;-----------------------------------------------------------------------------
