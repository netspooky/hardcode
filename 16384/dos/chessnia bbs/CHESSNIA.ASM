; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;  C H E S S N I A   B B S   I N T R O
;
; This Intro is dedicated to NoisyMan who help us, when we was working in
; our third production: SIMPLE
;
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²² By Spanish Lords January 1996 ²²²
TITLE Intro for CHESSNIA BBS
DOSSEG
LOCALS @@
JUMPS
MODEL  LARGE
.386
.STACK 2048
;
;Some extra segments. It is not nice but works O:)
;
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;   B U F F E R    S E G M E N T
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
BUFFER    SEGMENT
          DB       64000 DUP (0)
BUFFER    ENDS
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;   G R A P H I C S    S E G M E N T
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
GRAPHICS  SEGMENT
          INCLUDE  AZULES.INC
GRAPHICS  ENDS
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;   E Q U A T E S
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; This is Intro have not equates X-D X-D X-D
;
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;   M A C R O S
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   C L E A R   M E M O R Y
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ClrMem    MACRO   Segmn,Lon
          PUSH    ES DI CX AX
          MOV     AX,Segmn
          MOV     ES,AX
          XOR     EAX,EAX
          XOR     DI,DI
          MOV     CX,Lon
          REP     STOSD
          POP     AX CX DI ES
          ENDM
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   R A N D O M     N U M B E R     0 - 1 5
;   Out : BX
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Random    MACRO
          PUSH    AX BP
          MOV     AX,[RandSeed]
          MOV     BX,[RandSeed2]
          MOV     BP,[RandSeed3]
          ADD     AX,0a137h
          ADD     BX,63f7h
          ADD     BP,784Ah
          ROL     AX,2
          MOV     [RandSeed],AX
          ADD     BX,AX
          ROR     BX,1
          MOV     [RandSeed2],BX
          SUB     BP,BX
          XOR     AX,BP
          MOV     [RandSeed3],BP
          ADD     BX,AX
          POP     BP AX
          ENDM
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;   D A T A   S E G M E N T
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
  .DATA
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   M E S S A G E S
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
ExitMsg   DB 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ',10,13
          DB '                    C H E S S N I A   B B S   ',10,13
          DB '                        +34-76-564641       ',10,13
          DB '                        +34-76-567786       ',10,13
          DB '                 Z A R A G O Z A   ( S P A I N )',10,13
          DB 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ',10,13
          DB 'þ Baudrate: 28800 þ 24 Open þ 2 lines  þ 6 CDROM on line þ 1Gb HDD  ',10,13
          DB '                 S Y S O P : J a v i e r    G i l',10,13
          DB 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ',10,13
          DB 'þ Code <rom  / Spanish Lords.',10,13
          DB 'þ Music NoisyMan / iGUANA',10,13
          DB 'If you want, you can contact with us here, in Chessnia BBS ;-)',10,13
          DB 'ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ',10,13,'$'
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   S E G M E N T    B U F F E R
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
SegBuff   DW 0000
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   G R A P H I C S    S E G M E N T
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
SegGraph  DW 0000
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   R A N D O M    S E E D
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
RandSeed  DW 348Bh
RandSeed2 DW 7F34h
RandSeed3 DW 32bfh
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   P U T S P R I T E C L I P    V A R S
;   Vars for PutSpriteClip
;   There are NOT nice ;(
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
SegOrg    DW 0000
OffOrg    DW 0000
SegDes    DW 0000
XDes      DW 0000
YDes      DW 0000
XDim      DW 0000
YDim      DW 0000
X1Clip    DW 0000
Y1Clip    DW 0000
X2Clip    DW 0000
Y2Clip    DW 0000
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   O L D   I N T E R R U P T S   V E C T O R S
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
OldInt9   DD 0
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   I N T R O   V A R S
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
InitRad   DB  30  ; Initial Radius.
EndRad    DB  90  ; End Radius.
IncRad    DB  01  ; Radius inc. Boolean.
IncAng    DB  03  ; Angle inc.
CntAng    DB  00  ; Angle counter.
PlayM     DB  00  ; Are playing music?

; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   I N C L U D E S
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
INCLUDE   SINTABLE.INC
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   D T T 1 . I N C   "The song"
;                      by NoisyMan / iGUANA
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
INCLUDE   DTT1.INC
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   P A L E T T E
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
INCLUDE   PALETTE.INC

; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;   C O D E   S E G M E N T
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
.CODE
INCLUDE   OPL2LIB.INC
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   O L D    I N T E R R U P T    V E C T O R
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
OldInt8   dd   0
CntStep   dw   0 ; This is going to be incremented each int. 8
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;   Only detect  E S C   K E Y
; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
EscKey    db   0
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   Here comes the timer interrupt to draw all texts.
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MyInt8    PROC
          INC     CS:CntStep
          JMP     DWORD PTR [CS:OldInt8]
;         MOV     AL,20h     ; Sending End Of Interrupt
;         OUT     20h,AL
          IRET
MyInt8    ENDP
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   I N T    9   we don't want PAUSE key :)
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MyInt9    PROC
          PUSH    AX
          IN      AL,60h
          PUSH    AX
          IN      AL,61h
          MOV     AH,AL
          OR      Al,80h
          OUT     61h,AL
          POP     AX
          SHL     AL,1
          SHR     AL,1
          CMP     AL,1
          JNE     @@NoEsc
          MOV     CS:[EscKey],1
@@NoEsc:
          MOV     AL,20h
          OUT     20h,AL
          POP     AX
          IRET
MyInt9    ENDP
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   P U T   P A L E T T E
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PutPal    PROC
          PUSH    ES DI AX CX DX
          CLI
          MOV     DX,03C8h
          XOR     AL,AL
          OUT     DX,AL
          STI
          MOV     AX,DS
          MOV     ES,AX
          LEA     DI,[Colours]
          XOR     CX,CX
@@RGBLoop:
          CLI
          MOV     AL,CL
          OUT     DX,AL
          INC     DX
          MOV     AL,ES:[DI]
          OUT     DX,AL
          INC     DI
          MOV     AL,ES:[DI]
          OUT     DX,AL
          INC     DI
          MOV     AL,ES:[DI]
          OUT     DX,AL
          INC     DI
          STI
          DEC     DX
          INC     CL
          JNZ     @@RGBLoop
          POP     DX CX AX DI ES
          RET
PutPal    ENDP

; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   L O O K   E Q U A L I Z E
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
LookEqu   PROC
          PUSH    DI AX BX

          CMP     PlayM,0
          JE      @@NoLook

          LEA     DI,[Equalizer]
          ADD     DI,8                    ; Channel 9 is the battery ;)
          MOV     AL,CS:[DI]
          CMP     AL,14
          JNE     @@NoPut
          JMP SHORT @@PutLogo

