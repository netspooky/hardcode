;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;
;     TITLE: Star field
;WRITTEN BY: DRAEDEN
;      DATE: 03/15/93
;
;     NOTES: Need 386 to execute.
;
;ASSOCIATED FILES:
;
;       STARGEN.BAS =>  Basic program that generates a set of 'randomized' 
;                       numbers.  Creates STARRND.DW
;
;       STARS.TXT   =>  The text file that explains starfields...
;
;       STARRND.DW  =>  File that contains a set of shuffled numbers.  
;                       Used to create 'random' star field.
;
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
    
    DOSSEG
    .MODEL SMALL
    .STACK 200h
    .CODE
    .386
    ASSUME CS:@CODE, DS:@CODE
    

;=== GLOBALS
;=== Data Includes

INCLUDE starrnd.dw      ;file that has label StarRnd numbers 

;=== DATA Structures
    
    Star_Struc      STRUC   
        X       dw  0
        Y       dw  0
        Z       dw  0
        OldDi   dw  0       ;where to erase last dot
        Color   db  0       ;BASE color. a number 0-16 is added to it
    Star_Struc      ENDS

    StarStrucSize = 9       ;number of bytes per entry

;=== DATA

ScreenWidth EQU 320
ScreenHeight EQU 200

NumRnds     EQU 400     ;number of random numbers defined

MaxZpos     EQU 4096
MinZpos     EQU 2
MaxStars    EQU 190
NumColors   EQU 5       ;number of Base colors in the Color Chart

WarpSpeed   dw  15      ;how quickly the stars move toward ya
MaxWarp     EQU 90

Xindex      dw  30      ;index into the StarRnd chart for X & Y
Yindex      dw  230     ; -note they must be different; set em the same to
                        ;see why
Cindex      dw  0       ;index into ColorChart

ColorChart  db  0,16,32,48,64,80    ;a list of base colors (-1)

Stars       Star_Struc MaxStars DUP (<>) ;where all the data is held
NumActive   dw  0       ;number of stars active

Palette     db  3 dup (0)   ;the palette.. first entrie is BG color (black)
    i = 15
    REPT    16
            db  2*i,3*i,4*i
        i=i-1
    ENDM
    i = 15
    REPT    16
            db  2*i,2*i,4*i
        i=i-1
    ENDM
    i = 15
    REPT    16
            db  3*i,3*i,4*i
        i=i-1
    ENDM
    i = 15
    REPT    16
            db  3*i,2*i,4*i
        i=i-1
    ENDM
    i = 15
    REPT    16
            db  3*i,3*i,3*i
        i=i-1
    ENDM
    i = 15
    REPT    16
            db  2*i,4*i,3*i
        i=i-1
    ENDM

;=== Code Includes
;=== SUBROUTINES

    ;finds 1st available slot for a star and puts it there
MakeStar PROC NEAR
    pusha
    mov     ax,cs
    mov     es,ax
    mov     ds,ax

    cmp     [NumActive],MaxStars    ;is there room for another star?
    jae     NoEmptySpace            

    ;search for 1st available slot

    mov     si,0
TryAgain:
    cmp     word ptr [Stars.Z+si],0     ;is this slot empty?
    je      GotOne                      ;yes, go fill it

    add     si,StarStrucSize
    cmp     si,MaxStars*StarStrucSize
    jb      TryAgain
    jmp     NoEmptySpace

GotOne:         ;si points to the record for the star to fill
    mov     di,[Yindex]         ;grab index for Ypos
    add     di,di               ;multiply by 2 to make it a WORD index
    mov     ax,[StarRnd+di]     ;get the number
    shl     ax,3                ;multiply by 8- could been done in BAS file
    mov     [Stars.Y+si],ax     ;and save off the number
    
    mov     di,[Xindex]         ;grab index for Xpos
    add     di,di               ;... same as above, but for Xpos
    mov     ax,[StarRnd+di]
    shl     ax,3
    mov     [Stars.X+si],ax

    mov     [Stars.Z+si],MaxZpos    ;reset Zpos to the max
    inc     [NumActive]             ;we added a star so increase the counter

    mov     di,[Cindex]             ;grab the color index
    mov     al,[ColorChart+di]      ;grab the BaseColor for the star
    mov     [Stars.Color+si],al     ;save it in the record

    ;increase all the index pointers

    inc     [Cindex]                ;increases the color counter
    cmp     [Cindex],NumColors
    jb      OkColor
    mov     [Cindex],0
OkColor:
    inc     [Yindex]                ;increases Yindex
    cmp     [Yindex],NumRnds        ;note that for this one we
    jb      YindNotZero             ; subtract NumRnds from Yindex if we
    sub     [Yindex],NumRnds        ; go off the end of the chart
YindNotZero:
    inc     [Xindex]                ;increase Xindex
    cmp     [Xindex],NumRnds        ;have we gone through the entire chart?
    jb      XindNotZero             ;nope...

;This clever bit of code makes more use out of the chart by increasing Yindex
; one additional unit each time Xindex goes through the entire chart... the
; result is nearly NumRND^2 random non-repeating points
        
    inc     [Yindex]                ;yes, so change Yindex so that we get a
    mov     ax,[Yindex]             ;new set of random (x,y)
    cmp     ax,[Xindex]             ;does Xindex = Yindex?
    jne     NotTheSame              ;if the index were the same, you'd see 
                                    ;a graph of the line Y = X, not good...
    inc     [Yindex]                ;if they are the same, inc Yindex again
NotTheSame:
    mov     [Xindex],0              ;reset Xindex to 0
XindNotZero:                        ;all done making the star...

NoEmptySpace:
    popa
    ret
MakeStar ENDP

DisplayStars PROC NEAR
    pusha
    mov     ax,cs
    mov     ds,ax
    mov     ax,0a000h
    mov     es,ax

    mov     si,0
DispLoop:
    mov     cx,[Stars.Z+si]
    or      cx,cx                   ;if Zpos = 0 then this star is dead...
    je      Cont                    ;continue to the next one- skip this one

    mov     di,[Stars.OldDi+si]     ;grab old Di
    mov     byte ptr es:[di],0      ;erase the star
    
    cmp     cx,MinZpos
    jl      TermStar                ;if Zpos < MinZpos then kill the star

    mov     ax,[Stars.Y+si]
    movsx   dx,ah                   ;'multiply' Ypos by 256
    shl     ax,8
    
    idiv    cx                      ;and divide by Zpos
    add     ax,ScreenHeight/2       ;center it on the screen
    mov     di,ax
    cmp     di,ScreenHeight         ;see if the star is in range. 
    jae     PreTermStar             ; If not, kill it
    imul    di,ScreenWidth          ; DI = Y*ScreenWidth

    mov     ax,[Stars.X+si]
    movsx   dx,ah                   ;multiply Xpos by 256
    shl     ax,8

    idiv    cx                      ;and divide by Zpos
    add     ax,ScreenWidth/2        ;center it on the screen
    cmp     ax,ScreenWidth          ;are we inside the screen boundries?
    jae     PreTermStar
    add     di,ax                   ; DI = Y * ScreenWidth + X

    mov     [Stars.OldDi+si],di     ;save old di

    ;calculate the color below

    add     ch,cs:[Stars.Color+si]  ;i'm dividing cx (the zpos) by 256 and
                                    ; putting the result in ch and adding
                                    ; the base color to it in one instruction
    mov     es:[di],ch              ;put the dot on the screen

    mov     ax,cs:[WarpSpeed]
    sub     cs:[Stars.Z+si],ax      ;move the stars inward at WarpSpeed

Cont:
    add     si,StarStrucSize        ;point to next record
    cmp     si,MaxStars*StarStrucSize   ;are we done yet?
    jb      DispLoop
    popa
    ret

PreTermStar:
    mov     [Stars.Z+si],1  ;this is here so that the star will get erased
    jmp     short Cont      ;next time through if I just went off and killed
                            ;the star, it would leave a dot on the screen
TermStar:
    mov     [Stars.Z+si],0  ;this actually kills the star, after it has
    dec     [NumActive]     ;been erased
    jmp     short Cont

DisplayStars ENDP

;=== CODE

START:
    mov     ax,cs
    mov     ds,ax
    mov     es,ax

    mov     ax,0013h                ;set vid mode 320x200x256 graph
    int     10h
    
    mov     dx,offset Palette
    mov     ax,1012h                ; WRITE palette 
    mov     bx,0                    
    mov     cx,256                  ;write entire palette
    int     10h                     ;doesn't matter if we didnt define it all

StarLoop:
    call    MakeStar        ;make stars 2x as thick
    call    MakeStar

    mov     dx,3dah
VRT:
    in      al,dx
    test    al,8
    jnz     VRT             ;wait until Verticle Retrace starts

NoVRT:
    in      al,dx
    test    al,8
    jz      NoVRT           ;wait until Verticle Retrace Ends

    call    DisplayStars

    mov     ah,1            ;check to see if a char is ready
    int     16h
    jz      StarLoop        ;nope, continue
    
    mov     ah,0
    int     16h             ;get the character & put in AX

    cmp     al,"+"          ;compare ASCII part (al) to see what was pressed
    jne     NotPlus

    inc     [WarpSpeed]
    cmp     [WarpSpeed],MaxWarp
    jbe     StarLoop

    mov     [WarpSpeed],MaxWarp
    jmp     StarLoop

NotPlus:
    cmp     al,"-"
    jne     NotMinus

    dec     [WarpSpeed]
    cmp     [WarpSpeed],0
    jge     StarLoop

    mov     [WarpSpeed],0
    Jmp     StarLoop

NotMinus:

    mov     ax,0003h        ;set 80x25x16 char mode
    int     10h
    mov     ax,4c00h        ;return control to DOS
    int     21h
END START
