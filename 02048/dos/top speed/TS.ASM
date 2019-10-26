 ; Title .... : TOP SPEED
 ; Version .. : 1.1.53
 ; Category . : 2k game
 ; Author ... : Akos Fekete
 ; Country .. : Hungary
 ; E-mail ... : feketeakos@matavnet.hu

                .486

MAXSPEED        Equ     241
GAMETIME        Equ     120

CAR             Macro   carypos,carxpos,cartype
                DW      ((carypos)/4)*32+carxpos/4
                DB      cartype
                Endm

b               Equ     byte ptr
o               Equ     offset
s               Equ     short
w               Equ     word ptr
d               Equ     dword ptr

_B              Equ     0
_C              Equ     1
_D              Equ     2
_E              Equ     3
_I              Equ     4
_M              Equ     5
_O              Equ     6
_P              Equ     7
_R              Equ     8
_S              Equ     9
_T              Equ     10

salc            Equ     DB 0D6h

TopSpeed        Segment Use16
                Assume  cs:TopSpeed,ds:TopSpeed
                Org     0100h

START:          ;
                ;       depacking sprites
                ;

                mov     si,o PackedDatas
                mov     di,o Sprites
                mov     cl,4
                mov     bx,o Colors
Vehicles:       push    cx
                lodsw
                xchg    ax,cx
Reload:         lodsb
                xchg    ax,dx
                mov     ah,4
NextPixel:      dec     ah
                js      s Reload
                mov     al,dl
                shr     al,6
                shl     dl,2
                xlatb
                stosb
                loop    NextPixel
                add     bx,4
                pop     cx
                loop    Vehicles

                ;
                ;       initial screen
                ;

Reinit:         call    ResetAdlib
                mov     ax,13h
                int     10h
                mov     ah,09h
                mov     dx,o InitialText
                int     21h
                push    0a000h
                pop     es
                push    es
                pop     ds
                std
                mov     si,31999
                mov     di,63999
                mov     cx,100
DoubleSize:     push    cx
                push    si
                mov     cx,320
OneLine:        lodsb
                shl     al,1
                stosb
                loop    OneLine
                pop     si
                mov     cx,320
                rep     movsb
                pop     cx
                loop    DoubleSize
                cld
                push    cs
                pop     es
                push    es
                pop     ds
WaitKey:        xor     ax,ax
                int     16h
                cmp     al,27
                je      SimpleExit
                cmp     al,20h
                jne     s WaitKey

                ;
                ;       init variables
                ;

                mov     si,o DEFAULT
                mov     di,o SidePosition
                mov     cx,32
                rep     movsb

                ;
                ;       capturing interrupts
                ;

                mov     ax,3509h
                int     21h
                mov     ksgm,es
                mov     kofs,bx
                mov     ax,351Ch
                int     21h
                mov     tsgm,es
                mov     tofs,bx
                mov     ax,2509h
                mov     dx,o KeyboardHandler
                int     21h
                mov     ax,251Ch
                mov     dx,o TimerHandler
                int     21h
                mov     al,36h
                out     43h,al
                mov     al,0
                out     40h,al
                mov     al,24
                out     40h,al

                ;
                ;       320x200x8
                ;

                mov     ax,13h
                int     10h

                ;
                ;       main program
                ;

Main:           push    8000h
                pop     es

                ;
                ;       changing speed
                ;

                cmp     b sync,3
                jne     s SpeedOK
                mov     al,up
                add     al,al
                jc      s DoNotIncrease
                cmp     b speed,MAXSPEED
                jae     s DoNotIncrease
                mov     si,o Acceleration
BiggerSpeed:    lodsw
                cmp     al,b Speed
                jb      s BiggerSpeed
                cmp     ah,b sync4
                ja      s DoNotIncrease
                mov     b sync4,0
                inc     b speed
DoNotIncrease:  mov     al,down
                add     al,al
                jc      s SpeedOK
                sub     b speed,13
                jnc     s SpeedOK
                mov     b speed,0
SpeedOK:
                ;
                ;       changing position
                ;

                inc     b myps
                mov     al,MAXSPEED
                sub     al,b speed
                shr     al,6
                cmp     al,myps
                ja      s PositionOK
                mov     b myps,0
                mov     al,left
                add     al,al
                jc      s CheckRight
                dec     b carhor
                jns     s CheckRight
                inc     b carhor
CheckRight:     mov     al,right
                add     al,al
                jc      s PositionOK
                inc     b carhor
                cmp     b carhor,89
                jc      s PositionOK
                dec     b carhor
PositionOK:
                ;
                ;       synchron
                ;

Synchron:       shr     b sync2,1
                jnc     s Synchron

                ;
                ;       counting points
                ;

                mov     ax,speed
                cwde
                shl     ax,8
                add     dscore,eax

                ;
                ;       frame synchron
                ;

                cmp     b sync,4
                jc      OldScreen
                mov     b sync,0

                ;
                ;       clock - 50 Hz
                ;

                dec     b ts3
                jnz     s ClockOK
                mov     b ts3,50
                dec     b time
ClockOK:
                ;
                ;       clearing video puffer
                ;

                mov     cx,32768
                xor     di,di
                xor     ax,ax
                rep     stosw

                ;
                ;       titles
                ;

                mov     si,o TitleInfos
                mov     cx,18
PrintTitles:    lodsw
                xchg    ax,di
                lodsb
                cbw
                add     al,10
                xchg    ax,bx
                mov     ah,14
                call    PrintChar
                loop    PrintTitles

                ;
                ;       numbers
                ;

                mov     bx,10
                mov     al,time
                cbw
                cwd
                div     bx
                push    dx
                push    295+36*320
                mov     bl,6
                cwd
                div     bx
                push    dx
                push    285+36*320
                push    ax
                push    265+36*320
                push    w [Score]
                push    65+100*320
                push    w [BestScore]
                push    65+36*320
                push    w [Speed]
                push    290+100*320

                ;
                ;       display numbers
                ;

                mov     cl,6
GetNumberDatas: pop     di
                pop     ax
                push    cx
                mov     bl,10
                mov     cl,0
NextDigit:      cwd
                div     bx
                push    dx
                inc     cx
                or      ax,ax
                jnz     s NextDigit
                sub     di,cx
                sub     di,cx
                sub     di,cx
                sub     di,cx
                sub     di,cx
                sub     di,cx
                sub     di,cx
                sub     di,cx
                sub     di,cx
                sub     di,cx
DigitCycle:     pop     bx
                mov     ah,15
                Call    PrintChar
                add     di,10
                loop    DigitCycle
                pop     cx
                loop    GetNumberDatas

                ;
                ;       ":"
                ;

                mov     di,265+36*320
                mov     bl,21
                call    PrintChar

                ;
                ;       edges of the road
                ;

                mov     di,90
                mov     ax,SidePosition
                mov     cl,200
Edges:          push    cx
                add     ah,4
                mov     al,10
                js      s LeftEdgeColor
                mov     al,2
LeftEdgeColor:  mov     cl,10
                rep     stosb
                mov     al,7
                mov     cl,120
                rep     stosb
                mov     al,10
                js      s RightEdgeColor
                mov     al,2
RightEdgeColor: mov     cl,10
                rep     stosb
                add     di,320-140
                pop     cx
                loop    Edges

                ;
                ;       drawing bikes, cars and trucks
                ;

                mov     cl,CarNumber
                mov     si,o VehicleDatas
NextCar:        lodsw
                push    ax
                and     al,0E0h
                shr     ax,3
                mov     edi,CarPosOffset
                shr     edi,19
                add     di,ax
                and     di,1FFFh
                cmp     di,1FFFh-336
                pop     ax
                jb      s OutOfScreen
                imul    edi,edi,320
                sub     edi,2557340
                and     ax,001Fh
                cwde
                shl     ax,2
                add     edi,eax
                lodsb
                shl     al,3
                add     ax,o VDtable
                xchg    ax,sp
                pop     bp
                pop     dx
                pop     ebx
                xchg    ax,sp
                pushad
                mov     si,bp
                mov     cx,dx
NextSline:      push    cx
                mov     cx,bx
SpriteLine:     lodsb
                cmp     edi,64000
                ja      s InvalidPixel
                cmp     al,0Ch
                jne     s CarColorOK
                mov     al,01
CarColorOK:     stosb
                dec     di
InvalidPixel:   inc     di
                loop    SpriteLine
                pop     cx
                add     edi,320
                sub     edi,ebx
                loop    NextSLine
                popad
                DB      0A8h
OutOfScreen:    lodsb
                loop    NextCar

                ;
                ;       moving vehicles
                ;

                mov     ax,speed
                cwde
                shl     ax,6
                sub     w SidePosition,ax
                shl     eax,8
                sub     eax,1295360
                add     d CarPosOffset,eax

                ;
                ;       drawing my car
                ;

                mov     di,100+140*320
                mov     ax,Speed
                mov     bx,5
                cwd
                div     bx
                imul    ax,ax,320
                sub     di,ax
                add     di,carhor
                mov     si,o xcar
                pusha
                mov     cl,48
CrashScanY:     push    cx
                mov     cl,32
CrashScanX:     lodsb
                cmp     al,7
                je      s ExternalPixel
                cmp     b es:[di],7
ExternalPixel:  je      s FreePixel
CRASH:          pop     cx
                popa
                shr     w Speed,2
                jmp     s MyCarOK
FreePixel:      inc     di
                loop    CrashScanX
                add     di,320-32
                pop     cx
                loop    CrashScanY
GoodPosition:   popa
                mov     cl,48
MyCarYPixel:    push    cx
                mov     cl,32
MyCarXPixel:    lodsb
                cmp     al,7
                je      s SkipExtPixel
                stosb
                dec     di
SkipExtPixel:   inc     di
                loop    MyCarXPixel
                add     di,320-32
                pop     cx
                loop    MyCarYPixel
MyCarOK:
                ;
                ;       display the new screen
                ;

                mov     ch,80h
                xor     si,si
                xor     di,di
                push    es
                pop     ds
                push    0A000h
                pop     es
                rep     movsw
                push    cs
                pop     ds

                ;
                ;       motor noise - 10 Hz
                ;

                cmp     b sync3,10
                jb      s SoundOK
                mov     b sync3,cl
                mov     si,o maprms
                mov     cl,4
PrepareChannel: lodsw
                call    WriteAdlib
                loop    PrepareChannel
HighGear:       lodsw
                cmp     al,b speed
                jc      s HighGear
                shr     ax,6
                xchg    ax,bx
                mov     ax,Speed
                mul     bx
                shr     ax,6
                add     ax,0838h
                xchg    ax,bx
                mov     ah,bl
                mov     al,0A0h
                call    WriteAdlib
                mov     ah,bh
                or      ah,20h
                mov     al,0B0h
                call    WriteAdlib
SoundOK:
                ;
                ;       checking time
                ;

                cmp     b time,0
                ja      s OldScreen
                call    OldInterrupts
                call    ResetAdlib
                mov     si,o TimeOverText
                mov     ax,Score
                cmp     ax,BestScore
                jc      s RecordChecked
                mov     si,o NewRecordText
                mov     BestScore,ax
RecordChecked:
                ;
                ;       printing message
                ;

                mov     di,111+87*320
                mov     dx,0C0Fh
                mov     bx,24
                mov     ax,0200h
BlackBox:       mov     cl,96
                rep     stosb
                add     di,320-96
                dec     bx
                jnz     s BlackBox
                int     10h
                mov     cl,10
PrintMessage:   mov     bl,0Ch
                mov     ah,0Eh
                lodsb
                int     10h
                loop    PrintMessage

                ;
                ;       waiting for a key
                ;

WaitForSpace:   xor     ax,ax
                int     16h
                cmp     al,20h
                jne     s WaitForSpace
                jmp     Reinit
OldScreen:
                ;
                ;       checking ESC key
                ;

                cmp     b esc_,80h
                jnc     main

                ;
                ;       EXIT
                ;

Exit:           call    OldInterrupts
SimpleExit:     mov     ax,3
                int     10h
                mov     dx,o MyName
                mov     ax,3D02h
                cmp     b ds:[0080h],al
                jb      s DontSaveRecord
                int     21h
                mov     dx,-2
                mov     cx,0FFFFh
                xchg    ax,bx
                mov     ax,4202h
                int     21h
                mov     dx,o BestScore
                mov     cx,2
                mov     ah,40h
                int     21h
DontSaveRecord: ret

PrintChar       proc    near
                pusha
                shl     bx,4
                xor     bp,bp
                mov     cl,16
DigitLine:      push    cx
                mov     cl,8
ReadDigitPixel: bt      [bx+o N0],bp
                inc     bp
                mov     al,ah
                jc      s DigitPixelOK
                salc
DigitPixelOK:   stosb
                loop    ReadDigitPixel
                add     di,320-8
                pop     cx
                loop    DigitLine
                popa
                ret
PrintChar       endp

ResetAdlib      proc    near
                pusha
                mov     cl,255
rstac:          mov	ax,cx
                call	WriteAdlib
	        loop	rstac
                popa
                ret
ResetAdlib      endp

WriteAdlib      proc    near
                push    ax
                call    WriteOperator
                pop     ax
                add	al,03h
WriteOperator:  mov	dx,0388h
	        call	WriteAPort
	        inc	dx
	        mov	al,ah
WriteAport:	out	dx,al
	        in	al,41h
	        in	al,41h
	        in	al,41h
                ret
WriteAdlib      endp

OldInterrupts   proc    near
                pusha
                push    ds
                mov     ax,2509h
                mov     dx,kofs
                mov     ds,ksgm
                int     21h
                pop     ds
                mov     al,36h
                out     43h,al
                mov     al,00h
                out     40h,al
                out     40h,al
                push    ds
                mov     ax,251Ch
                mov     dx,tofs
                mov     ds,tsgm
                int     21h
                pop     ds
                popa
                ret
OldInterrupts   endp

KeyboardHandler:
                push    ds
                pusha
                push    cs
                pop     ds
                in      al,60h
                mov     ah,al
                and     al,7fh
                sub     al,01h
                jnz     s NotEsc
                mov     b esc_,01h
NotEsc:         sub     al,47h
                jnz     s NotUP
                mov     up,ah
NotUP:          sub     al,03h
                jnz     s NotLEFT
                mov     left,ah
NotLEFT:        sub     al,02h
                jnz     s NotRIGHT
                mov     right,ah
NotRIGHT:       sub     al,03h
                jne     s NotDOWN
                mov     down,ah
NotDOWN:        in      al,61h
                mov     ah,al
                or      al,80h
                out     61h,al
                mov     al,ah
                out     61h,al
                mov     al,20h
                out     020h,al
                popa
                pop     ds
                iret

TimerHandler:
                push    ds
                pusha
                push    cs
                pop     ds
                pushf
                add     b cdivr,12
                jns     s TooDense
                and     b cdivr,127
                DB      09Ah
tofs            dw      0
tsgm            dw      0
                push    ax
TooDense:       pop     ax
                inc     b sync
                inc     b sync2
                inc     b sync3
                inc     b sync4
                popa
                pop     ds
                iret

Colors          DB      07h,0Eh,06h,00h
                DB      0Ch,0Bh,07h,00h
                DB      07h,0Fh,00h,05h
                DB      03h,0Bh,00h,00h

VDtable         DW      o xcar
                DW      48
                DD      32
                DW      o xmot
                DW      37
                DD      20
                DW      o xcam
                DW      136
                DD      40
                DW      o xcar2
                DW      48
                DD      32

packeddatas:
        DW      20*37
	DB	000h,000h,0FCh,000h,000h,000h,003h,0FFh,000h,000h,000h,003h
	DB	0FFh,000h,000h,000h,003h,0FFh,000h,000h,000h,003h,0FFh,000h
	DB	000h,000h,003h,057h,000h,000h,000h,001h,055h,000h,000h,000h
	DB	005h,055h,040h,000h,000h,005h,055h,040h,000h,000h,005h,0FDh
	DB	040h,000h,000h,005h,0FDh,040h,000h,000h,005h,0FDh,040h,000h
	DB	000h,017h,0FFh,050h,000h,000h,0FFh,0FFh,0FCh,000h,00Fh,0FFh
	DB	0FFh,0FFh,0C0h,03Fh,055h,055h,057h,0F0h,0F0h,0A5h,0FDh,068h
	DB	03Ch,0A2h,0A5h,0FDh,06Ah,028h,0A2h,0A5h,055h,06Ah,028h,0A2h
	DB	0A5h,055h,06Ah,028h,0A8h,0A9h,0FDh,0A8h,0A8h,0AAh,0ABh,0FFh
	DB	0AAh,0A8h,02Ah,0ABh,0FFh,0AAh,0A0h,02Ah,0ABh,0FFh,0AAh,0A0h
	DB	00Ah,0AAh,0FEh,0AAh,080h,000h,0AAh,0AAh,0A8h,000h,000h,016h
	DB	0AAh,050h,000h,000h,015h,055h,050h,000h,000h,055h,055h,054h
	DB	000h,000h,055h,055h,054h,000h,000h,055h,055h,054h,000h,000h
	DB	015h,055h,050h,000h,000h,00Fh,057h,0C0h,000h,000h,00Fh,0FFh
	DB	0C0h,000h,000h,00Fh,0FFh,0C0h,000h,000h,00Fh,0FFh,0C0h,000h
	DB	000h,003h,0FFh,000h,000h

        DW      32*48
        DB      0AAh,0AAh,000h,000h,000h,000h,0AAh
	DB	0AAh,0AAh,080h,000h,000h,000h,000h,002h,0AAh,0A8h,000h,000h
	DB	000h,000h,000h,000h,02Ah,0A0h,000h,000h,000h,000h,000h,000h
	DB	00Ah,0A0h,000h,000h,000h,000h,000h,000h,00Ah,0A0h,000h,000h
	DB	000h,000h,000h,000h,00Ah,0A0h,000h,000h,000h,000h,000h,000h
	DB	00Ah,0A0h,000h,000h,000h,000h,000h,000h,00Ah,0F0h,000h,000h
	DB	000h,000h,000h,000h,00Fh,0F0h,000h,000h,000h,000h,000h,000h
	DB	00Fh,0F0h,000h,000h,000h,000h,000h,000h,00Fh,0F0h,000h,000h
	DB	000h,000h,000h,000h,00Fh,0F0h,000h,000h,055h,055h,000h,000h
	DB	00Fh,0F0h,000h,055h,055h,055h,055h,000h,00Fh,0F0h,015h,055h
	DB	055h,055h,055h,054h,00Fh,0F1h,055h,055h,055h,055h,055h,055h
	DB	04Fh,0A1h,055h,055h,055h,055h,055h,055h,04Ah,0A1h,055h,055h
	DB	000h,000h,055h,055h,04Ah,0A0h,055h,000h,000h,000h,000h,055h
	DB	00Ah,0A8h,000h,000h,000h,000h,000h,000h,02Ah,0A9h,000h,000h
	DB	000h,000h,000h,000h,06Ah,0A9h,040h,000h,000h,000h,000h,001h
	DB	06Ah,0A9h,040h,000h,000h,000h,000h,001h,06Ah,0A9h,040h,000h
	DB	000h,000h,000h,001h,06Ah,0A9h,040h,000h,000h,000h,000h,001h
	DB	06Ah,0A9h,040h,000h,000h,000h,000h,001h,06Ah,0A9h,040h,000h
	DB	000h,000h,000h,001h,06Ah,0A9h,040h,000h,000h,000h,000h,001h
	DB	06Ah,0A9h,000h,000h,000h,000h,000h,000h,06Ah,0A8h,000h,000h
	DB	000h,000h,000h,000h,02Ah,0A8h,000h,000h,000h,000h,000h,000h
	DB	02Ah,0A0h,000h,000h,000h,000h,000h,000h,00Ah,0A0h,000h,000h
	DB	000h,000h,000h,000h,00Ah,0A0h,000h,000h,000h,000h,000h,000h
	DB	00Ah,0A0h,000h,000h,000h,000h,000h,000h,00Ah,0A0h,015h,055h
	DB	000h,000h,055h,054h,00Ah,080h,055h,055h,055h,055h,055h,055h
	DB	002h,0C0h,055h,055h,055h,055h,055h,055h,003h,0C0h,000h,015h
	DB	055h,055h,054h,000h,003h,0C0h,000h,000h,000h,000h,000h,000h
	DB	003h,0C0h,000h,000h,000h,000h,000h,000h,003h,0C0h,000h,000h
	DB	000h,000h,000h,000h,003h,0C0h,000h,000h,000h,000h,000h,000h
	DB	003h,0C0h,000h,000h,000h,000h,000h,000h,003h,0C0h,000h,000h
	DB	000h,000h,000h,000h,003h,080h,000h,000h,000h,000h,000h,000h
	DB	002h,080h,000h,000h,000h,000h,000h,000h,002h,0A0h,000h,000h
	DB	000h,000h,000h,000h,00Ah

        DW      40*136
        DB      000h,000h,001h,055h,055h,055h,055h
	DB	040h,000h,000h,005h,055h,055h,055h,055h,055h,055h,055h,055h
	DB	050h,005h,055h,055h,055h,055h,055h,055h,055h,055h,050h,015h
	DB	055h,055h,055h,055h,055h,055h,055h,055h,054h,015h,055h,055h
	DB	055h,055h,055h,055h,055h,055h,054h,015h,055h,055h,055h,055h
	DB	055h,055h,055h,055h,054h,015h,055h,055h,055h,056h,095h,055h
	DB	055h,055h,054h,015h,055h,05Ah,0AAh,05Ah,0A5h,0AAh,0A5h,055h
	DB	054h,015h,056h,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,095h,054h,015h
	DB	05Ah,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0A5h,054h,095h,06Ah,0AAh
	DB	0AAh,0AAh,0AAh,0AAh,0AAh,0A9h,056h,095h,06Ah,0AAh,0AAh,0AAh
	DB	0AAh,0AAh,0AAh,0A9h,056h,095h,06Ah,0AAh,0AAh,0AAh,0AAh,0AAh
	DB	0AAh,0A9h,056h,095h,055h,056h,0AAh,0AAh,0AAh,0AAh,095h,055h
	DB	056h,095h,055h,055h,055h,05Ah,0A5h,055h,055h,055h,056h,095h
	DB	055h,055h,055h,05Ah,0A5h,055h,055h,055h,056h,095h,055h,055h
	DB	055h,06Ah,0A9h,055h,055h,055h,056h,095h,055h,055h,055h,06Ah
	DB	0A9h,055h,055h,055h,056h,095h,055h,055h,055h,0AAh,0AAh,055h
	DB	055h,055h,056h,095h,055h,055h,055h,0AAh,0AAh,055h,055h,055h
	DB	056h,015h,055h,055h,055h,06Ah,0A9h,055h,055h,055h,054h,015h
	DB	055h,055h,055h,055h,055h,055h,055h,055h,054h,002h,0AAh,0AAh
	DB	0A2h,00Ah,0A0h,08Ah,0AAh,0AAh,080h,002h,0AAh,0AAh,0A0h,0AAh
	DB	0AAh,00Ah,0AAh,0AAh,080h,002h,0AAh,0AAh,0A2h,00Ah,0A0h,08Ah
	DB	0AAh,0AAh,080h,02Ah,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh
	DB	0A8h,02Ah,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0A8h,02Ah
	DB	0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0A8h,02Ah,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0A8h,02Ah,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0A8h,02Ah,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0A8h,0AAh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0AAh,0AAh,000h,000h,000h,000h,000h,000h,000h,000h,0AAh,0AAh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0AAh,0AAh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0AAh,0AFh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0FAh,0AFh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0FAh,0AFh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0FAh,0AFh,000h,000h,000h,000h,000h,000h,000h,000h,0FAh,0AFh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0FAh,0AFh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0FAh,02Fh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0F8h,0AFh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0FAh,0AFh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0FAh,0AFh,000h,000h,000h,000h,000h,000h,000h,000h,0FAh,0AFh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0FAh,0AAh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0AAh,0AAh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0AAh,0AAh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0AAh,0AAh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0AAh,0AAh,000h,000h,000h,000h,000h,000h,000h,000h,0AAh,0AAh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0AAh,02Ah,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0A8h,02Ah,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0A8h,02Ah,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0A8h,02Ah,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0A8h,02Ah,000h,000h,000h,000h,000h,000h,000h,000h,0A8h,02Ah
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0A8h,02Ah,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0A8h,02Ah,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0A8h,02Ah,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0A8h,02Ah,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0A8h,02Ah,000h,000h,000h,000h,000h,000h,000h,000h,0A8h,02Ah
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0A8h,02Fh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0F8h,02Fh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0F8h,02Fh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0F8h,02Fh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0F8h,02Fh,000h,000h,000h,000h,000h,000h,000h,000h,0F8h,02Fh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0F8h,02Fh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0F8h,02Fh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0F8h,02Fh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0F8h,02Fh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0F8h,02Ah,000h,000h,000h,000h,000h,000h,000h,000h,0A8h,02Ah
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0A8h,02Ah,0AAh,0AAh
	DB	000h,000h,000h,000h,0AAh,0AAh,0A8h,02Ah,0AAh,0AAh,000h,000h
	DB	000h,000h,0AAh,0AAh,0A8h,02Ah,0AAh,0AAh,000h,000h,000h,000h
	DB	0AAh,0AAh,0A8h,02Ah,0AAh,0AAh,000h,000h,000h,000h,0AAh,0AAh
	DB	0A8h,02Ah,000h,000h,000h,000h,000h,000h,000h,000h,0A8h,02Ah
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0A8h,02Ah,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0A8h,02Ah,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0A8h,02Ah,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0A8h,02Ah,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0A8h,02Ah,000h,000h,000h,000h,000h,000h,000h,000h,0A8h,02Fh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0F8h,02Fh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0F8h,02Fh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0F8h,02Fh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0F8h,02Fh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0F8h,02Fh,000h,000h,000h,000h,000h,000h,000h,000h,0F8h,02Fh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0F8h,02Fh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0F8h,0AFh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0FAh,0AFh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0FAh,0AAh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0AAh,0AAh,000h,000h,000h,000h,000h,000h,000h,000h,0AAh,0AAh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0AAh,0AAh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0AAh,0AAh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0AAh,0AAh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0AAh,0AAh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0AAh,0AAh,000h,000h,000h,000h,000h,000h,000h,000h,0AAh,02Ah
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0A8h,0AAh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0AAh,0AAh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0AAh,0AAh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0AAh,0AAh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0AAh,0AAh,000h,000h,000h,000h,000h,000h,000h,000h,0AAh,0AAh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0AAh,0AAh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0AAh,0AAh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0AAh,0AAh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0AAh,0AAh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0AAh,02Fh,000h,000h,000h,000h,000h,000h,000h,000h,0F8h,0AFh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0FAh,0AFh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0FAh,0AFh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0FAh,0AFh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0FAh,0AFh,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0FAh,0AFh,000h,000h,000h,000h,000h,000h,000h,000h,0FAh,0AFh
	DB	000h,000h,000h,000h,000h,000h,000h,000h,0FAh,0AFh,000h,000h
	DB	000h,000h,000h,000h,000h,000h,0FAh,0AFh,000h,000h,000h,000h
	DB	000h,000h,000h,000h,0FAh,0AAh,000h,000h,000h,000h,000h,000h
	DB	000h,000h,0AAh,02Ah,000h,000h,000h,000h,000h,000h,000h,000h
	DB	0A8h,02Ah,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0A8h,02Ah
	DB	0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0A8h,02Ah,0AAh,0AAh
	DB	0AAh,0AAh,0AAh,0AAh,0AAh,0AAh,0A8h,02Ah,0AAh,0AAh,0AAh,0AAh
	DB	0AAh,0AAh,0AAh,0AAh,0A8h,02Ah,0AAh,0AAh,000h,000h,000h,000h
	DB	0AAh,0AAh,0A8h,02Ah,0AAh,0AAh,000h,000h,000h,000h,0AAh,0AAh
	DB	0A8h,02Ah,0AAh,0AAh,000h,000h,000h,000h,0AAh,0AAh,0A8h,02Ah
	DB	0AAh,0AAh,000h,000h,000h,000h,0AAh,0AAh,0A8h

        DW      32*48
        DB      0AAh,0AAh,000h,000h,000h,000h,0AAh
	DB	0AAh,0AAh,080h,000h,000h,000h,000h,002h,0AAh,0A8h,000h,000h
	DB	000h,000h,000h,000h,02Ah,0A0h,000h,000h,000h,000h,000h,000h
	DB	00Ah,0A0h,000h,000h,000h,000h,000h,000h,00Ah,0A0h,000h,000h
	DB	000h,000h,000h,000h,00Ah,0A0h,000h,000h,000h,000h,000h,000h
	DB	00Ah,0A0h,000h,000h,000h,000h,000h,000h,00Ah,0F0h,000h,000h
	DB	000h,000h,000h,000h,00Fh,0F0h,000h,000h,000h,000h,000h,000h
	DB	00Fh,0F0h,000h,000h,000h,000h,000h,000h,00Fh,0F0h,000h,000h
	DB	000h,000h,000h,000h,00Fh,0F0h,000h,000h,055h,055h,000h,000h
	DB	00Fh,0F0h,000h,055h,055h,055h,055h,000h,00Fh,0F0h,015h,055h
	DB	055h,055h,055h,054h,00Fh,0F1h,055h,055h,055h,055h,055h,055h
	DB	04Fh,0A1h,055h,055h,055h,055h,055h,055h,04Ah,0A1h,055h,055h
	DB	000h,000h,055h,055h,04Ah,0A0h,055h,000h,000h,000h,000h,055h
	DB	00Ah,0A8h,000h,000h,000h,000h,000h,000h,02Ah,0A9h,000h,000h
	DB	000h,000h,000h,000h,06Ah,0A9h,040h,000h,000h,000h,000h,001h
	DB	06Ah,0A9h,040h,000h,000h,000h,000h,001h,06Ah,0A9h,040h,000h
	DB	000h,000h,000h,001h,06Ah,0A9h,040h,000h,000h,000h,000h,001h
	DB	06Ah,0A9h,040h,000h,000h,000h,000h,001h,06Ah,0A9h,040h,000h
	DB	000h,000h,000h,001h,06Ah,0A9h,040h,000h,000h,000h,000h,001h
	DB	06Ah,0A9h,000h,000h,000h,000h,000h,000h,06Ah,0A8h,000h,000h
	DB	000h,000h,000h,000h,02Ah,0A8h,000h,000h,000h,000h,000h,000h
	DB	02Ah,0A0h,000h,000h,000h,000h,000h,000h,00Ah,0A0h,000h,000h
	DB	000h,000h,000h,000h,00Ah,0A0h,000h,000h,000h,000h,000h,000h
	DB	00Ah,0A0h,000h,000h,000h,000h,000h,000h,00Ah,0A0h,015h,055h
	DB	000h,000h,055h,054h,00Ah,080h,055h,055h,055h,055h,055h,055h
	DB	002h,0C0h,055h,055h,055h,055h,055h,055h,003h,0C0h,000h,015h
	DB	055h,055h,054h,000h,003h,0C0h,000h,000h,000h,000h,000h,000h
	DB	003h,0C0h,000h,000h,000h,000h,000h,000h,003h,0C0h,000h,000h
	DB	000h,000h,000h,000h,003h,0C0h,000h,000h,000h,000h,000h,000h
	DB	003h,0C0h,000h,000h,000h,000h,000h,000h,003h,0C0h,000h,000h
	DB	000h,000h,000h,000h,003h,080h,000h,000h,000h,000h,000h,000h
	DB	002h,080h,000h,000h,000h,000h,000h,000h,002h,0A0h,000h,000h
	DB	000h,000h,000h,000h,00Ah

        ;
        ;       "0"
        ;

N0      DB    00111110b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    00000000b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    00111110b

        ;
        ;       "1"
        ;

        DB    00000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    00000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    00000000b

        ;
        ;       "2"
        ;

        DB    00111110b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    00111110b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00111110b

        ;
        ;       "3"
        ;

        DB    00111110b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    00111110b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    00111110b

        ;
        ;       "4"
        ;

        DB    00000000b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    00111110b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    00000000b

        ;
        ;       "5"
        ;

        DB    00111110b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00111110b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    00111110b

        ;
        ;       "6"
        ;

        DB    00111110b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00000001b
        DB    00111110b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    00111110b

        ;
        ;       "7"
        ;

        DB    00111110b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    00000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    00000000b

        ;
        ;       "8"
        ;

        DB    00111110b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    00111110b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    00111110b

        ;
        ;       "9"
        ;

        DB    00111110b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    01000001b
        DB    00111110b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    01000000b
        DB    00111110b

        ;
        ;     "B"
        ;

        DB      00011111b
        DB      00100001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      00100001b
        DB      00011111b
        DB      00100001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      00100001b
        DB      00011111b

        ;
        ;       "C"
        ;

        DB      01111100b
        DB      00000010b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000010b
        DB      01111100b

        ;
        ;       "D"
        ;

        DB      00011111b
        DB      00100001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      00100001b
        DB      00011111b

        ;
        ;       "E"
        ;

        DB      01111111b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00111111b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      01111111b

        ;
        ;       "I"
        ;

        DB      00011100b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00011100b

        ;
        ;       "M"
        ;

        DB      01000001b
        DB      01000001b
        DB      01100011b
        DB      01100011b
        DB      01010101b
        DB      01010101b
        DB      01001001b
        DB      01001001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b

        ;
        ;       "O"
        ;

        DB      00011100b
        DB      00100010b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      00100010b
        DB      00011100b

        ;
        ;       "P"
        ;

        DB      00011111b
        DB      00100001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      00100001b
        DB      00011111b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b
        DB      00000001b

        ;
        ;       "R"
        ;

        DB      00011111b
        DB      00100001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      01000001b
        DB      00100001b
        DB      00011111b
        DB      00010001b
        DB      00010001b
        DB      00100001b
        DB      00100001b
        DB      00100001b
        DB      01000001b
        DB      01000001b
        DB      01000001b

        ;
        ;       "S"
        ;

        DB      00011100b
        DB      00100010b
        DB      01000001b
        DB      00000001b
        DB      00000001b
        DB      00000010b
        DB      00000100b
        DB      00001000b
        DB      00010000b
        DB      00100000b
        DB      01000000b
        DB      01000000b
        DB      01000000b
        DB      01000001b
        DB      00100010b
        DB      00011100b

        ;
        ;       "T"
        ;

        DB      01111111b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b
        DB      00001000b

        ;
        ;       ":"
        ;

        DB      00000000b
        DB      00000000b
        DB      00000000b
        DB      00000000b
        DB      00000000b
        DB      00011000b
        DB      00011000b
        DB      00000000b
        DB      00000000b
        DB      00000000b
        DB      00011000b
        DB      00011000b
        DB      00000000b
        DB      00000000b
        DB      00000000b
        DB      00000000b

TitleInfos      DW      20+1*16*320
                DB      _B
                DW      30+1*16*320
                DB      _E
                DW      40+1*16*320
                DB      _S
                DW      50+1*16*320
                DB      _T
                DW      255+1*16*320
                DB      _T
                DW      265+1*16*320
                DB      _I
                DW      275+1*16*320
                DB      _M
                DW      285+1*16*320
                DB      _E
                DW      250+5*16*320
                DB      _S
                DW      260+5*16*320
                DB      _P
                DW      270+5*16*320
                DB      _E
                DW      280+5*16*320
                DB      _E
                DW      290+5*16*320
                DB      _D
                DW      15+5*16*320
                DB      _S
                DW      25+5*16*320
                DB      _C
                DW      35+5*16*320
                DB      _O
                DW      45+5*16*320
                DB      _R
                DW      55+5*16*320
                DB      _E

MyName          DB      'TS.COM',0

CRLF            Equ     0dh,0ah
InitialText:    DB      CRLF,CRLF,CRLF
                DB      '                TOP SPEED'
                DB      CRLF,CRLF,CRLF
                DB      '                 2K GAME$'

TimeOverText    DB      'TIME  OVER'
NewRecordText   DB      'NEW RECORD'

CARNUMBER       Equ     62
VehicleDatas:   CAR     8175,80,0
                CAR     8000,80,0
                CAR     7875,20,1
                CAR     7725,80,0
                CAR     7500,48,0
                CAR     7475,84,0
                CAR     7225,45,1
                CAR     7025,10,0
                CAR     6800,48,0
                CAR     6900,80,1
                CAR     6625,10,0
                CAR     6525,80,0
                CAR     6400,84,1
                CAR     6300,10,0
                CAR     6175,10,0
                CAR     6050,84,1
                CAR     6000,48,0
                CAR     5825,10,0
                CAR     5750,40,0
                CAR     5525,84,1
                CAR     5375,10,0
                CAR     5250,80,0
                CAR     5125,10,0
                CAR     5025,40,1
                CAR     4900,80,1
                CAR     4750,10,0
                CAR     4550,50,0
                CAR     4400,10,0
                CAR     4275,84,1
                CAR     4100,48,0
                CAR     4075,84,0
                CAR     3825,20,1
                CAR     3675,40,0
                CAR     3425,80,0
                CAR     3350,60,1
                CAR     3325,80,0
                CAR     3200,10,0
                CAR     3025,70,0
                CAR     2800,10,0
                CAR     2650,40,1
                CAR     2500,10,0
                CAR     2300,80,2
                CAR     2328,84,3
                CAR     2380,84,3
                CAR     2250,90,1
                CAR     2150,10,0
                CAR     2000,80,0
                CAR     1800,10,0
                CAR     1625,40,1
                CAR     1500,80,0
                CAR     1375,40,1
                CAR     1275,10,0
                CAR     1225,40,0
                CAR     1075,80,0
                CAR     975,10,1
                CAR     900,10,0
                CAR     700,80,0
                CAR     500,48,1
                CAR     550,48,1
                CAR     350,84,0
                CAR     250,10,0
                CAR     175,40,0

maprms          DW      0A40h,8060h,8080h,02B0h
AccSound        DB      25,230
                DB      61,133
                DB      97,99
                DB      157,67
                DB      255,61

Acceleration    DB      97,1
                DB      154,3
                DB      188,9
                DB      213,17
                DB      229,29
                DB      255,71

DEFAULT         DW      0
                DD      0
                DW      0
                DW      40
                DB      GAMETIME
                DB      50
                DB      80h
                DB      80h
                DB      80h
                DB      80h
                DB      80h
                DD      0

BestScore       DW      0

ksgm            DW      ?
kofs            DW      ?
cdivr           DB      ?
t100            DW      ?
sync            DB      ?
sync2           DB      ?
sync3           DB      ?
sync4           DB      ?
myps            DB      ?

SidePosition    DW      ?
dscore          DD      ?
                Org     $-2
Score           DW      ?
Speed           DW      ?
carhor          DW      ?
time            DB      ?
ts3             DB      ?
up              DB      ?
down            DB      ?
left            DB      ?
right           DB      ?
esc_            DB      ?
CarPosOffset    DD      ?

                org     8000h
Sprites:
xmot            DB      20*37  dup(?)
xcar            DB      32*48  dup(?)
xcam            DB      40*136 dup(?)
xcar2           DB      32*48  dup(?)

TopSpeed        Ends
                End     START