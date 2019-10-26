; ========================= CONDOM Intro ver 1.11 ===========================
; 23/07/94
; CONDOM.ASM source of CONDOM.COM
; Public domain code.
;
; Copyright and blah-blah (c) 1994 "SuiCYCOManiac"

.386 ; for real mode 386

;********  a little EQU to start

; the memory size (given in para for DOS)
ProgramSize  EQU 128 + 1  ;  2048 bytes of code + 16 bytes for para
DataSize     EQU 2000 + 1 ; 32000 bytes of data + 16 bytes for para
; I exaggerate the memory size so there will be no problem

; some EQU to change the Intro look-like
NumberOfStars EQU 512     ; if you want more or less
SpeedOfStars  EQU 4       ; do your changes

;************************************************************

Code Segment para public USE16 'CODE'

     Assume CS:Code
     ORG 100h

Start:  Jmp      Near Ptr EntryPoint ; jump over some code...

CompleteBailOut:
; reinits the screen to the "classic" text mode (80x25) and exits
       Mov       AX,0003h       ; it's the mode 3h
       Int       10h            ; call BIOS

BailOut:                        ; exits this marvelous program
       Mov       AX,CS          ; it's time
       Mov       DS,AX          ; to tell you
       Mov       DX,Offset EndMsg ; goodbye...
       Mov       AH,09          ;
       Int       21h            ;

       Mov       AX,4C00h       ; exit !
       Int       21h            ; Hey DOS, you have some work to do

EntryPoint:
; first we have to manage memory :
       Mov       AH,4Ah         ; Deallocate the not need memory for code,
       Mov       BX,ProgramSize ; the constants and initialized variables
       Mov       CX,CS          ;
       Mov       ES,CX          ;

       Int       21h            ; call DOS
       Jc        Short BailOut  ; sorry, don't work

; check if the user got a VGA
       Mov       AX,1A00h       ;
       Int       10h            ;
       Cmp       BL,07          ; if upper he's got a VGA or a MCGA
       Jb        Short BailOut  ; else go out

       Mov       AH,48h         ; allocate the memory for the datas and
       Mov       BX,DataSize    ; the stack
       Int       21h            ; call DOS
       Jc        Short BailOut  ; not enough memory or something like that

       Mov       DS,AX          ; init DS on the Data
       Mov       SS,AX          ; init the stack
       Mov       SP,07D00h      ; init the pile pointer
       Cld                      ; everyone in this program increment

; check if the user got at least a 386
       Push      SP             ; test if this is a 8086
       Pop       BX             ;
       Cmp       BX,SP          ;
       Jne       Short BailOut  ; no, so go out

       Mov       BX,1110000000000000b  ; test if this is a 80286
       Push      BX             ; bit 12-15 is always clear on a 80286
       Popf                     ;
       Pushf                    ;
       Pop       BX             ;
       Test      BX,1110000000000000b ;
       Jz        Short BailOut ; if clear then it's a 80286

       Mov       FS,AX          ; init FS as an alternate data segment

     Assume DS:Data,SS:Data,FS:Data

; zero the data segment
       Mov       ES,AX          ;
       Mov       CX,8000        ; 32000 bytes of datas
       Mov       DI,Offset StarsX ; StarsX is the first data
       Xor       EAX,EAX        ;
       Rep       Stosd          ;

; init the screen:
       Mov       AX,0013h       ; mode 13h (320x200 256 colors)
       Int       10h            ; Call video BIOS

       Call      Near Ptr MakeMsgs  ; create fonts and the messages
       Call      Near Ptr MakeStars ; create the Stars

       Mov       AX,0A000h      ; init ES the screen segment
       Mov       ES,AX          ;

; clear the screen
       Xor       EAX,EAX        ; we want to clear the screen
       Mov       CX,16000       ;
       Xor       DI,DI          ;
       Rep       Stosd          ; clear screen

       Call      WaitVerticalRetrace ; try to synchronise the timer
       Call      InitTimer           ; with the vertical retrace

MainLoop:

WaitLoop:
       Cmp       CS:[IncCounter],2 ; waiting loop used to slow down
       Jnae      WaitLoop          ; the animation to less than 36 FPS
                                   ; otherwise it will be too fast on fast
                                   ; computer, or on very fast VGA card

       Call      WaitVerticalRetrace ; wait for the vertical retrace
       Mov       CS:[IncCounter],00 ; start counter
       Call      DisplayStars   ; show the Stars
       Call      DisplayMsgs    ; show the publicity messages

       Mov       AH,01          ; if the user press a
       Int       16h            ; key, make sure that we can know
       Jz        MainLoop       ; if keypressed the user is bored so go out

TheEndComplete:
       Call      UnInitTimer      ; uninstall the timer
       Call      Near Ptr FadeOut ; fade this screen out and then
       Jmp       CompleteBailOut  ; it's the end of the show

;******** Here's some PROCs.

;======== InitTimer ========
; install the frame

InitTimer PROC NEAR

       Push      DS

       Xor       SI,SI          ; first point the data segment on
       Mov       DS,SI          ; the interrupt table

       Mov       EDX,DS:[32]    ; save the old int 08h vector
       Mov       CS:[OldInt08h],EDX

       Mov       DX,CS          ; here's the new int 08h vector
       Shl       EDX,16         ;
       Mov       DX,Offset NewInt08h ;

       Cli
       Mov       DS:[32],EDX    ; assign the NewInt08h

       Mov       AL,36h         ; now the timer runs at about 36.4 Hz
       Out       43h,AL         ; this 4 times faster than the original timer
       Xor       AL,AL          ;
       Out       40h,AL         ;
       Mov       AL,40h         ;
       Out       40h,AL         ;
       Sti                      ;

       Pop       DS
       Ret                      ;
InitTimer ENDP

;======== UnInitTimer ========
; uninstall the new timer and restore the old one

UnInitTimer PROC NEAR
       Push      DS             ;

       Xor       SI,SI          ;
       Mov       DS,SI          ;

       Cli                      ; some crucial code
       Mov       EDX,CS:[OldInt08h] ;
       Mov       DWord Ptr DS:[32],EDX

       Mov       AL,36h         ;
       Out       43h,AL         ;
       Xor       AL,AL          ;
       Out       40h,AL         ;
       Out       40h,AL         ;
       Sti                      ; finished, Ints enable

       Pop       DS
       Ret                      ;

UnInitTimer ENDP

;======== NewInt08h ========
; it's the new int 08h, four times faster

NewInt08h PROC FAR
       Pushf                   ; save the flags
       Cmp      CS:[Clock],4   ;
       Jne      NoIretThroughOldInt08
       Pushf                   ; we've called four times the timer
       Call     CS:[OldInt08h] ; so we must update the old
       Mov      CS:[Clock],00  ; timer

NoIretThroughOldInt08:
       Inc      CS:[Clock]      ; update the clock
       Inc      CS:[IncCounter] ;

       Mov      AL,20h          ;
       Out      20h,AL          ;
       Popf                     ; restore flags
       Iret                     ;
NewInt08h ENDP

;======== MakeStars ========
; init the Stars

MakeStars PROC NEAR

; first start to init the palette of the Stars
       Mov       AX,63          ; 64 BW colors for the star gradiant
       Xor       SI,SI          ; clear the index
       Mov       DI,Offset Palette+(64*3) ; keep an eye on the palette for
                                          ; the fade out
       Mov       DX,03C9h       ; load some value for DX

StarsPalCreateLoop:
       Dec       DX             ; DX=03C8h,
       Out       DX,AL          ; which color ?

       Inc       DX             ; DX=03C9h, we can send the RGB value now
       Mov       [StarsCol+SI],AL ; store the color number
       Mov       [DI],AL        ; save value
       Out       DX,AL          ; send red value
       Mov       [StarsCol+SI+1],AL ;
       Mov       [StarsCol+SI+2],AL ;
       Out       DX,AL          ; send green value
       Mov       [DI-1],AL      ;
       Mov       [DI-2],AL      ;
       Mov       [StarsCol+SI+3],AL ;
       Out       DX,AL          ; send blue value
       Add       SI,04          ; next.
       Sub       DI,03

       Dec       AX             ; decrement
       Jns       StarsPalCreateLoop ; next...

; now it's time to create some Stars
       Mov       SI,(NumberOfStars shl 1) -2 ; clear index

StarsXYZCreateLoop:
; creation of X value :
       Mov       DI,320         ; first create some X value,
       Call      Near Ptr Random ; find some random value
       Sub       AX,160         ; the result was in AX
       Imul      AX,80          ; mul it (integer)
       Mov       [StarsX+SI],AX ; and save it

CreateY:
; creation of Y value :
       Mov       DI,200        ; create random value
       Call      Near Ptr Random ; for the Y
       Sub       AX,100        ; do the complex
       Imul      AX,80         ; alchemy...
       Mov       [StarsY+SI],AX ; save it

CreateX:
; creation of Z value:
       Mov       DI,256         ; random !
       Call      Near Ptr Random ; ...
       Inc       AX             ;
       Mov       [StarsZ+SI],AX ; saving

       Sub       SI,02          ; next X,Y,Z
       Jns       StarsXYZCreateLoop ; continue the loop if necessary

       Ret                      ; that's all

MakeStars ENDP

;======== DisplayStars ========
; display the Stars

DisplayStars PROC NEAR

       Mov      SI,(NumberOfStars shl 1) -2  ; clear index

DisplayStarsLoop:

       Sub      Word Ptr [StarsZ+SI],SpeedOfStars ;
       Cmp      Word Ptr [StarsZ+SI],1
       Jnle     NoChangeWithZ
       Mov      Word Ptr [StarsZ+SI],256

NoChangeWithZ:
; calculate Y

       Push     Word Ptr [LastSY+SI] ; do the unwrite of the
       Push     Word Ptr [LastSX+SI] ; precedent Stars
       Xor      AL,AL                ;
       Call     Near Ptr SetPixel    ;

       Mov      AX,[StarsY+SI]  ; for the perspective
       Mov      CX,[StarsZ+SI]  ; projection

       Cwd                      ; clear DX and extend sign
       Idiv     CX              ; do the perspective projection (Y/Z)
                                ; the quotient is in AL so extend
                                ; the sign to the AH
       Add      AX,100          ; the origin is the center of the
                                ; screen (160,100)
       Mov      [LastSY+SI],AX  ; save the value so we can unwrite latter
       Push     AX              ; push it so we can draw it

; calculate X
       Mov      AX,[StarsX+SI]  ; now do it for X value

       Cwd                      ;
       Idiv     CX              ;

       Add      AX,160          ; put him to the center
       Mov      [LastSX+SI],AX  ;
       Push     AX              ; push it for SetPixel

; select the correct color
       Mov      DI,(offset StarsCol) - 1 ;
       Add      DI,CX           ; Stars have their colors according to their Z

       Mov      AL,[DI]         ; get the correct color
       Call     Near Ptr SetPixel ; write the pixel

       Sub      SI,02
       Jns      DisplayStarsLoop

       Ret

DisplayStars ENDP

;======== WaitVerticalRetrace ========
; wait for the vertical retrace
; used register(s) : AX,DX

WaitVerticalRetrace PROC NEAR

       Mov       DX,03DAh       ;

Wait1:
       In        AL,DX          ;
       Test      AL,08h         ;
       Jnz       Wait1          ;

Wait2:
       In        AL,DX          ;
       Test      AL,08h
       Jz        Wait2          ;
       Ret                      ;

WaitVerticalRetrace ENDP

;======== SetPixel ========
; set a pixel at X,Y with a given color
; X EQU [BP+02]
; Y EQU [BP+04]
 ; PixelColor EQU AL
; destroyed register(s) : DI

SetPixel PROC NEAR

        Mov      BP,SP          ; init the stack pointer
        Mov      DI,[BP+04]     ; load DI
        Cmp      DI,200         ; check if not out of the screen
        Jae      SetPixelEnd    ; yes, so don't write
        Cmp      Word Ptr [BP+02],320 ; idem for the X
        Jae      SetPixelEnd    ;

        Shl      DI,08          ; PixelOffset = (Y*320) + X
        Shl      Word ptr [BP+04],06 ; so we can do some Shl to replace
        Add      DI,[BP+04]     ; the muls
        Add      DI,[BP+02]     ; adding the X value
        Mov      ES:[DI],AL     ; set the pixel

SetPixelEnd:
        Ret      04h            ; and last but not the least

SetPixel ENDP


;======== SetColor ========
; set the corresponding color with his new R,G,B value
; FirstColorToChange EQU AL
; PaletteOffset      EQU SI  (this offset is set to the first color to set)
; NumberOfColor      EQU BX
; destroyed register(s) : DX

SetColor PROC NEAR
        Mov      DX,03C8h       ; first tell VGA that we

WriteColor:
        Out      DX,AL          ; want that color

        Inc      DX
        Outsb                   ; send red value
        Outsb                   ; send green value
        Outsb                   ; send blue value

        Dec     DX
        Inc     AL

        Dec     BX              ; do the loop
        Jnz     WriteColor      ;

        Ret                     ; ?

SetColor ENDP

;======== FadeOut ========
; fade out the palette

FadeOut PROC NEAR
	Mov     CX,64           ; do this is 64 times

FadingOut:
        Mov     DI,767          ; load the "looper"

DecrementingColorIntensity:
        Cmp     Byte Ptr [Palette+DI],0 ; is it already faded out
        Je      FadedOut        ; if yes, next
        Dec     Byte Ptr [Palette+DI]   ; make this color fade out

FadedOut:
        Dec     DI              ; do the loop
        Jns     DecrementingColorIntensity

        Call    Near Ptr WaitVerticalRetrace ; avoid some display problem
        Mov     SI,Offset Palette  ; load the correct offset
        Mov     BX,256             ; change 256 colors
        Xor     AL,AL              ; first color is zero
        Call    Near Ptr SetColor  ; write the colors

        Loop    FadingOut       ; fade this out (loop is not the quickest way
                                ; but is fast enough)
        Ret                     ; don't forget to go back

FadeOut ENDP


;======== Random ========
; return a random number in the specified range
; Range EQU DI
; return in AX
; destroyed register(s) : DX

Random PROC NEAR

	Mov     AX,30247        ; load the "muller"
        Mul     CS:[Seed]       ; mul with the Seed
        Xor     AX,8690h        ; do some stuff to make this
        Add     AX,27128        ; value random
        Mov     CS:[Seed],AX    ; save the Seed

; now cut our value to make him fit in the range
        Mul     DI              ; AX is the virtual fractional part of a
                                ; fixed point who got an integer part of zero
        Mov     AX,DX           ; so the value will fit the range

        Ret                     ; don't forget to go back

Random ENDP

;======== MakeMsgs ========
; create the messages

MakeMsgs PROC NEAR
; make color 15 invisible
        Mov     DX,03C8h        ; select color 128
        Mov     AL,0            ;
        Out     DX,AL           ;
        Inc     DX
        Xor     AL,AL
        Mov     CX,80           ;

CreateBlackColors:
        Out     DX,AL
        Out     DX,AL
        Out     DX,AL
        Loop    CreateBlackColors

; now we can extract ROM fonts
        Mov     CX,05           ; five messages
        Mov     SI,Offset Message1 ;

MsgGrabbingLoop:
        Push    CX

        Mov     DX,CS           ; it's in the initialized data
        Mov     ES,DX           ;

        Mov     AX,1300h        ; write string BIOS function
        Mov     CX,CS:[SI]      ; load size
        Mov     BX,0015         ;
        Mov     DX,0100h        ; column and row zero
        Add     SI,6            ;
        Mov     BP,SI           ; load the correct offset in BP
        Int     10h             ;

; now save
        Mov     CX,CS:[SI-6]    ; load size
        Mov     DI,CS:[SI-4]    ; know where to store it

        Shl     CX,02           ; in pixel that give you what ?
        Add     CX,CX           ;
        Mov     BP,CX           ; save it for futher use

        Mov     AX,0A000h       ; ES = VRAM segment
        Mov     ES,AX           ;

        Mov     AL,80           ; load the color counter
        Mov     DX,1920         ; DX is the looper

GrabingLoop:
        Mov     BX,DX           ; in BX is the offset

RowLoop:
        Cmp     Byte Ptr ES:[BX],00 ;
        Jz      NoWrite         ;
        Mov     [DI],AL         ;

NoWrite:
        Inc     BX
        Inc     DI
        Loop    RowLoop         ; do the row loop

        Mov     CX,BP           ; restore
        Add     DX,320          ; do the loop
        Inc     AL              ; adjust the color count
        Cmp     DX,5760         ;
        Jne     GrabingLoop     ;

        Add     SI,CS:[SI-6]
        Mov     AL,80
        Pop     CX
        Loop    MsgGrabbingLoop

; init the SinusVal
        Mov     DI,59
        Call    Near Ptr Random
        Mov     [SinusVal],AX

        Ret

MakeMsgs ENDP

;======== DisplayMsgs ========
; display the messages

DisplayMsgs PROC NEAR

        Mov     BX,Offset Message1 ;
        Mov     AH,05              ; 5 messages

DisplayMsgsLoop:
        Add     BX,06
        Mov     BP,CS:[BX-6]    ; how many rows ?

        Shl     BP,02
        Add     BP,BP
        Xor     CX,CX
        Sub     BP,02

DisplayMsgsRowLoop:
        Mov     DX,12
        Mov     DI,CS:[BX-2]    ; load the offset on screen

        Mov     SI,Offset SinusTab
        Add     SI,[SinusVal]

        Push    BP

        Movsx   SI,CS:[SI]

        Mov     BP,SI
        Shl     BP,06
        Shl     SI,08
        Add     SI,BP

        Pop     BP

        Add     DI,SI

        Mov     SI,CS:[BX-4]    ; load the offset in mem

        Add     SI,CX
        Add     DI,CX

        Inc     [SinusVal]
        Cmp     [SinusVal],60
        Jne     DisplayMsgsLineLoop
        Mov     [SinusVal],00

DisplayMsgsLineLoop:
        Mov     AL,[SI]
        Mov     ES:[DI],AL

        Add     SI,BP
        Inc     AL
        Add     SI,02
        Add     DI,320
        Dec     DX
        Jnz     DisplayMsgsLineLoop

        Mov     AL,80
        Inc     CX
        Cmp     BP,CX
        Jne     DisplayMsgsRowLoop

        Add     BX,CS:[BX-6]
        Dec     AH
        Jnz     DisplayMsgsLoop ;

        Ret                     ;

DisplayMsgs ENDP

;******** Some CONSTANTS and Initialized value to finish !

Seed DW 35467 ; the seed for the Random function

Message1:
     DW 32                                 ; first his size in char
     DW Offset Message1SPR                 ; his offset in the memory
     DW 5120 + 32                          ; his offset on the screen
     DB 'þ Condom HQ (33-1) 46-70-75-62 þ' ; the message
  ; decalage (32 pixels)

Message2:
     DW 18
     DW Offset Message2SPR
     DW 10240 + 88
     DB 'þ Generalist BBS þ'
  ; (decalage 88 pixels de l'‚cran)

Message3:
     DW 38
     DW Offset Message3SPR
     DW 20480 + 8
     DB 'þ Over 110 international conferences þ'
  ; (decalage 8 pixels de l'‚cran)

Message4:
     DW 16
     DW Offset Message4SPR
     DW 25600 +96
     DB 'þ Open 24h/24h þ'
  ; (decalage 96 pixels )

Message5:
     DW 33
     DW Offset Message5SPR
     DW 30720 + 28
     DB 'þ Running FrontDoor 2.12 Mailer þ'
  ; (decalage 28 pixels)

SinusTab DB 0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3,3,3
         DB 2,2,2,2,2,1,1,1,1,1,0,0,0,0,0
         DB -1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2
         DB -1,-1,-1,-1,-1

EndMsg DB 'Condom HQ (33-1) 46-70-75-62 Ivry Sur Seine, France.',0Ah,0Dh
       DB 0Ah,0Dh
       DB '74:320/7@SparkNet       34:200/400@FrancoPhoNet',0Ah,0Dh
       DB '400:433/9@Direct_Link   222:320/6@GameNet',0Ah,0Dh
       DB 'FREQ allowed any System. Point Mode Accepted.',0Ah,0Dh
       DB 0Ah,0Dh
       DB 'Coded by SuiCYCOmaniac.',0Ah,0Dh
       DB 'Your sysop St‚phane Boullet.',0Ah,0Dh,'$'

OldInt08h  DD 00000000h ; the old int 08h vector
Clock      DB 00h       ; the clock used to manage the old int 08h
IncCounter DB 00h       ; used to slow down animation

Code ENDS

Data Segment Para USE16  ; "virtual" segment on the heap

DataSeg_MCB  DB 16 Dup (?)

; the value for the Stars are some integers
StarsX   DW  NumberOfStars Dup (?) ; some X,Y,Z value
StarsY   DW  NumberOfStars Dup (?) ;
StarsZ   DW  NumberOfStars Dup (?) ;
LastSX   DW  NumberOfStars Dup (?) ; value used for the unwrite
LastSY   DW  NumberOfStars Dup (?) ;
StarsCol DB  256 Dup (?)           ; color value for the stars
Palette  DB  768 Dup (?)           ; palette, useful for the fade out

; messages storages
Message1SPR DB  3072 Dup (?)
Message2SPR DB  1728 Dup (?)
Message3SPR DB  3648 Dup (?)
Message4SPR DB  1536 Dup (?)
Message5SPR DB  3168 Dup (?)
SinusVal    DW  ?

; StackData DB ? Dup (?)  ; the reminder place of this data segment
                          ; is reserved for the stack

Data ENDS

End Start



