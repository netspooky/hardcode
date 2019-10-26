;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
SUB_0003	PROC	NEAR
		CMP	BYTE PTR CS:DATA_0044,0	        ; (7047:0A1A=0)
		JE	@@LOC_RET_0033
		CMP	BYTE PTR CS:DATA_0045,3FH	; (7047:0A1B=0) '?'
		JE	@@LOC_RET_0033
		INC	CS:DATA_0045		        ; (7047:0A1B=0)
		PUSH	ES
		PUSH	CS
		POP	ES
		MOV	CX,12H
		MOV	DI,OFFSET DATA_0038	        ; (7047:0A01=1)
		MOV	AL,1
		REP	STOSB
		POP	ES
@@LOC_RET_0033:
		RETN
SUB_0003	ENDP
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;  Read song data for this tick ?
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
SUB_0004	PROC	NEAR
		MOV	SI,CS:Off3Song		; (7047:0A2B=0)
		MOV	BX,CS:Off2Song		; (7047:0A29=0)
		XOR	AX,AX
		MOV	AL,CS:Pattern		; (7047:0A5A=0)
		ADD	BX,AX
		XOR	AX,AX
		MOV	AL,[BX]
		MOV	CS:Track,AL		; (7047:0A5B=0)
		MOV	BX,480H
		MUL	BX
		ADD	SI,AX
		XOR	AX,AX
		MOV	AL,CS:Position		; (7047:0A5C=0)
		MOV	BL,12H
		MUL	BL
		ADD	SI,AX
		MOV	CX,9
@@LOCLOOP_0034:
		CALL	SUB_0005		; (026A)
		LOOP	@@LOCLOOP_0034

		MOV	DI,OFFSET Position	; (7047:0A5C=0)
		INC	BYTE PTR CS:[DI]
		MOV	BL,CS:[DI]
		CMP	BL,40H			; '@'
		JNE	@@LOC_RET_0037
		XOR	AL,AL
		MOV	CS:[DI],AL
		MOV	DI,OFFSET Pattern	; (7047:0A5A=0)
		MOV	AL,1
		ADD	CS:[DI],AL
		MOV	SI,CS:Off2Song		; (7047:0A29=0)
		XOR	BX,BX
		MOV	BL,CS:[DI]
		MOV	AL,[BX+SI]
		TEST	AL,80H
		JZ	@@LOC_RET_0037
		CMP	AL,0FFH
		JNE	@@LOC_0035
		MOV	AL,80H
@@LOC_0035:
		SUB	AL,80H
		CMP	AL,31H			; '1'
		JB	@@LOC_0036
		XOR	AL,AL
@@LOC_0036:
		MOV	CS:[DI],AL

@@LOC_RET_0037:
		RETN
SUB_0004	ENDP
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;    In - si
;    I think it translates partiture ;)
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
SUB_0005	PROC	NEAR
		XOR	AX,AX
		MOV	AL,[SI]
		INC	SI
		CMP	AL,80H
		JNE	@@LOC_0038
		JMP	@@LOC_0049		; (0360)
@@LOC_0038:
		CMP	AL,0
		JE	@@LOC_0039
		MOV	AH,9
		SUB	AH,CL
		CALL	SUB_0010		; (0609)
@@LOC_0039:
		MOV	AL,[SI]
		INC	SI
		CMP	AL,0
		JNE	@@LOC_0040
		JMP	@@LOC_RET_0048		; (035F)
@@LOC_0040:
		CMP	AL,1
		JNE	@@LOC_0041
		MOV	AH,3FH			; '?'
		MOV	CS:Position,AH		; (7047:0A5C=0)
		JMP	@@LOC_RET_0048		; (035F)
@@LOC_0041:
		MOV	AH,AL
		AND	AX,0FF0H
		SHR	AL,4
		CMP	AL,1
		JNE	@@LOC_0043
		MOV	DI,OFFSET DATA_0034	; (7047:09CB=0)
		MOV	BX,OFFSET DS:[9]	; (7047:0009=5)
		SUB	BX,CX
		SHL	BX,1
		INC	AH
		ADD	CS:[BX+DI],AH
		MOV	WORD PTR CS:[BX+DI+12H],1
@@LOC_0042:
		JMP	@@LOC_RET_0048		; (035F)
