;
; Did you realize that this is:
;   Just Another Generic Loader!
;
; Coded by Air Richter [HaRDCoDE '94] (the Original Keyboard Handler)
;
; A generic loader with all that stuff listed in the main module.  This
; module in particular has pivitol importance due to the fact that the
; lovely star scroller code can be found here.
;
; HOLY SHIT!  Could it be another horizontal STAR SCROLLER?!?  My GOD,
; what has come over our hero Air Richter to make him torture the pub-
; lic with such progamming trash?
;

Include video.mac

Ideal
Model Small
P386

Include "video.inc"
Include "loader.inc"


Segment CoDe Public DWord 'Code'
Assume Cs:CoDe


;============================================================================
;
; Proc: UpdateStars
;
; Erases and redraws stars. Stars are serviced every frame.  All stars,
; including level three (which are not moved) are redrawn so that they will
; reappear when the text and flames change position.  Stars are also drawn
; OVER any pixels that are of a color below or equal to 19.
;        
;============================================================================

Proc UpdateStars

        Call    EraseStars
        Mov     Si,[StarPtr1]            ; Get offset to display stars
        Add     Si,200 * 2 - 2              
        Mov     Bl,19                    ; Bx = Register optimization
             
; ----> Draw level 3 stars <----

        Mov     Cx,105
        Mov     Al,1                     ; Al = Color of this level stars
        Call    PlotStars

; ----> Draw Level 2 stars <----

        Mov     Cx,65
        Mov     Al,2
        Call PlotStars
        
; ----> Draw Level 1 stars <----

        Mov     Cx,30
        Mov     Al,3
        Call    PlotStars

        Ret     

EndP UpdateStars


;============================================================================
;
; Proc: PlotStars
;
; Plots a given number of pixels with a certain color.  Checks if there is
; a colored pixel already below, and if so no star is drawn.
;                                                           
; Note:
;   This procedure is sheerly a size optimization.  If this had been in a
; demo, I would have replaced the above call statements with the code below.
; Size is an issue here, however.                                                                          
;                      
; InRegs:
;   Al - Color of Stars
;   Cx - Number of stars to plot
;   Si - Pointer to star location buffer
;   Bl - Maximum color value for a star overwrite
;
;============================================================================

Proc PlotStars

@@Disp1:Mov     Di,[Si]                  ; Di = Address in Video Mem of star
        Sub     Si,2
        Cmp     [Byte Es:Di],Bl          ; Do not plot star if something is
        Ja      @@NoS1                   ;  under it...
        Stosb
@@NoS1: Loop    @@Disp1
        
        Ret
        
EndP PlotStars

                         
;============================================================================
;
; Proc: EraseStars
;
; Clears the stars (by using the old star buffer info) before the redrawing
; procedure does its work.
;
;============================================================================

Proc EraseStars

; ----> Clear levels 1 and 2 stars <----
           
        Mov     Si,[StarPtr2]
        Mov     Cx,95
        Xor     Al,Al
@@Disp1:
        Mov     Di,[Si]
        Add     Si,2  
        Cmp     [Byte Es:Di],3
        Ja      @@Deez
        Stosb
@@Deez: Loop    @@Disp1
        
        Ret
        
EndP EraseStars


;============================================================================
;
; Proc: HorizStars
;
; Increments star positions horizontally to the right.  Higher level stars
; are scrolled faster than lower level, giving the impression of 3-D.  All
; stars are wrapped across the screen both on the right and on the bottom.
; This is done because it is small and fast.  It eliminates any need for
; range checking or location overrides.
;                                                                         
;============================================================================

Proc HorizStars
                     
        Push    Es Ds
        Pop     Es                      ; Es = Data Segment

        Call    CopyStars               ; Make both buffers equal
        Mov     Si,[StarPtr1]
        Mov     Di,[StarPtr2]
        Mov     Cx,30                   ; Level 1 has 30 stars
@@IncStar1:
        Lodsw
        Inc     Ax
@@NCh1: Stosw
        Loop    @@IncStar1

; ----> Level 2 update (every other call)

        Dec     [Lev2]                  ; Service level 2 stars every other call
        Jnz     @@SkipStar
        Mov     [Lev2],4
        Mov     Cx,65                   ; Level 2 has 65 stars
@@IncStar2:
        Lodsw
        Inc     Ax
@@NCh2: Stosw
        Loop    @@IncStar2

@@SkipStar:
        Mov     Ax,[StarPtr1]           ; Exchange Buffer pointers 1 and 2
        Xchg    Ax,[StarPtr2]
        Mov     [StarPtr1],Ax

        Pop     Es   
@@Skip: Ret

EndP HorizStars
           

;============================================================================
; 
; Proc: CopyStars
;
; The double star buffer concept:
;   One star buffer is needed so that the stars that are already on the
;   screen can be cleared before the next stars are displayed.  This allows
;   for the program to do all possible calculations, and then display without
;   much thinking (which, in turn, helps reduce flicker).
;                                                                  
; So that both buffers keep up with the current information of the star
; levels two and three, the buffers are periodically copied over each other.
;      
; Es = Data Segment
;
;============================================================================

Proc CopyStars

        Mov     Si,[StarPtr1]
        Mov     Di,[StarPtr2]
        Mov     Cx,50                   ; Copy 200 bytes (100 stars)
        Rep     Movsd                   ;  Only top two levels need be copied

        Ret

EndP CopyStars                       
EndS CoDe
End
                      
 