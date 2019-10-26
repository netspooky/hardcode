;
; Yep, This is:
;   Just Another Generic Loader!
;
; Coded by Air Richter [HaRDCoDE '94] (the Master in Disguise)
; Moon drawn by Pinball Wizard
;
;   Additional thanks:    
;     Rao and Red Penguin [HaRDCoDE]
;     Pel [Psychic Monks] for his wonderful flame code
; 
; A generic loader with stars, flames, copper bars, and a text scroller. Any-
; thing else of generic value that I might have left out will be in my next 
; loader entitled `Just Another Generic Loader ]['
;
; HEY!  WAIT A MINUTE!  Where's the cool SB/GUS muzak?
;    Well, if you really want some music, run your favorite player and
;    shell to DOS.                                                                
;
; Side Note:
;   If this loader is not commented well enough for you to understand for the
; most part how it works and why, then you surely need more help than some
; example source code can provide.  However, if anyone has any questions they
; need answered either about this or anything else, I am willing to help.
;
; Air Richter can be contacted at:
;
;    Internet: 
;       jstine@is.isnet.wfu.edu       (temporary - expires June 1995)
;       dstine@acme.highpoint.edu 
;                                                                           
                  
Include video.mac

Ideal
Model Small
P386

Include "video.inc"
Include "loader.inc"

Segment STaCK Public DWord Stack 'Stack'
      Db 300h Dup(?)
EndS STaCK

                   
; -----> Data Segment <-----
                   
Segment DaTa Public DWord 'Data'

Include "moon1.img"
;Include "moon2.img"


; -----> Some Data Notes + Stuff...
;
; The FlipText structure format looks something like this:
;
;   Dw   CharPtr       --->   Pointer to character font data
;   Dw   XCount        --->   Counter (VRs to wait before starting flip)
;   Dw   ScrnPtr       --->   Pointer to address onscreen to display char
;   Db   CharHeight    --->   Character height (8 or 16)
;   Db   CharWidth     --->   Current char's displayed width
; 
; (Buffers FlipText and FlipText2 are stored in this format) 
                                                      

FLSEED    = 2+4*4             ; Initial Flames Seed - Only the first number
   ; Larger values designate  ;  should be changed.  The 4*4 is what subtracts
   ; shorter flames.          ;  16 from the preaveraged value of each pixel.
                              ;  (see the flame procs for more info)                                              
XDOTS     = 104               ; Buffer Screen Dimensions in Pixels
YDOTS     = 94
HIDDEN    = 9                 ; Number of Hidden Working Lines
TOPSEED   = XDOTS * (YDOTS + HIDDEN - 2)

CTR_NUMPARA   = 6             ; Number of messages in the center
UNFOLD_DELAY1 = 320           ; Delay for the text.  These number represent
UNFOLD_DELAY2 = 120           ;  the number of screen updates to wait before      
FOLD_DELAY1   = 55            ;  moving onto the next string paragraph.
FOLD_DELAY2   = 75

; -----> Palette used in this demo

label   Palette byte                    ; Flames RGB Palette:

        db   0,0,0
        I=23                            ; Stars (black + three shades of grey)
        rept 3
        db   I,I,I
        I=I+12
        endm

        I=0                             ; black to blue
        rept 6
        db   0,0,(2*I) + 2
        I=I+1
        endm

        I=0                             ; darkblue to midblue
        rept 10 
        db   0,0,14-I  
        I=I+1
        endm

        I=0                             ; midblue to brightblue
        rept 24
        db   0,0,16+47*I/24
        I=I+1
        endm

        I=0                             ; brightblue to lightblue/cyan
        rept 32
        db   0,31*I/16,63
        I=I+1
        endm

        I=0                             ; lightblue/cyan to white
        rept 24
        db   21*I/8,63,63
        I=I+1 
        endm 

; Set palette font please

        I=0                             ; This is the Green palette used by
        rept 16                         ;  the lovely text in the corner.
        db   0,I,0
        I=I+1
        endm
        I=0
        rept 48        
        db   I/3,I+16,I/2
        I=I+1              
        endm

        I=0                             ; This is the Yellow palette used by
        rept 16                         ;  the lovely text in the center!
        db   I,I,0
        I=I+1
        endm
        I=0
        rept 48        
        db   I+16,I+16,I/3
        I=I+1              
        endm
        
; Moon1 and Logo Palette

        I=0
        rept 8                          ; Dark moon colors (the clouds)
        db   I,I,I
        I=I+2
        endm
        
        I=10 
        rept 8                          ; Bright moon colors (the moon)
        db   I,I,I
        I=I+5
        endm
        
        rept 14                         ; The rest is black!
        db 0,0,0
        endm
        
; ----> Loader Text <----
;
;   Format of each string: 
;     Dw   TimeDelay, DisplayLocation
;     Db   String,LineEnd (13) or ParagraphEnd (0 - 12)
;               
; 1)  A LineEnd designates that the next chars will be a new string, and there-
;     fore will be preceeded by the TimeDelay and DisplayLocation information.
; 2)  A ParagraphEnd designates the end of an entire text segment.  The string
;     processor runs until it encounters this.  Often, I did not specifically
;     use a byte to designate this, since the TimeDelay byte of the next para-
;     graph, in most cases, is below 13.
;                                                                            

; ----> Text in upper/left hand corner <----
  
AText  dw  0,8
       db  2,'H',1,'a',2,'RDC',1,'o',2,'DE ''94',13
       dw  10,14*320 + 38
       db  1,'-WHQ-'  
AText2 dw  0,0
       db  2,'The UnderWírld',13
       dw  14,14*320 + 48 
       db  1,'BBS' 

; ----> Text in center <----
       
AText3 dw  0,53*320 + 63
       db  2,'- The UnderWírld -',13
       dw  5,66*320 + 77             
       db  2,'USR 21.6 HST/DS',13
       dw  9,79*320 + 79 
       db  2,'[91o] 725-755o'       

AText4 dw  5,59*320 + 59
       db  2,'MikMod / XMM WHQ',13
       dw  0,72*320 + 28
       db  1,'Admire / Astek / Inertia',13
       dw  1,80*320 + 21
       db  1,'Digital Infinity Dist Site' 

AText5 dw  10,53*320 + 79
       db  1,'(-> NeTz <-)',13
       dw  3,61*320 + 42
       db  2,'SBC / DGi / GSN / CiP',13
       dw  7,74*320 + 50
       db  2,'SENSE / RUSH / FiDO'                               

AText6 dw  0,53*320 + 90
       db  1,'Running',13
       dw  19,62*320 + 57
       db  2,'PiPELiNE',13
       dw  19,62*320 + 149
       db  1,'BBS',13
       dw  19,70*320 + 129
       db  1,'Software'

AText7 dw  0,58*320 + 36
       db  1,'The credits for this',13
       dw  2,66*320 + 30
       db  1,'loader are as follows:'
              
AText8 dw  0,50*320 + 44
       db  1,'All Code by',13
       dw  8,58*320 + 55
       db  2,'Air Richter [HDC]',13
       dw  15,80*320 + 178
       db  1,'Moon Drawn by',13
       dw  22,88*320 + 188
       db  2,'Pinball Wizard'

APtrTable    dw   o AText3,o AText4,o AText5,o AText6,o AText7,o AText8

Seed         dw   4321h                 ; Random Seed
Lev2         db   2
Lev3         db   2                     ; Flame Frame Counter
StarPtr1     dw   Offset Stars1  
StarPtr2     dw   Offset Stars2

ATextPtr     dw   Offset AText
TimeIncr1    dw   85                    ; Frame Dealy corner text (UnfoldDelay)
TimeIncr2    dw   200                   ; Frame Delay center text (UnfoldDelay)
TimeIncr3    dw   FOLD_DELAY1           ; Frame Delay Corner Text (FoldDelay)
TimeIncr4    dw   FOLD_DELAY2           ; Frame Delay Center Text (FoldDelay)
CheckFlag    dw   0

FlameOfs     dw   200*320 + 4
YLen         db   -70h                 ; # Lines of Flame to Display
ATextPtr2    db   0
Temp         dw   ?    

FlipText     db   16*8 + 2 Dup(?)       ; 'TheUnderWorld BBS' CharFlip Buffer
FlipText2    db   140*8 + 2 Dup(?)      ; Center Text CharFlip Buffer

Stars1       dw   200 Dup(?)
Stars2       dw   200 Dup(?)
Ptr8x8       dd   ?
Ptr8x16      dd   ?
Frame        dw   XDOTS*(YDOTS+HIDDEN) dup(?) ; Flames Frame Buffer


EndS DaTa

 
; -----> Code Segment <-----

Segment CoDe Public DWord 'Code'
Assume Cs:CoDe,Ds:DaTa,Ss:STaCK


;============================================================================
;
; Proc: Loader
;
; Yep, this is `Just Another Generic Loader' by Air Richter of HaRDCoDE '94.
; If you're wondering why I even bothered to program this generic loader,
; feel relieved to know it is because this is all the more my programming
; talents extend.  That's right, I suck the big, hairy one when it comes to
; coding demos and the such.  Welp, later all!
;                                                                       
;============================================================================

Proc Loader

        Mov    Ax,@data ;+ 1
        Mov    Ds,Ax  
        Mov    Fs,Ax
        Mov    Ax,13h                   ; BIOS Std 320x200 256 colors mode
        Int    10h
        Call   SmallInit
        Mov    Ax,0a000h
        Mov    Es,Ax                    ; Es -> Video Memory

; ----> Get the first two strings processed
                                       
        Mov    Si,Offset AText
        Mov    Di,Offset FlipText
        Mov    [Byte BufferHeight + 1],0
        Call   ProcessString

        Mov    Si,Offset AText3
        Mov    Di,Offset FlipText2
        Call   ProcessString
                             
; ----> Display Moon (drawn by Pinball Wizard)

        Mov    Cx,66                    ; Cx = Moon Height
        Mov    Dx,114/2                 ; Dx = Moon Width
        Mov    Bp,320-114               ; Bp = XAdds
        Mov    Bl,228                   ; Bl = Color Increment
        Mov    Si,Offset Moon1
        Mov    Di,320*6 + 202
        Call   DispImage                ; Moon Goes Here...

; ----> The Main Loop <-----> Way Cool! <----

@@MainLoop:
        Call     WaitVR
        Call     StringDraw1            ; Update/Redraw string in the corner
        Call     DispFlames
        Call     UpdateStars
        Call     StringDraw2            ; Update/Redraw string in the center
    
; Redrawing Complete <----> Do Calculations Now

        Call     CalcFlames
        Call     HorizStars                            

; Calculations Complete <----> Check for Escape press

        In       Al,60h
        Cmp      Al,1
        Jnz      @@MainLoop
        
; ----> Exit Code <----
                   
@@Exit: Mov     Ax,3                    ; Std. Text Mode Set
        Int     10h           
        Mov     Ah,4ch                  ; Exit to DOS
        Int     21h
                                 
EndP Loader                 


;=============================================================================
;
; Proc: StringDraw1
;
; Keeps track of and draws the logos and stuff in the upper left hand corner
; of the screen.  Some specifics on this part: 1) It's kinda complex and I
; don't feel like describing it here.  If you want to know how it works,
; email me or call me or something.. I don't care :)
;                                                                      
;=============================================================================