@@LOC_0043:
		CMP	AL,2
		JNE	@@LOC_0044
		MOV	DI,OFFSET DATA_0034	; (7047:09CB=0)
		MOV	BX,OFFSET DS:[9]	; (7047:0009=5)
		SUB	BX,CX
		SHL	BX,1
		INC	AH
		SUB	CS:[BX+DI],AH
		MOV	WORD PTR CS:[BX+DI+12H],1
		JMP	SHORT @@LOC_0042		; (02BA)
@@LOC_0044:
		CMP	AL,0AH
		JNE	@@LOC_0045
		SHL	AH,2
		MOV	DI,OFFSET DATA_0035	; (7047:09EF=0)
		MOV	BX,OFFSET DS:[9]	; (7047:0009=5)
		SUB	BX,CX
		MOV	CS:[BX+DI],AH
		MOV	BYTE PTR CS:[BX+DI+12H],1
		JMP	SHORT @@LOC_RET_0048	; (035F)
@@LOC_0045:
		CMP	AL,0BH
		JNE	@@LOC_0046
		SHL	AH,2
		MOV	DI,OFFSET DATA_0035	; (7047:09EF=0)
		MOV	BX,OFFSET DS:[9]	; (7047:0009=5)
		SUB	BX,CX
		MOV	CS:[BX+DI+9],AH
		MOV	BYTE PTR CS:[BX+DI+1BH],1
		CMP	AX,265AH
		INC	BX
		JMP	SHORT @@LOC_RET_0048	; (035F)
@@LOC_0046:
		CMP	AL,0CH
		JNE	@@LOC_0047
		SHL	AH,2
		MOV	DI,OFFSET DATA_0035	; (7047:09EF=0)
		MOV	BX,OFFSET DS:[9]	; (7047:0009=5)
		SUB	BX,CX
		MOV	CS:[BX+DI],AH
		MOV	BYTE PTR CS:[BX+DI+12H],1
		PUSH	SI
		PUSH	AX
		PUSH	BX
		MOV	SI,OFFSET Instruments	; (7047:0A3F=0FFH)
		MOV	AL,CS:[BX+SI]
		XOR	AH,AH
		MOV	BX,OFFSET DS:[0CH]	; (7047:000C=0EH)
		MUL	BX
		MOV	SI,CS:Off1Song		; (7047:0A27=0)
		ADD	SI,AX
		POP	BX
		POP	AX
		TEST	BYTE PTR [SI+8],1
		POP	SI
		JZ	@@LOC_RET_0048
		MOV	CS:[BX+DI+9],AH
		MOV	BYTE PTR CS:[BX+DI+1BH],1
		JMP	SHORT @@LOC_RET_0048	; (035F)
@@LOC_0047:
		CMP	AL,0FH
		INC	AH
		MOV	CS:DATA_0043,AH		; (7047:0A19=0)
		MOV	CS:DATA_0041,AH		; (7047:0A17=0)
  
@@LOC_RET_0048:
		RETN
@@LOC_0049:
		MOV	AL,[SI]
		AND	AL,7FH
		INC	SI
		MOV	AH,9
		SUB	AH,CL
		CALL	PutAXIns		; (0528)
		JMP	SHORT @@LOC_RET_0048	; (035F)
SUB_0005	ENDP
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
SUB_0006	PROC	NEAR
		CMP	BYTE PTR CS:DATA_0025,0	; (7047:08DD=0)
		JE	@@LOC_0050
		MOV	AX,251CH
		MOV	DX,WORD PTR CS:OldInt1C	; (7047:0A13=0)
		MOV	CX,WORD PTR CS:OldInt1C+2	; (7047:0A15=7047H)
		MOV	DS,CX
		INT	21H			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		MOV	BYTE PTR CS:DATA_0025,0	; (7047:08DD=0)
@@LOC_0050:
		XOR	AL,AL
		CALL	InitAdlib		; (044C)
		MOV	BYTE PTR CS:DATA_0023,0	; (7047:08DB=0)
		RETN
