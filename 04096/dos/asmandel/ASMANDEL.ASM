;*****************************************************************************
;*
;*  ASMANDEL by (c) Taslehof / Null Pointer Assignment 1995   v1.0
;*
;*   This code is freeware. Only one thing: if you use it please remember me.
;*   ASMANDEL is the Mandelbrot's fractal in assembler, I use the iterated
;*   mode,the default number is 150 iterations
;*   The metod I used: we have the left upper corner point, and the size of
;*   the side. This is the zone will be zoom up to the screen's resolution.
;*   That's all folks!  See you soon.
;*   WARNING: YOU MUST HAVE A COPRO (8087+), or at least, a emulator.
;*
;*
;*****************************************************************************

.MODEL SMALL
.STACK 200h
.DATA
;=============================================================================
;=                            DATOS DEL PROGRAMA                             =
;=============================================================================

;Datos    LABEL    BYTE

	 MandelX  DD   -2.50           ;left y point of mandel
	 Mandely  DD   -1.50           ;left x point of mandel
	 Resx     =     320            ;resolution X
	 Resy     =     200            ;resolution y
	 Lado     DW    5              ;size of
	 Iteration DW   200            ;number of iterations
	 A        DD    0.0            ;general var
	 B        DD    0.0
	 X        DD    0.0
	 Y        DD    0.0
	 Xaux     DD    0.0
	 Yaux     DD    0.0
	 VGA      =     0A000h         ;my VGA and you
	 ESCALA   DD    0.015625       ;scale= lado /resx
	 KK       DD    ?              ;kk???
	 Color    DB    ?
	 Estado   DW    ?
	 DOS      DD    2
	 Caracter DB    0,0,0,0,0,255,255,255,255,255,255,0,0,0,0,0
	 TEXTO    DB    ' (c) TASLEHOF / Null Pointer Assignment 1995',10,13
		  DB    '        Saludos a la gente de la U.G.R Informatica',10,13
		  DB    '        If you have some request or some comment my email address:',10,13
		  DB    '                       jagarcia@verne.ugr.es                    ',10,13
		  DB    '$'
	 INCLUDE  FIRE.INC
;-----------------------------------------------------------------------------
;----------------------------[ FIN DE LOS DATOS ]-----------------------------
;-----------------------------------------------------------------------------
;

.CODE
;=============================================================================
;=                    CUERPO PRINCIPAL DEL PROGRAMA                          =
;=============================================================================

Main:
	 MOV     AX,@DATA              ;my data segment
	 MOV     DS,AX
	 MOV     AX,VGA                ;es = vga
	 MOV     ES,AX                 ;lets go to 13h
	 MOV     AX,13h
	 INT     10h
	 CALL    PAL

	 MOV     CX,319                ;For x=0 to 320 do begin
Loopx:   MOV     SI,CX                 ;si=cx to acces it easier.
	 MOV     WORD PTR KK,CX
	 MOV     WORD PTR KK+2,0
	 FINIT                         ;
	 FILD    KK                    ;A=x*escala+mandelx, this is necesari for calculate
	 FMUL    Escala                ;the color of point (si,di)
	 FADD    Mandelx               ;
	 FSTP    A                     ;is necesari for whatcolor
				       ;the parameters is pases by memori

	 PUSH    CX                    ;
				       ;loop whith the y
	 MOV     CX,199
Loopy:   MOV     DI,CX                 ;
	 MOV     WORD PTR KK,CX        ;B=y*escala+mandely
	 MOV     WORD PTR KK+2,0
	 FINIT
	 FILD    KK
	 FMUL    Escala
	 FADD    MandelY
	 FSTP    B                     ;


	 CALL    WHATCOLOR             ;this calculate the color whith A ,B
	 WAIT

	 MOV     AX,DI                 ;Draw the color  the pos (si,di):=color
	 MOV     BX,AX
	 SHL     AX,8
	 SHL     BX,6
	 ADD     BX,AX
	 ADD     BX,SI
	 MOV     Al,BYTE PTR Color
	 MOV     ES:[BX],Al            ;

	 LOOP    Loopy
	 POP     CX
	 LOOP    Loopx                 ;end of a line

 ReadK:  MOV     AH,1
	 INT     16h
	 JZ      ReadK
	 MOV     AX,03h                ;go to test mode
	 INT     10h
	 CALL    THEEND
	 MOV     AX,4C00h
	 INT     21h
;------------------------[ FIN DEL CUERPO DEL PROGRAMA ]----------------------


;.............................................................................
;::                     PROCEDIMIENTO DE CALCULO DEL COLOR                  ::
;.............................................................................


