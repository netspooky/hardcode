;
; Don't worry, it's:
;   Just Another Generic Loader!
;
; Coded by Air Richter [HaRDCoDE '94] (the Lame Loader Lover)
;
; A generic loader with the stuff you see when you watch the damn thing.
; But, in particular, this module covers the cool font manipulation that
; takes place and all that other groovy stuff (all except displaying the
; actual text, that is).  
;
                  
Include video.mac

Ideal
Model Small
P386

Include "cmds.inc"
Include "video.inc"
Include "loader.inc"


; -----> Data Segment <-----

Segment DaTa Public DWord 'Data'

BufferWidth   Dw  ?
BufferHeight  Dw  ?
BufferPtr     Dw  ?

EndS DaTa
 

; -----> FarData Segment <-----
  
Segment FarDaTa Public DWord

Font8x8      db   222*64 Dup(?)      ; 8x8 BIOS Font Buffer 33-222
Font8x16     db   222*128 Dup(?)     ; 8x16 BIOS Font Buffer 33-222

EndS FarDaTa  
 

; -----> Code Segment <-----

Segment CoDe Public DWord 'Code'
Assume Cs:CoDe,Ds:DaTa

;=============================================================================
;
; Proc: DownLoadBios
;          
; The start of this routine gets pointers to the BIOS 8x8 and 8x16 fonts.
; The lower part performes an anti-aliasing routine on each individual charac-
; ter of both the 8x8 and 8x16 BIOS fonts (helps to spice them up some at
; least).  This routine also serves the purpose of converting the 1 bit font
; to a more workable 8 bit font.                                        
; 
; All 256 characters are copied (well, it might only be 255, but who uses that
; last null character anyway? :)
;                                                                           
;=============================================================================

Proc DownLoadBios

        Mov     Ax,1130h               ; Get a pointer to the BIOS 8x8 font
        Mov     Bh,3
        Int     10h
        Mov     [Word Ptr8x8],Bp       ; Store Es:Bp in the 8x8 pointer var
        Mov     Cx,Es
        Mov     [Word Ptr8x8 + 2],Cx
        
        Mov     Ax,1130h               ; Get a pointer to the BIOS 8x16 font
        Shl     Bh,1
        Int     10h
        Mov     [Word Ptr8x16],Bp      ; Store Es:Bp in the 8x8 pointer var
        Mov     Ax,Es
        Mov     [Word Ptr8x16 + 2],Ax
        
; ----> Copy and apply the shade/anti-alias effect
          
        Push    Ds
        Mov     Ax,FarDaTa
        Mov     Es,Ax
                  
; ----> For now, Just copy the font into the Ds segment buffer.

        Lds     Si,[Ptr8x8]            ; Ds:Si points to BIOS Font
        Add     Si,108h                ; Skip first 33 characters
        Mov     Di,Offset Font8x8                                                 
        Mov     Cx,222*8                ; Grab 94 characters
        Call    ShadeToo
        
        Lds     Si,[Fs:Ptr8x16]
        Add     Si,33*16
        Mov     Cx,222*16              ; Do 8x16 this time around.
        Call    ShadeToo

        Pop     Ds
        Ret
       
EndP DownLoadBios


;=============================================================================           
;
; Proc: ShadeToo
;
; Not only are the BIOS fonts anti-aliased, but they are shaded as well.  The
; shading, although I cannot give a real name too it, reminds me of the Deluxe
; Paint ][ enhanced standard fill.  Whatever it is, it does a good job of
; spicing up the BIOS fonts.
;                                                                         
;============================================================================= 

Proc ShadeToo

@@GrabSome:
        Push    Cx
        Lodsb                          ; Get one row of charaters
        Mov     Bl,Al
        Mov     Cx,8
        Mov     Bh,not 1               ; Bh = Shading/Antialiasing mask
@@OneRow:    
        And     Al,Bh
        Shr     Al,2 
@@Stos: Stosb
        Add     Bl,Bl                  ; Take next bit, please
        Shl     Bh,1                   ; Decrement shading some
        Mov     Al,Bl                                    
        Loop    @@OneRow
        Pop     Cx
        Loop    @@GrabSome
        
        Ret                 

EndP ShadeToo


;==============================================================================
;
; Proc: ProcessString
;
; Processes a string and generates structure information in the format of 
; FlipText (documented in LOADER.ASM) for each character that is used by Proc
; FoldString.
;                                                
; XCount - Wait Factor before letter flip begins.
;                             
; InRegs:
;   Ds:Si -> String
;   Ds:Di -> Structure Buffer (Type Struc ChrFlip)
;   Cx    -> XCount Subtraction Value (left edge of rectange of text window)
;
;==============================================================================

Proc ProcessString

        Lodsw                       ; Ax = X Disp Location of Image
        Mov     Bp,Ax
        Lodsw                       
        Mov     Bx,Ax               ; Bx = Offset into buffer to begin display
        Add     Bx,4
        Xor     Ch,Ch
                                           
; ----> Check for and process any control chars

@@CharLoop:
        Lodsb
        Cmp     Al,32
        Ja      @@AlphaChr          ; Check if it's a normal alphabet char
        Je      @@Dolp              ; treat it like a space?
        Cmp     Al,13               ; 13 means new string is comming up!
        Je      ProcessString
        Cmp     Al,1
        Je      @@F8x8              ; Switch to 8x8 font?
        Cmp     Al,2
        Je      @@F8x16             ; Switch to 8x16 font?
        Mov     [Word Di],0         ; List termination!
        Ret
                 
; ----> Characters that are not control chars processed here

@@AlphaChr:            
        Mov     [Di + 2],Bp         
        Mov     [Di + 4],Bx         
        Xor     Ah,Ah
        Sub     Al,33               ; strip off ctrl chars
        Shl     Ax,Cl
        Add     Ax,Dx               ; Ax -> Actual Character Data
        Mov     [Di],Ax                             
        Mov     [Di + 6],Ch
        Add     Di,8                ; Di -> Next Structure to Update
        Add     Bp,2                ; Bp = XCount VR Delay
        Add     Bx,8                ; Bx = X Offset of Char Disp in Buffer
        Jmp     @@CharLoop
                                           
; ----> Control Char Execute Code
                                           
@@Dolp: Add     Bx,8                ; If none of the above, treat as a space
        Add     Bp,2                ; Increment both XCount and BufferPtr
        Jmp     @@CharLoop
@@F8x8: Mov     Cx,0806h            ; Cl - Multiply Ax by 8
        Mov     Dx,Offset Font8x8
        Jmp     @@CharLoop          ; Ch - Char width of 8
@@F8x16:Mov     Cx,0d07h            ; Cl - Multiply Ax by 16
        Mov     Dx,Offset Font8x16
        Jmp     @@CharLoop          ; Ch - Char Width of 16
                          
EndP ProcessString


;==============================================================================
;
; Proc: FoldString_Open
;
; When a string of characters needs to be unfolded, this is the routine that 
; should be called for every update.  The pointed to list of character fold
; info is processed and the string updated.  The foldtext information is up-
; dated as well.
;                                 
; InRegs:
;   Fs:Bp -> List of Character Fold Info (terminated by a dw 0)
;   
;==============================================================================

Proc FoldString_Open

        Push    Ds
        
        Mov     Ax,FarDaTa
        Mov     Ds,Ax               ; Ds -> Font Data Info
        
@@DisNut:
        Mov     Ax,[Fs:Bp]
        Or      Ax,Ax               ; Check for list termination
        Jz      @@Terminate
        
        Mov     Si,Ax
        Mov     Ax,[Word Fs:Bp + 2] ; Decrement XCount 
        Or      Ax,Ax
        Jz      @@Flipping          ; If Ax = 0 then char is flipping + stuff
        Dec     [Word Fs:Bp + 2]
@@Next: Add     Bp,8                ; Done here, so check next structure
        Jmp     @@DisNut
        
; Character XCount = 0, so either the char is flipping, or has already
; finished...

@@Flipping:
        Mov     Cl,[Fs:Bp + 7]
        Cmp     Cl,8                ; if it's 8, then it is already flipped
        Je      @@Next    
        
        Inc     Cl
        Test    Cl,1                ; Decrement scrn addr on even char widths
        Jz      @@SkpMv  
        Dec     [Word Fs:Bp + 4]    ; Draw one pixel to the left
@@SkpMv:Mov     [Fs:Bp + 7],Cl      ; Set New Char Width for later use
        Mov     Di,[Fs:Bp + 4]      ; Di -> Screen Address to Disp Char
        Mov     Al,[Fs:Bp + 6]      ; Get Height of this Character
        Mov     [Byte Fs:BufferHeight],Al 
        Xor     Dx,Dx
        Mov     Ax,0800h            ; Dx:Ax = 8 * 256
        Mov     [Cs:XAddsX],320
        Sub     [Cs:XAddsX],Cx
        Push    Bp
        Call    DispImg_SclX
        Pop     Bp 
        Jmp     @@Next
            
@@Terminate:
        Pop     Ds
        Ret
                    
EndP FoldString_Open


;=============================================================================
;
; Proc: FoldString_Close
;
; Yep Yep, here it is, and I bet you won't understand a single bit of it!
; Ok, this is the way it goes.  After a set of characters has been unfolded
; by the above procedure, they have to be folded back up again before another
; string can be folded open in their place.  That is what this procedure is
; for.
;
; InRegs:
;   Fs:Bp -> List of Character Fold Info (terminated by a dw 0)
;                                                                           
;=============================================================================

Proc FoldString_Close
        
        Push    Ds
        
        Mov     Ax,FarDaTa
        Mov     Ds,Ax               ; Ds -> Font Data Info
        Xor     Ch,Ch
        
@@DisNut:
        Mov     Ax,[Fs:Bp]
        Or      Ax,Ax               ; Check for list termination
        Jz      @@Terminate
        
        Mov     Si,Ax
        Mov     Ax,[Word Fs:Bp + 2] ; Decrement XCount 
        Or      Ax,Ax
        Jz      @@Flipping          ; If Ax = 0 then char is flipping + stuff
        Dec     [Word Fs:Bp + 2]
@@Next: Add     Bp,8                ; Done here, so check next structure
        Jmp     @@DisNut
        
; Character XCount = 0, so either the char is flipping, or has already
; finished...

@@Flipping:
        Mov     Cl,[Fs:Bp + 7]
        Cmp     Cl,1                ; 0 = erased, 1 = erase without redraw
        Je      @@ErsOld
        Jb      @@Next                                            
        
        Dec     Cl
        Test    Cl,1                ; Increment scrn addr on even char widths
        Jnz     @@SkpMv  
        Inc     [Word Fs:Bp + 4]    ; Draw one pixel to the right
@@SkpMv:Mov     [Fs:Bp + 7],Cl      ; Set New Char Width for later use
        Mov     Di,[Fs:Bp + 4]      ; Di -> Screen Address to Disp Char
        Mov     Al,[Fs:Bp + 6]      ; Get Height of this Character
        Mov     [Byte Fs:BufferHeight],Al 
        Xor     Dx,Dx                          
        Mov     Ax,0800h            ; Dx:Ax = 8 * 256
        Mov     [Cs:XAddsC],320 
        Sub     [Cs:XAddsC],Cx 
        Push    Bp
        
        Sub     Di,4                ; Di needs to be modified + stuff.. :)

        Call    ClrImg_SclX
        Pop     Bp
        Jmp     @@Next
                         
; If only one line left to be erased, the char redraw is skipped and just a
; single line is cleared (the only remaining line).

@@ErsOld:
        Mov     Di,[Fs:Bp + 4]
        Sub     Di,4 
        Movzx   Cx,[Fs:Bp + 6]      ; Char Height...
        Xor     Al,Al
@@ErsLoop: 
        Stosb
        Add     Di,319              ; XAdds...
        Loop    @@ErsLoop
        Jmp     @@Next
            
@@Terminate:
        Pop     Ds
        Ret
        
EndP FoldString_Close
       
EndS CoDe
End    