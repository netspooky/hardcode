.model tiny	;AZM the smurf
.code		;
.486		;256 byte intro by Akos Fekete (Chut)
		;
		;compiled by: Tasm, Tlink


o		EQU	offset
s		EQU	short

COLOR		EQU	0Fh			;color of lines

COORD		MACRO	x,y			;set cursor position
		DB	((y*2)/3)+((y*2)/3)+1	;x=0..319
		DB	(x*4)/5			;y=0..199
		ENDM

NLINE		MACRO	a,f,l			;a=quarter (0..3)
		DB	(f*4+a)*10+l*2		;f=vector in quarter (0..5)
		ENDM				;l=length (0..4)

END_OF_DATAS	EQU	DB 1

		ORG	0100h


AZM:		MOV	AL,13h
		INT	10H			;change video mode: 320x200/8

		PUSH	0A000h
		POP	ES

		MOV	SI,o LINES

RELOAD:		LODSB
		SHR	AL,1
		JNC	s LINE
		JZ	s EXIT
		CBW
		IMUL	BP,AX,6			;Y coord
		LODSB
		IMUL	BX,AX,5			;X coord
		JMP	s RELOAD

LINE:		AAM	5
		MOV	CX,0102h
		ADD	CL,AL			;   ( 0 1 2 3 4 )
		SHR	CX,CL			;CL=64,32,16,8,4

NEWPIXEL:	PUSH	AX			;packed stepping codes

		MOV	DI,BP
		SHR	DI,2
		IMUL	DI,DI,320
		MOV	DX,BX
		SHR	DX,2
		ADD	DI,DX			;DI=current video position

		SHR	AX,2			;AL two upper bit -> vector rotation
		MOV	DX,03FEh
		ADD	DL,AH			;DH=d.X (-2..3)   DL=d.Y (3)
ROTATE:		XCHG	DL,DH
		NEG	DL
		SUB	AL,40h
		JNC	s ROTATE				

		MOV	AL,DH
		CBW
		ADD	BX,AX			;X=X+d.X
		XCHG	AX,DX
		CBW
		ADD	BP,AX			;Y=Y+d.Y

		MOV	AL,COLOR
		STOSB

		PUSHA

		CBW
		INT	1Ah
		MOV	DI,DX
WAITFORTICK:	INT	1Ah			;55ms waiting
		CMP	DI,DX
		JE	s WAITFORTICK
		IN	AL,60h			;check key to abort
		DEC	AX
		POPA
		POP	AX
		JZ	s EXIT
		LOOP	NEWPIXEL
		JMP	s RELOAD

EXIT:		CBW				;AX=0
		INT	16h			;waiting for a keystroke
		MOV	AX,3
		INT	10h			;set text mode
		RET				;go back to OS

LINES:		COORD	210,123			;LEFT EYE + NOSE
		NLINE	1,1,2
		NLINE	1,2,2
		NLINE	1,2,3
		NLINE	1,4,2
		NLINE	0,0,2
		NLINE	0,4,3
		NLINE	3,0,3
		NLINE	3,2,2
		NLINE	3,4,2
		NLINE	3,5,3
		NLINE	2,0,2
		NLINE	3,2,4
		NLINE	0,4,2
		NLINE	3,0,2
		NLINE	3,2,2
		NLINE	3,3,3
		NLINE	3,5,3
		NLINE	2,1,3
		NLINE	2,3,2
		NLINE	1,0,2
		NLINE	1,1,2
		NLINE	1,2,2

		COORD	168,117			;LEFT EYE 2
		NLINE	3,0,4
		NLINE	3,1,4
		NLINE	3,2,4
		NLINE	3,4,3
		NLINE	2,0,4
		NLINE	2,2,3

		COORD	193,104			;RIGHT EYE
		NLINE	0,4,4
		NLINE	3,0,4
		NLINE	3,2,3
		NLINE	3,2,4
		NLINE	3,3,3
		NLINE	3,5,3
		NLINE	2,0,4

		COORD	203,112			;RIGHT EYE 2
		NLINE	3,2,3
		NLINE	3,5,3

		COORD	160,147			;MOUTH
		NLINE	0,4,3
		NLINE	2,4,4
		NLINE	3,4,3
		NLINE	3,3,1
		NLINE	3,2,1
		NLINE	3,1,2
		NLINE	3,1,3
		NLINE	2,4,2
		NLINE	2,5,2
		NLINE	1,0,2
		NLINE	1,1,2
		NLINE	1,2,3
		NLINE	1,3,3
		NLINE	1,4,3
		NLINE	0,1,3
		NLINE	0,2,3
		NLINE	0,3,2
		NLINE	0,4,3

		COORD	170,172			;TONGUE
		NLINE	3,1,2
		NLINE	3,2,3
		NLINE	3,4,2
		NLINE	2,1,3

		COORD	243,138			;CHIN + EAR + BROW
		NLINE	2,1,3
		NLINE	2,2,2
		NLINE	2,4,2
		NLINE	1,0,1
		NLINE	1,1,1
		NLINE	1,2,0
		NLINE	1,3,2
		NLINE	1,1,2
		NLINE	1,2,2
		NLINE	1,3,1
		NLINE	1,5,2
		NLINE	0,0,3
		NLINE	0,3,2
		NLINE	3,0,2
		NLINE	3,1,2
		NLINE	3,2,2
		NLINE	3,2,3
		NLINE	3,3,2
		NLINE	1,3,3
		NLINE	0,3,2
		NLINE	0,4,1
		NLINE	0,5,2
		NLINE	3,0,3
		NLINE	3,1,2
		NLINE	3,2,1
		NLINE	3,2,2
		NLINE	3,3,2
		NLINE	3,4,2
		NLINE	2,1,3

		COORD	116,162			;EAR2
		NLINE	1,3,2
		NLINE	1,1,2
		NLINE	2,0,2
		NLINE	3,3,2

		COORD	69,155			;CAP
		NLINE	0,1,1
		NLINE	0,2,1
		NLINE	0,3,1
		NLINE	0,4,1
		NLINE	0,5,1
		NLINE	3,0,2
		NLINE	3,1,0
		NLINE	3,2,0
		NLINE	3,3,1
		NLINE	3,4,2
		NLINE	2,0,3
		NLINE	2,2,3
		NLINE	2,4,3
		NLINE	1,0,2
		NLINE	1,1,1
		NLINE	1,2,1
		NLINE	1,2,3
		NLINE	1,4,3

		COORD	242,102			;CAP2
		NLINE	0,1,2
		NLINE	0,0,3
		NLINE	1,4,3
		NLINE	1,3,2
		NLINE	1,3,2
		NLINE	1,2,1
		NLINE	1,2,2
		NLINE	1,1,2

		COORD	202,61			;CAP3
		NLINE	2,1,2

		END_OF_DATAS

		END	AZM