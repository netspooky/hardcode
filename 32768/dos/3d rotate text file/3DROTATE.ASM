컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;
;     TITLE: 3d rotate
;WRITTEN BY: DRAEDEN /VLA CODER /iCE VGA CODER
;       FOR: Phantasm, (206) 232-5912
;               The first programing oriented board to hit the 206 area.
;               Any questions regarding this or ANY code in ANY programming
;               language can, and will be answered on Phantasm.
;               Send messages to 'Draeden' or post in the VLA programming
;               section.
;
;            The Deep (TDT/VLA), (305) 888-7824
;               Our first distribution site.  Messages will also be answered
;               if posted at this location.
;               Send messages to 'The Kabal'.
;
;      DATE: 02/25/93
;
;     NOTES: Compiled with TASM 2.51, TLINK 4.0
;            Must have a 386 or better to run, Moderate speed.
;            This program was chosen as an example because it utilizes
;            a lot of the neat little tricks you can do in assembly,
;            mainly Structures (STRUC), Unions (UNION), INCLUDEs,
;            the REPT macro, and the DUP() macro.  It also introduces
;            palette rotates in a less-than-boring application.
;
;ASSOCIATED FILES:
;
;       BWPRINT.ASM =>  Displays signed and unsigned bytes, words, or
;                    >  double words
;
;       SINCOS.DW   =>  Contains data for the sine and cosine operations
;
;       3DROTATE.TXT=>  A text file that further explains palette rotates
;                    >  and the basic 3d stuff.
;
;       MAKE.BAT    =>  The file that'll put it all together into an .EXE
;
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
    
    DOSSEG          ;tells compiler to sort segments according to the
                    ;DOS standards- code, data, stack
    .MODEL SMALL
    .STACK 200h     ;sets up a 512 byte stack
    .DATA           ;starts the data segment (empty)
    .CODE           ;starts the code segment
    .386            ;tells compiler to allow 386 instructions
    ASSUME CS:@CODE, DS:@CODE
                    ;tells compiler to assume offsets are taken from
                    ;the code segment
    LOCALS          ;turns local labels on eg. @@local:

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

;=== GLOBALS  -used to link multiple programs together

GLOBAL  PrintByte:PROC, PrintWord:PROC, PrintBig:PROC
    ;above is for the file BWPRINT.ASM

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

;=== Data Includes -include physically puts the file in this one on compile
                    
INCLUDE sincos.dw       ;Labels SINE: and COSINE: contains sine(0-255)*256

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

;=== DATA Structures
    
    Angle_Union     UNION
        B       db  0
        W       dw  0
    Angle_Union     ENDS    ;creates a new data type (eg. DW, DB, DD) called
                            ;Angle_Union. Used just like in C
    Point_Struc     STRUC
        X       dw  ?
        Y       dw  ?
        Z       dw  ?
                dw  0       ;a blank area to buffer it out to 8 bytes
                            ; this is done so that access to each point
                            ; is rapid; I can use a SHL XX,3 instead of
                            ; a imul XX,6  saving a few cycles...
    Point_Struc     ENDS    ;Create a structure (or a record)

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

;=== DATA

INCXV       EQU   3b00h   ;scan code/ascii code for f1
DECXV       EQU   3c00h   ;f2
INCYV       EQU   3d00h   ;f3
DECYV       EQU   3e00h   ;f4
INCZV       EQU   3f00h   ;f5
DECZV       EQU   4000h   ;f6
INCDV       EQU   4100h   ;f7
DecDV       EQU   4200h   ;f8
StopRot     EQU   3920h   ;space bar
ZeroAN      EQU   1c0dh   ;enter key

IncPV1      EQU   0231h   ;"1"
DecPV1      EQU   0332h   ;"2"
IncPV2      EQU   0433h   ;"3"
DecPV2      EQU   0534h   ;"4"

MaxLag      EQU   15      ;for now, leave at 15

MinDist     EQU   200
MaxDist     EQU   10000
Distance    dw    300
DistanceVel dw    0

STPS        EQU   10      ;size of each step
NST         EQU   100/STPS
NumPts      EQU   NST*NST*NST/2   ;the number of points the program 
                                  ; will rotate and display

  ;uses nested rept macros to build a solid cube
XYZcord  LABEL Point_Struc
    i=-25
    REPT NST/2
      j=-50
      REPT NST
        k=-50
        REPT NST
          Point_Struc <i, j, k>
          k=k+STPS
        ENDM
        j=j+STPS
      ENDM
      i=i+STPS
    ENDM

RotCord     Point_Struc NumPts DUP(<>)    ;holds rotated cordinates

HeadDi      dw    0
OldDi       dw    NumPts*MaxLag DUP (0)   ;holds old di for quick erasing
                                          ;for MaxLag stored frames
OffToCurDi  dw    offset OldDi            ;points to the correct frame
                                          ;to erase and fill
Zan         Angle_Union <?,?>
Yan         Angle_Union <?,?>   ; the '?' defaults to zero, but you can't
Xan         Angle_Union <?,?>   ;specify in a Union
PathAn1     Angle_Union <?,?>
PathAn2     Angle_Union <?,?>
                                
ZanVel      db    1             ;angle velocities
YanVel      db    3
XanVel      db   -2
P1Vel       db    1
P2Vel       db    3

PreAddX     dw    0             ;amount to ADD to each X, Y & Z >BEFORE<
PreAddY     dw    0             ;the distance transforms
PreAddZ     dw    0             ;causes the change to be scaled

PostAddX    dw  160             ;amount to ADD to each X & Y >AFTER<
PostAddY    dw  100             ;the distance transforms

Palette     db  3 dup (0)
            db  14 dup (60,40,30)    

            db  63,0,0
            db  2,0,0
            db  7,0,0
            db  9,0,0
            db 12,0,0
            db 15,0,0
            db 17,0,0
            db 20,0,0
            db 22,0,0
            db 25,0,0
            db 30,0,0
            db 35,0,0
            db 40,0,0
            db 45,0,0
            db 50,0,0
            db 63,0,0

PalTmp      db  32*3 DUP(0)

Color       db  15

AngleMsg    db  "Ang: $"
AngleVelMsg db  "Vel: $"
Control     db  "Control the angular velocity by hitting F1-F6 and 1 & 2",13,10
            db  "The distance is controlled by F7 & F8.  Hit a key to start.$"
Credits     db  13,10,"Coded by Draeden of VLA",13,10,"$"

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;=== Code Includes  ;none.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

;=== SUBROUTINES
    
    ;DESTROYS: ax,dx,si,di,es,ds
    ;Input: BX= X CX= Y BP= Z
    ;OutPut:BX= X CX= Y BP= Z
RotateXYZ proc near
    mov     ax,cs
    mov     ds,ax                       ; X-rotation
                                        ; Y := cos(Xan) * y - sin(Xan) * z
                                        ; Z := sin(Xan) * y + cos(Xan) * z
    mov     si,[Xan.W]
    add     si,si                       ; si = angle x
    mov     ax,[Cosine+si]              ; ax = cos(angle x)
    imul    cx                          ; ax = cos(angle x) * y
    mov     di,dx
    shl     edi,16
    mov     di,ax                       ; store for later use
    mov     ax,[Sine+si]                ; ax = sin(angle x)
    imul    bp                          ; ax = sin(angle x) * z
    shl     edx,16
    mov     dx,ax
    sub     edi,edx                     ; di = di-ax = cos(vx)*y - sin(vz)*z
    sar     edi,8                       ; remove the (co)sin "256-factor"
    mov     es,di                       ; es = x-coordinate

    mov     ax,[sine+si]                ; ax = sin(angle x)
    imul    cx                          ; ax = sin(angle x) * y
    mov     di,dx
    shl     edi,16
    mov     di,ax
    mov     ax,[cosine+si]              ; ax = cos(angle x)
    imul    bp                          ; ax = cos(angle x) * z
    shl     edx,16
    mov     dx,ax
    add     edi,edx                     ; di = di-ax = sin(vx)*y + cos(vx)*z
    sar     edi,8                       ; remove the (co)sin "256-factor"

    mov     cx,es                       ; update y
    mov     bp,di                       ; update z

                                        ; Y-rotation
                                        ; X :=  cos(vy) * xc + sin(vy) * zc
                                        ; Z := -sin(vy) * xc + cos(vy) * zc
    mov     si,[Yan.W]
    add     si,si                       ; si = angle y
    mov     ax,[Cosine+si]              ; ax = cos(angle y)
    imul    bx                          ; ax = cos(angle y) * x
    mov     di,dx
    shl     edi,16
    mov     di,ax                       ; store for later use
    mov     ax,[Sine+si]                ; ax = sin(angle y)
    imul    bp                          ; ax = sin(angle y) * z
    shl     edx,16
    mov     dx,ax
    add     edi,edx                     ; di = di+ax = cos(vy)*x + sin(vy)*z
    sar     edi,8                       ; remove the (co)sin "256-factor"
    mov     es,di                       ; es = x-coordinate

    mov     ax,[Sine+si]                ; ax = sin(angle y)
    neg     ax                          ; ax =-sin(angle y)
    imul    bx                          ; ax =-sin(angle y) * x
    mov     di,dx
    shl     edi,16
    mov     di,ax
    mov     ax,[Cosine+si]              ; ax = cos(angle y)
    imul    bp                          ; ax = cos(angle y) * z
    shl     edx,16
    mov     dx,ax
    add     edi,edx                     ; di = di-ax = sin(vy)*x - cos(vy)*z
    sar     edi,8                       ; remove the (co)sin "256-factor"

    mov     bx,es                       ; update x
    mov     bp,di                       ; update z

                                        ; Z-rotation
                                        ; X := cos(vz) * xc - sin(vz) * yc
                                        ; Y := sin(vz) * xc + cos(vz) * yc
    mov     si,[Zan.W]
    add     si,si                       ; si = angle z
    mov     ax,[Cosine+si]              ; ax = cos(angle z)
    imul    bx                          ; ax = cos(angle z) * x
    mov     di,dx
    shl     edi,16
    mov     di,ax
    mov     ax,[Sine+si]                ; ax = sin(angle z)
    imul    cx                          ; ax = sin(angle z) * y
    shl     edx,16
    mov     dx,ax
    sub     edi,edx                     ; di = di-ax = cos(vz)*x - sin(vz)*y
    sar     edi,8                       ; remove the (co)sin "256-factor"
    mov     es,di                       ; es = x-coordinate

    mov     ax,[Sine+si]                ; ax = sin(angle z)
    imul    bx                          ; ax = sin(angle z) * x
    mov     di,dx
    shl     edi,16
    mov     di,ax
    mov     ax,[Cosine+si]              ; ax = cos(angle z)
    imul    cx                          ; ax = cos(angle z) * y
    shl     edx,16
    mov     dx,ax
    add     edi,edx                     ; di = di+ax = sin(vz)*x+cos(vz)*y
    sar     edi,8                       ; remove the (co)sin "256-factor"

    mov     bx,es                       ; update x
    mov     cx,di                       ; update y
    
    ret
RotateXYZ   ENDP

    ;rotates all points and saves them
RotateBox   PROC NEAR
    pushad          ;saves EVERYTHING (extended registers, too), except flags
    mov     ax,cs
    mov     ds,ax
    mov     es,ax

    mov     di,0    ;point counter
@@DoNextPoint:
    ;Input: BX= X CX= Y BP= Z
    ;OutPut:BX= X CX= Y BP= Z

    mov     bx,[XYZcord.X +di]   ;load in cordinates to rotate
    mov     cx,[XYZcord.Y +di]
    mov     bp,[XYZcord.Z +di]

    push    di
    call    RotateXYZ
    pop     di

    mov     [RotCord.X +di],bx  ;save rotated cordinates IN A DIFFERENT PLACE
    mov     [RotCord.Y +di],cx
    add     bp,[Distance]
    mov     [RotCord.Z +di],bp

    add     di,8            ;size of each entry
    cmp     di,NumPts*8     ;are we done, yet?
    jb      @@DoNextPoint   ;No. Do another
    
    popad
    ret
RotateBox   ENDP

    ;draws the dots to the screen
DrawBox     PROC NEAR
    pusha               ;saves only non extended registers
    mov     ax,0a000h   ;segment to VGA memory
    mov     es,ax
    mov     ax,cs
    mov     ds,ax
    
    mov     bp,0        ;point counter
    mov     al,[Color]
    mov     bx,[OffToCurDi]
@@DoNextPoint:
    mov     si,bp
    add     si,si
    shl     si,2        ;si= bp*8
    
    mov     ax,[HeadDi]
    add     al,16

    mov     di,cs:[bx]
    cmp     BYTE PTR es:[di],al ;makes sure that we only erase the dots we
                                ;are sposed to.. works OK, BUT because we
                                ;erase and draw to the same frame, a dot 
                                ;that we just drew in this loop could be 
                                ;erase, causing black spots in the object
                                ;zoom it out too see what I'm saying
    jne     NotMineDontErase
    mov     BYTE PTR es:[di],0  ;clear out old point

NotMineDontErase:

    ;pixel location = ScreenWidth*Ypos + Xpos = 320 * (Y+AddY) + X + AddX
    mov     cx,[RotCord.Z +si]
    add     cx,[PreAddZ]
    
    mov     ax,[RotCord.Y +si]
    add     ax,[PreAddY]
    movsx   dx,ah
    shl     ax,8
    idiv    cx              ;you are witnessing the evils of depth emulation-
    add     ax,[PostAddY]   ; the divide that you just can't get rid of
    mov     di,ax
    cmp     di,200
    jae     DontDraw
    imul    di,320

    mov     ax,[RotCord.X +si]
    add     ax,[PreAddX]
    movsx   dx,ah
    shl     ax,8
    idiv    cx              ;Aaarrrgghh! Another one!
    add     ax,[PostAddX]
    cmp     ax,320
    jae     DontDraw
    add     di,ax
    mov     [bx],di

    mov     ax,[HeadDi]
    add     al,16
    stosb
RESUMEDRAW:
    add     bx,2
    inc     bp
    cmp     bp,NumPts       ;are we done, yet?
    jb      @@DoNextPoint  ;No. Do another

    ;adjust head pointer
    call    ChangePalette

    inc     [HeadDi]
    cmp     [HeadDi],MaxLag
    jb      NotAtEnd
    mov     [HeadDi],0
NotAtEnd:
    mov     bx,[Headdi]
    add     bx,bx
    imul    bx,NumPts
    add     bx,offset OldDi
    mov     [OffToCurDi],bx

    popa
    ret
DontDraw:
    mov     byte ptr [bx],0
    jmp     short RESUMEDRAW
DrawBox     ENDP

ChangePalette   PROC NEAR
    pusha
    mov     ax,cs
    mov     ds,ax
    mov     es,ax

    mov     si,offset Palette+3*15
    mov     di,offset PalTmp
    mov     bp,[HeadDi]

    mov     cx,bp     ;this bit of code is a quick way to
    add     bp,bp     ;
    add     bp,cx     ;multiply bp by 3
    
    add     di,bp     ;sets up for copy #1
    mov     cx,16*3
    sub     cx,bp
    rep     movsb     ;copies block #1

    or      bp,bp
    je      NoBlock2

    mov     di,offset PalTmp
    mov     cx,bp
    rep     movsb

NoBlock2:
    mov     al,16             ;we start the write at color #16
    mov     dx,03c8h
    out     dx,al
    inc     dx
    mov     si,offset PalTmp
    mov     cx,16*3           ;write 16 colors (3 bytes per color)
    rep     outsb

    popa
    ret
ChangePalette   ENDP

    ;DESTROYS: flags and AX
    ;updates all the distances, angles, ect...
AddAngles PROC NEAR
    mov     ax,[DistanceVel]
    add     [Distance],ax
    cmp     [Distance],MinDist
    jge     DistMinOk
    mov     [DistanceVel],0
    mov     [Distance],MinDist
DistMinOk:
    cmp     [Distance],MaxDist
    jle     DistMaxOk
    mov     [DistanceVel],0
    mov     [Distance],MaxDist
DistMaxOk:
    mov     al,[P1Vel]
    add     [PathAn1.b],al
    mov     al,[P2Vel]
    add     [PathAn2.b],al

    mov     al,[ZanVel]
    add     [Zan.b],al
    mov     al,[YanVel]
    add     [Yan.b],al
    mov     al,[XanVel]
    add     [Xan.b],al      ;note that by just increasing the byte part, the 
                            ;ranging is automatic (stays in 0-255 range)

    mov     bx,[PathAn1]    ;this little section of code fixes up the
    add     bx,bx           ;path that the object travels
    mov     ax,[Sine+bx]    ;PathAn1 controls the X-Z PreAdds and 
    mov     cx,[Cosine+bx]  ;PathAn2 controls PreYadd
    sar     ax,3            ;Because the sine and cosine chart are
    sar     cx,4            ;multiplied by 256, dividing by 8 and 16
    mov     [PreAddX],ax    ;is the same as multiplying the (co)sine by 
    mov     [PreAddZ],cx    ;32 and 16 respectivly
                            ;this gives the object a slightly nauseating
    mov     bx,[PathAn2]    ;bobbing pattern
    add     bx,bx
    mov     ax,[Sine+bx]
    sar     ax,4
    mov     [PreAddY],ax
    ret
AddAngles ENDP

    ;DESTROYS: AX,BX,DX, FLAGS
    ;puts all the text up top
DisplayStuff PROC NEAR
    mov     ah,2
    mov     bx,0
    mov     dx,0
    int     10h         ;set cursor pos to (dl,dh) on page BX

    mov     ah,9
    mov     dx,offset AngleMsg
    int     21h

    mov     al,[Xan.B]
    clc                 ;says print it unsigned
    call    PrintByte
    mov     al,[Yan.B]
    clc                 ;says print it unsigned
    call    PrintByte
    mov     al,[Zan.B]
    clc                 ;says print it unsigned
    call    PrintByte
    mov     ax,[Distance]
    clc                 ;says print it unsigned
    call    PrintWord
    
    mov     al,[PathAn1.B]
    clc                 ;says print it unsigned
    call    PrintByte
    mov     al,[PathAn2.B]
    clc                 ;says print it unsigned
    call    PrintByte
    
    mov     ah,2
    mov     bx,0
    mov     dx,0100h
    int     10h         ;set cursor pos to (dl,dh) on page BX

    mov     ah,9
    mov     dx,offset AngleVelMsg
    int     21h

    mov     al,[XanVel]
    stc                 ;says print it signed
    call    PrintByte
    mov     al,[YanVel]
    stc                 ;says print it signed
    call    PrintByte
    mov     al,[ZanVel]
    stc                 ;says print it signed
    call    PrintByte
    mov     ax,[DistanceVel]
    stc                 ;says print it signed
    call    PrintWord

    mov     al,[P1Vel.B]
    stc                 ;says print it signed
    call    PrintByte
    mov     al,[P2Vel.B]
    stc                 ;says print it signed
    call    PrintByte

    ret
DisplayStuff ENDP

    ;DESTROYS: a bunch of registers
    ;does all the keyboard oriented stuff..
    ;clears carry if we are to continue, sets it if we are to quit
DoKeyInput PROC NEAR
    mov     ah,11h
    int     16h         ;has a key been pressed? Z flag is set if not
    jnz     GetTheKey
    clc                 ;we continue
    ret

GetTheKey:
    mov     ah,10h      ;a key has been pressed, 
    int     16h         ; get it in AX (al= ascii, ah=scan code)

    cmp     al,27       ;was it the ESCAPE key?
    jne     KeepGoing
    stc                 ;we signal a quit
    ret

KeepGoing:              ;despite its apparent ungainly look, this
    cmp     ax,INCXV    ;is very fast..as little as 2 clocks for each
    je      DoINCXV     ;unsuccessful compare on the 486 and 5 clocks on
    cmp     ax,DECXV    ;the 386... A rather quick way to do it...
    je      DoDECXV
    cmp     ax,INCYV
    je      DoINCYV
    cmp     ax,DECYV
    je      DoDECYV
    cmp     ax,INCZV
    je      DoINCZV
    cmp     ax,DECZV
    je      DoDECZV
    cmp     ax,INCDV
    je      DoIncDV
    cmp     ax,DECDV
    je      DoDecDV
    cmp     ax,ZEROAN
    je      DoZeroAn
    cmp     ax,STOPROT
    je      DoStopRot

    cmp     ax,INCPV1
    je      DoIncPv1
    cmp     ax,DECPV1
    je      DoDecPv1
    cmp     ax,INCPV2
    je      DoIncPv2
    cmp     ax,DECPV2
    je      DoDecPv2

    clc               ;no valid keypress... Continue
    ret

DoINCXV:
    inc     [XanVel]
    clc
    ret
DoINCYV:
    inc     [YanVel]
    clc
    ret
DoINCZV:
    inc     [ZanVel]
    clc
    ret
DoDECXV:
    dec     [XanVel]
    clc
    ret
DoDECYV:
    dec     [YanVel]
    clc
    ret
DoDECZV:
    dec     [ZanVel]
    clc
    ret
DoINCDV:
    inc     [DistanceVel]
    clc
    ret
DoDECDV:
    dec     [DistanceVel]
    clc
    ret
DoStopRot:
    mov     [XanVel],0
    mov     [YanVel],0
    mov     [ZanVel],0
    mov     [DistanceVel],0
    clc
    ret
DoZeroAn:
    mov     [Xan.W],0
    mov     [Yan.W],0
    mov     [Zan.W],0
    clc
    ret
DoINCPv1:
    inc     [P1Vel]
    clc
    ret
DoDECPv1:
    dec     [P1Vel]
    clc
    ret
DoINCPv2:
    inc     [P2Vel]
    clc
    ret
DoDECPv2:
    dec     [P2Vel]
    clc
    ret

DoKeyInput ENDP
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

;=== CODE

START:
    mov     ax,cs
    mov     ds,ax
    mov     es,ax

    mov     ah,9              ;print a dollar sign terminating string
    mov     dx,offset control
    int     21h 

    mov     ah,0
    int     16h             ;wait for a keypress

    mov     ax,0013h                ;set 320x200x256 mode
    int     10h
    
    mov     dx,offset Palette       ;ES:DX points to palette data
    mov     ax,1012h                ; WRITE palette 
    mov     bx,0                    ;start at color 0                   
    mov     cx,16                   ; and write 16 of 'em
    int     10h

MainLoop:
    call    RotateBox
    call    AddAngles

    mov     dx,3dah
VRT:
    in      al,dx
    test    al,8
    jnz     VRT         ;wait until Verticle Retrace starts
NoVRT:
    in      al,dx
    test    al,8
    jz      NoVRT       ;wait until Verticle Retrace Ends

    call    DrawBox  
    call    DisplayStuff
    call    DoKeyInput
    jnc     MainLoop     ;jump if carry is clear
    
ByeBye:    
    mov     ax,0003h    ;set 80x25x16 text
    int     10h
    push    cs
    pop     ds
    mov     ah,9
    mov     dx,offset credits
    int     21h
    mov     ax,4c00h    ;return control to DOS
    int     21h
END START