@@NoLook:
          Random
          AND     BL,00000111
          JNZ     @@NoPut
@@PutLogo:
          Random
          AND     BL,00111111b
          XOR     BH,BH
          MOV     AX,BX
          Random
          AND     BL,00111111b
          XOR     BH,BH
          MOV     OffOrg,125*320
          MOV     XDes,AX
          MOV     YDes,BX
          MOV     XDim,270
          MOV     YDim,75
          CALL    PutSpriteClip
@@NoPut:
          POP     BX AX DI
          RET
LookEqu   ENDP

; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   G E T   R A N D O M    V A L U E S
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
GetRnd    PROC
          PUSH    BX
          MOV     IncRad,1
@@Equal:
          Random
          AND     BL,01111111b
          CMP     BL,InitRad
          JE      @@Equal
          JA      @@Plus
          MOV     IncRad,0
@@Plus:
          MOV     EndRad,BL
          Random
          AND     BL,00000011b
          ADD     BL,2
          MOV     IncAng,BL
          POP     BX
          RET
GetRnd    ENDP

; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   P U T    S P R I T E    C L I P
;   Solo Programadores routine. I wrote this routine for writing an
;   article in the magazine. It is not optimized, or, is it? :-?
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

PutSpriteClip PROC
          PUSH    AX BX
          mov     ax,X1Clip
          mov     bx,XDes
          add     bx,XDim
          cmp     bx,ax
          jle     @@End
          mov     ax,Y1Clip
          mov     bx,YDes
          add     bx,YDim
          cmp     bx,ax
          jle     @@End
          mov     ax,X2Clip
          cmp     XDes,ax
          jge     @@End
          mov     ax,Y2Clip
          cmp     YDes,ax
          jge     @@End


          PUSH    ES DI SI CX DX
          push    fs
          mov     ax,SegOrg
          mov     fs,ax
          mov     si,OffOrg
          mov     ax,SegDes
          mov     es,ax

          mov     ax,XDes
          cmp     ax,X1Clip
          jg      @@NoClipIzqdo
          mov     ax,X1Clip
          sub     ax,XDes
          add     si,ax
          mov     ax,XDes
          add     ax,XDim
          sub     ax,X1Clip
          mov     XDim,ax
          mov     ax,X1Clip
          mov     XDes,ax
