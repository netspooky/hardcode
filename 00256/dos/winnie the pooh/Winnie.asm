.model tiny	;Winnie The Pooh
.code		;
.486		;256 byte intro by Akos Fekete (Chut)
		;
		;compiled by: Tasm, Tlink

DEBUG		EQU	0			;for Turbo Debugger
DISPLAYCOORDS	EQU	0			;to display current coordinates
NOWAIT		EQU	0			;much faster drawing

NC		MACRO	x,y			;NEW COORDINATE
		DB	(y+2)/4*6		;x:(0,1,2...255)
		DB	x			;y:(0,4,8...160)
		ENDM				;y not need to round

LN		MACRO   x,y,s			;LINE
		DB      (6*x+y+21)*6+s		;x,y: stepping value (-3..+3)
        	ENDM				;s: length of the line

STOP		EQU	DB	0FCh		;Exit Code (fixed)
COLOR		EQU	0Fh			;Color of lines

o		EQU	offset
s		EQU	short


		ORG	0100h


Winnie:		IF	DEBUG			;Register values for Turbo Debugger
		 MOV	AX,0000h
		 MOV	BX,0000h
		 MOV	CX,0000h
		 MOV	DX,DS
		 MOV	SI,0100h
		 MOV	DI,0FFFEh
		 MOV	BP,0999h
		ENDIF

		MOV	AL,13h
		INT	10H			;change video mode: 320x200/8

		PUSH	0A000h
		POP	ES

		MOV	SI,o Lines-1

NewCoord:	CMP	AL,2Ah			;new Y coordinate or Exit code
		JAE	s NoMore
		IMUL	BX,AX,16		;BX=Y coordinate (*4)
		LODSB
		IMUL	BP,AX,4			;BY=X coordinate (*4)

NewTag:		LODSB				;Get new line data
		AAM	6
		XCHG	AL,AH
		JZ	s NewCoord		;Set new cursor position

GenLength:	ADD	CL,AH
		DEC	AH
		JNS	s GenLength		;CL=3,7,13,21,31,43,57
		ADC	CX,CX			;CX=length of current line

		AAM	6			;Decode vector direction

NextPixel:	PUSH	AX			;Save that!

		MOV	DI,BX
		SHR	DI,2
		IMUL	DI,DI,320
		MOV	DX,BP
		SHR	DX,2
		ADD	DI,DX			;DI=current video position

		MOV	DH,-3
		ADD	DH,AH
		SAR	DX,8			;DX=-3..+3
		ADD	BP,DX			;X step

		SUB	AL,3
		CBW				;AX=-3..+2
		ADD	BX,AX			;Y step

		MOV	AL,COLOR
		STOSB				;draw pixel

		IF	DISPLAYCOORDS
		 CALL	DISPCOORDS
		ENDIF


		PUSHA
		CBW
		INT	1Ah
		MOV	DI,DX
WaitForTick:	INT	1Ah
		CMP	DI,DX

		IF	NOWAIT
		ELSE
		 JE	s WaitForTick
		ENDIF

		IN	AL,60h
		DEC	AX
		POPA				;55ms waiting

		POP	AX
		JNZ	s NoKey
NoMore:		XCHG	AX,CX
		INT	16h
		MOV	AX,3
		INT	10h			;Set the normal text screen
		RET				;Go back to DOS

NoKey:		LOOP	NextPixel
		JMP	s NewTag

