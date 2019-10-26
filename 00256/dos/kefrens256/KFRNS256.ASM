;       Kefrens256, a 256byte intro
;       by Optimus/Dirty Minds/Nasty Bugs
;       Compiled with NASM
;       ---------------------------------
;
;       This must be my second X86 asm intro and my first one in 256b :)
;
;       Not what I wanted it to be as always :(
;       I am still newbie and I broke my head to find more bytes
;       but I decided to release it as I don't have more time to work 
;       to squish 256bytes and I want to get rid of it..
;
;       It is a hardware based effects, 2 sine Kefren bars
;       the special beeing that they are translucent each other
;       a nice colorfull raster background too. 306 colors total! ;)
;
;       If only there were more bytes to fix the sine movements :P
;       At the beginning I wanted to make btw 3 R,G,B bars
;       I also wanted to insert in the background
;       3 horizontal translucent rasterbars
;
;       Anyways,. I am still newbie and some parts of the code are messy
;       surelly much more bytes could be gained, but I had to stop
;       because my university exams starts in few days, and so I decided to
;       get rid with this thing quickly and send it to the xmas compo..
;
;       And I didn't had time to comment my source, so I leave it as it is..
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

	CLI                             ; I guess this asm command disables
					; interrupts? I got it from another
					; source. Just with this one it can
					; run good in windows too now! :)


; ---------- Do Line split ---------

	MOV     DX,3D4h
	OUT     DX,AL
	INC     DX
	XOR     AL,AL
	OUT     DX,AL




; ----------- Palgen ---------------



	MOV     BH,16
	MOV     BL,BH
	
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




; ----------- Sinegen ------------


	MOV     AX,08002h
	MOV     FS,AX
	ADD     AH,16
	MOV     DS,AX
	ADD     AH,16
	MOV     ES,AX


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


	INC     BL
	MOV     CX,400
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

	STI

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