SUB_0006	ENDP
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
;   I N I T    P L A Y E R
;   In - BL Play Mode. 0 background; 1 polling.
;        BH Chain 1C with Old 1C ?. 0 Yes; 1 No.
;        ES:SI The song.
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
InitPlayer	PROC	NEAR
		MOV	CS:PollingOnOff,BL	; (7047:08D9=0)
		MOV	CS:SegSong,ES		; (7047:0A25=7047H)
		MOV	CS:Off1Song,SI		; (7047:0A27=0)
		ADD	SI,600H
		MOV	CS:Off2Song,SI		; (7047:0A29=0)
		ADD	SI,33H
		MOV	CS:Off3Song,SI		; (7047:0A2B=0)
		MOV	DS,CS:SegSong		; (7047:0A25=7047H)
		XOR	AL,AL
		CALL	InitAdlib		; (044C)
		MOV	AL,1
		MOV	AH,20H			; ' '
		CALL	WriteAdlib		; (08A8)
		MOV	AL,8
		MOV	AH,40H			; '@'
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0BDH
		MOV	AH,0
		CALL	WriteAdlib		; (08A8)
		XOR	AX,AX
		MOV	CX,9

@@LOCLOOP_0051:
		CALL	PutAXIns		; (0528)
		ADD	AX,101H
		LOOP	@@LOCLOOP_0051

		MOV	BYTE PTR CS:DATA_0044,0	; (7047:0A1A=0)
		MOV	BYTE PTR CS:DATA_0045,0	; (7047:0A1B=0)
		MOV	BYTE PTR CS:DATA_0041,1	; (7047:0A17=0)
		XOR	AL,AL
		MOV	CS:Pattern,AL		; (7047:0A5A=0)
		MOV	CS:Track,AL		; (7047:0A5B=0)
		MOV	CS:Position,AL		; (7047:0A5C=0)
		MOV	AL,2
		MOV	CS:DATA_0043,AL		; (7047:0A19=0)
		PUSH	ES
		PUSH	CS
		POP	ES
		MOV	CX,12H
		MOV	DI,OFFSET DATA_0038	; (7047:0A01=1)
		MOV	AL,1
		REP	STOSB
		MOV	CX,9
		MOV	DI,OFFSET Equalizer	; (7047:0A48=0FFH)
		MOV	AL,0FFH
		REP	STOSB
		POP	ES
		MOV	AX,351CH
		INT	21H			; DOS Services  ah=function 35h
						;  get intrpt vector al in es:bx
		MOV	WORD PTR CS:OldInt1C+2,ES  ; (7047:0A15=7047H)
		MOV	WORD PTR CS:OldInt1C,BX	   ; (7047:0A13=0)
		MOV	AX,251CH
		PUSH	CS
		POP	DS
		MOV	DX,OFFSET INT_1CH_ENTRY
		INT	21H			; DOS Services  ah=function 25h
						;  set intrpt vector al to ds:dx
		MOV	AL,0FFH
		MOV	CS:DATA_0023,AL		; (7047:08DB=0)
		MOV	CS:DATA_0025,AL		; (7047:08DD=0)
		RETN
InitPlayer	ENDP
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
;   I N I T    A D L I B
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
InitAdlib       PROC    NEAR
		MOV	AL,1
		MOV	AH,0
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0B0H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0B1H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0B2H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0B3H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0B4H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0B5H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0B6H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0B7H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0B8H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,80H
		MOV	AH,0FFH
		CALL	WriteAdlib		; (08A8)
		MOV	AL,81H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,82H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,83H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,84H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,85H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,88H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,89H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,8AH
		CALL	WriteAdlib		; (08A8)
		MOV	AL,8BH
		CALL	WriteAdlib		; (08A8)
		MOV	AL,8CH
		CALL	WriteAdlib		; (08A8)
		MOV	AL,8DH
		CALL	WriteAdlib		; (08A8)
		MOV	AL,90H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,91H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,92H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,93H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,94H
		CALL	WriteAdlib		; (08A8)
		MOV	AL,95H
		CALL	WriteAdlib		; (08A8)
		PUSH	ES
		PUSH	CS
		POP	ES
		MOV	DI,OFFSET DATA_0034	; (7047:09CB=0)
		MOV	AX,0
		MOV	CX,9
		REP	STOSW
		MOV	AX,1
		MOV	CX,9
		REP	STOSW
		MOV	DI,OFFSET DATA_0035	; (7047:09EF=0)
		MOV	AL,0
		MOV	CX,12H
		REP	STOSB
		MOV	AL,1
		MOV	CX,12H
		REP	STOSB
		MOV	DI,OFFSET Instruments	; (7047:0A3F=0FFH)
		MOV	AL,0FFH
		MOV	CX,9
		REP	STOSB
		MOV	DI,OFFSET Notes	; (7047:0A2D=0)
		MOV	AL,0
		MOV	CX,9
		REP	STOSB
		MOV	CX,9
		REP	STOSB
		MOV	DI,OFFSET Equalizer	; (7047:0A48=0FFH)
		MOV	AL,0FFH
		MOV	CX,9
		REP	STOSB
		POP	ES
		RETN
