컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; The Immortal Syndicate BBS Advertisment #2 - Version 2.0

; Horizontal starfield coded by: NutCracker
; Adlib Music system coded by: NutCracker
; Font & other routines by: Tcw
; Music by: Surprise! Productions

; This code is hereby released into the public domain, use it.  But give
; credit where credit is due.  If you use any of these routines, make sure,
; you put us in the credz, and give us a call.

; I don't think there are any NEW routines in here, especially the horizontal
; starfield.... INFACT I KNOW there are no new routines in here, so since
; this is nothing special, I'm releasing the source....... As if you didn't
; know that already...

; And one more thing... There aren't many comments after this lame one...
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

_Code   Segment public
	ASSUME CS:_Code, DS:_Code, SS:_Code, ES:_Code
	Locals
	.386
	ORG 100h

START:
	jmp     begin

X320Y200 label  word
		db   0e3h    ; dot clock
		db   02      ; Number of CRTC Registers to update
		dw   00014h  ; turn off dword mode
		dw   0e317h  ; turn on byte mode
		dw   320     ; width
		dw   200     ; height

AC_INDEX        equ  03c0h   ;Attribute controller index register
MISC_OUTPUT     equ  03c2h   ;Miscellaneous Output register
SC_INDEX        equ  03c4h   ;Sequence Controller Index
GC_INDEX        equ  03ceh   ; Graphics controller Index
CRTC_INDEX      equ  03d4h   ;CRT Controller Index
DAC_READ_INDEX  equ  03c7h   ;
DAC_WRITE_INDEX equ  03c8h   ;
DAC_DATA        equ  03c9h   ;
INPUT_STATUS_0  equ  03dah   ;Input status 0 register

MAP_MASK        equ  02h     ;index in SC of Map Mask register
READ_MAP        equ  04h     ;index in GC of the Read Map register
BIT_MASK        equ  08h     ;index in GC of Bit Mask register

OVERFLOW        equ  07h     ; CRTC overflow register index
MAX_SCAN_LINE   equ  09h     ; CRTC maximum scan line register index
ADDR_HIGH       equ  0ch     ;Index of Start Address High reg in CRTC
ADDR_LOW        equ  0dh     ;                       Low
CRTC_OFFSET     equ  13h     ; CRTC offset register index
UNDERLINE       equ  14h     ; CRTC underline location register index
MODE_CONTROL    equ  17h     ; CRTC mode control register index
LINE_COMPARE    equ  18h     ; CRTC line compare reg. index (bits 0-7 of
			     ; split screen scan line

AC_MODE_CONTROL equ    10h   ; Index of Mode COntrol register in AC
PEL_PANNING     equ    13h   ; Pel panning register index in AC

PATTERN_BUFFER  equ  0fffch  ;offset in screen memory of pattern buffer


ScreenWidth     EQU 320
ScreenHeight    EQU 200

FntWidth        EQU     16
FntHeight       EQU     28

Level1          EQU 50
Level2          EQU 70
Level3          EQU 90
Level4          EQU 100


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CLEARSTARFIELD:
    pusha
    push    es ds

    mov     ax,cs
    mov     ds,ax
    mov     es,[VgaSeg]

    CMP     BP,0
    JNZ     PAGE0
    MOV     SI,200
    MOV     BX,400
    JMP     LOOPC
PAGE0:
    mov     si,0
    MOV     BX,200
LoopC:
    mov     di,[si + OLDDI]
    MOV     AH,[SI + OLDCH]
    MOV     DX,GC_INDEX
    MOV     AL,READ_MAP
    OUT     DX,AX

    MOV     CL,AH
    MOV     AH,11H
    SHL     AH,CL
    MOV     DX,SC_INDEX
    MOV     AL,MAP_MASK
    OUT     DX,AX

    CMP     byte ptr es:[di],10H
;    JBE     FONTTHERE
    AND     byte ptr es:[di],0FH
FONTTHERE:
    ADD     si,2
    CMP     SI,BX
    JNZ     LOOPC

    pop     ds es
    popa
    ret

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DISPSTARFIELD:
    pusha
    push    es ds

    mov     ax,cs
    mov     ds,ax
    mov     es,[VgaSeg]

    CMP     BP,0
    JZ      PAGE0D
    MOV     [THISOLD],200
    JMP     CONTDISP
PAGE0D:
    mov     [THISOLD],0
CONTDISP:
    mov     si,0
    MOV     CH,[CLEVEL1]
    MOV     BX,[VLEVEL1]
LOOPDISP:
    mov     di,[si + TheStars.Ypos]     
    add     di,di
    mov     di,[di + YposChart]

    add     [si + TheStars.Xpos],BX
    cmp     [si + TheStars.Xpos],ScreenWidth
    jl      NoWrap1
    sub     [si + TheStars.Xpos],ScreenWidth
NoWrap1:
    cmp     [si + TheStars.Xpos],0         
    jge     NoWrap1b
    add     [si + TheStars.Xpos],ScreenWidth
NoWrap1b:
    add     di,[si + TheStars.Xpos]

    MOV     AX,DI
    AND     AX,3
    PUSH    SI
    MOV     SI,[THISOLD]
    ADD     [THISOLD],2
    mov     [si + OLDCH],AL
    MOV     AH,AL
    MOV     DX,GC_INDEX
    MOV     AL,READ_MAP
    OUT     DX,AX

    MOV     CL,AH
    MOV     AH,11H
    SHL     AH,CL
    MOV     DX,SC_INDEX
    MOV     AL,MAP_MASK
    OUT     DX,AX

    SHR     DI,2
    ADD     DI,BP

    CMP     byte ptr ES:[DI],4H
;    Ja     FONTTHERE2
    OR      es:[di],CH
FONTTHERE2:
    mov     [si + OLDDI],di
    POP     SI
    
    add     si,size Star                   
    cmp     si,(size Star)*Level1
    jb      LOOPDISP
    MOV     CH,[CLEVEL2]
    MOV     BX,[VLEVEL2]
    cmp     si,(size Star)*Level2
    jb      LOOPDISP
    MOV     CH,[CLEVEL3]
    MOV     BX,[VLEVEL3]
    cmp     si,(size Star)*Level3
    jb      LOOPDISP
    MOV     CH,[CLEVEL4]
    MOV     BX,[VLEVEL4]
    cmp     si,(size Star)*Level4
    jb      LOOPDISP

    pop     ds es
    popa
    ret

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SEED    DD      18a159deh
RAND:
	mov     eax,seed
	mul     cs:seed
	shl     edx,6
	shr     eax,16
	xor     eax,edx
	mov     cs:seed,eax
	and     ax,127
	ret                             ;AX=RANDOM NUMBER 0-127

GENFNTPIX:
	PUSHA
	PUSH    DS ES
	MOV     AX, 1130H
	MOV     BH, 02
	INT     10H
	ADD     BP,14*' '-1
	MOV     AX,ES
	MOV     DS,AX

	MOV     AX,CS
	MOV     DI,OFFSET FNTPIX
	MOV     SI,BP
	MOV     ES,AX

	MOV     CX,32
GENLOOP:
	CMP     CX,64+32
	JGE     ENDGENFNT
	MOV     BP,0
NEXTLINE:
	MOV     AH,80H
	LODSB

NEXTPIX:
	XOR     DX,DX
	TEST    AH,AL
	JZ      @ZERO_BIT
	MOV     DX,0F0FH
@ZERO_BIT:
	MOV     ES:[DI+1],DX
	MOV     ES:[DI+1+FntWidth],DX
	ADD     DI,2
	SHR     AH,1
	CMP     AH,0
	JNZ     NEXTPIX

	ADD     DI,FntWidth

	ADD     BP,2

	CMP     BP,FntHeight
	JL      NEXTLINE

	PUSH    DX
	PUSH    SI
	PUSH    DI
	PUSH    CX

	MOV     SI,DI
	MOV     DI,OFFSET ONEPIX
	SUB     SI,FNTWIDTH*FNTHEIGHT
	PUSH    SI
@SMPIX:
	XOR     AX,AX
	MOV     BX,SI
	SUB     BX,OFFSET FNTPIX
	AND     BX,0FH
	CMP     BX,0
	JZ      @LEFT
	CMP     BX,FNTWIDTH-1
	JZ      @RIGHT
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH-1]
	ADD     AL,BYTE PTR ES:[SI         -1]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH-1]
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH  ]
	ADD     AL,BYTE PTR ES:[SI           ]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH  ]
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH+1]
	ADD     AL,BYTE PTR ES:[SI         +1]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH+1]
	JMP     @OK