Proc StringDraw1

        Test    [CheckFlag],1         ; Check the fold/unfold flag
        Jnz     @@UnFolded            ; Set means text is unfolded..
        Dec     [TimeIncr1]           ; Are we ready to unfold?
        Jnz     @@NebberMind
  
; ----> Unfold current/next text message

        Dec     [TimeIncr3]           ; TimeIncr3 - 
        Jz      @@UnFoldFinish        ;  Tracks when fold is finished
        Inc     [TimeIncr1] 
        Test    [TimeIncr3],111b      ;  And FoldString called every 8th VR
        Jz      @@NebberMind
        Mov     Bp,Offset FlipText
        Mov     [Cs:ClrAdd1],100
        Call    FoldString_Open
        Ret

; UnFold is finished... Reinitialize string so it may be folded up properly.
; Reinitialize wait and timer variables as well.
               
@@UnFoldFinish:
        Or      [CheckFlag],1         ; Set Unfolded flag!
        Mov     [TimeIncr1],UNFOLD_DELAY1
        Mov     [TimeIncr3],55
        Mov     Si,[ATextPtr]
        Mov     Di,Offset FlipText
        Call    ProcessString
        Ret
        
@@UnFolded:    
        Dec     [TimeIncr1]           ; Wait 100 frames before unfold
        Jnz     @@NebberMind
        