InitAdlib	ENDP
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
;   P U T   A N   I N S T R U M E N T
;   In - AX
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
PutAXIns	PROC	NEAR
		PUSHA
		XOR	CX,CX
		MOV	DI,OFFSET Instruments	; (7047:0A3F=0FFH)
		XOR	BX,BX
		MOV	BL,AH
		CMP	CS:[BX+DI],AL
		JNE	@@LOC_0052
		JMP	@@LOC_0053		; (0607)
@@LOC_0052:
		MOV	CS:[BX+DI],AL
		MOV	CL,AH
		XOR	AH,AH
		MOV	BX,0CH
		MUL	BX
		MOV	SI,CS:Off1Song		; (7047:0A27=0)
		ADD	SI,AX
		MOV	AL,0B0H
		ADD	AL,CL
		XOR	AH,AH
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0C0H
		ADD	AL,CL
		MOV	AH,[SI+8]
		CALL	WriteAdlib		; (08A8)
		MOV	DI,OFFSET DATA_0029	; (7047:09B3=3)
		ROL	CX,1
		ADD	DI,CX
		ROR	CX,1
		MOV	AL,20H			; ' '
		ADD	AL,CS:[DI]
		MOV	AH,[SI]
		CALL	WriteAdlib		; (08A8)
		MOV	AL,20H			; ' '
		ADD	AL,CS:[DI+1]
		MOV	AH,[SI+1]
		CALL	WriteAdlib		; (08A8)
		MOV	AL,60H			; '`'
		ADD	AL,CS:[DI]
		MOV	AH,[SI+4]
		CALL	WriteAdlib		; (08A8)
		MOV	AL,60H			; '`'
		ADD	AL,CS:[DI+1]
		MOV	AH,[SI+5]
		CALL	WriteAdlib		; (08A8)
		MOV	AL,80H
		ADD	AL,CS:[DI]
		MOV	AH,[SI+6]
		CALL	WriteAdlib		; (08A8)
		MOV	AL,80H
		ADD	AL,CS:[DI+1]
		MOV	AH,[SI+7]
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0E0H
		ADD	AL,CS:[DI]
		MOV	AH,[SI+9]
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0E0H
		ADD	AL,CS:[DI+1]
		MOV	AH,[SI+0AH]
		CALL	WriteAdlib		; (08A8)
		MOV	AL,40H			; '@'
		ADD	AL,CS:[DI]
		MOV	AH,[SI+2]
		CALL	WriteAdlib		; (08A8)
		MOV	AL,40H			; '@'
		ADD	AL,CS:[DI+1]
		MOV	AH,[SI+3]
		CALL	WriteAdlib		; (08A8)
		MOV	DI,OFFSET DATA_0035	; (7047:09EF=0)
		ADD	DI,CX
		MOV	AL,[SI+2]
		MOV	CS:[DI],AL
		MOV	BYTE PTR CS:[DI+12H],1
		MOV	AL,[SI+3]
		MOV	CS:[DI+9],AL
		MOV	BYTE PTR CS:[DI+1BH],1
		MOV	AL,[SI+0BH]
		AND	AL,0F0H
		SHR	AL,4
		MOV	DI,OFFSET DATA_0046	; (7047:0A1C=0)
		ADD	DI,CX
		MOV	CS:[DI],AL
@@LOC_0053:
		POPA
		RETN