@LEFT:
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH  ]
	ADD     AL,BYTE PTR ES:[SI           ]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH  ]
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH+1]
	ADD     AL,BYTE PTR ES:[SI         +1]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH+1]
	JMP     @OK
@RIGHT:
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH-1]
	ADD     AL,BYTE PTR ES:[SI         -1]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH-1]
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH  ]
	ADD     AL,BYTE PTR ES:[SI           ]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH  ]
@OK:
	CMP     BYTE PTR ES:[SI],0
	JNZ     PIXEL_ON
	MOV     BX,AX
	CALL    RAND
	CMP     AX,BX
	JB      PIXEL_ON
	XOR     AX,AX
	JMP     SETPIXEL
PIXEL_ON:
	MOV     AL,15
SETPIXEL:
	STOSB
	INC     SI
	CMP     DI,OFFSET ONEPIX+FNTWIDTH*FNTHEIGHT
	JNZ     @SMPIX
	POP     DI
	MOV     SI,OFFSET ONEPIX
	MOV     CX,FNTWIDTH*FNTHEIGHT
	PUSH    DS
	PUSH    ES
	POP     DS
	CLD
	REP     MOVSB
	POP     DS

	POP     CX
	POP     DI
	POP     SI
	POP     DX


	PUSH    DX
	PUSH    SI
	PUSH    DI
	PUSH    CX

	MOV     SI,DI
	MOV     DI,OFFSET ONEPIX
	SUB     SI,FNTWIDTH*FNTHEIGHT
	PUSH    SI
SMPIX:
	XOR     AX,AX
	MOV     BX,SI
	SUB     BX,OFFSET FNTPIX
	AND     BX,0FH
	CMP     BX,0
	JZ      LEFT
	CMP     BX,FNTWIDTH-1
	JZ      RIGHT
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH-1]
	ADD     AL,BYTE PTR ES:[SI         -1]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH-1]
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH  ]
	ADD     AL,BYTE PTR ES:[SI           ]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH  ]
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH+1]
	ADD     AL,BYTE PTR ES:[SI         +1]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH+1]
	JMP     OK
LEFT:
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH  ]
	ADD     AL,BYTE PTR ES:[SI           ]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH  ]
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH+1]
	ADD     AL,BYTE PTR ES:[SI         +1]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH+1]
	JMP     OK
RIGHT:
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH-1]
	ADD     AL,BYTE PTR ES:[SI         -1]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH-1]
	ADD     AL,BYTE PTR ES:[SI-FNTWIDTH  ]
	ADD     AL,BYTE PTR ES:[SI           ]
	ADD     AL,BYTE PTR ES:[SI+FNTWIDTH  ]
OK:
	MOV     BL,9
	DIV     BL
	STOSB
	INC     SI
	CMP     DI,OFFSET ONEPIX+FNTWIDTH*FNTHEIGHT
	JNZ     SMPIX
	POP     DI
	MOV     SI,OFFSET ONEPIX
	MOV     CX,FNTHEIGHT
	PUSH    DS
	PUSH    ES
	POP     DS
	CLD
LINE2XMODE:
	XOR     EAX,EAX
	MOV     AL,[SI+12]
	SHL     AX,8
	OR      AL,[SI+8]
	SHL     EAX,8
	OR      AL,[SI+4]
	SHL     EAX,8
	OR      AL,[SI]
	STOSD
	INC     SI
	XOR     EAX,EAX
	MOV     AL,[SI+12]
	SHL     AX,8
	OR      AL,[SI+8]
	SHL     EAX,8
	OR      AL,[SI+4]
	SHL     EAX,8
	OR      AL,[SI]
	STOSD
	INC     SI
	XOR     EAX,EAX
	MOV     AL,[SI+12]
	SHL     AX,8
	OR      AL,[SI+8]
	SHL     EAX,8
	OR      AL,[SI+4]
	SHL     EAX,8
	OR      AL,[SI]
	STOSD
	INC     SI
	XOR     EAX,EAX
	MOV     AL,[SI+12]
	SHL     AX,8
	OR      AL,[SI+8]
	SHL     EAX,8
	OR      AL,[SI+4]
	SHL     EAX,8
	OR      AL,[SI]
	STOSD
	ADD     SI,FNTWIDTH-3
	LOOP    LINE2XMODE
	POP     DS

	POP     CX
	POP     DI
	POP     SI
	POP     DX

	INC     CX
	JMP     GENLOOP

ENDGENFNT:
	POP     ES DS
	POPA
	RET


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
OUTCHAR:
	PUSHA
	PUSH    ES
	MOV     SI,AX
	MOV     DI,BX
	SHR     DI,2

	MOV     BX,OFFSET FNTPIX
	XOR     AX,AX
	MOV     AL,CL
	SUB     AX,' '
	IMUL    AX,FNTWIDTH*FNTHEIGHT
	ADD     BX,AX

	MOV     AX,0A000H
	MOV     ES,AX
	MOV     AX,SI
	IMUL    AX,80
	ADD     AX,DI
	ADD     AX,BP
	MOV     DI,AX
	MOV     SI,BX

	MOV     DX,SC_INDEX
	MOV     AX,0F02H
	OUT     DX,AX
	XOR     EAX,EAX
	CMP     DI,BP
	JL      DONT_CLEAR_YET
	MOV     ES:[DI-SCREENWIDTH/4],EAX
	MOV     ES:[DI-SCREENWIDTH/2],EAX
DONT_CLEAR_YET:
	MOV     AL,MAP_MASK
	OUT     DX,AL
	INC     DX

	MOV     AL,11H
@NEXTCOL:
	OUT     DX,AL
	MOV     CX,FNTHEIGHT
@NEXTLINE:
	CMP     DI,BP
	JL      NOT_IN_SCR
	ADD     BP,16000
	CMP     DI,BP
	JA      AT_BOTTOM
	MOVSD
	SUB     DI,4
	SUB     SI,4