@@NoClipIzqdo:
          mov     ax,YDes
          cmp     ax,Y1Clip
          jg      @@NoClipSup
          mov     ax,Y1Clip
          sub     ax,YDes
          mov     bx,320
          imul    bx
          add     si,ax
          mov     ax,YDes
          add     ax,YDim
          sub     ax,Y1Clip
          mov     YDim,ax
          mov     ax,Y1Clip
          mov     YDes,ax
@@NoClipSup:
          mov     ax,320                  ; Calcula el offset
          mov     bx,YDes
          imul    bx
          mov     di,ax
          add     di,XDes
          mov     ax,XDes
          add     ax,XDim
          cmp     ax,X2Clip
          jl      @@NoClipDrcho
          mov     ax,X2Clip
          sub     ax,XDes
          mov     XDim,ax
@@NoClipDrcho:
          mov     ax,YDes
          add     ax,YDim
          cmp     ax,Y2Clip
          jl      @@NoClipInf
          mov     ax,Y2Clip
          sub     ax,YDes
          mov     YDim,ax
@@NoClipInf:
          mov     cx,320                  ; Cte de cambio de linea
          sub     cx,XDim
@@AnotherLine:
          mov     dx,XDim
@@AnotherPix:
          mov     al,fs:[si]
          cmp     al,0
          je      @@NoPutPix
          mov     es:[di],al
@@NoPutPix:
          inc     di
          inc     si
          dec     dx
          jnz     @@AnotherPix
          add     di,cx
          add     si,cx
          dec     YDim
          jnz     @@AnotherLine
          pop     fs
          POP     DX CX SI DI ES
@@End:
          POP     BX AX
          RET
PutSpriteClip ENDP

; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   P U T    B A L L
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PutBall   PROC
          PUSH    AX BX DI
          XOR     AX,AX
          XOR     BX,BX
          MOV     AL,CntAng
          ADD     AL,64                   ; Now we have cosinus value O:)
          SHL     AX,1                    ; Sin values are 2 bytes.
          LEA     DI,[SinTable]
          ADD     DI,AX
          MOV     AX,DS:[DI]
          MOV     BL,InitRad
          IMUL    BX
          SAR     AX,8
          ADD     AX,160
          PUSH    AX                      ; Store X value in the stack
          XOR     AX,AX                   ; This is not nice :(
          XOR     BX,BX
          MOV     AL,CntAng
          SHL     AX,1
          LEA     DI,[SinTable]
          ADD     DI,AX
          MOV     AX,DS:[DI]
          MOV     BL,InitRad
          IMUL    BX
          SAR     AX,8
          ADD     AX,74
          POP     BX                      ; (BX,AX) = (x,y)
          MOV     OffOrg,0
          MOV     XDes,BX
          MOV     YDes,AX
          MOV     XDim,22
          MOV     YDim,22
          CALL    PutSpriteClip
          POP     DI BX AX
          RET
PutBall   ENDP

; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   B L U R   F I R E
;   NoisyMan puts the name :-D
;   Nice & special blur motion O;)
;   IN : DI = Number of points
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
BlurFire  PROC
          PUSH    DS ES AX BX DX
          MOV     AX,0A000h
          MOV     ES,AX
          MOV     AX,SegBuff
          MOV     DS,AX
@@Another:
          MOV     AL,DS:[DI]
          OR      AL,AL
          JZ      @@Nothing
          DEC     AL
          MOV     DS:[DI],AL
          XOR     AH,AH
          XOR     DX,DX
          MOV     BX,AX
          MOV     DL,DS:[DI-1]
          ADD     BX,DX
          MOV     DL,DS:[DI+1]
          ADD     BX,DX
          MOV     DL,DS:[DI+320]
          ADD     BX,DX
          SHR     BX,2
          MOV     DS:[DI],BL
@@Nothing:
          MOV     ES:[DI],AL
          DEC     DI
          JNZ     @@Another
          POP     DX BX AX ES DS
          RET
BlurFire  ENDP

; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;   M A I N
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
MAIN      PROC
          MOV     AX,@DATA                ; DS to Data segment
          MOV     DS,AX