PutAXIns	ENDP
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
SUB_0010	PROC	NEAR
		PUSHA
		CMP	AL,7FH
		JE	@@LOC_0054
		XOR	CX,CX
		MOV	CL,AH
		MOV	DI,CX
		MOV	CL,1
		MOV	CS:Notes[DI],AL	; (7047:0A2D=0)
		MOV	CS:DATA_0052[DI],CL	; (7047:0A36=0)
		DEC	AL
		MOV	CS:DATA_0042,AL		; (7047:0A18=0)
		XOR	CX,CX
		MOV	CL,AH
		MOV	DI,9B3H
		ROL	CX,1
		ADD	DI,CX
		ROR	CX,1
		MOV	AL,0B0H
		ADD	AL,CL
		XOR	AH,AH
		CALL	WriteAdlib		; (08A8)
		MOV	BX,OFFSET DATA_0034	; (7047:09CB=0)
		ROL	CX,1
		MOV	DI,CX
		ROR	CX,1
		ADD	DI,BX
		MOV	SI,OFFSET DATA_0028	; (7047:08F1=0)
		XOR	BX,BX
		MOV	BL,CS:DATA_0042		; (7047:0A18=0)
		ROL	BX,1
		MOV	AX,CS:[BX+SI]
		MOV	CS:[DI],AX
		MOV	WORD PTR CS:[DI+12H],1
		POPA
		RETN
@@LOC_0054:
		MOV	AL,AH
		XOR	AH,AH
		MOV	BX,9CBH
		ROL	AX,1
		MOV	DI,AX
		ADD	DI,BX
		MOV	AX,CS:[DI]
		AND	AH,0DFH
		MOV	CS:[DI],AX
		MOV	WORD PTR CS:[DI+12H],1
		POPA
		RETN
SUB_0010	ENDP
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
;   P U T    V A R I A B L E S
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
PutVars	        PROC	NEAR
		PUSHA
		MOV	CX,9
		MOV	DI,OFFSET DS:[8]	; (7047:0008=75H)
@@LOC_0055:
		MOV	BYTE PTR CS:Playing[DI],0	; (7047:0A51=0)
		CMP	BYTE PTR CS:DATA_0052[DI],0	; (7047:0A36=0)
		JE	@@LOC_0057
		MOV	AL,80H
		MOV	AH,CS:DATA_0035[DI]	; (7047:09EF=0)
		AND	AH,3FH			; '?'
		SUB	AL,AH
		MOV	AH,CS:DATA_0037[DI]	; (7047:09F8=0)
		AND	AH,3FH			; '?'
		SUB	AL,AH
		SHR	AL,3
		CMP	AL,0FH
		JBE	@@LOC_0056
		MOV	AL,0FH
@@LOC_0056:
		INC	AL
		MOV	CS:Equalizer[DI],AL	; (7047:0A48=0FFH)
		MOV	BYTE PTR CS:DATA_0052[DI],0	; (7047:0A36=0)
		MOV	BYTE PTR CS:Playing[DI],0FFH	; (7047:0A51=0)
@@LOC_0057:
		CMP	BYTE PTR CS:Equalizer[DI],0FFH	; (7047:0A48=0FFH)
		JE	@@LOC_0058
		DEC	CS:Equalizer[DI]	; (7047:0A48=0FFH)
@@LOC_0058:
		DEC	DI
		LOOP	@@LOCLOOP_0059
  
		POPA
		RETN

@@LOCLOOP_0059:
		JMP	SHORT @@LOC_0055		; (0686)
PutVars	ENDP
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
;   P L A Y    A L L    C H A N N E L S
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
PlayAllIns      PROC	NEAR
		PUSHA
		MOV	CX,9

@@LOCLOOP_0060:
		DEC	CX
		CALL	PlayCXIns		; (06E7)
		INC	CX
		LOOP	@@LOCLOOP_0060

		POPA
		RETN
PlayAllIns	ENDP
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
;   P L A Y    C X    C H A N N E L S
;   CX = 0..8
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
PlayCXIns       PROC	NEAR
		MOV	BX,OFFSET DATA_0034	; (7047:09CB=0)
		ROL	CX,1
		MOV	SI,CX
		ROR	CX,1
		MOV	DI,OFFSET DATA_0046	; (7047:0A1C=0)
		ADD	DI,CX
		CMP	BYTE PTR CS:[DI],0
		JNE	@@LOC_0061
		CMP	WORD PTR CS:[BX+SI+12H],0
		JE	@@LOC_0062