; ----> Fold up current text message

        Dec     [TimeIncr3]           ; TimeIncr3 - 
        Jz      @@FoldFinish          ;  Tracks when fold is finished
        Inc     [TimeIncr1] 
        Test    [TimeIncr3],111b      ;  And FoldString called every 8th VR
        Jz      @@NebberMind
        Mov     Bp,Offset FlipText    ; Address to flip info
        Mov     [Cs:ClrAdd2],100
        Call    FoldString_Close       
        Ret

; ----> Fold up completed <----> Get ready to unfold next paragraph
             
@@FoldFinish:
        Mov     [TimeIncr1],1         ; No delay for unfold!
        Mov     [TimeIncr3],FOLD_DELAY1
        And     [CheckFlag],not 1     ; Clear Fold bit

; ----> Setup pointer to fold other text paragraph the next time around

        Cmp     [ATextPtr],Offset AText
        Je      @@AText2              ; Jump if flipping HDC next
        Mov     [ATextPtr],Offset AText
        Jmp     @@Screw
@@AText2:
        Mov     [ATextPtr],Offset AText2
@@Screw:Mov     Si,[ATextPtr]
        Mov     Di,Offset FlipText
        Call    ProcessString         ; Prepare text again!
         
@@NebberMind:                                                                    
        Ret
                
