ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;     TITLE: 2d rotate
;WRITTEN BY: DRAEDEN /VLA CODER /iCE VGA CODER
;       FOR: Phantasm, (206) 232-5912
;               The first programing oriented board to hit the 206 area.
;               Any questions regarding this or ANY code in any language
;               can, and will be answered on Phantasm.
;               Send messages to 'Draeden' or post in the VLA programming
;               section.
;
;            The Deep (TDT/VLA), (305) 888-7724
;               Our first distribution site.  Messages will also be answered
;               if posted at this location.
;               Send messages to 'The Kabal'.
;
;      DATE: 02/13/93
;
;     NOTES: Compiled with TASM, TLINK
;            Must have a 386 or better to run. Any speed.
;            This program was chosen as an example because it utilizes
;            a lot of the neat little tricks you can do in assembly,
;            mainly Structures (STRUC), Unions (UNION), INCLUDEs,
;            the REPT macro, and the DUP() macro.
;
;ASSOCIATED FILES:
;
;       BWPRINT.ASM =>  Displays signed and unsigned bytes, words, or
;                    >  double words
;
;       SINCOS.DW   =>  Contains data for the sine and cosine operations
;
;       ROTATE.TXT  =>  A text file that further explains how to rotate
;                    >  objects, what BWPRINT.ASM does, and
;                    >  what the SINCOS.DW file is.
;
;       MAKE.BAT    =>  The file that'll put it all together into an .EXE
;
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    
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

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;=== GLOBALS  -used to link multiple programs together

GLOBAL  PrintByte:PROC, PrintWord:PROC, PrintBig:PROC
    ;above is for the file BWPRINT.ASM

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;=== Data Includes -include physically puts the file in this one on compile
                    
INCLUDE sincos.dw       ;Labels SINE: and COSINE: contains sine(0-255)*256

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;=== DATA Structures
    
    Angle_Union     UNION
        B       db  0
        W       dw  0
    Angle_Union     ENDS    ;creates a new data type (eg. DW, DB, DD) called
                            ;Angle_Union. Used just like in C
    Point_Struc     STRUC
        X       dw  ?
        Y       dw  ?
    Point_Struc     ENDS    ;Create a structure (or a record)

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;=== DATA

NumPts      EQU 8

XYCord      Point_Struc <-50,50>,<50,50>,<-50,-50>,<50,-50>
            Point_Struc <-30,30>,<30,30>,<-30,-30>,<30,-30>
    ;sets up data for the corners of a 2d box

RotCord     Point_Struc NumPts DUP(<>)

OldDi       dw  NumPts DUP (0)  ;holds di for quick erasing

Angle       Angle_Union <?,?>   ; the '?' defaults to zero, but you can't
                                ;specify in a Union
AngleVel    db  1       ;angle velocity

AddX        dw  160     ;amount to ADD to each X cordinate
AddY        dw  100     ;amount to ADD to each Y cord

Palette     db  3 dup (0)   ;sets up a palette that fades from (0,0,0) to
    i = 1                   ;(15*4,15*3,15*2) in 16 steps
    REPT    15
            db  4*i,3*i,2*i
        i=i+1
    ENDM

Color       db  15

AngleMsg    db  "ANGLE: $"
AngleVelMsg db  "VELOCITY: $"

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;=== Code Includes  ;none.
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;=== SUBROUTINES

    ;DESTROYS: ax, edx, edi, si, ebp
    ;Input: BX= X CX= Y which are rotated Angle degrees
    ;OutPut:BX= X CX= Y
RotateXY proc near
    push    ds
    mov     ax,cs                   ;the basic formula for rotations:
    mov     ds,ax                   ; X := cos(angle) * x - sin(Xan) * y
                                    ; Y := sin(angle) * x + cos(Xan) * y
    mov     si,[Angle.W]
    add     si,si                   ; si = angle*2
    mov     ax,[Cosine+si]          ; ax = cos(angle)
    imul    bx                      ; ax = cos(angle) * x
    shl     edx,16                  ; put dx in high edx
    mov     dx,ax                   ; save all 32 bits
    mov     edi,edx                 ; store for later use

    mov     ax,[Sine+si]            ; ax = sin(angle)
    imul    cx                      ; ax = sin(angle) * y
    shl     edx,16
    mov     dx,ax
    sub     edi,edx                 ; edi = edi-eax=cos(angle)*x-sin(angle)*y
    sar     edi,8                   ; remove the "256-factor"
    mov     ebp,edi                 ; ebp = x-coordinate

    mov     ax,[Sine+si]            ; ax = sin(angle x)
    imul    bx                      ; ax = sin(angle x) * x
    shl     edx,16
    mov     dx,ax
    mov     edi,edx

    mov     ax,[Cosine+si]          ; ax = cos(angle x)
    imul    cx                      ; ax = cos(angle x) * y
    shl     edx,16
    mov     dx,ax
    add     edi,edx                 ; di = di-ax = sin(vx)*y + cos(vx)*z
    sar     edi,8                   ; remove the (co)sin "256-factor"

    mov     bx,bp                   ; update X
    mov     cx,di                   ; update Y

    pop     ds
    ret