Lines:		NC	123,149			;Face
		LN	-3,-2,2
		LN	-3,-3,3
		LN	-2,-3,3
		LN	-1,-2,4
		LN	-1,-3,4
		LN	 0,-2,3
		LN	 1,-2,3
		LN	 3,-1,4
		LN	 1,-2,3
		LN	-1,-2,3
		LN	 1,-2,2
		LN	 2,-2,2
		LN	 3,-1,4
		LN	 3,-2,4
		LN	 3,-1,2
		LN	 3,-1,3
		LN	 3, 0,4
		LN	 3, 1,2
		LN	 3, 0,2
		LN	 3, 1,2

		NC	129,128			;Mouth
		LN	 0, 2,2
		LN	 2, 2,2
		LN	 2, 0,3
		LN	 3,-1,2
		LN	 2,-2,2
		LN	 2,-3,3
		
		NC	152,120			;Nose
		LN	-3, 2,3
		LN	-3, 1,2
		LN	-3, 0,3
		LN	-3,-1,2
		LN	-3,-2,2
		LN	-2,-2,3
		LN	-2,-3,2
		LN	-1,-3,3
		LN	 1,-3,2

		NC	124,132			;Chin
		LN	 1, 2,2
		LN	 2, 2,2

		NC	152,120			;Corner of mouth
		LN	-3,-1,1
		LN	 3, 1,2

		NC	119, 92			;Nose2
		LN	 2, 1,2
		LN	 0, 2,2
		LN	-2, 2,2
		LN	-3, 0,2
		LN	-3,-1,2
		LN	-1,-2,2
		LN	 0,-2,2
		LN	 3,-1,2
		LN	 2, 0,2
		LN	 2, 1,2

		NC	118, 92			;Nose3
		LN	 3,-1,2
		LN	 2, 0,3
		LN	 3, 1,2
		LN	 2, 1,2

		NC	136, 82			;Brow
		LN	 0, 2,2
		LN	-1, 2,2
		LN	-3, 1,2

		NC	128, 86			;Right eye
		LN	 1,-2,2
		LN	 3, 0,1
		LN	 0, 2,1

		NC	120, 76			;Right eyebrow
		LN	 2,-2,2
		LN	 2,-1,3

		NC	158, 96			;Left eye
		LN	-3,-1,2
		LN	 1,-2,2
		LN	 3, 0,1
		LN	 1, 1,2

		NC	163, 76			;Left eyebrow
		LN	 3, 0,1
		LN	 2, 1,3
		LN	 1, 1,2

		NC	210,122			;Neck
		LN	-3,-1,3
		LN	-3, 0,5
		LN	-3, 1,4
		LN	-3, 2,5
		LN	-3, 2,2
		LN	-3, 1,4

		NC	150, 50			;Right ear
		LN	-1,-3,2
		LN	 0,-2,2
		LN	 1,-2,3
		LN	 3,-1,2
		LN	 2, 0,3
		LN	 3, 1,3
		LN	 2, 2,3
		LN	 0, 2,2

		NC	209, 67			;Left ear
		LN	 2,-3,3
		LN	 1,-3,2
		LN	 0,-3,3
		LN	-2,-3,2
		LN	-3,-2,2
		LN	-2, 0,4
		LN	-3, 2,2
		LN	-1, 2,4
		LN	 1, 2,1
		LN	 0, 2,2
		LN	 1, 2,2

		NC	205,118			;Neck2
		LN	 0, 1,2
		LN	 0,-2,2
		LN	 2,-3,3
		LN	 1,-3,4
		LN	 0,-3,3
		LN	 1,-3,1
		LN	 0,-2,3
		LN	-1,-3,3
		LN	-2,-2,2

		NC	110,134			;Shoulder
		LN	-3, 2,3
		LN	-2, 2,3

		NC	205,118			;Shoulder2
		LN	 3, 0,2
		LN	 3, 1,2
		LN	 1, 2,2
		LN	 0, 2,2
		LN	-2, 1,3
		LN	-1, 2,2
		LN	 2, 2,2
		
		STOP


		IF	DISPLAYCOORDS
DISPCOORDS	PROC	NEAR
		PUSHA
		XCHG	AX,BP
		SHR	AX,2
		MOV	BP,10
		MOV	CX,3
Loop1:		CWD
		DIV	BP
		PUSH	DX
		LOOP	Loop1
		PUSH	',' xor 30h
		XCHG	AX,BX
		SHR	AX,2
		MOV	CL,3
Loop2:		CWD
		DIV	BP
		PUSH	DX
		LOOP	Loop2
		MOV	AH,0Fh
		INT	10h
		MOV	AH,02h
		XOR	DX,DX
		INT	10h
		MOV	CL,7
PrintNext:	POP	AX
		XOR	AL,30h
		INT	29h
		LOOP	PrintNext
		POPA
		RET	
		ENDP
		ENDIF


		END	Winnie



; Stored data format (one byte): dddddsss
;
; ddddd : course of the vector
;
; sss   : length of line
;
; the x and y coordinates are changed by course vector value
; at each circle. the code work with 4-times higher value in
; coordinate registers because of the continuity of lines.
;
; is sss=0 that means, new absolute coordinate will be read
; but iff dddddd>29h that the drawing will be stop.
;
; after decoding y coordinate, the next byte will be "x"
; y is decoded from "ddddd" bits