EndP StringDraw1
        
        
;============================================================================
;
; Proc: StringDraw2
;
; This procedure works much the same as StringDraw1, except for the fact
; that 1) It supports several texts which it cycles through by use of a
; handy dandy pointer chart and 2) the timing is different.                                                                      
;
;============================================================================

Proc StringDraw2

        Test    [CheckFlag],10b       ; Check fold/unfold flag
        Jnz     @@UnFolded
        Dec     [TimeIncr2]           ; Are we ready to unfold?
        Jnz     @@NebberMind
  
; ----> Unfold current/next text message

        Dec     [TimeIncr4]           ; TimeIncr3 - 
        Jz      @@UnFoldFinish        ;  Tracks when fold is finished
        Inc     [TimeIncr2] 
        Test    [TimeIncr4],111b      ;  And FoldString called every 8th VR
        Jz      @@NebberMind
        Mov     Bp,Offset FlipText2
        Mov     [Cs:ClrAdd1],164
        Call    FoldString_Open      
        Ret                        

; UnFold is finished... Reinitialize string so it may be folded up properly.
; And set some variables as well..

@@UnFoldFinish:
        Or      [CheckFlag],10b         ; Set Unfolded flag!
        Mov     [TimeIncr2],UNFOLD_DELAY2
        Mov     [TimeIncr4],FOLD_DELAY2
        Movzx   Bx,[ATextPtr2]
        Mov     Si,[APtrTable + Bx]
        Mov     Di,Offset FlipText2
        Call    ProcessString
        Ret
        
@@UnFolded:    
        Dec     [TimeIncr2]           ; Wait 100 frames before unfold
        Jnz     @@NebberMind
        
; ----> Fold up current text message

        Dec     [TimeIncr4]           ; TimeIncr3 - 
        Jz      @@FoldFinish          ;  Tracks when fold is finished
        Inc     [TimeIncr2] 
        Test    [TimeIncr4],111b      ;  And FoldString called every 8th VR
        Jz      @@NebberMind
        Mov     Bp,Offset FlipText2   ; Address to flip info
        Mov     [Cs:ClrAdd2],164
        Call    FoldString_Close       
        Ret

; ----> Fold up completed <----> Get ready to unfold next paragraph
             
@@FoldFinish:
        Mov     [TimeIncr2],1        ; No delay for unfold!
        Mov     [TimeIncr4],FOLD_DELAY2
        And     [CheckFlag],not 10b  ; Clear Fold bit