@@LOC_0061:
		MOV	WORD PTR CS:[BX+SI+12H],0
		MOV	AL,0A0H
		ADD	AL,CL
		MOV	AH,CS:[BX+SI]
		ADD	AH,CS:[DI]
		CALL	WriteAdlib		; (08A8)
		MOV	AL,0B0H
		ADD	AL,CL
		MOV	AH,CS:[BX+SI+1]
		CALL	WriteAdlib		; (08A8)
@@LOC_0062:
		MOV	DI,OFFSET DATA_0029	; (7047:09B3=3)
		ROL	CX,1
		ADD	DI,CX
		ROR	CX,1
		MOV	SI,OFFSET DATA_0035	; (7047:09EF=0)
		ADD	SI,CX
		CMP	BYTE PTR CS:[SI+12H],0
		JE	@@LOC_0063
		MOV	BYTE PTR CS:[SI+12H],0
		MOV	AL,40H			; '@'
		ADD	AL,CS:[DI]
		MOV	DX,AX
		MOV	AL,3FH			; '?'
		SUB	AL,CS:[SI]
		PUSH	DX
		MOV	DH,AL
		AND	DH,0C0H
		AND	AX,3FH
		PUSH	DX
		MOV	BL,3FH			; '?'
		SUB	BL,CS:DATA_0045		; (7047:0A1B=0)
		XOR	BH,BH
		MUL	BX
		MOV	BX,3FH
		DIV	BX
		POP	DX
		MOV	DL,AL
		MOV	AL,3FH			; '?'
		SUB	AL,DL
		AND	AL,3FH			; '?'
		OR	AL,DH
		POP	DX
		MOV	AH,AL
		MOV	AL,DL
		CALL	WriteAdlib		; (08A8)
@@LOC_0063:
		CMP	BYTE PTR CS:[SI+1BH],0
		JE	@@LOC_RET_0066
		MOV	BYTE PTR CS:[SI+1BH],0
		MOV	AL,40H			; '@'
		ADD	AL,CS:[DI+1]
		MOV	DX,AX
		MOV	AL,CS:[SI+9]
		PUSH	DI
		PUSH	AX
		PUSH	DX
		PUSH	BX
		MOV	DI,OFFSET Instruments	; (7047:0A3F=0FFH)
		MOV	BX,CX
		MOV	AL,CS:[BX+DI]
		XOR	AH,AH
		MOV	BX,0CH
		MUL	BX
		MOV	DI,CS:Off1Song		; (7047:0A27=0)
		ADD	DI,AX
		TEST	BYTE PTR [DI+8],1
		JNZ	@@LOC_0064
		POP	BX
		POP	DX
		POP	AX
		POP	DI
		JMP	SHORT @@LOC_0065		; (07E1)
@@LOC_0064:
		POP	BX
		POP	DX
		POP	AX
		POP	DI
		MOV	AL,3FH			; '?'
		SUB	AL,CS:[SI+9]
		PUSH	DX
		MOV	DH,AL
		AND	DH,0C0H
		AND	AX,3FH
		PUSH	DX
		MOV	BL,3FH			; '?'
		SUB	BL,CS:DATA_0045		; (7047:0A1B=0)
		XOR	BH,BH
		MUL	BX
		MOV	BX,3FH
		DIV	BX
		POP	DX
		MOV	DL,AL
		MOV	AL,3FH			; '?'
		SUB	AL,DL
		AND	AL,3FH			; '?'
		OR	AL,DH
		POP	DX
@@LOC_0065:
		MOV	AH,AL
		MOV	AL,DL
		CALL	WriteAdlib		; (08A8)
  
@@LOC_RET_0066:
		RETN
PlayCXIns	ENDP
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;			       SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
SUB_0014	PROC	NEAR
		PUSH	BX
		PUSH	DX
		MOV	BX,OFFSET DATA_0027	; (7047:08DF=18H)
@@LOC_0067:
		MOV	DX,CS:[BX]
		MOV	CS:DATA_0030,DX		; (7047:09C5=388H)
		INC	DX
		MOV	CS:DATA_0031,DX		; (7047:09C7=389H)
		MOV	DX,3DAH
@@LOC_0068:
		IN	AL,DX			; port 3DAH, CGA/EGA vid status
		TEST	AL,8
		JNZ	@@LOC_0068
		MOV	DX,3DAH