WHATCOLOR        PROC
		  PUSH    CX           ;keep register in use
		  PUSH    DI
		  PUSH    SI
		  FINIT
		  FLD     X            ;PUSH ,ST=X
		  FSUB    X            ;ST=X-X
		  FSTP    X            ;X=X-X=0 , POP
		  FLD     Y            ;PUSH , ST=Y
		  FSUB    Y            ;ST = ST-Y
		  FSTP    Y            ;Y=ST=0  , POP
		  MOV     CX,iteration ;iterations

				       ;keep the registers
	  @bucle: PUSH    ES
		  PUSH    CX
		  MOV     AX,DS        ;ES=DS
		  MOV     ES,AX
				       ;lets to copy xaux=x
		  MOV     CX,4
		  MOV     SI,OFFSET X
		  MOV     DI,OFFSET Xaux
		  REP     MOVSB
				       ;same yaux=y
		  MOV     CX,4
		  MOV     SI,OFFSET Y
		  MOV     DI,OFFSET Yaux
		  REP     MOVSB

		  POP     CX           ;well
		  POP     ES           ;


		  FINIT
		  FLD     Xaux         ;st = xaux
		  FMUL    Xaux         ;st = st* Xaux
		  FLD     Yaux         ;push st ,st(1)=xaux^2 , st=yaux
		  FMUL    Yaux         ;st = yaux^2
		  FSUBR   ST,ST(1)     ;st = st-st(1) +- st =xaux^2-yaux^2
		  FADD    A            ;st = st+ a
		  FSTP    X            ;X  = xaux^2 + yaux^2 + a ,pop
		  FFREE   ST(0)        ;set st=0

		  FLD     Xaux         ;st = xaux
		  FMUL    Yaux         ;st = xaux * yaux
		  FIMUL   DOS          ;st = xaux * yaux *2
		  FADD    B            ;st = xaux * yaux *2 +b
		  FSTP    Y            ;y  = st

		  FLD     X            ;st = x
		  FMUL    X            ;st = st* x
		  FSTP    KK           ;KK = x^2
		  FLD     Y            ;st = y ,st(1)= x^2
		  FMUL    Y            ;st = st * y = y^2
		  FADD    kk           ;st = x^2+y^2
		  FSQRT                ;st = st^1/2


		  FICOM   DOS          ;st = st-2
		  FSTSW   ESTADO       ;estado = word of state of the copro
		  FWAIT                ; no comment
		  MOV     AH,BYTE PTR ESTADO+1
		  SAHF                 ;set flag

		  JA      @FIN         ;

		  DEC     CX
		  CMP     CX,0
		  JE      @FIN         ;this jump is so far
		  JMP     @BUCLE       ;lets use JMP
	    @FIN:
		  CMP     CX,0         ;and calc the color with the number of iterations
		  JNE     NOFINITO
		  MOV     BYTE PTR COLOR,254
		  JMP     EXIT
	NOFINITO:
		  ;MOV     AX,CX
		  ;MOV     CX,2
		  ;MUL     CX
		  ;MOV     CX,AX
		  ADD     CX,40
		  MOV     BYTE PTR COLOR,CL    ;!!!!! CH !!!!!!! ja

	EXIT:     POP     SI
		  POP     DI
		  POP     CX
		  RET

		ENDP

;-----------------------------[FIN DE WHATCOLOR ]----------------------------

;.............................................................................
;::             PROC PAL = SET A FIRE PALETTE                                ::
;.............................................................................

PAL       PROC
	   mov  cx,255
	   mov  bx,offset paleta
      @@1: mov  dx,3C8h
	   mov  al,cl
	   out  dx,al
	   inc  dx
	   mov  al,[bx]
	   out  dx,al
	   mov  al,[bx+1]
	   out  dx,al
	   mov  al,[bx+2]
	   out  dx,al
	   add  bx,3
	   loop @@1
	   ret
	  endp


;.............................................................................
;::                     PROC THEEND WRITE THE CREDITS AND THE FLAG            ::
;.............................................................................

THEEND     PROC
	    MOV     AX,@DATA
	    MOV     ES,AX
	    MOV     BP,OFFSET (caracter)    ;lets change the 219 for my flag char
	    MOV     AX,1100h
	    MOV     BH,16
	    MOV     BL,0
	    MOV     CX,1
	    MOV     DX,219
	    INT     10h
	    MOV     AH,09h                  ;Write 3 char #219
	    MOV     AL,219
	    MOV     BH,0
	    MOV     BL,78
	    MOV     CX,3
	    INT     10h
					    ;¨what is the cursor position?
	    MOV     AH,03h
	    MOV     BX,0                    ;RETURN DH=column ,DL=row
	    INT     10h

	    ADD     DL,3                    ;
	    MOV     AH,02h
	    MOV     BH,0                    ; set the cursor in 3 pos right
	    INT     10h

	    MOV     DX,OFFSET Texto         ; set credits
	    MOV     AH,9
	    INT     21h
	    RET
	   ENDP

	 END     Main