AT_BOTTOM:
	SUB     BP,16000
NOT_IN_SCR:

	ADD     DI,(SCREENWIDTH)/4
	ADD     SI,FNTWIDTH
	LOOP    @NEXTLINE
	SUB     SI,(FNTWIDTH*FNTHEIGHT)-4
	SUB     DI,(SCREENWIDTH*FNTHEIGHT)/4
	SHL     AL,1
	CMP     AL,10H
	JNZ     @NEXTCOL

	POP     ES
	POPA
	ADD     BX,FNTWIDTH

	RET

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

begin:
	;CLEAR Z DATA
	MOV   CX,(N_OF_Z_DATA-N_OF_NZ_DATA)/4+1
	MOV   DI,OFFSET N_OF_NZ_DATA
	XOR   EAX,EAX
	REPZ  STOSD
	;GENERATE FONT FROM ROM FONT TO ??? FONT
	CALL  GENFNTPIX
	;SET VGA XMODE
	mov   ax,13h                ; let the BIOS set standard 256-color
	int   10h                   ;  mode (320x200 linear)

	mov   dx,SC_INDEX
	mov   ax,0604h
	out   dx,ax                 ; disable chain4 mode
	MOV   AX,0F02H
	OUT   DX,AX
	MOV   AX,0A000H
	MOV   ES,AX
	MOV   DI,0
	MOV   CX,4000H
	MOV   EAX,0
	REPZ  STOSD
	mov   ax,0100h
	out   dx,ax                 ; synchronous reset while setting Misc
				    ;  Output for safety, even though clock
				    ;  unchanged

	mov   si, OFFSET X320Y200
	lodsb

	mov   dx,MISC_OUTPUT
;        out   dx,al               ; select the dot clock and Horiz
				  ;  scanning rate
	mov   dx,SC_INDEX
	mov   ax,0300h
	out   dx,ax                ; undo reset (restart sequencer)

	mov   dx,CRTC_INDEX       ; reprogram the CRT Controller
	mov   al,11h              ; VSync End reg contains register write
	out   dx,al               ; protect bit
	inc   dx                  ; CRT Controller Data register
	in    al,dx               ; get current VSync End register setting
	and   al,07fh             ; remove write protect on various
	out   dx,al               ; CRTC registers
	dec   dx                  ; CRT Controller Index
	cld
	xor   cx,cx
	lodsb
	mov   cl,al

@@SetCRTParmsLoop:
	lodsw                     ; get the next CRT Index/Data pair
	out   dx,ax               ; set the next CRT Index/Data pair
	loop  @@SetCRTParmsLoop


    MOV     BX,0
    CALL    SAT_PLAYER
    MOV     BX,1
    CALL    SAT_PLAYER
    MOV     BX,OFFSET MUSIC
    SHR     BX,4
    MOV     AX,CS
    ADD     BX,AX
    MOV     ES,BX
    MOV     BX,2
    MOV     AX,1
    CALL    SAT_PLAYER
    MOV     BX,3
    CALL    SAT_PLAYER

    mov     ax,cs
    mov     es,ax
    mov     ds,ax

    mov     dx,offset Palette      
    mov     ax,1012h               
    mov     bx,0
    mov     cx,256
    int     10h

    MOV     DX,21H
    MOV     AL,000H
    OUT     DX,AL
    MOV     DX,0A1H
    OUT     DX,AL
    MOV     SI,0

ONEPAGE:
    MOV     AL,[SI+STRING]
    CMP     AL,0
    JNZ     NO_REPEAT
    MOV     SI,0
    JMP     ONEPAGE

NO_REPEAT:
    MOV     [LINES_SCR],AL
    DEC     AL
    XOR     AH,AH
    IMUL    AX,28
    SHR     AX,1
    ADD     AX,100-28
    MOV     [NOWBASE],AX
    ADD     AX,28
    NEG     AX
    ADD     AX,200
    SUB     AX,29
    MOV     [ENDBASE],AX
    INC     SI
NEXT_LINE:
    PUSH    SI
    PUSH    DI
    PUSH    CX
    PUSH    ES
    MOV     AX,CS
    MOV     DS,AX
    MOV     ES,AX
    MOV     CX,20
    MOV     SI,OFFSET SPOS_Y
    MOV     DI,OFFSET POS_Y
    CLD
    REPZ    MOVSW
    POP     ES
    POP     CX
    POP     DI
    POP     SI
ONELINE:
    call    CLEARSTARFIELD
    XOR     CS:[PAGEOFF],04000H
    MOV     BP,CS:[PAGEOFF]

    PUSH    SI
    XOR     AX,AX
    MOV     AL,[SI+STRING]

    ADD     AX,SI
    MOV     [SI_END],AX
    ADD     [SI_END],1
    XOR     AX,AX
    MOV     AL,[SI+STRING]
    NEG     AX
    ADD     AX,20
    SHL     AX,3
    MOV     [LEFT_OFF],AX
    INC     SI
    MOV     DI,0
@LOOP:
    MOV     AX,[POS_Y+DI]
    MOV     BX,[POS_X+DI]
    ADD     BX,[LEFT_OFF]
    CMP     AX,[NOWBASE]
    JL      SKIP
    MOV     AX,[NOWBASE]
    MOV     [POS_Y+DI],AX
SKIP:
    MOV     DX,[ADD_V+DI]
    ADD     [POS_Y+DI],DX
SKIP_ALL:
    MOV     CL,[STRING+SI]
    CMP     CL,'a'
    JB      NOT_LOWER
    CMP     CL,'z'
    JA      NOT_LOWER
    SUB     CL,'a'-'A'
NOT_LOWER:
    CALL    OUTCHAR
    ADD     DI,2
    INC     SI
    CMP     SI,[SI_END]
    JL      @LOOP

    call    DISPSTARFIELD

    MOV     AX,BP
	mov  bh,al                          ; setup CRTC start addr regs and
	mov  ch,ah                          ; fast word outs

	mov  bl,ADDR_LOW
	mov  cl,ADDR_HIGH

	mov  dx,INPUT_STATUS_0    ;Wait for trailing edge of Vsync pulse

@@WaitDE:
	in   al,dx
	test al,01h
	jnz  @@WaitDE             ;display enable is active low (0 = active)

	mov  dx,CRTC_INDEX
	mov  ax,bx
	out  dx,ax               ;start address low
	mov  ax,cx
	out  dx,ax               ;start address high

	mov  dx,AC_INDEX
	mov  al,PEL_PANNING+20h   ; Point the attribute controller to pel pan
	out  dx,al                ; reg. Bit 5 also set to prevent blanking

    PUSH    BX
    PUSH    ES
    MOV     BX,4
    CALL    SAT_PLAYER
    POP     ES
    POP     BX
    mov     dx,3dah
@@VRT:
    in      al,dx
    test    al,8
    jnz     @@VRT
