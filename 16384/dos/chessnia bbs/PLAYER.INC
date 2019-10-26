;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
;  TITLE OPL2 player by Spanish Lords.
;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;  PUBLIC  NewSong     ; ˛ bl-PollingOnOff    ˛ es:si-music data
;  PUBLIC  PlayPoll    ; do NOT work correctly :(
;  PUBLIC  StopMusic   ;
;  PUBLIC  FadeOut     ; Fade out music. silly PROC ;)
;  PUBLIC  DetectOPL2  ; do NOT work with GUS  Out - Carry if error.
;  PUBLIC  OffVar      ; Out - ES:DI  variables Seg:Off
; ∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
;   V A R I A B L E S
;   Notes          DB   9       actual notes
;   DATA_0052      DB   9       more about notes.
;   Instruments    DB   9       actual instruments
;   Equalizer      DB   9       equalizer (ffh-0fh)
;   Playing        DB   9       equalizer peaks (ffh = peak)
;   Pattern        DB   1       actual pattern
;   Track          DB   1       actual track
;   Position       DB   1       actual position
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   Call this routine when you start a new tune.
;
;   ENTRIES:
;
;   bl      PollingOnOff 0 background, using 1C int.
;                        1 is polling-mode. do NOT work correctly :(
;   es:si   music data   pointer to the music data loaded into memory.
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
NewSong         PROC    FAR
		PUSH    DS ES
		MOV     CS:DosIrqSeg,CS         ; For Timer Polling Syncro
		CMP     BYTE PTR CS:DATA_0023,0 ;
		JE      @@LOC_0008
		PUSHA
		CALL    SUB_0006
		POPA
@@LOC_0008:
		PUSHA
		CALL    InitPlayer
		POPA
		POP     ES DS
		RETF
NewSong         ENDP
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   Poll music   when in polling mode, you have to call this function at
;                least 18 times per second. it will play the music.
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PlayPoll        PROC    FAR
		PUSH    DS ES
		CMP     BYTE PTR CS:DATA_0022,0 ; (7047:08DA=0)
		JE      @@LOC_0011
		CMP     BYTE PTR CS:DATA_0023,0 ; (7047:08DB=0)
		JE      @@LOC_0011
		PUSHA
		PUSH    DS
		PUSH    ES
		MOV     DS,CS:SegSong           ; (7047:0A25=7047H)
		MOV     DI,OFFSET DATA_0041     ; (7047:0A17=0)
		DEC     BYTE PTR CS:[DI]
		MOV     AH,CS:[DI]
		CMP     AH,0
		JNE     @@LOC_0010
		MOV     AL,CS:DATA_0043         ; (7047:0A19=0)
		MOV     CS:[DI],AL
		CALL    SUB_0004                ; (01F8)
@@LOC_0010:
		CALL    PutVars                 ; (067F)
		CALL    PlayAllIns              ; (06DA)
		CALL    SUB_0003                ; (01D4)
		POP     ES
		POP     DS
		POPA
@@LOC_0011:
		MOV     BYTE PTR CS:DATA_0022,0 ; (7047:08DA=0)
		POP     ES DS
		RETF                            ; (0058)
PlayPoll        ENDP
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   Stop music.
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
StopMusic       PROC    FAR
		PUSH    DS ES
		CMP     BYTE PTR CS:DATA_0023,0 ; (7047:08DB=0)
		JE      @@QuitNow
		PUSHA
		CALL    SUB_0006                ; (036E)
		POPA
@@QuitNow:
		POP     ES DS
		RETF
StopMusic       ENDP
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   fade out    fades out the music.
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FadeOut         PROC    FAR
		MOV     BYTE PTR CS:DATA_0044,0FFH      ; (7047:0A1A=0)
		RETF
FadeOut         ENDP
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;  detect/reset searches for an adlib or compatible soundcard. returns
;               with carry set when an error occurs, otherwise ax contains
;               the port found. this has to be started one time to reset
;               the soundcard.
;               The detect fails, if a gravis ultrasound sticks in your
;               system. Don't forget to give your users the possibility
;               to skip the detection.
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
DetectOPL2      PROC    FAR
		PUSH    DS ES
		PUSHA
		MOV     CS:DosIrqSeg,AX         ; (7047:08D7=7047H)
		CALL    SUB_0014                ; (07E9)
		CMP     AX,0FFFFH
		JNE     @@LOC_0015
		POPA
		MOV     AX,0FFFFH
		STC
		POP     ES DS
		RETF                            ; (0058)
@@LOC_0015:
		POPA
		MOV     AX,CS:DATA_0030         ; (7047:09C5=388H)
		CLC
		POP     ES DS
		RETF                            ; (0058)
DetectOPL2      ENDP
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   Return Seg:Off of interesting variables for make players in ES:DI
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
OffVar          PROC    FAR
		PUSH    CS
		POP     ES
		LEA     DI,[Notes]
		RETF
OffVar          ENDP
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
;   P L A Y E R   H A N D L E R    1 C   I N T E R R U P T
; ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤
INT_1CH_ENTRY   PROC    FAR
		PUSHA
		PUSH    DS
		PUSH    ES
		CMP     BYTE PTR CS:PollingOnOff,0 ; (7047:08D9=0)
		JE      @@LOC_0019
		MOV     BYTE PTR CS:DATA_0022,1 ; (7047:08DA=0)
		JMP     @@LOC_0031              ; (01C3)
@@LOC_0019:
		MOV     DS,CS:SegSong           ; (7047:0A25=7047H)
		MOV     DI,OFFSET DATA_0041     ; (7047:0A17=0)
		DEC     BYTE PTR CS:[DI]
		MOV     AH,CS:[DI]
		CMP     AH,0
		JNE     @@LOC_0027
		MOV     AL,CS:DATA_0043         ; (7047:0A19=0)
		MOV     CS:[DI],AL
		CALL    SUB_0004                ; (01F8)
@@LOC_0027:
		CALL    PutVars                 ; (067F)
		CALL    PlayAllIns              ; (06DA)
		CALL    SUB_0003                ; (01D4)
@@LOC_0031:
		POP     ES
		POP     DS
		POPA
		JMP     DWORD PTR CS:OldInt1C   ; Call old int 1Ch
		IRET
INT_1CH_ENTRY   ENDP
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   I N C L U D E S
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
INCLUDE         OPL2PROC.INC
INCLUDE         OPL2DATA.INC