RotateXY    ENDP

    ;rotates all points and saves them
RotateBox   PROC NEAR
    pushad          ;saves EVERYTHING (extended registers, too), except flags
    mov     ax,cs
    mov     ds,ax
    mov     es,ax

    mov     bp,0    ;point counter
@@DoNextPoint:
    mov     bx,[XYCord.X +bp]   ;load in cordinates to rotate
    mov     cx,[XYCord.Y +bp]
    push    bp
    call    RotateXY
    pop     bp

    mov     [RotCord.X +bp],bx  ;save rotated cordinates IN A DIFFERENT PLACE
    mov     [RotCord.Y +bp],cx

    add     bp,4            ;size of each entry
    cmp     bp,NumPts*4     ;are we done, yet?
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
@@DoNextPoint:
    mov     si,bp
    add     si,si
    mov     bx,si       ;bx= bp*2
    add     si,si       ;si= bp*4

    mov     di,[OldDI+bx]
    mov     BYTE PTR es:[di],0  ;clear out old point

        ;pixel location = ScreenWidth*Ypos + Xpos = 320 * (Y+AddY) + X + AddX
    mov     di,[RotCord.Y +si]
    add     di,[AddY]
    imul    di,320
    add     di,[AddX]
    add     di,[RotCord.X +si]
    
    mov     [OldDi+bx],di
    stosb

    inc     bp
    cmp     bp,NumPts       ;are we done, yet?
    jb      @@DoNextPoint   ;No. Do another

    popa
    ret
DrawBox     ENDP

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;=== CODE

START:
    mov     ax,cs
    mov     ds,ax
    mov     es,ax

    mov     ax,0013h                ;set 320x200x256 mode
    int     10h
    
    mov     dx,offset Palette       ;ES:DX points to palette data
    mov     ax,1012h                ; WRITE palette 
    mov     bx,0                    ;start at color 0                   
    mov     cx,16                   ; and write 16 of 'em
    int     10h

    mov     dx,03d5h        ;this bit of code turns the cursor OFF
    mov     al,0ah          ;by setting bit 5 of index 0ah to 0
                            ;(CRT controll register selector = 03d5h)
    mov     ah,0            ;this is done because some video cards
    out     dx,ax           ;do not always turn off the cursor in
                            ;graphics mode
                            ;(note: it also turns all the other bit to 0)
BoxLoop:
    call    RotateBox
    mov     al,[AngleVel]
    add     [Angle.b],al    ;note that by just increasing the byte part, the 
                            ;ranging is automatic (stays in 0-255 range)
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
    
    mov     ah,2
    mov     bx,0
    mov     dx,0
    int     10h         ;set cursor pos to (dl,dh) on page BX

    mov     ah,9
    mov     dx,offset AngleMsg
    int     21h

    mov     al,[Angle.B]
    clc                 ;says print it unsigned
    call    PrintByte
    
    mov     ah,2
    mov     bx,0
    mov     dx,0014h
    int     10h         ;set cursor pos to (dl,dh) on page BX

    mov     ah,9
    mov     dx,offset AngleVelMsg
    int     21h

    mov     al,[AngleVel]
    stc                 ;says print it signed
    call    PrintByte

    mov     ah,1
    int     16h         ;has a key been pressed? Z flag is set if not
    jz      BoxLoop
    mov     ah,0        ;a key has been pressed, 
    int     16h         ; get it in AX (al= ascii, ah=scan code)

    cmp     al,27       ;was it the ESCAPE key?
    je      ByeBye      ;Yup, take off

    cmp     al,"+"          ;increases angle velocity
    jne     NotPlus
    inc     [AngleVel]
    jmp     SHORT BoxLoop
NotPlus:
    cmp     al,"-"          ;decreases angle velocity
    jne     NotMinus
    dec     [AngleVel]
    jmp     SHORT BoxLoop
NotMinus:
    cmp     al," "          ;will reset the angle velocity to Zero
    jne     NotSpace
    mov     [AngleVel],0
    jmp     BoxLoop
NotSpace:
    cmp     al,13           ;will reset the angle to zero
    jne     NotEnter
    mov     [Angle.W],0
    jmp     BoxLoop
NotEnter:

    jmp     BoxLoop

ByeBye:    
    mov     ax,0003h    ;set 80x25x16 text
    int     10h
    mov     ax,4c00h    ;return control to DOS
    int     21h
END START
