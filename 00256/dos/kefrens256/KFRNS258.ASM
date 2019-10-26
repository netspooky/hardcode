;       Kefrens258, the final version of Kfrns256
;       by Optimus/Dirty Minds/Nasty Bugs
;       Compiled with NASM
;       ---------------------------------
;
;       Phew! Fixed (Weeelll,.. almost :)
;
;       --------------------------------------------------------------------
;
;       Mail me at: mkargas@hotmail.com
;       Find me at: http://users.auth.gr/mkargas
;
;       Goodies to stare at:
;       http://users.auth.gr/mkargas/grscene
;       http://cpc-demoscene.paraknowya.com
;       http://cfemales.paraknowya.com
;       -----------------------


org 100h

	
	MOV     AL,13h
	INT     10h

; ---------- Do Line split ---------

	MOV     DX,3D4h
	OUT     DX,AL
	INC     DX
	XOR     AL,AL
	OUT     DX,AL

	


; ----------- Palgen ---------------



	MOV     BH,16
	MOV     BL,BH
	
	XOR     AL,AL
	MOV     DL,0C8h
	OUT     DX,AL
	INC     DX


loop0:

	
	MOV     AL,16
	SUB     AL,BH
	SHL     AL,1
	ADD     AL,31
	OUT     DX,AL

	XOR     AL,AL
	OUT     DX,AL

	MOV     AL,16
	SUB     AL,BL
	SHL     AL,1
	ADD     AL,31
	OUT     DX,AL
	

	DEC     BL
	JNZ     loop0

	MOV     BL,16
	DEC     BH
	JNZ     loop0




	PUSH WORD 0A002h
	POP     ES

; ----------- Sinegen ------------

	MOV     AX,CS
	SHL     BX,2
	ADD     AX,BX
	MOV     FS,AX
	ADD     AX,BX
	MOV     DS,AX


	XOR     CX,CX
	MOV     BX,CX

	MOV     SI,395
Singen:
	MOV     [FS:BX],CH
	ADD     CX,SI
	MOV     AX,40
	IMUL    CX
	sub     dx,3
	SUB     SI,DX
	INC     BL
	JNZ     Singen



; ----------- Start ------------


	
nextframe:

sti
cli
	INC     BL
	MOV     CX,390

W4Vsync:

	MOV     DX,3DAh                       ; Wait For Retrace
Vs1:
	IN      AL,DX
	AND     AL,8
	JZ      Vs1


nextline:



; ---------- Horizontal sync -----------

	MOV     DX,3DAh
hsync1:
	IN      AL,DX                   ; hsync1 waits until start of line
	AND     AL,1
	JNZ     hsync1

hsync2:
	IN      AL,DX                   ; hsync2 waits until end of line
	AND     AL,1
	JZ      hsync2


CALL    SkyColors

	
; ----------- Sinemove ------------

	MOV     AX,CX
	ADD     AL,BL
	XOR     AH,AH
	MOV     SI,AX

	XOR     DX,DX

	MOV     DL,[FS:SI]
	ADD     AL,BL
	MOV     DI,AX
	ADD     DL,[FS:DI]

	MOV     BH,15
bar:


	MOV     AL,[FS:SI]
	ADD     AL,128
	ADD     AL,BH
	MOV     DI,AX

	MOV     [DI],BH
	MOV     AL,BH
	OR      AL,[DI+320]
	MOV     [ES:DI],AL

	MOV     DI,DX
	MOV     AL,[FS:DI]
	ADD     AL,80
	ADD     AL,BH
	MOV     DI,AX
	MOV     AL,BH
	SHL     AL,4
	MOV     [DI+320],AL
	OR      AL,[DI]
	MOV     [ES:DI],AL

	DEC     BH
	JNZ     bar



	DEC     CX
	JNZ     nextline


	MOV     DI,320
eraseloop:
	MOV     [ES:DI],CL
	MOV     [DI],CL
	MOV     [DI+320],CL
	DEC     DI
	JNZ     eraseloop

	IN      AL,60h          ; check if Esc pressed
				; If Esc is pressed we get the value 1 at AL
	DEC     AL
	JNZ     nextframe



	MOV     DX,3D4h
	MOV     AX,2813h                ; set normal screen width
	OUT     DX,AX

	

	MOV     AX,3
	INT     10h

	
RET


SkyColors:

	DEC     AX
	MOV     DL,0C8h
	OUT     DX,AL

	INC     DX

	MOV     AX,CX
	SHR     AX,3
	MOV     BH,AL
	OUT     DX,AL
	SHR     AL,1
	OUT     DX,AL
	MOV     AL,BH
	MOV     BH,50
	SUB     BH,AL
	MOV     AL,BH
	OUT     DX,AL

RET
Endcode:
