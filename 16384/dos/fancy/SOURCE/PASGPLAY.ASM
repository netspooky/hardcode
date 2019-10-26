        Comment &
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        Gus play routine V 1.5 by Robert Adolfsson - CASCADA
        Not for release!  <- Really?  Why was it on ftp.uwp.edu then?
                             And it even came with a text file from Cascada
                             Spooky.

        NoiseTracker/SoundTracker/StarTrekker/FastTracker/OctaComposer
        compatible


        Hacked for Turbo/Borland Pascal interfacing by Juggler/BTL.
        I also fixed some spelling errors, added and altered comments.
        Send me mail at bre@os.is or chat with me on the IRC.

        AND!!  I added the Renaissance code in here somewhere.. one big
        happy bit of assembler.  Find it by scanning for "Renaissance", or
        just the next Comment.  My code is at the very end of the file.
        (Copyrighted too!  :-P nyah nyah nyah..)

        ..Tabs should be set to 8 spaces..
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        &

        Jumps
        .286
        .model tpascal
        .CODE

;       Publics

;Public  MainVolume,PlayingPattern,RealPPattern,PatternRow,RealRow,OrderLen,ChanOn,NumChans,Time,SampChans,Bar,BasePort,ErrorCode

Public  ClearMem, StartPlaying, StopPlaying, InitDevice, Init
Public  U_Peek, U_Poke, U_SetFreq, U_SetBalance, U_SetVolume, U_SetLoopMode
Public  U_StopVoice, U_StartVoice, U_ReadPos, U_ChangeInOut
Public  U_DumpSampleToDRAM, U_DumpDRAMToMemory
Public  GetVariables, LoadModule, ProtSampAdd, ProtSampPlay, ProtSampPop

;       Structures

ChanSize        Equ 52
ChanInfo        Struc
        SampOff         dd 0
        FreqVal         dw 0
        Vol             dw 0
        OldVol          dw 0
        Fine            dw 0
        Repeat          dw 0
        RepLen          dw 0
        Len             dw 0
        Amiga           dw 0
        Effect          dw 0
        VibratoPek      dw 0
        OldVibrato      dw 0
        PortTo          dw 0
        OldPortTo       dw 0
        EffectTime      dw 0
        CurrSamp        dw 0
        OldSamp         dw 0
        Arp             dw 0,0,0
        ArpCounter      dw 0
        InstSet         dw 0
        LoopOnOff       dw 0
        OffsetAdd       dw 0
        Bar             dw 0
ChanInfo        EndS

; Pointers to local data, for the Pascal interface.
;
ProgData        Struc
        BasePortP       dd 0    ; GUS Base port
        ErrorP          dd 0    ; Error codes..
        VarP            dd 0    ; Misc variables, following MainVolume
        TimerP          dd 0    ; Timer
        GMemP           dd 0    ; Top of .MOD samples
        GMemProtP       dd 0    ; Top of protected samples
        ChanInfoP       dd 0    ; An array of ChanInfo structs (0..7?)
        GusVolP         dd 0    ; Pointer to the volume table
                                ; Module sample data (arrays of 0..31)
        MSOffset        dd 0    ;       Offset in GUS mem
        MSLen           dd 0    ;       Sample length
        MSVol           dd 0    ;       Sample volume
        MSRep           dd 0    ;       Loop beginning (ofs from MSOffset)
        MSRepLen        dd 0    ;       Loop length
                                ; Protected sample data (arrays of 0..63)
        PSOffset        dd 0    ;       Offset in GUS mem
        PSLen           dd 0    ;       Sample length
        PSVol           dd 0    ;       Sample volume
        PSRep           dd 0    ;       Loop beginning (ofs from PSOffset)
        PSRepLen        dd 0    ;       Loop length
ProgData        EndS

; UltraSound Ports

StatusPort      Equ 6h
TimerCtrlPort   Equ 8h
TimerDataPort   Equ 9h
MidiCtrlPort    Equ 100h
MidiDataPort    Equ 101h
ActiveVoicePort Equ 102h
CommandPort     Equ 103h
DataLowPort     Equ 104h
DataHighPort    Equ 105h
DRAMIOPort      Equ 107h

; UltraSound Commands

WriteVoiceMode  Equ 00h
SetVoiceFreq    Equ 01h         ; Value=Freq/Divisor
LoopStartLo     Equ 02h
LoopStartHi     Equ 03h
SampleEndLo     Equ 04h
SampleEndHi     Equ 05h
VolRampRate     Equ 06h
VolRampStart    Equ 07h
VolRampEnd      Equ 08h
SetVolume       Equ 09h
SampleStartLo   Equ 0Ah
SampleStartHi   Equ 0Bh
VoiceBalance    Equ 0Ch
VolumeCtrl      Equ 0Dh
VoicesActive    Equ 0Eh
DMACtrl         Equ 41h
DRAMAddrLo      Equ 43h
DRAMAddrHi      Equ 44h
TimerCtrl       Equ 45h
TimerCount1     Equ 46h
TimerCount2     Equ 47h
SampleFreq      Equ 48h
SampleCtrl      Equ 49h
Initialize      Equ 4Ch
Read            Equ 80h
ReadVolume      Equ Read+SetVolume      ; 89h
VoicePosLo      Equ Read+SampleStartLo  ; 8Ah
VoicePosHi      Equ Read+SampleStartHi  ; 8Bh
ReadVolCtrl     Equ Read+VolumeCtrl     ; 8Dh
IRQStatus       Equ 8Fh

; Divisors

Voices14        Equ 4300
Voices15        Equ 4000
Voices16        Equ 3700
Voices17        Equ 3500
Voices18        Equ 3300
Voices19        Equ 3100
Voices20        Equ 3030
Voices21        Equ 2800
Voices22        Equ 2700
Voices23        Equ 2600
Voices24        Equ 2500
Voices25        Equ 2400
Voices26        Equ 2300
Voices27        Equ 2200
Voices28        Equ 2100
Voices29        Equ 2000
Voices30        Equ 2000
Voices31        Equ 1900
Voices32        Equ 1800

; Number of voices to use

NumVoices       Equ 20
DivVoices       Equ Voices20

;       Variables

MKSign          db 'M.K.'
MKMod           db 0
FilePos         dw 0
ModSeg          dw 0
ModSamples      dw 0
ModPatterns     dw 0
SampleMemBuf    dw 0
Info            db 1084 dup (0)
Waveform        db 256 dup (0)
OrderLen        db 0
Restart         db 0
PatternOrder    db 128 dup (0)
SinTab          db 0,25,50,74,98,120,142,162,180,197,212,225,236
                db 244,250,254,255,254,250,244,236,225,212,197,180
                db 162,142,120,98,74,50,25

ArpTable        db 70,70,70,70,70,70,70,70,70,70,70,70,70,70,70
                db 70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70
                db 70,70,70,70,70,70,70,70,70,70,70,70,70,70,70
                db 70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,70,68,68,68,68,68,68,68,66,66,66,66,66,66,66,64,64,64,64,64,64,64,64,62,62,62,62,62,62,62,62,60,60,60,60,60,60,60,60,58,58,58,58,58,58
                db 58,58,58,56,56,56,56,56,56,56,56,56,56,54,54
                db 54,54,54,54,54,54,54,54,52,52,52,52,52,52,52,52,52,52,50,50,50,50,50,50,50,50,50,50,50,50,48,48,48,48,48,48,48,48,48,48,48,48,46,46,46,46,46,46,46,46,46,46,46,46,44,44,44,44,44,44,44,44,44,44
                db 44,44,44,44,42,42,42,42,42,42,42,42,42,42,42
                db 42,42,42,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,36,34,34,34,34,34,34,34,34,34,34,34,34,34
                db 34,34,34,34,34,32,32,32,32,32,32,32,32,32,32
                db 32,32,32,32,32,32,32,32,32,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,28,26,26,26,26,26,26,26,26,26,26,26,26,26
                db 26,26,26,26,26,26,26,26,26,26,24,24,24,24,24
                db 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,22,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20,20
                db 20,20,20,20,20,20,20,18,18,18,18,18,18,18,18
                db 18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,14,14,14,14,14,14,14,14,14,14,14,14,14,14
                db 14,14,14,14,14,14,14,14,14,14,14,14,14,14,14
                db 14,14,14,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10
                db 10,10,10,10,10,10,10,10,10,8,8,8,8,8,8,8,8,8
                db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
                db 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,2,2,2,2,2,2
                db 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

PanRegs         db 6,8,8,6 ,7,7,7,7,7,7,7,7,7,7,7,7
                db 6,6,8,8,8,6 ,7,7,7,7,7,7,7,7,7,7
                db 6,6,8,8,8,8,6,6 ,7,7,7,7,7,7,7,7

EvenData

AmigaVals       dw 856,808,762,720,678,640,604,570,538,508,480,453 ;C-1 to B-1 Finetune +0.
                dw 428,404,381,360,339,320,302,285,269,254,240,226 ;C-2 to B-2 Finetune +0.
                dw 214,202,190,180,170,160,151,143,135,127,120,113 ;C-3 to B-3 Finetune +0.

                dw 850,802,757,715,674,637,601,567,535,505,477,450 ;C-1 to B-1 Finetune +1.
                dw 425,401,379,357,337,318,300,284,268,253,239,225 ;C-2 to B-2 Finetune +1.
                dw 213,201,189,179,169,159,150,142,134,126,119,113 ;C-3 to B-3 Finetune +1.

                dw 844,796,752,709,670,632,597,563,532,502,474,447 ;C-1 to B-1 Finetune +2.
                dw 422,398,376,355,335,316,298,282,266,251,237,224 ;C-2 to B-2 Finetune +2.
                dw 211,199,188,177,167,158,149,141,133,125,118,112 ;C-3 to B-3 Finetune +2.

                dw 838,791,746,704,665,628,592,559,528,498,470,444 ;C-1 to B-1 Finetune +3.
                dw 419,395,373,352,332,314,296,280,264,249,235,222 ;C-2 to B-2 Finetune +3.
                dw 209,198,187,176,166,157,148,140,132,125,118,111 ;C-3 to B-3 Finetune +3.

                dw 832,785,741,699,660,623,588,555,524,495,467,441 ;C-1 to B-1 Finetune +4.
                dw 416,392,370,350,330,312,294,278,262,247,233,220 ;C-2 to B-2 Finetune +4.
                dw 208,196,185,175,165,156,147,139,131,124,117,110 ;C-3 to B-3 Finetune +4.

                dw 826,779,736,694,655,619,584,551,520,491,463,437 ;C-1 to B-1 Finetune +5.
                dw 413,390,368,347,328,309,292,276,260,245,232,219 ;C-2 to B-2 Finetune +5.
                dw 206,195,184,174,164,155,146,138,130,123,116,109 ;C-3 to B-3 Finetune +5.

                dw 820,774,730,689,651,614,580,547,516,487,460,434 ;C-1 to B-1 Finetune +6.
                dw 410,387,365,345,325,307,290,274,258,244,230,217 ;C-2 to B-2 Finetune +6.
                dw 205,193,183,172,163,154,145,137,129,122,115,109 ;C-3 to B-3 Finetune +6.

                dw 814,768,725,684,646,610,575,543,513,484,457,431 ;C-1 to B-1 Finetune +7.
                dw 407,384,363,342,323,305,288,272,256,242,228,216 ;C-2 to B-2 Finetune +7.
                dw 204,192,181,171,161,152,144,136,128,121,114,108 ;C-3 to B-3 Finetune +7.

                dw 907,856,808,762,720,678,640,604,570,538,504,480 ;C-1 to B-1 Finetune -8.
                dw 453,428,404,381,360,339,320,302,285,269,254,240 ;C-2 to B-2 Finetune -8.
                dw 226,214,202,190,180,170,160,151,143,135,127,120 ;C-3 to B-3 Finetune -8.

                dw 900,850,802,757,715,675,636,601,567,535,505,477 ;C-1 to B-1 Finetune -7.
                dw 450,425,401,379,357,337,318,300,284,268,253,238 ;C-2 to B-2 Finetune -7.
                dw 225,212,200,189,179,169,159,150,142,134,126,119 ;C-3 to B-3 Finetune -7.

                dw 894,844,796,752,709,670,632,597,563,532,502,474 ;C-1 to B-1 Finetune -6.
                dw 447,422,398,376,355,335,316,298,282,266,251,237 ;C-2 to B-2 Finetune -6.
                dw 223,211,199,188,177,167,158,149,141,133,125,118 ;C-3 to B-3 Finetune -6.

                dw 887,838,791,746,704,665,628,592,559,528,498,470 ;C-1 to B-1 Finetune -5.
                dw 444,419,395,373,352,332,314,296,280,264,249,235 ;C-2 to B-2 Finetune -5.
                dw 222,209,198,187,176,166,157,148,140,132,125,118 ;C-3 to B-3 Finetune -5.

                dw 881,832,785,741,699,660,623,588,555,524,494,467 ;C-1 to B-1 Finetune -4.
                dw 441,416,392,370,350,330,312,294,278,262,247,233 ;C-2 to B-2 Finetune -4.
                dw 220,208,196,185,175,165,156,147,139,131,123,117 ;C-3 to B-3 Finetune -4.

                dw 875,826,779,736,694,655,619,584,551,520,491,463 ;C-1 to B-1 Finetune -3.
                dw 437,413,390,368,347,338,309,292,276,260,245,232 ;C-2 to B-2 Finetune -3.
                dw 219,206,195,184,174,164,155,146,138,130,123,116 ;C-3 to B-3 Finetune -3.

                dw 868,820,774,730,689,651,614,580,547,516,487,460 ;C-1 to B-1 Finetune -2.
                dw 434,410,387,365,345,325,307,290,274,258,244,230 ;C-2 to B-2 Finetune -2.
                dw 217,205,193,183,172,163,154,145,137,129,122,115 ;C-3 to B-3 Finetune -2.

                dw 862,814,768,725,684,646,610,575,543,513,484,457 ;C-1 to B-1 Finetune -1.
                dw 431,407,384,363,342,323,305,288,272,256,242,228 ;C-2 to B-2 Finetune -1.
                dw 216,203,192,181,171,161,152,144,136,128,121,114 ;C-3 to B-3 Finetune -1.

GusVol          dw 20000,39120,41376,42656,43936,45072,45696,46240,46848,47408
                dw 47952,48528,49072,49360,49632,49920,50160,50432,50704,50928
                dw 51168,51424,51680,51952,52160,52448,52672,52912,53152,53312
                dw 53440,53584,53664,53808,53952,54048,54144,54288,54400,54496
                dw 54608,54720,54832,54944,55072,55184,55312,55440,55552,55696
                dw 55760,55888,56016,56096,56240,56304,56448,56528,56672,56752
                dw 56896,56976,57136,57216

SampOffset      dd 31 dup (0)
SampLen         dw 31 dup (0)
SampVol         dw 31 dup (0)
SampFine        dw 31 dup (0)
SampRep         dw 31 dup (0)
SampRepLen      dw 31 dup (0)

ProtSampOffset  dd 63 dup (0)
ProtSampLen     dw 63 dup (0)
ProtSampVol     dw 63 dup (0)
ProtSampRep     dw 63 dup (0)
ProtSampRepLen  dw 63 dup (0)

; MainVolume,PlayingPattern,RealPPattern,PatternRow,RealRow
; ChanOn,NumChans,ProtSampNum,ProtMainVolume,NextVoice

MainVolume      dw 64
PlayingPattern  dw 0
RealPPattern    dw 0
PatternRow      dw 0
RealRow         dw 0
ChanOn          dw 0FFh
NumChans        dw 4                    ; 4,6 or 8 (Default = 4)
ProtSampNum     dw 0                    ; Number of protected samples.
ProtMainVolume  dw 64
NextVoice       dw 8                    ; Next voice 2 use 4 playback (prot)

BasePort        dw 220h                 ; Default GUS base address
ErrorCode       dw 0

ChanOnCount     dw 0
PatternSpeed    dw 0
PatternCount    dw 0
TempVol         dw 0

FreqTable       dw 908 dup (0)

PatternPek      equ this DWord
BytePattern     dw 0
SegPattern      dw 0

SampMem         dw 0
PatternMem      dw 0
BreakData       dw 0
OldTimer        dd 0
GUSMemProt      dd 0                    ; Top of protected sample data
GUSMem          dd 0                    ; Top of module sample data
Speed           dd 0
SpeedAdd        dd 0
Counter         dw 0
Time            dd 0
JumpOldTimer    dw 0

SampChans       ChanInfo 8 dup (<>)


;       Macros

NopLoop         Macro   Nops
Local   NopLoop

        push    cx
        mov     cx,Nops
NopLoop:
        nop
        loop    NopLoop
        pop     cx

                EndM


;       The Code

Pattern         Proc    Near

        pusha
        push    ds
        push    es

        mov     ax,cs
        mov     ds,ax

        mov     al,20h
        out     20h,al
        sti

        clc
        add     Word Ptr [Time],1
        adc     Word Ptr [Time+2],0

        inc     [Counter]
        mov     ax,Word Ptr [Speed+2]
        clc
        add     Word Ptr [SpeedAdd+2],ax
        mov     ax,Word Ptr [Speed]
        adc     Word Ptr [SpeedAdd],ax
        jc      JumpPattern
        cmp     [Counter],4
        je      ClearNotes
        cmp     [Counter],5
        je      SetNotes
        jmp     EndPattern

ClearNotes:
        mov     di,offset [SampChans]
        mov     cx,[NumChans]
        mov     dx,[BasePort]
        add     dx,CommandPort

StopVoices:
        dec     dx
        mov     al,Byte Ptr [NumChans]
        sub     al,cl
        out     dx,al
        inc     dx

        cmp     [di.InstSet],2
        je      VoiceOff1
        cmp     [di.InstSet],1
        je      VoiceOff2
        cmp     [di.OffsetAdd],0
        jne     VoiceOff1
        jmp     NoVoiceOff

VoiceOff2:
        mov     ax,[di.CurrSamp]
        cmp     ax,[di.OldSamp]
        jne     VoiceOff1
        jmp     NoVoiceOff

VoiceOff1:
        mov     ax,[di.OldVol]
        mov     [di.OldVol],0
        mov     bx,[MainVolume]
        mul     bx
        shr     ax,6
        adc     ax,0
        mov     bx,ax
        shl     bx,1
        mov     bx,[GusVol+bx]

        mov     dx,[BasePort]
        add     dx,CommandPort

        mov     al,VolumeCtrl
        out     dx,al
        add     dx,2
        mov     al,3
        out     dx,al
        sub     dx,2

        mov     bp,[GusVol]
        mov     ah,0
        cmp     bx,bp
        jb      NoFixVolDir1
        mov     ah,01000000b
        xchg    bx,bp
NoFixVolDir1:

        mov     al,VolRampStart
        out     dx,al
        xchg    ax,bx
        inc     dx
        out     dx,ax
        dec     dx

        mov     al,VolRampEnd
        out     dx,al
        mov     ax,bp
        inc     dx
        out     dx,ax
        dec     dx

        mov     al,VolumeCtrl
        out     dx,al
        mov     al,bh
        add     dx,2
        out     dx,al
        sub     dx,2
NoVoiceOff:

        add     di,ChanSize
        dec     cx
        jnz     StopVoices
        jmp     EndPattern

SetNotes:
        mov     [Counter],1
        mov     di,offset [SampChans]
        mov     cx,[NumChans]
        mov     dx,[BasePort]
        add     dx,CommandPort

ChangeSamps:
        dec     dx
        mov     al,Byte Ptr [NumChans]
        sub     al,cl
        out     dx,al
        inc     dx

        cmp     [di.InstSet],2
        je      SampChange1
        cmp     [di.InstSet],1
        je      SampChange2
        cmp     [di.OffsetAdd],0
        jne     ChangeOffset
        jmp     NoChangeSamp

ChangeOffset:
        mov     al,SampleStartLo
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        mov     bp,Word Ptr [di.SampOff+2]
        add     ax,[di.OffsetAdd]
        adc     bp,0
        shr     ax,7
        shl     bp,9
        or      ax,bp
        out     dx,ax
        dec     dx
        mov     al,SampleStartHi
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        add     ax,[di.OffsetAdd]
        shl     ax,9
        out     dx,ax
        dec     dx
        sub     dx,CommandPort
        Rept    6
        in      al,dx
        EndM
        add     dx,CommandPort
        jmp     NoChangeSamp

SampChange1:
        mov     al,WriteVoiceMode
        out     dx,al
        add     dx,2
        mov     al,3
        out     dx,al
        sub     dx,DataHighPort
        Rept    6
        in      al,dx
        EndM
        add     dx,CommandPort

        mov     al,SampleStartLo
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        mov     bp,Word Ptr [di.SampOff+2]
        add     ax,[di.OffsetAdd]
        adc     bp,0
        shr     ax,7
        shl     bp,9
        or      ax,bp
        out     dx,ax
        dec     dx
        mov     al,SampleStartHi
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        add     ax,[di.OffsetAdd]
        shl     ax,9
        out     dx,ax
        sub     dx,DataLowPort
        Rept    6
        in      al,dx
        EndM
        add     dx,CommandPort

        mov     ax,[di.OldSamp]
        cmp     ax,[di.CurrSamp]
        je      NoChangeSamp

        mov     al,SampleEndLo
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        mov     bp,Word Ptr [di.SampOff+2]
        add     ax,[di.Len]
        adc     bp,0
        shr     ax,7
        shl     bp,9
        or      ax,bp
        out     dx,ax
        dec     dx
        mov     al,SampleEndHi
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        add     ax,[di.Len]
        shl     ax,9
        out     dx,ax
        dec     dx

        mov     al,LoopStartLo
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        mov     bp,Word Ptr [di.SampOff+2]
        add     ax,[di.Repeat]
        adc     bp,0
        shr     ax,7
        shl     bp,9
        or      ax,bp
        out     dx,ax
        dec     dx
        mov     al,LoopStartHi
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        add     ax,[di.Repeat]
        shl     ax,9
        out     dx,ax
        dec     dx

        mov     al,WriteVoiceMode
        out     dx,al
        add     dx,2
        mov     al,3
        out     dx,al
        sub     dx,2
        jmp     NoChangeSamp

SampChange2:
        mov     ax,[di.OldSamp]
        cmp     ax,[di.CurrSamp]
        je      NoChangeSamp

        mov     al,VoicePosLo
        out     dx,al
        inc     dx
        in      ax,dx
        mov     bx,ax
        dec     dx
        mov     al,VoicePosHi
        out     dx,al
        inc     dx
        in      ax,dx
        dec     dx
        xchg    ax,bx
        shl     ax,7
        shr     bx,9
        and     bx,7Fh
        or      ax,bx
        mov     bx,[di.OldSamp]
        dec     bx
        shl     bx,2
        sub     ax,Word Ptr [SampOffset+bx]
        mov     bx,ax
        cmp     bx,[di.Len]
        jb      NoFixStart
        mov     bx,[di.Len]
        dec     bx
NoFixStart:

        cmp     [di.OffsetAdd],0
        jne     NoOffsetEff
        mov     [di.OffsetAdd],bx
NoOffsetEff:

        mov     al,SampleStartLo
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        mov     bp,Word Ptr [di.SampOff+2]
        add     ax,[di.OffsetAdd]
        adc     bp,0
        shr     ax,7
        shl     bp,9
        or      ax,bp
        out     dx,ax
        dec     dx
        mov     al,SampleStartHi
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        add     ax,[di.OffsetAdd]
        shl     ax,9
        out     dx,ax
        sub     dx,DataLowPort
        Rept    6
        in      al,dx
        EndM
        add     dx,CommandPort

        mov     al,SampleEndLo
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        mov     bp,Word Ptr [di.SampOff+2]
        add     ax,[di.Len]
        adc     bp,0
        shr     ax,7
        shl     bp,9
        or      ax,bp
        out     dx,ax
        dec     dx
        mov     al,SampleEndHi
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        add     ax,[di.Len]
        shl     ax,9
        out     dx,ax
        dec     dx

        mov     al,LoopStartLo
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        mov     bp,Word Ptr [di.SampOff+2]
        add     ax,[di.Repeat]
        adc     bp,0
        shr     ax,7
        shl     bp,9
        or      ax,bp
        out     dx,ax
        dec     dx
        mov     al,LoopStartHi
        out     dx,al
        inc     dx
        mov     ax,Word Ptr [di.SampOff]
        add     ax,[di.Repeat]
        shl     ax,9
        out     dx,ax
        dec     dx

        mov     al,WriteVoiceMode
        out     dx,al
        add     dx,2
        mov     al,Byte Ptr [di.LoopOnOff]
        out     dx,al
        sub     dx,DataHighPort
        Rept    6
        in      al,dx
        EndM
        add     dx,CommandPort
NoChangeSamp:

        mov     ax,[di.Vol]
        cmp     ax,[di.OldVol]
        je      NoSetBar
        mov     [di.Bar],ax
NoSetBar:

        mov     [TempVol],ax
        mov     ax,[Counter]
        test    [ChanOn],ax
        jnz     NoChanOff
        mov     [TempVol],0
        mov     [di.Bar],0
NoChanOff:

        mov     ax,[di.OldVol]
        mov     bx,[MainVolume]
        mul     bx
        shr     ax,6
        adc     ax,0
        mov     bx,ax
        shl     bx,1
        mov     bx,[GusVol+bx]
        mov     ax,[TempVol]
        mov     bp,[MainVolume]
        mul     bp
        shr     ax,6
        adc     ax,0
        mov     bp,ax
        shl     bp,1
        mov     bp,[GusVol+bp]

        mov     dx,bp
        mov     dl,bh
        cmp     dl,dh
        jne     SetVol

        mov     dx,[BasePort]
        add     dx,CommandPort

        mov     al,VolumeCtrl
        out     dx,al
        add     dx,2
        mov     al,3
        out     dx,al
        sub     dx,2

        mov     al,SetVolume
        out     dx,al
        mov     ax,bp
        inc     dx
        out     dx,ax
        dec     dx
        jmp     NoSetVol

SetVol:
        mov     dx,[BasePort]
        add     dx,CommandPort

        mov     al,VolumeCtrl
        out     dx,al
        add     dx,2
        mov     al,3
        out     dx,al
        sub     dx,2

        mov     ah,0
        cmp     bx,bp
        jb      NoFixVolDir
        mov     ah,01000000b
        xchg    bx,bp
NoFixVolDir:

        mov     dx,[BasePort]
        add     dx,CommandPort
        mov     al,VolRampStart
        out     dx,al
        xchg    ax,bx
        inc     dx
        out     dx,ax
        dec     dx

        mov     al,VolRampEnd
        out     dx,al
        mov     ax,bp
        inc     dx
        out     dx,ax
        dec     dx

        mov     al,VolumeCtrl
        out     dx,al
        mov     al,bh
        add     dx,2
        out     dx,al
        sub     dx,2
NoSetVol:

        mov     al,SetVoiceFreq
        out     dx,al
        inc     dx
        mov     ax,[di.FreqVal]
        out     dx,ax
        dec     dx

        shl     [Counter],1
        add     di,ChanSize
        dec     cx
        jnz     ChangeSamps

        mov     di,offset [SampChans]
        mov     cx,[NumChans]

StartVoices:
        dec     dx
        mov     al,Byte Ptr [NumChans]
        sub     al,cl
        out     dx,al
        inc     dx

        cmp     [di.InstSet],2
        jne     NoVoiceStart

        mov     al,WriteVoiceMode
        out     dx,al
        add     dx,2
        mov     al,Byte Ptr [di.LoopOnOff]
        out     dx,al
        sub     dx,DataHighPort
        Rept    6
        in      al,dx
        EndM
        add     dx,CommandPort
NoVoiceStart:

        mov     [di.InstSet],0
        mov     [di.OffsetAdd],0

        add     di,ChanSize
        dec     cx
        jnz     StartVoices
        jmp     EndPattern

JumpPattern:

        mov     [Counter],0

        dec     Word Ptr [PatternCount]
        jnz     DoEffects
        jmp     DoPattern
DoEffects:

        mov     di,offset [SampChans]
        mov     cx,[NumChans]

EffectLoop:

        mov     ax,[di.Vol]
        mov     [di.OldVol],ax

        inc     [di.EffectTime]
        add     [di.ArpCounter],2
        cmp     [di.ArpCounter],6
        jb      NoWrapArp
        mov     [di.ArpCounter],0
NoWrapArp:
        mov     ax,[di.Effect]
        cmp     ax,0
        jne     DoEffect
        jmp     NoEffect
DoEffect:
        mov     bl,al
        mov     bh,0
        cmp     bl,0Eh
        je      DoEEffects
        shl     bx,1
        jmp     cs:[EffectJumps+bx]
DoEEffects:
        mov     bl,ah
        and     ah,0Fh
        shr     bl,4
        shl     bx,1
        jmp     cs:[EEffectJumps+bx]
Arpeggio:
;        mov     bx,[di.ArpCounter]
;        mov     bx,[di.Arp+bx]
;        shl     bx,1
;        mov     ax,Word Ptr [FreqTable+bx]
;        mov     [di.FreqVal],ax
        jmp     NoEffect
PortUp:
        xchg    ah,al
        mov     ah,0
        mov     bp,[di.Fine]
        mov     bp,[AmigaVals+35*2+bp]
        mov     bx,[di.Amiga]
        sub     bx,ax
        jnc     NoFix1
        mov     bx,bp
NoFix1:
        cmp     bx,bp
        jae     NotSmall1
        mov     bx,bp
NotSmall1:
        mov     [di.Amiga],bx
        shl     bx,1
        mov     ax,[FreqTable+bx]
        mov     [di.FreqVal],ax
        jmp     NoEffect
PortDown:
        xchg    ah,al
        mov     ah,0
        mov     bp,[di.Fine]
        mov     bp,[AmigaVals+bp]
        mov     bx,[di.Amiga]
        add     bx,ax
        cmp     bx,bp
        jbe     NotBig1
        mov     bx,bp
NotBig1:
        mov     [di.Amiga],bx
        shl     bx,1
        mov     ax,[FreqTable+bx]
        mov     [di.FreqVal],ax
        jmp     NoEffect
PortToTone:
        xchg    ah,al
        xor     ah,ah
        mov     dx,[di.PortTo]
        mov     bx,[di.Amiga]
        cmp     bx,dx
        jae     NoPortToUp
        add     bx,ax
        cmp     bx,dx
        jna     NoPortToUp
        mov     [di.Amiga],dx
NoPortToUp:
        cmp     bx,dx
        jbe     NoPortToDown
        sub     bx,ax
        jnc     NoPortToError
        mov     bx,dx
NoPortToError:
        cmp     bx,dx
        jnb     NoPortToDown
        mov     bx,dx
NoPortToDown:
        mov     [di.Amiga],bx
        shl     bx,1
        mov     ax,[FreqTable+bx]
        mov     [di.FreqVal],ax
        jmp     NoEffect
Vibrato:
;        mov     bp,[di.Fine]
;        mov     si,[AmigaVals+bp]
;        mov     bp,[AmigaVals+35*2+bp]
;        mov     dl,ah
;        and     ah,0F0h
;        shr     ah,2
;        and     dl,0Fh
;        mov     bl,Byte Ptr [di.VibratoPek]
;        add     bl,ah
;        mov     Byte Ptr [di.VibratoPek],bl
;        shr     bl,2
;        and     bx,1Fh
;        mov     al,[SinTab+bx]
;        mul     dl
;        rol     ax,1
;        xchg    ah,al
;        and     ah,1
;        test    Byte Ptr [di.VibratoPek],128
;        jne     VibUp1
;        neg     ax
VibUp1:
;        add     ax,[di.Amiga]
;        cmp     ax,bp
;        jae     NoHighVibrato1
;        mov     ax,bp
NoHighVibrato1:
;        cmp     ax,si
;        jbe     NoLowVibrato1
;        mov     ax,si
NoLowVibrato1:
;        shl     ax,1
;        mov     bx,ax
;        mov     ax,[FreqTable+bx]
;        mov     [di.FreqVal],ax
        jmp     NoEffect
PortToVSlide:
;        mov     al,ah
;        and     ah,0Fh
;        shr     al,4
;        sub     ah,al
;        mov     al,Byte Ptr [di.Vol]
;        sub     al,ah
;        jns     NoSlideLow2
;        mov     al,0
NoSlideLow2:
;        cmp     al,40h
;        jb      NoSlideHigh2
;        mov     al,3Fh
NoSlideHigh2:
;        mov     Byte Ptr [di.Vol],al
;        mov     ax,[di.OldPortTo]
;        mov     dx,[di.PortTo]
;        mov     bx,[di.Amiga]
;        cmp     bx,dx
;        jae     NoPortToUp2
;        add     bx,ax
;        cmp     bx,dx
;        jna     NoPortToUp2
;        mov     [di.Amiga],dx
NoPortToUp2:
;        cmp     bx,dx
;        jbe     NoPortToDown2
;        sub     bx,ax
;        jnc     NoPortToError2
;        mov     bx,0
NoPortToError2:
;        cmp     bx,dx
;        jnb     NoPortToDown2
;        mov     bx,dx
NoPortToDown2:
;        mov     [di.Amiga],bx
;        shl     bx,1
;        mov     ax,Word Ptr [FreqTable+bx]
;        mov     [di.FreqVal],ax
        jmp     NoEffect
VibratoVSlide:
;        mov     al,ah
;        and     ah,0Fh
;        shr     al,4
;        sub     ah,al
;        mov     al,Byte Ptr [di.Vol]
;        sub     al,ah
;        jns     NoSlideLow3
;        mov     al,0
NoSlideLow3:
;        cmp     al,40h
;        jb      NoSlideHigh3
;        mov     al,3Fh
NoSlideHigh3:
;        mov     Byte Ptr [di.Vol],al
;        mov     bp,[di.Fine]
;        mov     si,[AmigaVals+bp]
;        mov     bp,[AmigaVals+35*2+bp]
;        mov     ah,Byte Ptr [di.OldVibrato]
;        or      ah,Byte Ptr [di.OldVibrato+1]
;        mov     dl,ah
;        and     ah,0F0h
;        shr     ah,2
;        and     dl,0Fh
;        mov     bl,Byte Ptr [di.VibratoPek]
;        add     bl,ah
;        mov     Byte Ptr [di.VibratoPek],bl
;        shr     bl,2
;        and     bx,1Fh
;        mov     al,[SinTab+bx]
;        mul     dl
;        rol     ax,1
;        xchg    ah,al
;        and     ah,1
;        test    Byte Ptr [di.VibratoPek],128
;        jne     VibUp2
;        neg     ax
VibUp2:
;        add     ax,[di.Amiga]
;        cmp     ax,bp
;        jae     NoHighVibrato2
;        mov     ax,bp
NoHighVibrato2:
;        cmp     ax,si
;        jbe     NoLowVibrato2
;        mov     ax,si
NoLowVibrato2:
;        shl     ax,1
;        mov     bx,ax
;        mov     ax,[FreqTable+bx]
;        mov     [di.FreqVal],ax
        jmp     NoEffect
VolSlide:
        mov     al,ah
        and     ah,0Fh
        shr     al,4
        cmp     al,0
        je      NoVolSlideUp
        neg     al
        mov     ah,al
NoVolSlideUp:
        mov     al,Byte Ptr [di.Vol]
        sub     al,ah
        jns     NoSlideLow1
        mov     al,0
NoSlideLow1:
        cmp     al,40h
        jb      NoSlideHigh1
        mov     al,3Fh
NoSlideHigh1:
        mov     Byte Ptr [di.Vol],al
        jmp     NoEffect
RetrigNote:
        cmp     ah,Byte Ptr [di.EffectTime]
        jne     NoRetrig
        mov     [di.EffectTime],0
        mov     [di.InstSet],2
NoRetrig:
        jmp     NoEffect
CutNote:
        cmp     ah,Byte Ptr [di.EffectTime]
        jne     NoCutNote
        mov     [di.Amiga],0
        mov     [di.FreqVal],0
NoCutNote:
        jmp     NoEffect
DelayNote:
        cmp     ah,Byte Ptr [di.EffectTime]
        jne     NoDelayNote
        mov     [di.InstSet],2
        mov     [di.VibratoPek],0
        mov     bx,[di.PortTo]
        mov     [di.Amiga],bx
        shl     bx,1
        mov     bx,[FreqTable+bx]
        mov     [di.FreqVal],bx
NoDelayNote:
        jmp     NoEffect
NoEffect:

        add     di,ChanSize
        dec     cx
        jz      EndEffects
        jmp     EffectLoop
EndEffects:
        jmp     EndPattern

DoPattern:
        mov     ax,[PatternSpeed]
        mov     [PatternCount],ax
        cmp     [PatternRow],64
        jb      NoPatternWrap
        mov     ax,[PlayingPattern]
        cmp     al,[OrderLen]
        jb      NoTrackWrap
        mov     ax,0
        cmp     [Restart],78h
        jae     NoRestart
        mov     al,[Restart]
NoRestart:
        mov     [PlayingPattern],ax
NoTrackWrap:
        mov     bx,[PlayingPattern]
        mov     [RealPPattern],bx
        inc     [RealPPattern]
        mov     ah,0
        mov     al,[PatternOrder+bx]
        mov     dx,[NumChans]
        shl     dx,8
        mul     dx
        shl     dx,12
        add     dx,[PatternMem]
        mov     [SegPattern],dx
        mov     [BytePattern],ax
        mov     ax,[BreakData]
        mov     [PatternRow],ax
        shl     ax,4
        add     [BytePattern],ax
        mov     [BreakData],0
        inc     [PlayingPattern]
NoPatternWrap:

        les     si,[PatternPek]
        mov     di,offset [SampChans]
        mov     cx,[NumChans]
        mov     ax,[PatternRow]
        mov     [RealRow],ax

PattLoop:

        mov     ax,[di.Vol]
        mov     [di.OldVol],ax

        mov     bh,es:[si]              ; New Sample
        mov     bl,es:[si+2]
        and     bh,0F0h
        shr     bl,4
        add     bl,bh
        je      NoNewSample
        mov     bh,Byte Ptr [di.CurrSamp]
        mov     Byte Ptr [di.OldSamp],bh
        mov     Byte Ptr [di.CurrSamp],bl
        mov     bh,0
        dec     bx
        shl     bx,1
        mov     ax,[SampVol+bx]
        cmp     ax,40h
        jb      NoHighVol
        mov     ax,3Fh
NoHighVol:
        mov     [di.Vol],ax
        mov     [di.InstSet],1
        shl     bx,1
        mov     ax,Word Ptr [SampOffset+bx]
        mov     Word Ptr [di.SampOff],ax
        mov     ax,Word Ptr [SampOffset+bx+2]
        mov     Word Ptr [di.SampOff+2],ax
        shr     bx,1
        mov     ax,[SampFine+bx]
        shl     ax,3
        mov     [di.Fine],ax
        shl     ax,3
        add     [di.Fine],ax
        mov     [di.LoopOnOff],0
        mov     ax,[SampLen+bx]
        mov     [di.Len],ax
        mov     ax,[SampRep+bx]
        mov     [di.Repeat],ax
        mov     ax,[SampRepLen+bx]
        mov     [di.RepLen],ax
        cmp     ax,2
        jbe     NoNewSample
        mov     [di.LoopOnOff],8
        mov     ax,[di.Repeat]
        add     ax,[di.RepLen]
        cmp     ax,[di.Len]
        ja      NoNewSample
        mov     [di.Len],ax
NoNewSample:

        mov     bx,es:[si]
        xchg    bh,bl
        and     bx,0FFFh
        je      NoNewNote

        mov     bl,[ArpTable+bx]
        mov     bh,0
        add     bx,[di.Fine]
        mov     bx,[AmigaVals+bx]
        mov     [di.PortTo],bx
        mov     ax,es:[si+2]
        and     al,0Fh
        and     ah,0F0h
        cmp     al,03h
        je      PortToP
        cmp     al,05h
        je      PortToP
        jmp     NoPortToP
PortToP:
        push    cx
        neg     cx
        add     cx,[NumChans]
        mov     ax,1
        shl     ax,cl
        test    ax,[ChanOn]
        je      NoSetPortBar
        mov     ax,[di.Vol]
        mov     [di.Bar],ax
NoSetPortBar:
        pop     cx
        jmp     NoNewNote
NoPortToP:
        cmp     ax,0D00Eh
        jne     NewNote
        mov     al,es:[si+2]
        cmp     al,0
        je      NewNote
        mov     [di.InstSet],0
        jmp     NoNewNote
NewNote:
        mov     [di.InstSet],2
        mov     [di.VibratoPek],0
        mov     [di.Amiga],bx
        shl     bx,1
        mov     bx,[FreqTable+bx]
        mov     [di.FreqVal],bx
NoNewNote:

        mov     [di.ArpCounter],0
        mov     ax,es:[si+2]
        and     al,0Fh
        mov     [di.Effect],ax
        cmp     al,7
        jb      NoSetOldFreq
        mov     bx,ax
        and     bh,0F0h
        cmp     bx,0C00Eh
        je      NoSetOldFreq
        cmp     bx,0D00Eh
        je      NoSetOldFreq
        mov     bx,[di.Amiga]
        shl     bx,1
        mov     bx,[FreqTable+bx]
        mov     [di.FreqVal],bx
NoSetOldFreq:
        mov     bh,0
        mov     bl,al
        cmp     bl,0Eh
        je      DoEPattEffects
        shl     bx,1
        jmp     cs:[PattJumps+bx]
DoEPattEffects:
        mov     bl,ah
        and     ah,0Fh
        shr     bl,4
        shl     bx,1
        jmp     cs:[EPattJumps+bx]
ArpeggioFix:
        mov     bx,[di.Amiga]
        mov     bl,[ArpTable+bx]
        mov     bh,0
        mov     bp,bx
        add     bx,[di.Fine]
        mov     dx,[AmigaVals+bx]
        mov     [di.Arp],dx
        xchg    ah,al
        mov     ah,0
        mov     dx,ax
        shr     dx,4
        and     ax,0Fh
        shl     dx,1
        shl     ax,1
        mov     bx,bp
        add     bx,dx
        cmp     bx,70
        jbe     NoWrapArp1
        mov     bx,70
NoWrapArp1:
        add     bx,[di.Fine]
        mov     dx,[AmigaVals+bx]
        mov     [di.Arp+2],dx
        mov     bx,bp
        add     bx,ax
        cmp     bx,70
        jbe     NoWrapArp2
        mov     bx,70
NoWrapArp2:
        add     bx,[di.Fine]
        mov     dx,[AmigaVals+bx]
        mov     [di.Arp+4],dx
        jmp     NoPattEffect
PortToFix:
        cmp     ah,0
        jne     NoPortPekFix
        mov     ah,Byte Ptr [di.OldPortTo]
NoPortPekFix:
        mov     Byte Ptr [di.OldPortTo],ah
        mov     Byte Ptr [di.Effect+1],ah
        jmp     NoPattEffect
VibratoFix:
        mov     al,ah
        and     al,0Fh
        and     ah,0F0h
        cmp     al,0
        jne     NoVibratoFix1
        mov     al,Byte Ptr [di.OldVibrato]
NoVibratoFix1:
        cmp     ah,0
        jne     NoVibratoFix2
        mov     ah,Byte Ptr [di.OldVibrato+1]
NoVibratoFix2:
        mov     Byte Ptr [di.OldVibrato],al
        mov     Byte Ptr [di.OldVibrato+1],ah
        or      al,ah
        mov     Byte Ptr [di.Effect+1],al
        jmp     NoPattEffect
SampleOff:
        mov     al,0
        cmp     ax,[di.Len]
        jb      NoFixOffset
        mov     ax,[di.Len]
        dec     ax
NoFixOffset:
        mov     [di.OffsetAdd],ax
        jmp     NoPattEffect
PosJump:
        mov     [PatternRow],63
        mov     Byte Ptr [PlayingPattern],ah
        jmp     NoPattEffect
Volume:
        cmp     ah,40h
        jb      NoFixVol1
        mov     ah,3Fh
NoFixVol1:
        mov     Byte Ptr [di.Vol],ah
        jmp     NoPattEffect
BreakPatt:
        mov     [PatternRow],63
        cmp     ah,64h
        jb      NoFixBreak
        mov     ah,63h
NoFixBreak:
        mov     al,ah
        and     al,0Fh
        shr     ah,4
        shl     ah,1
        mov     Byte Ptr [BreakData],al
        add     Byte Ptr [BreakData],ah
        shl     ah,2
        add     Byte Ptr [BreakData],ah
        jmp     NoPattEffect
SpeedSet:
        cmp     ah,0
        je      NoPattEffect
        cmp     ah,1Fh
        jbe     UsualSpeed

        xchg    ah,al
        mov     ah,0
        shl     ax,1                    ;
        mov     bl,5                    ; Denna bit 꼛 f봱 att st꼕la
        div     bl                      ; Effects till annat 꼗 50Hz
        mov     dl,al                   ; Detta ger automatiskt en annan
        mov     dh,0                    ; patternspeed.; Hz=2*BPM/5
        mov     ax,0
        mov     bx,1000
        div     bx
        mov     Word Ptr cs:[Speed],ax
        mov     ax,0
        div     bx
        mov     Word Ptr cs:[Speed+2],ax
        jmp     NoPattEffect
UsualSpeed:
        mov     Byte Ptr [PatternSpeed],ah
        mov     Byte Ptr [PatternCount],ah
        jmp     NoPattEffect
FinePortUp:
        xchg    ah,al
        mov     ah,0
        sub     [di.Amiga],ax
        mov     bx,[di.Fine]
        mov     bx,[AmigaVals+35*2+bx]
        cmp     [di.Amiga],bx
        jae     NoFixFineUp
        mov     [di.Amiga],bx
NoFixFineUp:
        jmp     NoPattEffect
FinePortDown:
        xchg    ah,al
        mov     ah,0
        add     [di.Amiga],ax
        mov     bx,[di.Fine]
        mov     bx,[AmigaVals+bx]
        cmp     [di.Amiga],bx
        jbe     NoFixFineDown
        mov     [di.Amiga],bx
NoFixFineDown:
        jmp     NoPattEffect
FineVolUp:
        add     Byte Ptr [di.Vol],ah
        cmp     Byte Ptr [di.Vol],3Fh
        jbe     NoFixFineVolUp
        mov     Byte Ptr [di.Vol],3Fh
NoFixFineVolUp:
        jmp     NoPattEffect
FineVolDown:
        sub     Byte Ptr [di.Vol],ah
        jnc     NoFixFineVolDown
        mov     Byte Ptr [di.Vol],0
NoFixFineVolDown:
        jmp     NoPattEffect
NoPattEffect:

        add     si,4
        jnc     NoChangeSeg1
        mov     dx,es
        add     dx,1000h
        mov     es,dx
NoChangeSeg1:
        mov     [di.EffectTime],0
        add     di,ChanSize
        dec     cx
        jz      EndChannels
        jmp     PattLoop
EndChannels:

        inc     [PatternRow]
        mov     ax,[NumChans]
        shl     ax,2
        add     [BytePattern],ax
        jnc     EndPattern
        add     [SegPattern],1000h
EndPattern:

        dec     [JumpOldTimer]
        jnz     NoJumpOld
        mov     [JumpOldTimer],55
        pop     es
        pop     ds
        popa
        jmp     DWord Ptr cs:[OldTimer]
NoJumpOld:
        pop     es
        pop     ds
        popa
        iret

Pattern         EndP

PattJumps       dw offset cs:[ArpeggioFix]      ; 0
                dw offset cs:[NoPattEffect]     ; 1
                dw offset cs:[NoPattEffect]     ; 2
                dw offset cs:[PortToFix]        ; 3
                dw offset cs:[VibratoFix]       ; 4
                dw offset cs:[NoPattEffect]     ; 5
                dw offset cs:[NoPattEffect]     ; 6
                dw offset cs:[NoPattEffect]     ; 7
                dw offset cs:[NoPattEffect]     ; 8
                dw offset cs:[SampleOff]        ; 9
                dw offset cs:[NoPattEffect]     ; A
                dw offset cs:[PosJump]          ; B
                dw offset cs:[Volume]           ; C
                dw offset cs:[BreakPatt]        ; D
                dw offset cs:[NoPattEffect]     ; E
                dw offset cs:[SpeedSet]         ; F

EPattJumps      dw offset cs:[NoPattEffect]     ; 0
                dw offset cs:[FinePortUp]       ; 1
                dw offset cs:[FinePortDown]     ; 2
                dw offset cs:[NoPattEffect]     ; 3
                dw offset cs:[NoPattEffect]     ; 4
                dw offset cs:[NoPattEffect]     ; 5
                dw offset cs:[NoPattEffect]     ; 6
                dw offset cs:[NoPattEffect]     ; 7
                dw offset cs:[NoPattEffect]     ; 8
                dw offset cs:[NoPattEffect]     ; 9
                dw offset cs:[FineVolUp]        ; A
                dw offset cs:[FineVolDown]      ; B
                dw offset cs:[NoPattEffect]     ; C
                dw offset cs:[NoPattEffect]     ; D
                dw offset cs:[NoPattEffect]     ; E
                dw offset cs:[NoPattEffect]     ; F

EffectJumps     dw offset cs:[Arpeggio]         ; 0
                dw offset cs:[PortUp]           ; 1
                dw offset cs:[PortDown]         ; 2
                dw offset cs:[PortToTone]       ; 3
                dw offset cs:[Vibrato]          ; 4
                dw offset cs:[PortToVSlide]     ; 5
                dw offset cs:[VibratoVSlide]    ; 6
                dw offset cs:[NoEffect]         ; 7
                dw offset cs:[NoEffect]         ; 8
                dw offset cs:[NoEffect]         ; 9
                dw offset cs:[VolSlide]         ; A
                dw offset cs:[NoEffect]         ; B
                dw offset cs:[NoEffect]         ; C
                dw offset cs:[NoEffect]         ; D
                dw offset cs:[NoEffect]         ; E
                dw offset cs:[NoEffect]         ; F

EEffectJumps    dw offset cs:[NoEffect]         ; 0
                dw offset cs:[NoEffect]         ; 1
                dw offset cs:[NoEffect]         ; 2
                dw offset cs:[NoEffect]         ; 3
                dw offset cs:[NoEffect]         ; 4
                dw offset cs:[NoEffect]         ; 5
                dw offset cs:[NoEffect]         ; 6
                dw offset cs:[NoEffect]         ; 7
                dw offset cs:[NoEffect]         ; 8
                dw offset cs:[RetrigNote]       ; 9
                dw offset cs:[NoEffect]         ; A
                dw offset cs:[NoEffect]         ; B
                dw offset cs:[CutNote]          ; C
                dw offset cs:[DelayNote]        ; D
                dw offset cs:[NoEffect]         ; E
                dw offset cs:[NoEffect]         ; F

        assume  ds:nothing

StartPlaying    Proc    Far

        pusha
        push    ds
        push    es

        cli

        mov     [JumpOldTimer],55
        mov     di,offset cs:[SampChans]
        mov     cx,cs:[NumChans]
ClearVarLoop:
        mov     cs:[di.FreqVal],0
        mov     cs:[di.Vol],0
        add     di,ChanSize
        loop    ClearVarLoop

        mov     ax,0
        mov     es,ax

        mov     bx,es:[20h]
        mov     ax,es:[22h]
        mov     Word Ptr cs:[OldTimer],bx
        mov     Word Ptr cs:[OldTimer+2],ax

        push    cs
        pop     ds
        mov     dx,offset cs:[Pattern]

        mov     es:[20h],dx
        mov     es:[22h],ds

        mov     al,36h
        out     43h,al
        mov     al,169
        out     40h,al
        mov     al,4
        out     40h,al

        mov     ax,0
        mov     dx,50
        mov     bx,1000
        div     bx
        mov     Word Ptr cs:[Speed],ax
        mov     ax,0
        div     bx
        mov     Word Ptr cs:[Speed+2],ax
        mov     Word Ptr cs:[SpeedAdd],0
        mov     Word Ptr cs:[SpeedAdd+2],0
        mov     [Counter],20
        mov     Word Ptr [Time],0
        mov     Word Ptr [Time+2],0

;        mov     dx,cs:[BasePort]        ; Speaker On!!!
;        mov     al,00000001b
;        out     dx,al

        sti

        pop     es
        pop     ds
        popa
        ret

StartPlaying    EndP

StopPlaying     Proc    Far

        pusha
        push    ds
        push    es

        cli

;       mov     dx,cs:[BasePort]        ; Speaker Off!!!
;       mov     al,00000011b
;       out     dx,al                   ; We don't REALLY want to
                                        ; turn it off.. do we?
        mov     ax,0
        mov     es,ax

        mov     al,36h
        out     43h,al
        mov     al,0
        out     40h,al
        mov     al,0
        out     40h,al

        mov     dx,Word Ptr cs:[OldTimer]
        mov     ds,Word Ptr cs:[OldTimer+2]
        mov     es:[20h],dx
        mov     es:[22h],ds
        sti

        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
;       mov     cx,NumVoices            ; Wouldn't wanna turn of the SFX..
        mov     cx,cs:[NumChans]
VoiceClearL:
        mov     al,cl
        dec     al
        out     dx,al
        inc     dx
        mov     al,0
        out     dx,al
        add     dx,2
        mov     al,3    ; Voice Off
        out     dx,al
        sub     dx,2
        mov     al,0Dh
        out     dx,al
        add     dx,2
        mov     al,3    ; Ramp Off
        out     dx,al
        sub     dx,3
        loop    VoiceClearL

        pop     es
        pop     ds
        popa
        ret

StopPlaying     EndP

Init            Proc    Far

        pusha
        push    ds
        push    es
        mov     cs:[PatternRow],64
        mov     cs:[PlayingPattern],0
        mov     cs:[PatternSpeed],6
        mov     cs:[PatternCount],1
        pop     es
        pop     ds
        popa
        ret

Init            EndP

InitDevice      Proc    Far

        pusha
        push    es
        push    ds

        mov     si,108*2
        mov     bp,108
        mov     cx,908-108+1
CountLoop:
        mov     dx,36h
        mov     ax,9DE4h
        div     bp
        mov     dx,100
        mul     dx
        mov     bx,DivVoices
        div     bx
        shr     bx,1
        adc     bx,0
        cmp     dx,bx
        jb      NoHigherFreq
        inc     ax
NoHigherFreq:
        mov     Word Ptr cs:[FreqTable+si],ax
        inc     bp
        add     si,2
        loop    CountLoop

;       Init the UltraSound

        cli
        mov     bx,cs:[BasePort]
        mov     cx,bx
        mov     dx,bx
        mov     al,00000011b
        out     dx,al            ; Speaker off...
        add     bx,CommandPort
        add     cx,DataHighPort
        mov     dx,bx
        mov     al,Initialize
        out     dx,al
        mov     dx,cx
        mov     al,00000000b
        out     dx,al           ; Enter RESET state.
        mov     dx,cs:[BasePort]
        Rept    6
        in      al,dx
        EndM
        mov     dx,bx
        mov     al,Initialize
        out     dx,al
        mov     dx,cx
        mov     al,00000001b
        out     dx,al           ; Deactivate RESET state.
        mov     dx,cs:[BasePort]
        Rept    6
        in      al,dx
        EndM

        mov     dx,bx
        mov     al,DMACtrl
        out     dx,al
        mov     dx,cx
        mov     al,0
        out     dx,al           ; Turn off DMA stuff
        mov     dx,bx
        mov     al,TimerCtrl   ; 45h
        out     dx,al
        mov     dx,cx
        mov     al,0
        out     dx,al           ; Turn off timer IRQ's
        mov     dx,bx
        mov     al,SampleCtrl  ; 49h
        out     dx,al
        mov     dx,cx
        mov     al,0
        out     dx,al           ; Disable sampling

        mov     dx,bx
        mov     al,VoicesActive
        out     dx,al
        mov     dx,cx
        mov     al,NumVoices
        dec     al
        or      al,0C0h
        out     dx,al           ; Set active voices

        mov     dx,cs:[BasePort]
        add     dx,StatusPort
        in      al,dx
        mov     dx,bx
        mov     al,DMACtrl
        out     dx,al
        mov     dx,cx
        in      al,dx
        mov     dx,bx
        mov     al,SampleCtrl
        out     dx,al
        mov     dx,cx
        in      al,dx
        mov     dx,bx
        mov     al,IRQStatus    ; 8Fh
        out     dx,al
        mov     dx,cx
        in      al,dx

        push    cx
        mov     cx,32
VoiceClearLoop:
        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
        mov     al,cl
        dec     al
        out     dx,al
        inc     dx
        mov     al,0
        out     dx,al
        add     dx,2
        mov     al,3    ; Voice Off
        out     dx,al
        sub     dx,2
        mov     al,VolumeCtrl
        out     dx,al
        add     dx,2
        mov     al,3    ; Ramp Off
        out     dx,al
        loop    VoiceClearLoop
        pop     cx

        mov     dx,bx
        mov     al,DMACtrl
        out     dx,al
        mov     dx,cx
        in      al,dx
        mov     dx,bx
        mov     al,SampleCtrl
        out     dx,al
        mov     dx,cx
        in      al,dx
        mov     dx,bx
        mov     al,IRQStatus
        out     dx,al
        mov     dx,cx
        in      al,dx

        mov     dx,bx
        mov     al,Initialize
        out     dx,al
        mov     dx,cx
        mov     al,00000011b    ; Reset off, DAC on, IRQs OFF.
        out     dx,al

        mov     cx,NumVoices
SetRampRateLoop:
        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
        mov     al,NumVoices
        sub     al,cl
        out     dx,al

        mov     dx,cs:[BasePort]
        add     dx,CommandPort
        mov     al,VolRampRate
        out     dx,al
        mov     al,00111111b
        mov     dx,cs:[BasePort]
        add     dx,DataHighPort
        out     dx,al

        mov     dx,cs:[BasePort]
        add     dx,CommandPort
        mov     al,SetVolume
        out     dx,al
        mov     ax,cs:[GusVol]
        mov     dx,cs:[BasePort]
        add     dx,DataLowPort
        out     dx,ax
        loop    SetRampRateLoop

        mov     dx,cs:[BasePort]
        mov     al,00000000b
        out     dx,al           ; Speaker On!  (and line-in enabled)
        sti

;       Finished Initialize (Pheewww!!!!!!!!!!!!!)

        pop     ds
        pop     es
        popa
        ret

InitDevice      EndP

ClearMem        Proc    Far

        pusha
        push    es
        mov     es,cs:[PatternMem]
        call    DeAlloc
        pop     es
        popa
        ret

ClearMem        EndP

LoadMod         Proc    Near
; Error if CF set! ax=errorcode.
; ax=1, File or path not found.
; ax=2, Error loading file.
; ax=3, Out of memory.

        call    ModLoad
        ret

LoadMod         EndP

ModLoad         Proc    Near

        pusha
        push    ds
        push    es

        mov     cs:[MainVolume],64
        mov     cx,1084
        mov     dx,offset cs:[Info]
        push    cs
        pop     ds
        call    FileRead
        mov     cs:[NumChans],4
        mov     bp,offset cs:[Info+1080]
        mov     bx,0
        mov     si,offset cs:[Info+952]
        mov     cs:[MKMod],1

Load:
        mov     ax,cs:[si-2]
        mov     Word Ptr cs:[OrderLen],ax
        mov     di,offset cs:[PatternOrder]
        mov     cx,128
CopyOrder:
        mov     al,cs:[si]
        mov     cs:[di],al
        inc     si
        inc     di
        loop    CopyOrder
        mov     si,offset cs:[PatternOrder]
        mov     cx,128
        mov     ax,0
CheckPatt:
        mov     al,cs:[si]
        cmp     al,ah
        jb      NoHigh
        xchg    ah,al
NoHigh:
        inc     si
        loop    CheckPatt
        inc     ah
        xor     al,al
        mov     bx,cs:[NumChans]
        mul     bx
        mov     si,dx
        mov     di,ax
        ; Align patterns to segment boundary
        mov     ax,ModPatterns
        shr     ax,4
        add     ax,ModSeg
        add     ax,43h
        mov     cs:[PatternMem],ax
        mov     ds,ax

LoadLoop:
        dec     si
EndBigLoad:
        mov     cx,di
        mov     dx,0
        call    FileRead

        mov     cx,31
NoMK:
        mov     ax,SampleMemBuf
        mov     cs:[SampMem],ax
        push    ax
        mov     ax, Word Ptr cs:[GUSMemProt]
        mov     Word Ptr cs:[GUSMem], ax
        mov     ax, Word Ptr cs:[GUSMemProt+2]
        mov     Word Ptr cs:[GUSMem+2], ax
        pop     ax
        mov     si,offset cs:[Info+42]
        mov     bp,0
LoadIns:
        push    cx
        mov     Word Ptr cs:[SampLen+bp],0
        mov     cx,cs:[si]
        add     si,2
        xchg    ch,cl
        cmp     cx,2
        jbe     NoIns
        shl     cx,1
        mov     cs:[SampLen+bp],cx
        mov     ds,cs:[SampMem]
        mov     dx,0
        ; generate sample instead of load it
        ; cx - sample length
        ; ds:dx - sample address
        call    SampleGen

;       Lets move the sample to the UltraSound!

        push    bp
        mov     cx,cs:[SampLen+bp]
        shl     bp,1
        mov     di,Word Ptr cs:[GUSMem]
        mov     bl,Byte Ptr cs:[GUSMem+2]
        mov     Word Ptr [SampOffset+bp],di
        mov     Byte Ptr [SampOffset+bp+2],bl
        mov     bp,di
        mov     di,0
        mov     dx,cs:[BasePort]
        add     dx,CommandPort
MSamp2GUS:
        mov     al,DRAMAddrLo
        out     dx,al
        inc     dx
        mov     ax,bp
        out     dx,ax
        dec     dx
        mov     al,DRAMAddrHi
        out     dx,al
        add     dx,2
        mov     al,bl
        out     dx,al
        add     dx,2
        mov     al,[di]
        out     dx,al
        sub     dx,4
        inc     di
        add     bp,1
        adc     bl,0
        loop    MSamp2GUS
        dec     di
        mov     al,DRAMAddrLo
        out     dx,al
        inc     dx
        mov     ax,bp
        out     dx,ax
        dec     dx
        mov     al,DRAMAddrHi
        out     dx,al
        add     dx,2
        mov     al,bl
        out     dx,al
        add     dx,2
        mov     al,[di]
        out     dx,al
        sub     dx,4
        add     bp,1
        adc     bl,0
        mov     Word Ptr cs:[GUSMem],bp
        mov     Byte Ptr cs:[GUSMem+2],bl
        pop     bp

NoIns:
        mov     ah,0
        mov     al,cs:[si]
        inc     si
        mov     cs:[SampFine+bp],ax
        mov     al,cs:[si]
        inc     si
        mov     Byte Ptr cs:[SampVol+bp],al

        mov     dx,cs:[SampLen+bp]
        mov     ax,cs:[si]
        add     si,2
        xchg    ah,al
        mov     cx,cs:[si]
        add     si,2
        xchg    ch,cl
        shl     ax,1
        shl     cx,1
STMod1:
        mov     cs:[SampRepLen+bp],cx
        add     cx,ax
        cmp     cx,dx
        jbe     NoRepFix
        mov     cx,dx
        sub     cx,ax
        mov     cs:[SampRepLen+bp],cx
NoRepFix:
        mov     cs:[SampRep+bp],ax

        add     si,22
        add     bp,2
        pop     cx
        dec     cx
        jz      Loaded
        jmp     LoadIns
Loaded:
        mov     es,cs:[SampMem]
;        call    DeAlloc
        mov     cs:[ErrorCode],0
        clc

;       Set Pan Regs!!

ErrorLoad:
        mov     cx,cs:[NumChans]
        mov     bx,cx
        shr     bx,1
        sub     bx,2
        shl     bx,4
        mov     cx,16                   ; Bjarni
SetPanLoop:
        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
        mov     al,Byte Ptr cs:[NumChans]
        sub     al,cl
        out     dx,al

        mov     dx,cs:[BasePort]
        add     dx,CommandPort
        mov     al,VoiceBalance
        out     dx,al
        mov     dx,cs:[BasePort]
        add     dx,DataHighPort
        mov     al,cs:[PanRegs+bx]
        out     dx,al
        inc     bx
        loop    SetPanLoop

        pop     es
        pop     ds
        popa
        ret

ModLoad         EndP

Alloc           Proc    Near

        push    bx
        mov     ax,4800h
        int     21h
        pop     bx
        ret

Alloc           EndP

DeAlloc         Proc    Near

        push    ax
        push    es
        mov     ax,4900h
        int     21h
        pop     es
        pop     ax
        ret

DeAlloc         EndP

; Generate sample to ds:dx
.386
SampleGen Proc Near
          pusha
          push es
          push ds
          mov si,ModSamples
          mov di,dx
          push ds
          pop es
          mov ax,ModSeg
          mov ds,ax
          ; Now ds:si - sample generator data; es:di - output
          mov dl,[si+2] ; Oscillators count
          mov cx,[si]  ; Sample length
          xor ax,ax
          pusha
          rep stosb   ; Clear sample data
          popa
          add si,4
@AddOsc:  push dx
          push di
          ; Generate primary waveform to es:di
          pusha
          push es
          push cs
          pop es
          mov di,offset WaveForm
          cmp byte ptr [si],0
          jne @Noise
          ; generate sine-based waveform
          push si
          mov al,[si+1] ; parameter
          cbw
          shr al,1
          mov bl,5
          sub bl,al ; bl=5-p/2
          mov ah,48
          imul ah ; ax=(p/2)*48
          mov si,di
          movsx edx,bl
          movsx ebx,ax
          xor eax,eax
          xor cx,cx
@02:      push ax
          mov es:[di],ah
          not ah
          mov es:[si+255],ah
          pop ax
          add eax,ebx
          add ebx,edx
          inc di
          dec si
          inc cl
          jno @02

          pop si
          jmp @EndWave

@noise:   ; copy 256 bytes of noise
          mov cx,256
          push si
          mov si,offset @01-64
@01:      mov al,cs:[si]
          stosb
          inc si
          loop @01
          pop si
@EndWave: pop es
          popa
          ; Now let's mix wave
          xor bx,bx ; v
          xor dx,dx ; x
@03:      ; main loop
          ; addval:=(WaveForm[(v div 4) and $ff]*EnvF[i] div 128)
          pusha
          shr bx,2
          xor bh,bh
          add bx,offset Waveform
          mov bl,cs:[bx]
          push bx
          mov bx,11
          call IntFunc
          pop bx
          imul bl
          shl ax,1
          add es:[di],ah
          popa
          inc di
          ; d:=PitF[i]
          push bx
          mov bx,2
          call IntFunc
          pop bx
          add bx,ax

          inc dx
          cmp dx,cx
          jne @03

          add si,20
          mov ModSamples,si
          pop di
          pop dx
          dec dl
          jnz @AddOsc

          pop ds
          pop es
          popa
          ret
SampleGen Endp

; Get interpolated value
; Input: dx - x, cx - length, bx - data offset (actual data is at ds:[si+bx])
; Output: ax
IntFunc  proc near
         pusha
         mov ax,dx
         push dx
         xor dx,dx
         shr cx,3
         div cx
         add bx,ax
         mul cx
         pop dx
         sub dx,ax ; now dx is a frac part of x
         mov ax,[si+bx]
         mov bl,al
         sub ah,al
         mov al,ah
         cbw
         imul dx
         idiv cx
         add al,bl
         cbw
         mov result,ax
         popa
         mov ax,result
         ret
result   dw 0
IntFunc  endp

FileRead        Proc    Near

        pusha
        push ds
        push es
        mov si,FilePos
        add FilePos,cx
        add si,ModPatterns
        push ds
        pop es
        push ModSeg
        pop ds
        mov di,dx
        rep movsb
        pop es
        pop ds
        popa
        ret

FileRead        EndP

MovePoint       Proc    Near

        mov FilePos,0
        ret

MovePoint       EndP

        Comment &
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

        These are the GUS routines distributed by Renaissance..
        Slightly modified to work with the rest of it of course.

                -- Juggler

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        &

UDelay          Proc    Near
        push    dx
        push    ax
        mov     dx,300h
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        in      al,dx
        pop     ax
        pop     dx
        ret
UDelay          EndP

; CX:AX  - Number
; Destroys BX
RShift          Proc    Near
        mov     bx,cx
        shr     ax,7
        shr     cx,7
        shl     bx,9
        or      ax,bx
        ret
RShift          EndP

; BX:CX Set to whatever.
; AL Set set to value at BX:CX
; AH Destroyed
U_Peek          Proc    Far
        push    dx
        mov     dx,cs:[BasePort]
        add     dx,CommandPort
        mov     al,43h
        out     dx,al
        inc     dx                      ; DataLowPort
        mov     ax,cx
        out     dx,ax
        dec     dx                      ; CommandPort
        mov     al,44h
        out     dx,al
        add     dx,2
        mov     al,bl
        out     dx,al
        add     dx,2
        in      al,dx
        pop     dx
        ret
U_Peek          EndP

; BX:CX Set to whatever.
; AX Value to poke
U_Poke          Proc    Far
        push    dx
        push    ax
        mov     dx,cs:[BasePort]
        add     dx,CommandPort
        mov     al,DRAMAddrLo
        out     dx,al
        inc     dx              ; DataLowPort
        mov     ax,cx
        out     dx,ax
        dec     dx              ; CommandPort
        mov     al,DRAMAddrHi
        out     dx,al
        add     dx,2            ; DataHighPort
        mov     al,bl
        out     dx,al
        add     dx,2            ; DRAMIOPort
        pop     ax
        out     dx,al
        pop     dx
        ret
U_Poke          EndP

; BX - Voice
; AX - Frequency
; Destroys CX, DX
U_SetFreq       Proc    Far     ; Close enough for me...
        xor     dx,dx
        mov     cx,DivVoices/100
        div     cx
        push    ax
        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
        mov     ax,bx
        out     dx,al
        inc     dx              ; CommandPort
        mov     al,1
        out     dx,al
        inc     dx              ; DataLowPort
        pop     ax
        out     dx,ax
        ret
U_SetFreq       EndP

; AX - Voice
; BX - Balance (0-f) 7 is middle
; Destroys DX
U_SetBalance    Proc    Far
        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
        out     dx,al
        inc     dx
        mov     al,VoiceBalance
        out     dx,al
        add     dx,2
        mov     ax,bx
        out     dx,al
        ret
U_SetBalance    EndP

; AX - Voice
; BX - Volume
; Destroys DX
U_SetVolume     Proc    Far
        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
        out     dx,al
        inc     dx              ; CommandPort
        mov     al,SetVolume
        out     dx,al
        inc     dx              ; DataLowPort
        mov     ax,bx
        out     dx,ax
        ret
endp    U_SetVolume

; AX - Voice
; BX - Mode
;          bit 0: 0=voice on (along with bit 1)
;          bit 1: 0=voice on (along with bit 0)
;          bit 2: 0=8 bit data, 1=16 bit data
;          bit 3: 0=No loop, 1=Loop
;          bit 4: 0=Go forward, 1=Go backward
U_SetLoopMode   Proc    Far
        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
        out     dx,al
        inc     dx              ; CommandPort
        mov     al,80h
        add     dx,2            ; DataHighPort
        in      al,dx
        mov     bh,al
        sub     dx,2            ; CommandPort
        xor     al,al
        out     dx,al
        add     dx,2            ; DataHighPort
        and     bh,0E7h
        or      bh,bl
        mov     al,bh
        out     dx,al
        ret
U_SetLoopMode   EndP

; AX - Voice
; Destroys DX, BX
U_StopVoice     Proc    Far
        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
        out     dx,al
        inc     dx              ; CommandPort
        mov     al,80h
        add     dx,2            ; DataHighPort
        in      al,dx
        mov     bh,al
        sub     dx,2            ; CommandPort
        xor     al,al
                out     dx,al
        add     dx,2            ; DataHighPort
        mov     al,bh
        and     bh,0DFh
        or      al,3
        out     dx,al
        call    UDelay
        sub     dx,2            ; CommandPort
        xor     al,al
        out     dx,al
        add     dx,2            ; DataHighPort
        mov     al,bh
        and     bh,0DFh
        or      al,3
        out     dx,al
        ret
U_StopVoice      EndP


_SampleBegin    dd      0       ; Start location in DRAM
                                ; (apparently 32-byte aligned) NOT!
_SampleStart    dd      0       ; Start location of loop
_SampleEnd      dd      0       ; End of sample

; AX - Voice
; BX - Mode
_U_StartVoice    Proc    Near
        push    bx
        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
        out     dx,al
; ***** Send sample begin
        inc     dx              ; CommandPort 103h
        mov     al,SampleStartLo
        out     dx,al
        inc     dx              ; DataLowPort 104h
        mov     ax,Word Ptr cs:[_SampleBegin]
        mov     cx,Word Ptr cs:[_SampleBegin+2]
        call    RShift
        out     dx,ax
        dec     dx              ; CommandPort 103h
        mov     al,SampleStartHi
        out     dx,al
        inc     dx              ; DataLowPort 104h
        mov     ax,Word Ptr cs:[_SampleBegin]
        shl     ax,9
        out     dx,ax
; ***** Send sample start
        dec     dx              ; CommandPort 103h
        mov     al,2
                out     dx,al
        inc     dx              ; DataLowPort 104h
        mov     ax,Word Ptr cs:[_SampleStart]
        mov     cx,Word Ptr cs:[_SampleStart+2]
        call    RShift
        out     dx,ax
        dec     dx              ; CommandPort 103h
        mov     al,3
        out     dx,al
        inc     dx              ; DataLowPort 104h
        mov     ax,Word Ptr cs:[_SampleStart]
        shl     ax,9
        out     dx,ax
; ***** Send sample end
        dec     dx              ; CommandPort 103h
        mov     al,4
        out     dx,al
        inc     dx              ; DataLowPort 104h
        mov     ax,Word Ptr cs:[_SampleEnd]
        mov     cx,Word Ptr cs:[_SampleEnd+2]
        call    RShift
        out     dx,ax
        dec     dx              ; CommandPort 103h
        mov     al,5
        out     dx,al
        inc     dx              ; DataLowPort 104h
        mov     ax,Word Ptr cs:[_SampleEnd]
        shl     ax,9
        out     dx,ax
        dec     dx              ; CommandPort 103h
; ***** Play it!  (I hope)
        mov     al,0
        out     dx,al
        pop     ax
        add     dx,2            ; DataHighPort 105h
        out     dx,al
        ret
endp    _U_StartVoice

U_StartVoice    Proc    Far     Voice:Word,LoopMode:Word,StartP:Dword,BeginP:Dword,SEndP:Dword
        mov     ax,Word Ptr [StartP]
        mov     bx,Word Ptr [StartP+2]
        mov     Word Ptr cs:[_SampleBegin  ],ax
        mov     Word Ptr cs:[_SampleBegin+2],bx
        ret
U_StartVoice    EndP

; AX - Voice
; Returns:  DX:AX - Position
; Wastes CX
U_ReadPos       Proc    Far
        mov     dx,cs:[BasePort]
        add     dx,ActiveVoicePort
        out     dx,al
        inc     dx              ; CommandPort 103h
        mov     al,VoicePosLo
        out     dx,al
        inc     dx              ; DataLowPort 104h
        in      ax,dx           ; TEMP0
        mov     cx,ax
        dec     dx              ; CommandPort 103h
        mov     al,VoicePosHi
        out     dx,al
        inc     dx              ; DataLowPort 104h
        in      ax,dx           ; TEMP1
        shl     cx,7
        shr     ax,9
        and     ax,7Fh
        mov     dx,ax
        and     dx,0Fh
        mov     ax,cx
        ret
U_ReadPos       EndP

; AX - Mixer control
;  bit 0: 0=linein on, 1=linein off
;  bit 1: 0=output on, 1=output off
;  bit 2: 0=micin off, 1=micin on
U_ChangeInOut   Proc    Far
        mov     dx,cs:[BasePort]
        out     dx,al
        ret
U_ChangeInOut   EndP

; The only reason I do it this way is because I haven't figured out the dump
; RAM to DRAM via DMA yet.
;
; Dump sample to Ram
;   ES:BX - Max 64k sample to dump to RAM.
;   SI:DI - DRAM location to dump to.
;   CX    - Max bytes to dump.
;   AH    - Xor value for twos complement.  Should actually be negated, but
;           oh, well.
;   Wastes BX, DX
;
; Approximate time to dump 1 megabyte of samples to DRAM (assuming they were
; all loaded in memory) is 5 seconds.
U_DumpSampleToDRAM      Proc    Far
        push    ds
        mov     dx,cs:[BasePort]
        add     dx,CommandPort
        mov     al,DRAMAddrHi   ; Dump upper byte, only do
        out     dx,al           ; it on carry from now on.
        add     dx,2            ; DataHighPort
        push    ax
        mov     ax,si
        out     dx,al
        pop     ax
        sub     dx,2            ; CommandPort
@@MainLoop:
        mov     al,DRAMAddrLo
        out     dx,al
        inc     dx              ; DataLowPort
        push    ax
        mov     ax,di
        out     dx,ax
        pop     ax
        dec     dx              ; CommandPort
        add     di,1
        jnc     @@DumpByte
        inc     si
        mov     al,DRAMAddrHi
        out     dx,al
        add     dx,2            ; DataHighPort
        push    ax
        mov     ax,si
        out     dx,al
        pop     ax
        sub     dx,2            ; CommandPort
@@DumpByte:
        add     dx,4            ; DRAMIOPort
        mov     al,es:[bx]
        xor     al,ah
        inc     bx
        out     dx,al
        sub     dx,4            ; CommandPort
        loop    @@MainLoop
        pop     ds
        ret
U_DumpSampleToDRAM      EndP

; Same as above, but strawkcab?
; Uncommented in the Ultradox..
;
U_DumpDRAMToMemory      Proc    Far
        mov     dx,cs:[BasePort]
        add     dx,CommandPort
        mov     al,DRAMAddrHi   ; Dump upper byte, only do  XXXXX
        out     dx,al           ; it on carry from now on.
        add     dx,2            ; DataHighPort
        mov     ax,si
        out     dx,al
        sub     dx,2            ; CommandPort
@@MainLoop2:
        mov     al,DRAMAddrLo
        out     dx,al
        inc     dx              ; DataLowPort
        mov     ax,di
        out     dx,ax
        dec     dx              ; CommandPort
        add     di,1
        jnc     @@DumpByte2
        inc     si
        mov     al,DRAMAddrHi
        out     dx,al
        add     dx,2            ; DataHighPort
        mov     ax,si
        out     dx,al
        sub     dx,2            ; CommandPort
@@DumpByte2:
        add     dx,4            ; DRAMIOPort
        in      al,dx
        mov     es:[bx],al
        inc     bx
        sub     dx,4            ; CommandPort
        loop    @@MainLoop2
        ret
U_DumpDRAMToMemory      EndP



        Comment &
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

        The following code is (C) Copyright, 1993 by Bjarni R. Einarsson
        See GP15.DOX for more info.

        The following routines I wrote/hacked to interface the GusPlay
        and Renaissance code with Turbo/Borland Pascal and to handle
        protected samples (sound effects)... with games in mind, of
        course.

                -- Juggler

        P.S.    I'm still pretty new to assembly, so don't be to harsh in
                your judgements.. ;)

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        &

; Dumps all sorts of pointers into the address pointed to by ProgDataP.
; See the ProgData structure for more info.
;
GetVariables    Proc    Far     ProgDataP:DWord
        push    ds
        pusha
        les     di,ProgDataP
        mov     ax,es
        mov     ds,ax
        mov     ax,cs
        mov     Word Ptr [di.BasePortP  ],offset cs:[BasePort]
        mov     Word Ptr [di.BasePortP+2],ax
        mov     Word Ptr [di.ErrorP     ],offset cs:[ErrorCode]
        mov     Word Ptr [di.ErrorP+2   ],ax
        mov     Word Ptr [di.VarP       ],offset cs:[MainVolume]
        mov     Word Ptr [di.VarP+2     ],ax
        mov     Word Ptr [di.TimerP     ],offset cs:[Time]
        mov     Word Ptr [di.TimerP+2   ],ax
        mov     Word Ptr [di.GMemP      ],offset cs:[GUSMem]
        mov     Word Ptr [di.GMemP+2    ],ax
        mov     Word Ptr [di.GMemProtP  ],offset cs:[GUSMemProt]
        mov     Word Ptr [di.GMemProtP+2],ax
        mov     Word Ptr [di.ChanInfoP  ],offset cs:[SampChans]
        mov     Word Ptr [di.ChanInfoP+2],ax
        mov     Word Ptr [di.GusVolP    ],offset cs:[GusVol]
        mov     Word Ptr [di.GusVolP+2  ],ax
        mov     Word Ptr [di.MSOffset   ],offset cs:[SampOffset]
        mov     Word Ptr [di.MSOffset+2 ],ax
        mov     Word Ptr [di.MSLen      ],offset cs:[SampLen]
        mov     Word Ptr [di.MSLen+2    ],ax
        mov     Word Ptr [di.MSVol      ],offset cs:[SampVol]
        mov     Word Ptr [di.MSVol+2    ],ax
        mov     Word Ptr [di.MSRep      ],offset cs:[SampRep]
        mov     Word Ptr [di.MSRep+2    ],ax
        mov     Word Ptr [di.MSRepLen   ],offset cs:[SampRepLen]
        mov     Word Ptr [di.MSRepLen+2 ],ax
        mov     Word Ptr [di.PSOffset   ],offset cs:[ProtSampOffset]
        mov     Word Ptr [di.PSOffset+2 ],ax
        mov     Word Ptr [di.PSLen      ],offset cs:[ProtSampLen]
        mov     Word Ptr [di.PSLen+2    ],ax
        mov     Word Ptr [di.PSVol      ],offset cs:[ProtSampVol]
        mov     Word Ptr [di.PSVol+2    ],ax
        mov     Word Ptr [di.PSRep      ],offset cs:[ProtSampRep]
        mov     Word Ptr [di.PSRep+2    ],ax
        mov     Word Ptr [di.PSRepLen   ],offset cs:[ProtSampRepLen]
        mov     Word Ptr [di.PSRepLen+2 ],ax
        popa
        pop     ds
        ret
GetVariables    EndP

; Does what it says it does..
; seg:ofs points to the file name.  (null terminated string)
; Returns the same error codes as LoadMod, 0 if successfull.
;
LoadModule      Proc    Far     NameSeg:word,NameOfs:word,SampOfs:word,SampBuf:word
        push    ds
        mov     ax,cs
        mov     ds,ax
        call    Init
        mov     ax, NameSeg
        mov     ModSeg,ax
        mov     ax, NameOfs
        mov     ModPatterns,ax
        mov     ax,SampOfs
        mov     ModSamples,ax
        mov     ax,SampBuf
        mov     SampleMemBuf,ax
        call    LoadMod
        xor     ax,ax
        mov     cs:[errorcode],ax
        pop     ds
        ret
LoadModule      EndP


; This procedure loads (Amigafied?) samples to GUS DRAM and increments
; the protected memory marker.. so modules loaded AFTER this won't
; destroy it.  If ya do this while a module is also in memory you'll get
; funny results.  :-)  Returns the number of the loaded sample (0-63).
;
ProtSampAdd     Proc    Far     WData:dword,WLen:word,SVol:word,SRep:word,SRepLen:word,XORval:byte
        push    ds
        mov     bx,cs:[ProtSampNum]
        cmp     bx,63
        ja      TooManySamples
        shl     bx,1
        inc     cs:[ProtSampNum]
        mov     cx,WLen
        mov     Word Ptr cs:[ProtSampLen+bx], cx
        push    cx
        shr     cx,2
        add     cx,1
        shl     cx,2            ; Forces dword alignment, wastes 1-4 bytes.
        mov     ax,SVol
        cmp     ax,63
        jna     OK_volume
        mov     ax,63
OK_volume:
        mov     Word Ptr cs:[ProtSampVol+bx], ax
        mov     ax,SRep
        cmp     ax,WLen
        jna     OK_Rep
        mov     ax,WLen
OK_Rep:
        mov     Word Ptr cs:[ProtSampRep+bx], ax
        mov     ax,SRepLen
        cmp     ax,0
        ja      OK_RepLen
        mov     ax,WLen
OK_RepLen:
        mov     Word Ptr cs:[ProtSampRepLen+bx], ax
        shl     bx,1
        mov     di,Word Ptr cs:[GUSMemProt]
        mov     si,Word Ptr cs:[GUSMemProt+2]
        add     Word Ptr cs:[GUSMemProt],cx
        adc     Word Ptr cs:[GUSMemProt+2],0
        mov     Word Ptr cs:[ProtSampOffset+bx],di
        mov     Word Ptr cs:[ProtSampOffset+bx+2],si
        les     bx,Wdata
        mov     al,XORval
        mov     ah,al
        pop     cx
        call    U_DumpSampleToDRAM
        mov     ax,cs:[ProtSampNum]
        dec     ax
        mov     bx, ax
        mov     dx, ax          ; I forget which damn register
        mov     cx, ax          ; is the return value :)
        jmp     PSA_End
TooManySamples:
        mov     ax, 0FFFFh      ; Returns FFFF hex if there are too many
        mov     dx, ax          ; samples, otherwise it returns the number
        mov     bx, ax          ; of the sample.  (0-63)
        mov     cx, ax
PSA_End:
        pop     ds
        ret
ProtSampAdd     EndP


_PSP_Voice      dw 0
_PSP_Freq       dw 0
_PSP_LoopMode   dw 0
_PSP_Balance    dw 0

; Play back a sample previously loaded by ProtSampAdd.
; Snum is the number ProtSampAdd returned.
; Uses one of 8 voices, and rotates the voice counter, so the next call
; to this routine won't try to use the same GUS voice.
;
ProtSampPlay    Proc    Far     Snum:Word,Freq:Word,Balance:Word,LoopMode:Word
        push    ds
        push    bp
        mov     ax,Freq
        mov     bx,LoopMode
        mov     cx,Balance
        mov     cs:[_PSP_Freq],ax
        mov     cs:[_PSP_LoopMode],bx
        mov     cs:[_PSP_Balance],cx
        mov     ax,Snum
        cmp     ax,cs:[ProtSampNum]
        jae     ForgetIt
        mov     bp,ax
        mov     ax,cs:[NextVoice]
        mov     cs:[_PSP_Voice], ax
        inc     ax
        cmp     ax,19
        jna     NoWrapVoices
        mov     ax,8
NoWrapVoices:
        mov     cs:[NextVoice], ax      ; Rotate playback voices..
        shl     bp,2
        mov     ax,Word Ptr cs:[ProtSampOffset+bp  ]
        mov     cx,Word Ptr cs:[ProtSampOffset+bp+2]
        shr     bp,1
        mov     bx,Word Ptr cs:[ProtSampLen+bp]
        mov     dx,Word Ptr cs:[ProtSampRep+bp]
        push    dx
        add     dx,Word Ptr cs:[ProtSampRepLen+bp]
        jc      NoChangeLen
        cmp     bx,dx
        jb      NoChangeLen
        mov     bx,dx
NoChangeLen:
        pop     dx
        mov     Word Ptr cs:[_SampleBegin  ],ax
        mov     Word Ptr cs:[_SampleBegin+2],cx
        mov     Word Ptr cs:[_SampleStart  ],ax
        mov     Word Ptr cs:[_SampleStart+2],cx
        clc
        add     Word Ptr cs:[_SampleStart  ],dx
        adc     Word Ptr cs:[_SampleStart+2],0
        mov     Word Ptr cs:[_SampleEnd    ],ax
        mov     Word Ptr cs:[_SampleEnd+2  ],cx
        clc
        add     Word Ptr cs:[_SampleEnd    ],bx         ; Set up variables
        adc     Word Ptr cs:[_SampleEnd+2  ],0          ; for _U_StartVoice
        mov     bx,Word Ptr cs:[_PSP_Voice]
        mov     ax,Word Ptr cs:[_PSP_Freq]
        call    U_SetFreq
        mov     ax,Word Ptr cs:[_PSP_Voice]
        mov     bx,Word Ptr cs:[_PSP_Balance]
        call    U_SetBalance
        mov     bx,Word Ptr cs:[_PSP_Voice]
        mov     ax,Word Ptr cs:[ProtSampVol+bp]
        mov     cx,Word Ptr cs:[ProtMainVolume]
        xor     dx,dx
        mul     cx
        shr     ax,6
        adc     ax,0
        shl     ax,1
        xchg    ax,bx
        mov     bx,Word Ptr cs:[GusVol+bx]
        call    U_SetVolume
        mov     ax,Word Ptr cs:[_PSP_Voice]
        mov     bx,Word Ptr cs:[_PSP_LoopMode]
        call    _U_StartVoice
ForgetIt:
        pop     bp
        pop     ds
        ret
ProtSampPlay    EndP

; Pop the most recently loaded protected sample off the sample stack.
; Preserves all registers.
;
ProtSampPop     Proc    Far
        cmp     Word Ptr cs:[ProtSampNum],1
        jb      AtBottom
        push    ax
        push    cx
        push    bx
        dec     Word Ptr cs:[ProtSampNum]
        mov     bx,cs:[ProtSampNum]
        shl     bx,2
        mov     ax,Word Ptr cs:[ProtSampOffset+bx]
        mov     cx,Word Ptr cs:[ProtSampOffset+bx+2]
        mov     Word Ptr cs:[GUSMemProt  ],ax
        mov     Word Ptr cs:[GUSMemProt+2],cx
        pop     bx
        pop     cx
        pop     ax
AtBottom:
        ret
ProtSampPop     EndP

        End