;          MOV     BX,4000
          MOV     SegBuff,SEG Buffer
          MOV     SegGraph, SEG Graphics
          MOV     AX,13H
          INT     10H                     ; MCGA ON
          CALL    PutPal

          PUSH    DS
          MOV     AH,35H
          MOV     AL,8
          INT     21H                     ; Get Old Int 8 in ES:BX
          MOV     WORD PTR CS:[OldInt8  ],BX
          MOV     WORD PTR CS:[OldInt8+2],ES
          MOV     AX,CS
          MOV     DS,AX
          MOV     DX,OFFSET MyInt8
          MOV     AH,25H
          MOV     AL,8
          INT     21H                     ; Set our Int 8.
          POP     DS

          PUSH    DS
          MOV     AH,35H
          MOV     AL,9
          INT     21H                     ; Get Old Int 9 in ES:BX
          MOV     WORD PTR [OldInt9  ],BX
          MOV     WORD PTR [OldInt9+2],ES
          MOV     AX,CS
          MOV     DS,AX
          MOV     DX,OFFSET MyInt9
          MOV     AH,25H
          MOV     AL,9
          INT     21H                     ; Set our Int 9.
          POP     DS

          MOV     PlayM,0
          CALL    DetectOPL2
          JC      @@NoMusic
          MOV     PlayM,1
          MOV     BL,0                    ; No polling
          MOV     AX,DS
          MOV     ES,AX                   ; Song is in DS
          LEA     SI,[Song]
          CALL    StartMusic              ; Detect OPL2 and play now!
@@NoMusic:
          ClrMem  0A000h,16000            ; Now clear screen.
          ClrMem  SegBuff,16000           ; ClearBuffer

          MOV     AX,SegGraph             ; Prepare PutSpriteClip
          MOV     SegOrg,AX
          MOV     AX,0A000h
          MOV     SegDes,AX
          MOV     X1Clip,0
          MOV     Y1Clip,0
          MOV     X2Clip,319
          MOV     Y2Clip,199

          MOV     OffOrg,57*320
          MOV     XDes,0
          MOV     YDes,200-54
          MOV     XDim,320
          MOV     YDim,54
          CALL    PutSpriteClip
          MOV     AX,SegBuff              ; Prepare PutSpriteClip
          MOV     SegDes,AX
          MOV     Y2Clip,146

@@MainLoop:
          MOV     AL,InitRad
          CMP     AL,EndRad
          JNE     @@NoGetNewValues
          CALL    GetRnd
@@NoGetNewValues:
          CALL    PutBall
          CMP     IncRad,1
          JE      @@Add
          DEC     InitRad
          JMP SHORT @@Continue
@@Add:
          INC     InitRad
@@Continue:
          CALL    LookEqu

@@WaitSyncro:
          CMP     CS:CntStep,0            ; Now 18 frames in ALL computers.
          JE      @@WaitSyncro
          MOV     CS:CntStep,0

          MOV     DX,03DAh
@@Jump1:
          IN      AL,DX
          TEST    AL,08h
          JZ      @@Jump1
@@Jump2:
          IN      AL,DX
          TEST    AL,08h
          JNZ     @@Jump2

          MOV     DI,320*(200-54)
          CALL    BlurFire
          MOV     AH,IncAng
          ADD     CntAng,AH

          CMP     CS:[EscKey],0
          JE      @@MainLoop

          MOV     Y2Clip,199
          MOV     OffOrg,57*320
          MOV     XDes,0
          MOV     YDes,200-54
          MOV     XDim,320
          MOV     YDim,54
          CALL    PutSpriteClip

          MOV     CX,20                  ; The End
@@WaitSyncro2:
          CMP     CS:CntStep,0
          JE      @@WaitSyncro2
          MOV     CS:CntStep,0

          MOV     DX,03DAh
@@Jump3:
          IN      AL,DX
          TEST    AL,08h
          JZ      @@Jump3
@@Jump4:
          IN      AL,DX
          TEST    AL,08h
          JNZ     @@Jump4

          MOV     DI,64000
          CALL    BlurFire
          DEC     CX
          JNZ     @@WaitSyncro2

          CMP     PlayM,0
          JE      @@NoStopMusic
          CALL    StopMusic
@@NoStopMusic:

          PUSH    DS
          MOV     DX,WORD PTR CS:[OldInt8  ]
          MOV     AX,WORD PTR CS:[OldInt8+2]
          MOV     DS,AX
          MOV     AH,25H
          MOV     AL,8
          INT     21H                     ; Set old Int 8.
          POP     DS

          PUSH    DS
          MOV     DX,WORD PTR [OldInt9  ]
          MOV     AX,WORD PTR [OldInt9+2]
          MOV     DS,AX
          MOV     AH,25H
          MOV     AL,9
          INT     21H                     ; Set old Int 9.
          POP     DS

          MOV     AX,SegBuff
          MOV     ES,AX
          MOV     AX,3
          INT     10h
Salida:
          lea     si,[ExitMsg]
          MOV     DX,si
          MOV     AH,9
          INT     21h
          MOV     AX,4C00h
          INT     21h                     ; DOS control
MAIN      ENDP
          END     MAIN