@@LOC_0069:
		IN	AL,DX			; port 3DAH, CGA/EGA vid status
		TEST	AL,8
		JZ	@@LOC_0069
		MOV	DX,3DAH
@@LOC_0070:
		IN	AL,DX			; port 3DAH, CGA/EGA vid status
		TEST	AL,8
		JZ	@@LOC_0070
		MOV	DX,3DAH
@@LOC_0071:
		IN	AL,DX			; port 3DAH, CGA/EGA vid status
		TEST	AL,8
		JNZ	@@LOC_0071
		MOV	AL,4
		MOV	AH,60H			; '`'
		CALL	WriteAdlib		; (08A8)
		MOV	AL,4
		MOV	AH,80H
		CALL	WriteAdlib		; (08A8)
		MOV	DX,CS:DATA_0030		; (7047:09C5=388H)
		IN	AL,DX			; port 388H, comm 8273 status
		AND	AL,0E0H
		MOV	CS:DATA_0032,AL		; (7047:09C9=0)
		MOV	AL,2
		MOV	AH,0FFH
		CALL	WriteAdlib		; (08A8)
		MOV	AL,4
		MOV	AH,21H			; '!'
		CALL	WriteAdlib		; (08A8)
		MOV	DX,3DAH
@@LOC_0072:
		IN	AL,DX			; port 3DAH, CGA/EGA vid status
		TEST	AL,8
		JNZ	@@LOC_0072
		MOV	DX,3DAH
@@LOC_0073:
		IN	AL,DX			; port 3DAH, CGA/EGA vid status
		TEST	AL,8
		JZ	@@LOC_0073
		MOV	DX,3DAH
@@LOC_0074:
		IN	AL,DX			; port 3DAH, CGA/EGA vid status
		TEST	AL,8
		JZ	@@LOC_0074
		MOV	DX,3DAH
@@LOC_0075:
		IN	AL,DX			; port 3DAH, CGA/EGA vid status
		TEST	AL,8
		JNZ	@@LOC_0075
		MOV	DX,CS:DATA_0030		; (7047:09C5=388H)
		IN	AL,DX			; port 388H, comm 8273 status
		AND	AL,0E0H
		MOV	CS:DATA_0033,AL		; (7047:09CA=0)
		MOV	AL,4
		MOV	AH,60H			; '`'
		CALL	WriteAdlib		; (08A8)
		MOV	AL,4
		MOV	AH,80H
		CALL	WriteAdlib		; (08A8)
		CMP	BYTE PTR CS:DATA_0032,0	; (7047:09C9=0)
		JNE	@@LOC_0077
		CMP	BYTE PTR CS:DATA_0033,0C0H	; (7047:09CA=0)
		JNE	@@LOC_0077
		MOV	AX,CS:DATA_0030		; (7047:09C5=388H)
@@LOC_0076:
		POP	BX
		POP	DX
		RETN
@@LOC_0077:
		ADD	BX,2
		MOV	DX,CS:[BX]
		CMP	DX,0FFFFH
		JE	@@LOC_0078
		JMP	@@LOC_0067		; (07EE)
@@LOC_0078:
		MOV	AX,0FFFFH
		JMP	SHORT @@LOC_0076		; (0892)
SUB_0014	ENDP
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   W R I T E    A D L I B
;   Send AL to adlib address/Status port (R/W).-wait for 12 cycles
;   Send AL to adlib data port           (W/O).-wait for 84 cycles
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
WriteAdlib      PROC	NEAR
		MOV	DX,CS:DATA_0030		; (7047:09C5=388H)
		OUT	DX,AL			; port 388H, comm 8273 command
		IN	AL,DX			; port 388H, comm 8273 status
		IN	AL,DX			; port 388H, comm 8273 status
		IN	AL,DX			; port 388H, comm 8273 status
		IN	AL,DX			; port 388H, comm 8273 status
		IN	AL,DX			; port 388H, comm 8273 status
		IN	AL,DX			; port 388H, comm 8273 status
		INC	DX
		MOV	AL,AH
		OUT	DX,AL			; port 389H, comm 8273 parametr
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		IN	AL,DX			; port 389H, comm 8273 status
		RETN
WriteAdlib	ENDP