@@NoVRT:
    in      al,dx
    test    al,8
    jz      @@NoVRT
    POP     SI


    MOV     DX,60H
    IN      AL,DX
    TEST    AL,080H
    JZ      CYAL8R
    MOV     AX,[NOWBASE]
    CMP     AX,[POS_Y]
    JGE     ONELINE
    CMP     [TWICE],1
    MOV     [TWICE],1
    JL      ONELINE
    MOV     [TWICE],0
    SUB     AX,28
    MOV     [NOWBASE],AX
    MOV     BL,[SI+STRING]
    XOR     BH,BH
    ADD     SI,BX
    INC     SI
    CMP     AX,[ENDBASE]
    JG      NEXT_LINE
    PUSH    AX
    PUSH    DX
    PUSH    DI
    PUSH    ES
    MOV     DX,SC_INDEX
    MOV     AX,0F02H
    OUT     DX,AX
    MOV     AX,0A000H
    MOV     ES,AX
    XOR     DI,DI
    MOV     CX,02000H
    XOR     EAX,EAX
    REP     STOSD
    POP     ES
    POP     DI
    POP     DX
    POP     AX
    JMP     ONEPAGE

cyal8r:
    MOV     BX,5
    CALL    SAT_PLAYER
    MOV     DX,21H
    MOV     AL,0
    OUT     DX,AL
    MOV     DX,0A1H
    OUT     DX,AL
    mov     ax,3
    int     10h
    mov     ax,4c00h
    int     21h

;컴컴컴컴컴컴컴 Macros 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

WriteFM macro   I, D

	push    ax
	mov     dx, 388h                ; Index port of AdLib
	mov     al, &I
	out     dx, al                  ; write index
	inc     dx
	push    cx
	mov     cx, 7
	call    wait_
	pop     cx
	mov     al, &D
	out     dx, al                  ; write data
	push    cx
	mov     cx, 30
	call    wait_
	pop     cx
	pop     ax

Endm

wait_   proc    near
	in      al,dx
	loop    wait_
	ret
wait_   endp

;컴컴컴컴컴컴컴 SAT format data 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

SongLen         equ     Byte ptr es:[44Bh]
RestartPosition equ     Byte ptr es:[44Ch]
CallsPerSecond  equ     Byte ptr es:[44Dh]
PatternOffset   equ     44Fh
InstrumentOffset equ    5h
PatternOrderOffset equ  842

;컴컴컴컴컴컴컴 PROCEDURES 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� This is the actual player 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

MusicSEG        dw      0               ; segment of sat-file
PlayMode        db      0               ; 0 = timer, 1 = poll

noteplay        db      0               ; internal, boulean

SAT_SongPos     db      0               ; Current Song Position
SAT_PatternPos  dw      0               ; Current Pattern Position
					; (real offset!)

Channel_Volumes db      9 dup (0)       ; volumes of all 9 channels.

Modulator_numbers       db      00h,01h,02h,08h,09h,0ah,10h,11h,12h
Carrier_numbers         db      03h,04h,05h,0bh,0ch,0dh,13h,14h,15h

f_number        dw      343,363,385,408,432,458,485,514,544,577,611,647

SAT_Speed       db      6               ; current speed
TempSpeed       db      6               ; counter for speed

SAT_Equalizer   db      36 dup (0)      ; equalizer (0-63)

Player  proc    far

	pusha

	mov     ax, cs
	mov     ds, ax                  ; DS = code seg (and data)
	mov     ax, [MusicSeg]          ; ES = seg of sat-file
	mov     es, ax

;컴컴컴컴컴컴컴 Check Speed 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

	dec     [TempSpeed]
	jnz     Exit_PLayer
	mov     al, [SAT_Speed]
	mov     [TempSpeed], al

;컴컴컴컴컴컴컴 Update notes and instruments 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

	xor     bh, bh
	xor     ah, ah
	mov     bl, [SAT_SongPos]       ; get song position and get pattern
	mov     al, byte ptr es:[PatternOrderOffset+bx]
	mov     cx, 2880
	mul     cx                      ;
	add     ax, 44fh                ; calc offset to real pattern in file

	add     ax, [SAT_PatternPos]    ; calc offset to current note
	mov     Di, Ax                  ; put it in DI

	xor     bp, bp                  ; counter number channels
ChannelLoop:
	xor     ax, ax                  ; clear out ax
	mov     al, es:[di+1]           ; get current instrument
	or      al, al                  ; is it a note
	jz      Skip_SetupInstr         ; nope, don't program FM
	dec     al                      ; actual instr
	call    Set_Instrument          ; program FM

	mov     [noteplay], 1           ; flag, we have to play a note

Skip_SetupInstr:

;컴컴컴컴컴컴컴 Check special effects 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

	cmp     byte ptr es:[di+2], 0Ch ; is it Volume Set
	jne     Check_Speed             ; nope
	mov     al, es:[di+3]           ; get volume
	shl     al, 4                   ;
	or      al, es:[di+4]           ;
	mov     ah, [channel_volumes+bp]; get old volume
	and     ah, 11000000b           ; save KSL value
	or      al, ah                  ; calc new value
	mov     [channel_volumes+bp], al; set it
	call    Set_Volume              ; reprogram FM

Check_Speed:
	cmp     byte ptr es:[di+2], 0Fh ; is it Speed Change
	jne     Check_Done              ; nope
	mov     al, es:[di+3]           ; get speed
	shl     al, 4                   ;
	or      al, es:[di+4]           ;
	mov     [SAT_speed], al         ; save it
	mov     [tempspeed], al

Check_Done:

	cmp     [noteplay], 1           ; Is there a note to play?
	jne     Check_Done_1            ; nope
	call    play_Note


Check_Done_1:
	mov     [noteplay], 0           ; clear flag

	inc     bp                      ; next channel
	add     di, 5                   ; next note
	cmp     bp, 10                  ; all channels done?
	jne     ChannelLoop             ; nope..

;컴컴컴컴컴컴컴 Update pointers 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

	add     [SAT_PatternPos], 9*5   ; next row
	cmp     [SAT_PatternPos], 64*9*5; all rows done?
	jb      No_Set_Songpos          ; nope.. not yet..
	mov     [SAT_PatternPos], 0     ; first row
	inc     [SAT_SongPos]           ; next songpos
	mov     al, SongLen             ;
	cmp     [SAT_SongPos], al       ; are we done yet?
	jbe     No_Set_SongPos          ; nope
	mov     al, RestartPosition     ; do it again..
	mov     [SAT_SongPos], al       ;
No_Set_Songpos:

Exit_Player:
	popa

	retf

