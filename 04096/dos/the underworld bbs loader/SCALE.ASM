;
; Hmm, could it be worse than
;   Just Another Generic Loader?
;
; Coded By Air Richter [HaRDCoDE '94] (I think I'm running out of one-liners)
;
; Scaling and regular display routines.  There is X Scaling and X Scaling with
; left and right pixels cleared.
;

Include video.mac

Ideal
Model Small
P386

Include "cmds.inc"
Include "video.inc"
Include "loader.inc"


; ----->  Data Segment  <-----
             
Segment DaTa Public DWord 'Data'

YYInc     Dw ?

EndS DaTa


; ----->  Code Segment  <-----

Segment CoDe Public DWord 'Code'
Assume Cs:CoDe,Ds:DaTa

;==============================================================================
;
; Proc: DispImage
;
; Displays the pointed to image.  Uses the variables defined in this module
; for image buffer height and width.  The image must be in 16 color format.
;            
; InReg Values:
;   Si -> Buffer/Image Ptr                                                       
;   Di -> Display location onscreen
;   Dx  - Buffer/Image Width
;   Cx  - Buffer/Image Height
;   Bp  - XAdds
;   Bl  - Color Increment
;  
;==============================================================================

Proc DispImage

@@DDVolvo:
        Push   Cx
        Mov    Cx,Dx                     ; Cx = Width of Image
@@Short:
        Lodsb
        Mov    Ah,Al
        Shr    Al,4                      ; write out top bits
        Jz     @@Zero1                   ; Skip color increment if color is 0
        Add    Al,Bl                     
@@Zero1:Stosb
        And    Ah,0fh                    ; Now mask out top bits
        Jz     @@Zero2                   ; Color increment skip check here too
        Add    Ah,Bl                     
@@Zero2:Mov    [Es:Di],Ah                ; And write in lower bits
        Inc    Di
        Loop   @@Short
        
        Add    Di,Bp                     ; Increment to next line
        Pop    Cx
        Loop   @@DDVolvo                             

        Ret
        
EndP DispImage
 

;==============================================================================
;
; Proc: DispImg_SclX
;
; Displays the pointed to image scaled along the X axis to either a larger or
; smaller size.  It works by creating an 8 bit fixed point variable which de-
; fines the number of pixels to skip each cycle.  This also works for sit-
; uations where each pixel is displayed more than once. (ie, NewWidth > OldWidth) 
; Uses the variables defined in this module for image buffer height and width.
;              
; InRegs:
;   Si          -> Buffer of Image to Display
;   Ds          -> Segment of image
;   Di          -> Offset into VidMem
;   [Cs:XAddsX]  - ScreenWidth (320) - NewImageWidth 
;   [Cs:ClrAdd1] - Color Offset (ie, colors 0-64 displayed as 64-128)
;   Dx:Ax        - Old Buffer Width * 256
;   Cx           - New Image Width on-screen
;                                             
;==============================================================================

Proc DispImg_SclX

; ----> Establish a horizontal pixel skip factor

        Div    Cx
        Mov    Bp,Ax                     ; Bp = NewWidth / OldWidth
        Mov    Dx,Cx                     ; Dx = New Width of Image
        Xor    Bx,Bx

; ----> Done with that <----> Time to plot the image
       
        Mov    Cx,[Fs:BufferHeight]      ; Cx = Height of image
@@DDVolvo:
        Push   Cx
        Mov    Cx,Dx                     ; Cx = Width of Image
@@AAVolvo:
        Mov    Al,[Si]
        Db     ADDAL_BI                  ; Add Al,ClrAdd1
ClrAdd1 Db     ?
        Stosb

; ----> Update ratio counter and image pointer (Si)

        Add    Bx,Bp                     ; Bx has 8 bit fixed accuracy
        Or     Bh,Bh                     ;  Bh is the whole part
        Jz     @@NoIncSi                 ; Check Scale Ratio Counter
        Movzx  Ax,Bh
        Add    Si,Ax                     ; Add whole part of Bx to Si                            
        Xor    Bh,Bh                     ; Clear out whole part of Bh
@@NoIncSi:
        Loop   @@AAVolvo

        Dw     ADDDI_WI                  ; Add Di,XAdds - 
XAddsX  Dw     ?                         ;  Increment to next line                 
        Pop    Cx
        Loop   @@DDVolvo                             

        Ret
        
EndP DispImg_SclX


;==============================================================================
;
; Proc: ClrImg_SclX
;
; Displays the pointed to image.  Uses the variables defined in this module
; for image buffer height and width.  The cool part and major difference of
; this procedure next to the one above it is this one clears a pixel to
; the left and right of the image.
;
; InRegs:
;   Ds          -> Segment of image
;   Di          -> Offset into VidMem
;   [Cs:XAddsC]  - ScreenWidth (320) - NewImageWidth 
;   [Cs:ClrAdd2] - Color Offset (ie, colors 0-64 displayed as 64-128)
;   Dx:Ax        - Old Buffer Width * 256
;   Cx           - New Image Width on-screen
;                                             
;==============================================================================

Proc ClrImg_SclX

; ----> Establish a horizontal pixel skip factor

        Div    Cx
        Mov    Bp,Ax                     ; Bx = NewWidth / OldWidth
        Mov    Dx,Cx                     ; Dx = New Width of Image
        Xor    Bx,Bx
       
; ----> Done with that <----> Time to plot the image
       
        Mov    Cx,[Fs:BufferHeight]      ; Cx = Height of image
@@DDVolvo:
        Push   Cx
        Mov    Cx,Dx                     ; Cx = Width of Image
       
        Mov    [Byte Es:Di - 1],0        ; Clear pixel to left of image
@@AAVolvo:
        Mov    Al,[Si]
        Db     ADDAL_BI                  ; Add Al,ColorAdd
ClrAdd2 Db     ?
        Stosb

; ----> Update ratio counter and image pointer (Si)

        Add    Bx,Bp                     ; Bx has 8 bit fixed accuracy
        Or     Bh,Bh                     ;  Bh is the whole part
        Jz     @@NoIncSi                 ; Check Scale Ration Counter
        Movzx  Ax,Bh
        Add    Si,Ax                     ; Add whole part of Bx to Si                            
        Xor    Bh,Bh                     ; Clear out whole part of Bh
@@NoIncSi:
        Loop   @@AAVolvo
        Mov    [Es:Di],Bh                ; Clear pixel to the right
        Dw     ADDDI_WI                  ; Add Di,XAdds -
XAddsC  Dw     ?                         ;  Increment to next line                 
        Pop    Cx
        Loop   @@DDVolvo                             

        Ret
        
EndP ClrImg_SclX

EndS CoDe
End