; ----> Setup pointer to fold other text paragraph the next time around

        Movzx   Bx,[ATextPtr2]      ; Bx -> Index into a pointer buffer.
        Add     Bl,2                ;  C buffs would find the terminology
        Cmp     Bl,(CTR_NUMPARA-1)*2;  ** (a pointer to a pointer) more
        Jbe     @@Screw             ;  familiar.
        Xor     Bl,Bl               ; <-- Loop back around to first paragraph            

@@Screw:Mov     [ATextPtr2],Bl
        Mov     Si,[APtrTable + Bx]
        Mov     Di,Offset FlipText2
        Call    ProcessString         ; Prepare text again!
         
@@NebberMind:                                                                    
        Ret

EndP StringDraw2


;============================================================================
;
; Proc: SmallInit
;
; Some small, but very vital, initialization code for the loader.  Both star
; randomization and flame buffer clearing are done here.
;                                           
;============================================================================

Proc SmallInit

        Push    Ds
        Pop     Es                       ; Es -> Data Segment

; ----> Initialize TextFold Structure Info for the Kiddies

        Xor     Ch,Ch
        Mov     Di,Offset FlipText + 7
        Mov     Cl,16      
        Xor     Al,Al
@@InitLoop2: 
        Stosb                            ; Set Current Char Width byte to 0
        Add     Di,7                     ; The rest not need initialization
        Loop    @@InitLoop2

        Add     Di,2                     ; Clear second FoldText Buffer 
        Mov     Cl,140      
@@InitLoop1:
        Stosb                            ; Set Current Char Width byte to 0
        Add     Di,7                     ; The rest not need initialization
        Loop    @@InitLoop1                           

; ----> Initialize random stars for the kiddies

        Mov     Cx,200                   ; Make 200 random stars
        Mov     Si,Offset Stars1
@@RandStar:
        Call    Random
        Mov     [Si],Ax
        Mov     [Si + 400],Ax            ; Fill both buffers with a copy
        Add     Si,2
        Loop    @@RandStar

; ----> Some Flames initialization code for the kiddies...

        Mov     Di,Offset Frame 
        Mov     Cx,(XDOTS*(YDOTS+HIDDEN+1)) / 4
        Xor     Eax,Eax
        Rep     Stosd
        
; ----> SoME BioS FoNT iNiTiaLiZaTioN FoR THe KiDDieS!

        Call    DownLoadBios

; ----> Initialize the color palette for red flames + stars

        Mov     Si,Offset Palette       ; Sets Color Palette
        Mov     Cx,768
        Mov     Dx,3C8h
        Xor     Al,Al
        Out     Dx,Al
        Inc     Dx
        Rep     Outsb
    
        Ret

EndP SmallInit


;============================================================================
;
; Proc: Flames
;
; This updates the flames at the bottom of the screen.  Those evil looking
; flames are the real treat of this generic little loader.  The flames are
; actually displayed three times so that they take up MOST of the width of
; the screen (there is also a four pixel buffer area on both the left and
; right).                                                                           
;                                                                            
;============================================================================

Proc DispFlames

        Cmp     [YLen],YDOTS            ; This small segment of code moves
        Je      @@FlamesLoop            ;  the flames up from the bottom of the
        Inc     [YLen]                  ;  screen.
        Cmp     [YLen],1
        Jge     @@FlamesLoop 
        Ret
              
@@FlamesLoop:
        Cmp     [FlameOfs],320 * (200-YDOTS) + 4
        Je      @@FlamesLoops
        Sub     [FlameOfs],320
@@FlamesLoops:
        Mov     [Temp],Offset Frame + XDOTS ; Display the frame to the screen
                                        ; The first line is skipped because 
                                        ; nothing is on it except for some 
                                        ; random garbage dots.
        Mov     Di,[FlameOfs]           ; Flames at the bottom of screen
        Mov     Bl,[YLen]
        Xor     Eax,Eax
        
@@LineLoop:
        Mov     Cx,3                    ; Draw three copies of the image
@@Repeat:
        Push    Cx
        Mov     Si,[Temp]               ; Display First image
        Mov     Cx,XDOTS/4
        Rep     Movsd
        Pop     Cx
        Loop    @@Repeat

        Mov     Eax,0ffffffffh          ; Fill the borders with color 255
        Stosd                           ; 4 + 4 = 8 bytes... 4 on the right
        Stosd                           ;                    4 on the left
        Add     [Temp],XDOTS            ; Display next line in image
        Dec     Bl
        Jnz     @@LineLoop

        Ret
        
EndP DispFlames


;============================================================================
;
; Proc: CalcFlames
;
; Calculates the next flames frame.  The flames are stored in a buffer so
; that they can be updated without the requirement of accessing the video
; memory constantly (which is quite slow).
;
; NOTE:  These flames use an ultracool algorhythm that actually smooths them
;        around the sides (basically, the left and right sides match).  This
;        makes the flames very good for displaying side by side.  There
;        is only one flaw with my method: the left side is one pixel lower
;        than the right.                                          
;                         
;============================================================================

Proc CalcFlames

        Mov     Bp,FLSEED               ; Loads Flames Seed Factor
        Xor     Bh,Bh
                 
; To make it so the flames use colors 4 and up (0-3 are the stars), I subtract
; 16 out of the preaveraged, average, and then add four to the pixel before
; plotting.
       
ByteMe: Mov     Cx,TOPSEED              
        Mov     Si,Offset Frame + 1*XDOTS - 3
FlamesTransform:
        Mov     Al,[Si+2*XDOTS]         ; Each point is set as the average of
        Mov     Bl,[Si]                 ; four pixels to the left below it.
        Add     Ax,Bx                   ;  Example:
        Mov     Bl,[Si+1]               ; P(x,y) = ((P(x-3,y+1) + P(x-2,y+1) +
        Sub     Ax,Bp                   ; P(x-3,y+2) + P(x-3,y+3) - 16) / 4) + 4
        Add     Ax,Bx                   
        Mov     Bl,[Si+1*XDOTS]         ; Averaging the pixels to the left as         
        Add     Ax,Bx                   ; such provides the smoothing across the 
                                        ; edges.
        Sar     Ax,2
        Jge     FlameNotTooLow
        Xor     Ax,Ax
        
FlameNotTooLow:            
        Add     Al,4
        Mov     [Si-1*XDOTS + 3],Al
        Inc     Si           
        Loop    FlamesTransform

; ----> Sets New Random Bottom Flames with Colors from 0 to 127.

        Mov     Si,Offset Frame+1*XDOTS*(YDOTS+HIDDEN-2)
        Mov     Cx,XDOTS
        Xor     Dx,Dx
RandomFlames:
        Call    Random                  ; Use Random to Create a New
        Or      Ax,Ax                   ; Flames Bottom Lines
        Js      NotNewColor
        Call    Random
NotNewColor:
        Sub     Al,35  
        Mov     [Si+1*XDOTS+3],Al       ; To also promote smoothing around
        And     Al,07fh                 ; the edges, two copies of each new
        Mov     [Si],Al                 ; pixel are saved -->
        Add     Si,2                    ;   P(x,y) and P(x+3,y+1)
        Loop    RandomFlames

FlamesExit:
        Ret
        
EndP CalcFlames


;============================================================================
;
; Proc: WaitVR - Waits for the beginning of a vertical retrace.. oh joy.
;
;============================================================================

Proc WaitVR

        Mov     Dx,3DAh
@@1:    In      Al,Dx                   ; First we wait for a VREnd
        Test    Al,8
        Je      @@1
@@2:    In      Al,Dx                   ; Now we wait for a VRStart
        Test    Al,8
        Jne     @@2
        
        Ret                             ; Now at the beginning of a VR                     
        
EndP WaitVR
    
    
;============================================================================
;
; Proc: Random - Returns a random number of 16 bits.
;
;============================================================================

Proc Random
        
        Mov     Ax,[Seed]
        iMul    Ax,8905h               ; originally 8905h
        Inc     Ax
        Mov     [Seed],Ax
        
        Ret             

EndP Random
EndS CoDe
End Loader