Player  endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� This routine has to be called by the master program (intro/demo)
;�
;� IN:  BX = 0          Check for FM chip
;�                      - returns:      CF clear: FM chip found
;�                                      CF set: no FM chip found
;�      BX = 1          Reset FM chip
;-      BX = 2          Init player
;-                      - in:           ES: segment of SAT file
;�                                      AL = 0: timer mode (don't poll)
;�                                      AL = 1: polling mode (has to be
;�                                              called exactly 50 or 70 times
;�                                              a second. (ie. in a vertical
;�                                              retrace)
;�      BX = 3          Start Playing
;�      BX = 4          Poll player
;�      BX = 5          Stop Playing
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

JumpTable       dw      offset TestFMchip, offset ResetFMchip, offset InitPlay
		dw      offset TestFMchip, offset Player, offset ResetFMchip

SAT_player      proc    far

	cmp     bx, 4
	je      Skip_PushA
	pusha
Skip_Pusha:
	shl     bx, 1
	jmp     cs:[JumpTable+BX]

SAT_player      endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� Initialize player (set musicseg and playmode) 컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

InitPlay        proc    far
	mov     cs:[MusicSeg], es       ; Set music segment
	mov     cs:[PlayMode], al       ; seg playing mode (timer/poll)
	popa
	retf
InitPlay        endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� calc freq and write it to FM 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Play_Note       proc    near

	xor     ax, ax

	mov     al, 0B0h                ; disable an old note
	add     ax, bp
	WriteFM al, 0
	mov     al, 0A0h
	add     ax, bp
	WriteFM al, 0

	mov     al, es:[di]             ; get note
	dec     ax

	mov     bx, ax                  ; update equalizer
	mov     cs:[SAT_Equalizer+bx], 63

	mov     cl, 12
	div     cl                      ; Get freq and block
	push    ax
	mov     bx, ax
	shr     bx, 8
	shl     bx, 1
	mov     cx, cs:[f_number+BX]    ; get freq for output

	mov     al, 0A0h
	add     ax, bp
	WriteFM al, cl                  ; write it

	pop     ax                      ; restore block
	xor     ah, ah
	add     al, 2
	shl     al, 2
	or      ch, al
	or      ch, 32                  ; calc output value (32=enable ins)

	mov     al, 0B0h                ; write it
	add     ax, bp
	WriteFM al, CH

	ret

Play_Note       endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� Program instrument
;� in:  AL = instrument number (0 = instr. 1 etc)
;�      BP = channel
;�      ES = segment of music file
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Set_Instrument      proc    near

	xor     ah, ah
	mov     cx, 11
	mul     cx
	add     ax, 5                   ; calc offset of instr info in file
	mov     si, ax

;컴컴컴컴컴컴컴 program instruments 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

	xor     ax, ax
	mov     al, 0C0h
	add     ax, bp
	WriteFM al, es:[si]

	mov     al, 020h
	add     al, [offset Modulator_numbers+bp]
	WriteFM al, es:[si+1]

	mov     al, 020h
	add     al, [offset Carrier_numbers+bp]
	WriteFM al, es:[si+2]

	mov     al, 060h
	add     al, [offset Modulator_numbers+bp]
	WriteFM al, es:[si+3]

	mov     al, 060h
	add     al, [offset Carrier_numbers+bp]
	WriteFM al, es:[si+4]

	mov     al, 080h
	add     al, [offset Modulator_numbers+bp]
	WriteFM al, es:[si+5]

	mov     al, 080h
	add     al, [offset Carrier_numbers+bp]
	WriteFM al, es:[si+6]

	mov     al, 0E0h
	add     al, [offset Modulator_numbers+bp]
	WriteFM al, es:[si+7]

	mov     al, 0E0h
	add     al, [offset Carrier_numbers+bp]
	WriteFM al, es:[si+8]

	mov     al, 040h
	add     al, [offset Modulator_numbers+bp]
	WriteFM al, es:[si+9]

	mov     al, 040h
	add     al, [offset Carrier_numbers+bp]
	WriteFM al, es:[si+10]

	mov     al, es:[si+10]
	mov     [channel_volumes+bp], al; update volume settings

	ret

Set_Instrument      endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� Programs FM volume 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Set_Volume      proc    near

	mov     al, 040h
	add     al, [offset Carrier_numbers+bp]
	WriteFM al, [Channel_volumes+bp]
	mov     al, 040h
	add     al, [offset Modulator_numbers+bp]
	WriteFM al, [channel_volumes+bp]

	ret

Set_Volume      endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� Check for FM chip, returns CF = 0 if found, or CF = 1 if not 컴컴컴컴컴컴컴
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

TestFMchip      proc    far
										      WriteFM 1, 0                    ; Wis test register                           WriteFM 4, 60h                  ; zet doorvoer uit/stop tellers
	WriteFM 4, 80h
	mov     dx, 388h
	in      al, dx
	mov     cl, al
	WriteFM 2, 0Ffh
	WriteFM 4, 21h
	mov     cx, 100
	loop    $
	mov     dx, 388h
	in      al, dx
	mov     ch, al
	WriteFM 4, 60h
	WriteFM 4, 80h

	and     cl, 0E0h
	cmp     cl, 0
	jne     No_FMchip
	and     ch, 0E0h
	cmp     ch, 0C0h
	jne     No_FMchip

	popa
	clc
	ret

No_FMchip:

	popa
	stc
	ret

TestFMchip      endp

;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;� Reset FM chip 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

ResetFMchip     proc    far

	WriteFM 1, 0                    ; enable writing to FM chip
	WriteFM 8, 0                    ; select normal mode and split

	mov     al, 0A0h                ; kill all freq
	mov     cx, 63
boe_loop:
	WriteFM al, 0
	inc     al
	loop    boe_loop

	WriteFM 0BDh, 11111111b         ; select rythm mode

	mov     al, 040h                ; kill all volumes (and rythm ins)
	mov     cx, 32
boe1_loop:
	WriteFM al, 63
	inc     al
	loop    boe1_loop

	popa
	retf

ResetFMchip     endp


Star STRUC
    XPos    dw  0
    YPos    dw  0
Star ENDS

VLevel1 dw  1
VLevel2 dw  2
VLevel3 dw  3
VLevel4 dw  4

CLevel1 db  40H
CLevel2 db  30H
CLevel3 db  20H
CLevel4 db  10H

Palette DB   0,0,0
	I=4
	REPT 15
	db   I,0,0
	I=I+4
	ENDM
	I=-1
	REPT 16
	I=I+4
	DB   60*(64-I)/64 + I,64-I,64-I
	ENDM
	I=-1
	REPT 16
	I=I+4
	DB   45*(64-I)/64 + I,48-I*3/4,48-I*3/4
	ENDM
	I=-1
	REPT 16
	I=I+4
	DB   30*(64-I)/64 + I,32-I/2,32-I/2
	ENDM
	I=-1
	REPT 16
	I=I+4
	DB   15*(64-I)/64 + I,16-I/4,16-I/4
	ENDM
	
TheStars Star <  9,125>,< 33,  8>,<173,154,>,<268,112>,< 20, 47>
 Star <198,186>,< 19, 32>,<108,108,>,< 62, 27>,<175,157>,< 24,177>
 Star <114, 83>,< 88, 52>,<179, 20,>,<193, 79>,< 12, 51>,<196, 39>
 Star <127, 26>,<118,  6>,<274, 27,>,<149,134>,<124, 81>,< 92,104>
 Star < 36,130>,<173, 10>,<299, 43,>,<317,100>,<140, 84>,<162,167>
 Star <  6, 25>,< 97,194>,< 92,113,>,<153, 36>,<224, 89>,<243,169>
 Star <143, 47>,<169, 74>,<195,154,>,< 29, 83>,<171, 16>,< 58, 66>
 Star <151, 91>,<236,174>,<155,157,>,<292, 27>,<183, 24>,<109,157>
 Star < 23,106>,<209, 98>,< 92, 29,>,< 78,125>,<126,104>,< 91, 49>
 Star <181, 37>,<318, 50>,<121, 97,>,< 47,178>,<139,132>,<270, 82>
 Star < 88, 32>,<169, 12>,<160, 49,>,< 78, 49>,< 55,158>,< 54,  4>
 Star <143, 78>,<113,156>,<153,130,>,<245, 39>,<172,162>,<170, 87>
 Star <137,105>,<150,125>,< 35,196,>,<269,106>,<190, 41>,<122,103>
 Star < 27,130>,<176,151>,<118,  3,>,< 18,138>,<147, 66>,<199,142>
 Star <153, 56>,<  1, 26>,<257,158,>,< 76, 75>,<150,169>,< 58, 90>
 Star <249,115>,< 84,125>,< 71,116,>,<162, 81>,<194, 99>,<251,145>
 Star <142,171>,<111, 79>,<192, 24,>,<186,165>,< 56, 12>,<  8,191>


VgaSeg  dw  0A000h      ; set mode13h (BLEH)

LABEL YposChart WORD
    i=0
    REPT ScreenHeight
	dw i*ScreenWidth
	i=i+1
    ENDM
컴컴

STRING  DB       5
	DB       1,' '
	DB       9,'BBS Ad #2'                     ; All the text
	DB      18,'Immortal Syndicate'            ;
	DB       1,' '                             ;
	DB       1,' '                             ;

	DB      3
	DB      13,'IS Dist-Sites'                 ;
	DB      19,'Call these official'           ;
	DB       1,' '                             ;
						   
	DB      5
	DB      19,'Programming & Music'           ;
	DB      19,'Dedicated to Demos,'           ;
	DB      13,'(604)582-9894'                 ;
	DB      16,'Michelangelo BBS'              ;
	DB       1,' '

	DB      5                                  ;
	DB      19,'Infinity Demo group'           ;
	DB      18,'WHQ BBS of Digital'            ;
	DB      13,'(214)328-8979'                 ;
	DB      17,'Programmers Oasis'             ;
	DB       1,' '

	DB      5
	DB       9,'and music'                     ;
	DB      19,'Demos, Programming,'           ;
	DB      13,'(604)882-8647'                 ;
	DB      15,'Garbage Inbound'               ;
	DB       1,' '                             ;

	DB      7
	DB      11,'Programming'                   ;
	DB      16,'Demos, music and'              ;
	DB      17,'BBS. Dedicated to'             ;
	DB      19,'The official IS WHQ'           ;
	DB      13,'(604)533-3720'                 ;
	DB      11,'Pentium BBS'                   ;
	DB       1,' '
	DB      0

POS_X   DW      00H,10H,20H,30H,40H,50H,60H,70H,80H,90H,0A0H,0B0H,0C0H,0D0H,0E0H,0F0H,100H,110H,120H,130H
SPOS_Y  DW     -60,-30,-50,-50,-20,-50,-50,-20,-60,-10,-80,-30,-80,-40,-20,-40,-60,-70,-90,-20
ADD_V   DW      1,3,1,2,3,2,1,2,3,2,2,1,3,2,1,2,1,2,2,1

ALIGN   16
MUSIC   DB 053H,041H,064H,054H,001H,007H,060H,020H
	DB 0F7H,0A8H,038H,035H,003H,003H,000H,000H
	DB 009H,021H,022H,0F7H,0F4H,034H,034H,001H
	DB 002H,000H,000H,009H,003H,004H,0E5H,0E4H
	DB 036H,036H,001H,000H,003H,003H,00DH,001H
	DB 000H,0E9H,0EAH,008H,005H,000H,001H,000H
	DB 000H,00FH,040H,0C0H,0F9H,0F6H,006H,005H
	DB 000H,001H,003H,003H,009H,0E5H,0E5H,075H
	DB 074H,034H,034H,001H,001H,000H,003H,009H
	DB 060H,021H,0A0H,0A0H,00FH,00FH,000H,002H
	DB 005H,005H,00BH,023H,023H,0EAH,0EAH,024H
	DB 024H,001H,000H,000H,000H,009H,00AH,00AH
	DB 0E5H,0E4H,034H,034H,001H,000H,003H,003H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,010H,063H,068H,06FH,072H,064H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,010H,047H,075H,06EH,067H
	DB 021H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,010H,047H,075H,06EH
	DB 067H,021H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,010H,064H,072H
	DB 075H,06DH,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,010H,074H
	DB 06FH,06DH,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,010H
	DB 068H,069H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 010H,042H,072H,075H,06DH,06DH,06DH,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,010H,047H,075H,06EH,067H,021H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,010H,047H,075H,06EH,067H,021H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,010H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,010H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,010H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,010H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,010H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 010H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,010H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,010H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,010H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,010H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,010H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,010H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,010H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 010H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,010H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,010H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,010H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,010H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,010H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,010H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,020H
	DB 020H,020H,020H,020H,020H,020H,020H,010H
	DB 020H,020H,000H,000H,001H,002H,001H,002H
	DB 003H,004H,005H,006H,006H,002H,003H,004H
	DB 005H,001H,000H,006H,000H,006H,007H,007H
	DB 008H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00AH,000H,017H,000H,046H,000H,00DH
	DB 003H,00FH,000H,006H,00DH,002H,000H,000H
	DB 000H,00DH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,003H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,003H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,003H,000H
	DB 000H,000H,00DH,002H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,003H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00DH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00DH,003H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00DH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,012H,003H,000H,000H,000H
	DB 012H,002H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,003H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 003H,000H,000H,000H,014H,002H,000H,000H
	DB 000H,008H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,003H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,008H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,003H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,003H,000H
	DB 000H,000H,014H,002H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,003H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,008H,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,003H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 008H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,017H,003H,000H,000H,000H
	DB 017H,002H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,003H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 003H,000H,000H,000H,019H,002H,000H,000H
	DB 000H,00BH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,003H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00BH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,003H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,003H,000H
	DB 000H,000H,017H,002H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,003H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00BH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00DH,003H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00BH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,012H,003H,000H,000H,000H
	DB 019H,002H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,003H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 003H,000H,000H,000H,012H,002H,000H,000H
	DB 000H,006H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,003H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,006H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,003H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,003H,000H
	DB 000H,000H,012H,002H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,003H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,006H,001H
	DB 000H,000H,000H,019H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,003H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 019H,005H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 006H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,017H,003H,000H,000H,000H
	DB 014H,002H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,003H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,019H,005H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 006H,00CH,004H,000H,00DH,002H,000H,000H
	DB 000H,00DH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,00DH,002H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00DH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00DH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,006H,000H,000H,000H
	DB 012H,002H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,006H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,014H
	DB 006H,000H,000H,000H,014H,002H,000H,000H
	DB 000H,008H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,006H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,008H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,006H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,014H,002H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,008H,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 008H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 017H,002H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,006H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,019H
	DB 006H,000H,000H,000H,019H,002H,000H,000H
	DB 000H,00BH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00BH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,006H,000H
	DB 000H,000H,017H,002H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00BH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00BH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,019H,006H,000H,000H,000H
	DB 019H,002H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,006H,003H,000H,007H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,003H
	DB 000H,007H,000H,000H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,003H,000H,007H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,003H,000H,007H,012H,002H,000H,000H
	DB 000H,006H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,006H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,010H,006H,000H
	DB 000H,000H,012H,002H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,006H,001H
	DB 000H,000H,000H,019H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,006H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 019H,005H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 006H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,006H,000H,000H,000H
	DB 014H,002H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,006H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,019H,005H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00CH,000H,000H,00DH,007H,000H,000H
	DB 000H,00DH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,007H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,00DH,007H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00DH,007H,000H,000H,000H,00DH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00DH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00DH,007H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,00DH,007H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,014H,007H,000H,000H
	DB 000H,008H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,008H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,007H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,014H,007H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,007H,000H,000H,000H,008H,001H
	DB 000H,000H,000H,019H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 008H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 014H,007H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,014H,007H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,019H,005H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,019H,007H,000H,000H
	DB 000H,00BH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00BH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,017H,007H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00BH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00BH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 019H,007H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,012H,007H,000H,000H
	DB 000H,006H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,006H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,010H,007H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,019H,005H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,006H,001H
	DB 000H,000H,000H,019H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 006H,001H,000H,000H,000H,019H,005H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,007H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,020H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,01DH
	DB 005H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,018H,005H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,005H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 006H,00CH,004H,000H,00DH,007H,000H,000H
	DB 000H,00DH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,007H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,00DH,007H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00DH,007H,000H,000H,000H,00DH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00DH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,006H,000H,000H,000H
	DB 00DH,007H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,006H,000H
	DB 000H,000H,00DH,007H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,014H
	DB 006H,000H,000H,000H,014H,007H,000H,000H
	DB 000H,008H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,006H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,008H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,007H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,006H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,014H,007H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,007H,000H,000H,000H,008H,001H
	DB 000H,000H,000H,019H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 008H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 014H,007H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,006H,000H
	DB 000H,000H,014H,007H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,019H,005H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,019H
	DB 006H,000H,000H,000H,019H,007H,000H,000H
	DB 000H,00BH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00BH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,006H,000H
	DB 000H,000H,017H,007H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00BH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00BH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,019H,006H,000H,000H,000H
	DB 019H,007H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,006H,003H,000H,006H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,003H
	DB 000H,006H,000H,000H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,003H,000H,006H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,003H,000H,006H,012H,007H,000H,000H
	DB 000H,006H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,006H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,010H,006H,000H
	DB 000H,000H,010H,007H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,019H,005H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,006H,001H
	DB 000H,000H,000H,019H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,006H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 006H,001H,000H,000H,000H,019H,005H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,006H,000H,000H,000H
	DB 012H,007H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,020H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,01DH
	DB 005H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,006H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,018H,005H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,005H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 006H,00CH,004H,000H,00DH,008H,000H,000H
	DB 000H,00DH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,00BH,008H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00DH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00DH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,006H,000H,000H,000H
	DB 008H,008H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,006H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,014H
	DB 006H,000H,000H,000H,006H,008H,000H,000H
	DB 000H,008H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,006H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,008H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,006H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,004H,008H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,008H,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 008H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,006H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,019H
	DB 006H,000H,000H,000H,008H,008H,000H,000H
	DB 000H,00BH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00BH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,006H,000H
	DB 000H,000H,00BH,008H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00BH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00BH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,019H,006H,000H,000H,000H
	DB 008H,008H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,006H,003H,000H,007H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,003H
	DB 000H,007H,000H,000H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,003H,000H,007H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,003H,000H,007H,010H,008H,000H,000H
	DB 000H,006H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,006H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,010H,006H,000H
	DB 000H,000H,00FH,008H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,006H,001H
	DB 000H,000H,000H,019H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,006H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 019H,005H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 006H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,006H,000H,000H,000H
	DB 00BH,008H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,006H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,019H,005H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 006H,00CH,004H,000H,00DH,008H,000H,000H
	DB 000H,00DH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,010H,008H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00DH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00DH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,006H,000H,000H,000H
	DB 00DH,008H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,006H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,014H
	DB 006H,000H,000H,000H,012H,008H,000H,000H
	DB 000H,008H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,006H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,008H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,006H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,014H,008H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,008H,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 008H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,006H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,019H
	DB 006H,000H,000H,000H,012H,008H,000H,000H
	DB 000H,00BH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00BH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,006H,000H
	DB 000H,000H,014H,008H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00BH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00BH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,019H,006H,000H,000H,000H
	DB 017H,008H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,006H,003H,000H,007H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,003H
	DB 000H,007H,000H,000H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,003H,000H,007H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,003H,000H,007H,012H,008H,000H,000H
	DB 000H,006H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,006H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,010H,006H,000H
	DB 000H,000H,010H,008H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,006H,001H
	DB 000H,000H,000H,019H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,006H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 019H,005H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 006H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,006H,000H,000H,000H
	DB 00FH,008H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,00DH,008H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,012H,006H,000H
	DB 000H,000H,00BH,008H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,019H,005H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,008H
	DB 008H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 003H,00CH,004H,000H,00DH,009H,000H,000H
	DB 000H,00DH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,003H,000H,000H,000H,00DH,009H
	DB 000H,000H,000H,00DH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,003H,000H,000H,000H
	DB 00DH,009H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,003H,000H
	DB 000H,000H,00DH,009H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,003H,000H,000H,000H,00DH
	DB 009H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00DH,009H,000H,000H,000H,00DH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00DH,003H,000H,000H,000H,008H,009H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00DH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,012H,003H,000H,000H,000H
	DB 00BH,009H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,003H,000H
	DB 000H,000H,00CH,009H,000H,000H,000H,00DH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 003H,000H,000H,000H,014H,009H,000H,000H
	DB 000H,008H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,003H,000H,000H,000H,014H,009H
	DB 000H,000H,000H,008H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,003H,000H,000H,000H
	DB 014H,009H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,003H,000H
	DB 000H,000H,014H,009H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,003H,000H,000H,000H,014H
	DB 009H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,009H,000H,000H,000H,008H,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,003H,000H,000H,000H,012H,009H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 008H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,017H,003H,000H,000H,000H
	DB 00BH,009H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,003H,000H
	DB 000H,000H,00DH,009H,000H,000H,000H,008H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 003H,000H,000H,000H,00FH,009H,000H,000H
	DB 000H,00BH,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,003H,000H,000H,000H,00FH,009H
	DB 000H,000H,000H,00BH,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,003H,000H,000H,000H
	DB 00FH,009H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,003H,000H
	DB 000H,000H,00FH,009H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,003H,000H,000H,000H,00FH
	DB 009H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00FH,009H,000H,000H,000H,00BH,001H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00DH,003H,000H,000H,000H,012H,009H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00BH,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,012H,003H,000H,000H,000H
	DB 010H,009H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,003H,000H
	DB 000H,000H,00FH,009H,000H,000H,000H,00BH
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 003H,000H,000H,000H,00DH,009H,000H,000H
	DB 000H,006H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,003H,000H,000H,000H,00DH,009H
	DB 000H,000H,000H,006H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,003H,000H,000H,000H
	DB 00DH,009H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,003H,000H
	DB 000H,000H,00DH,009H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,003H,000H,000H,000H,00DH
	DB 009H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00DH,009H,000H,000H,000H,006H,001H
	DB 000H,000H,000H,019H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,003H,000H,000H,000H,010H,009H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 019H,005H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 006H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,017H,003H,000H,000H,000H
	DB 00FH,009H,000H,000H,000H,012H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,003H,000H
	DB 000H,000H,00BH,009H,000H,000H,000H,006H
	DB 001H,000H,000H,000H,019H,005H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,019H
	DB 006H,00CH,004H,000H,00DH,007H,000H,000H
	DB 000H,019H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,019H,007H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00DH,007H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,019H,006H,000H,000H,000H
	DB 019H,007H,000H,000H,000H,019H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,00DH,007H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,006H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,019H,001H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,019H,007H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,019H,006H,000H,000H,000H,00DH,007H
	DB 000H,000H,000H,019H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 019H,007H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,007H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,019H,006H,000H
	DB 000H,000H,00DH,007H,000H,000H,000H,019H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,019H
	DB 007H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,019H
	DB 006H,000H,000H,000H,00DH,007H,00CH,003H
	DB 008H,019H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00CH,007H,00CH,003H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,018H,006H,000H,000H,000H,00BH,007H
	DB 00CH,002H,008H,018H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00AH,007H,00CH,002H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,016H,006H,000H,000H,000H
	DB 009H,007H,00CH,001H,008H,016H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,008H,007H,00CH
	DB 001H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,006H,000H
	DB 000H,000H,007H,007H,00CH,000H,008H,014H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,006H
	DB 007H,00CH,000H,004H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,012H
	DB 006H,000H,000H,000H,019H,009H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,017H,009H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,011H,006H,000H,000H,000H,014H,009H
	DB 000H,000H,000H,014H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,017H,009H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00FH,006H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,009H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,00DH,006H,000H
	DB 000H,000H,014H,009H,000H,000H,000H,016H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,017H
	DB 009H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,017H
	DB 006H,000H,000H,000H,019H,009H,000H,000H
	DB 000H,017H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,019H,009H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,017H,006H,000H,000H,000H
	DB 017H,009H,000H,000H,000H,017H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,014H,009H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,017H,001H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,017H
	DB 006H,000H,000H,000H,012H,009H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,009H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,012H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,017H,006H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,017H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,017H,009H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,017H,006H,000H
	DB 000H,000H,014H,009H,000H,000H,000H,017H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,017H
	DB 009H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,017H
	DB 006H,000H,000H,000H,019H,009H,000H,000H
	DB 000H,017H,001H,000H,000H,000H,012H,004H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,019H,009H
	DB 000H,000H,000H,016H,001H,000H,000H,000H
	DB 012H,004H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,001H,000H,006H
	DB 019H,009H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,001H,000H,009H,017H,009H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,002H
	DB 000H,006H,000H,000H,000H,000H,000H,012H
	DB 001H,000H,000H,000H,012H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,001H,000H,008H,019H
	DB 009H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,012H,004H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,002H,000H,006H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,002H,000H
	DB 008H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,019H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,001H,000H,006H,017H,009H
	DB 000H,000H,000H,012H,001H,000H,000H,000H
	DB 019H,005H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 002H,000H,007H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,001H,000H,005H
	DB 019H,009H,000H,000H,000H,014H,001H,000H
	DB 000H,000H,019H,005H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,002H,000H,005H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,001H
	DB 000H,005H,017H,009H,000H,000H,000H,016H
	DB 001H,000H,000H,000H,019H,005H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,002H,000H,007H,019H
	DB 009H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00DH
	DB 007H,000H,000H,000H,00DH,007H,000H,000H
	DB 000H,00DH,009H,000H,000H,000H,019H,008H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00FH,007H
	DB 000H,000H,000H,00FH,007H,000H,000H,000H
	DB 00FH,009H,000H,000H,000H,014H,008H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,010H,007H,000H,000H,000H
	DB 010H,007H,000H,000H,000H,010H,009H,000H
	DB 000H,000H,017H,008H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,00DH,007H,000H
	DB 000H,000H,00DH,007H,000H,000H,000H,00DH
	DB 009H,000H,000H,000H,012H,008H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,007H
	DB 007H,000H,000H,000H,013H,007H,000H,000H
	DB 000H,014H,009H,000H,000H,000H,014H,008H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,015H,009H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,009H,000H,000H,000H
	DB 00DH,008H,00CH,002H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 013H,009H,000H,000H,000H,00FH,008H,00CH
	DB 002H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,00AH,000H,003H
	DB 000H,000H,00AH,000H,003H,014H,009H,000H
	DB 000H,000H,010H,008H,00CH,002H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,00AH,000H,003H,000H,000H,00AH
	DB 000H,003H,015H,009H,000H,000H,000H,00FH
	DB 008H,00CH,002H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00AH
	DB 000H,002H,000H,000H,00AH,000H,002H,014H
	DB 009H,000H,000H,000H,00DH,008H,00CH,001H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,00AH,000H,002H,000H
	DB 000H,00AH,000H,002H,013H,009H,000H,000H
	DB 000H,000H,000H,00CH,000H,00EH,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00AH,000H,001H,000H,000H,00AH,000H
	DB 001H,014H,009H,000H,000H,000H,000H,000H
	DB 00CH,000H,00CH,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,015H,009H
	DB 000H,000H,000H,000H,000H,00CH,000H,00AH
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,014H,009H,000H,000H,000H
	DB 000H,000H,00CH,000H,008H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 013H,009H,000H,000H,000H,000H,000H,00CH
	DB 000H,006H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,014H,009H,000H
	DB 000H,000H,000H,000H,00CH,000H,004H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,015H,009H,000H,000H,000H,000H
	DB 000H,00CH,000H,002H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,014H
	DB 009H,000H,000H,000H,000H,000H,00CH,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,013H,009H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,014H,009H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,001H,000H
	DB 009H,000H,000H,001H,000H,009H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,001H,001H,000H,000H,000H
	DB 001H,001H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 001H,001H,000H,000H,000H,001H,001H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,00AH,000H,003H
	DB 000H,000H,00AH,000H,003H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,008H
	DB 009H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,008H,009H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,008H,009H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,008H
	DB 009H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,001H
	DB 007H,00CH,001H,000H,00DH,007H,00CH,001H
	DB 000H,00DH,009H,000H,000H,000H,019H,007H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,001H,007H,00AH,000H,005H
	DB 00DH,007H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,00AH,000H,005H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,00AH,000H,004H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,00AH,000H,004H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,00AH
	DB 000H,003H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00AH,000H
	DB 003H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,00AH,000H,002H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00AH,000H,002H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,00AH,000H
	DB 005H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,00AH,000H,004H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 00AH,000H,003H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,00AH,000H,002H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H
	DB 000H,000H,000H,000H,000H,000H,000H,000H

N_OF_NZ_DATA    DB      'Is'

TWICE           DW      0
POS_Y           DW      20 DUP (0)

ENDBASE         DW      0
NOWBASE         DW      0
LINES_SCR       DB      0

SI_END          DW      0
LEFT_OFF        DW      0
THISOLD DW      0
OLDDI   DW      200 DUP (0)
OLDCH   DB      2*200 DUP (0)

PAGEOFF DW      0

ROMFNT  DW      0,0

FntPix  db      FntWidth*FntHeight*(64) dup (0)
OnePix  db      FntWidth*FntHeight dup (0)

N_OF_Z_DATA     DB      'Is'
ENDS    _Code

END     Start                                   ; loops the intro
