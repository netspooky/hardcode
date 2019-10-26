; BBSTRO for Intereor WHQ bbs! [SysGod: Zyark] [+45 36701219]
; Code & Graphics by CyPoxl of Intereor productions
; Font by Sector/Intereor                           
; Thanks to Vulture of Outlaw Triad for the plasma...
; Code suxx, I know... [Not yours Vulture] - AND it is pretty old stuff! :(
; Lots of confusing comments :)
 Dosseg                         ; Ehh, who cares?.. we only got 1 seg to play with
 Model Tiny                     ; 1 seg := c0m file
 Jumps                          ; Nice looong jumps :)
 Code   Segment                 ; Instead of .code we make our own code seg..
 Assume Cs:Code, Ds:Code, Es:Code; e.g: Totally irrelevant!
 Org 100h                       ; c0m entry point
                                                  
;[][][][][][][][][][][][][][][][][][MACROS][][][][][][][][][][][][][][][][][]
                                                       
WaitVRT         Macro           ; Macro = happy word :)
        Local @Vrt, @Vrt2
 Mov Dx,3dah                    ; Vga reg [status register]
@Vrt:                                                                
 In Al,Dx                       ; Get Status
 Test Al,8                      ; Vertical retrace?
 Jz @Vrt                        ; Nope      
@Vrt2:                                             
 In Al,Dx                                          
 Test Al,8                      ; Vertical Retrace?                   
 Jnz @Vrt2                      ; Yer, now its time to write
Endm                                                       
                                                           
;[][][][][][][][][][][][][][][][][][]CODE[][][][][][][][][][][][][][][][][][]
                                                           
Intro           Proc                                       
 Jmp Next                                   
 Db '(c)ypoxl'                  ; (c)opyright CyPoxl '97, but who cares..?
Next:                                                                     
 Call SetVgaStuff               ; Init mode 13h, set palette..
 Cli                            ; FuCK interrupts
 Mov Dx,21h                     ; Interrupt mask reg!      
 In Al,Dx                                            
 Mov Byte Ptr Ds:[OldIRQs],Al                    
 Or Al,11b                      ; Turn off keyboard and timer interrupt
 Out Dx,Al                                  
 Xor Di,Di
 Lea Si,ITlogo                                                
 Mov Cx,15021                                                 
 Rep Movsb                                                    
 Mov Di,47*320                  ; After logo     
 Mov Al,64                      ; e.g blueish
 Call MakeBar                   ; Draw nice bar  
 Mov Di,143*320                 ; After plasma/before font
 Xor Al,Al                      ; Greyish   
 Call MakeBar                                              
 Mov Di,173*320                 ; After font     
 Xor Al,Al                      ; Greyish [like font]
 Call MakeBar                                    
 Mov Bp,140                     ; 10x14 equals...?
@StartTxt:                                        
 Lea Bx,IntereorTxt             ; Pointer to txt  
@GetChar:                                         
 Mov Al,byte ptr Ds:[Bx]        ; Get Char
 Inc Bx                         ; Point to next char in Txt
 Xor Ah,Ah                      ; I forgot why..uhm.. think its cuz we multiply
 Or Al,Al                       ; Zero indicator?
 Jz @StartTxt                   ; All over...again
 Cmp Al,' '                     ; Space?
 Jnz @NotSpace                  ; Not space       
 Mov Dh,8                       ; 8 vertical lines
 Call MoveXScreen               ; If you cant guess I wont tell ya
 Jmp @GetChar                                     
@NotSpace:                                        
 Lea Si,Font                    ; Font pointer    
 Sub Al,'('                     ; Start char = '('
 Mul Bp                         ; Calculate offset in font [Bp=140]
 Add Si,Ax                      ; ^^^^^^^^^^^^^^^^^^^^^^^^
 Mov Cl,10                      ; 10 like in 10x14 font!
@HLine:                                           
 Push Si                        ; Save Si, cuz we mess with it
 Mov Di,159*320+280-1           ; Very hardcore calculation, hehe :)
 Mov Ch,14                      ; 14 like in..... 
@VLine:                                
 Movsb                          ; Move string byte (Font => Screen)
 Add Di,320-1                   ; Next line (on screen)
 Add Si,10-1                    ; Next byte in font [vertical]
 Dec Ch            
 Jnz @VLine                     ; Not through with vertical line
 In Al,60h                      ; Keyboard reg
 Cmp Al,1                       ; Check Escape
 Jz QuitIntro                   ; Quit on escape
 Call MoveScreen                ; Next vertical line
 Call Do_Plasma                 ; Hmm...      
 Pop Si                         ; Font in si 
 Inc Si                         ; Next byte in font
 WaitVRT           
 Loop @HLine                    ; Next vertical line
 Mov Dh,2                       ; Dist between letters
 Call MoveXScreen                               
 Jmp @GetChar                                   
QuitIntro:                                      
 Sti
 Mov Ax,3                       ; Init text mode [80x25x16c]
 Int 10h                                        
 Call DispAnsi                  ; Nice ansi w. softscroll :)
 Cli
 Mov Dx,21h
 Mov Al,Byte Ptr Ds:[OldIRQs]   ; Old IRQ settings
 Out Dx,Al                      ; Trust me, the user will like this, hehe :)
 Sti                                            
 Mov Ax,4C00h                   ; Save terminate function
 Int 21h                        ; TermiNate Prog         
Intro           Endp                                     
                                                         
MoveXScreen     Proc                                     
 Call MoveScreen                ; Move screen
 Call Do_Plasma                 ; Remember to update plasma
 Push Dx                                                 
 WaitVRT
 Pop Dx                                                  
 Dec Dh
 Jnz MoveXScreen                ; Counter=0?             
 Ret                                                     
MoveXScreen     Endp
                                                            
MoveScreen      Proc                                        
 Push Cx Es                     ; Cx must not be messed with
 Pop Ds                                                      
 Mov Si,159*320+40+1            ; Source
 Mov Di,159*320+40              ; Destination=source-1
 Mov Dl,14                      ; 10x14 font!
@MV:                                                        
 Mov Cx,240                     ; Scroll window size
 Rep Movsb                                                   
 Add Di,320-240                                                              
 Add Si,320-240                
 Dec Dl                         ; Dl=counter
 Jnz @MV                       
 Push Cs                                                     
 Pop Ds Cx                                                   
 Ret                                                         
MoveScreen      Endp                                        
                                                            
SetVgaStuff     Proc                    
 Mov Ax,13h                     ; Init mode 13h [320x200x256c]
 Int 10h                                 
 Mov Ax,0A000h                  ; Vga seg
 Mov Es,Ax                      ; Es:Di [for stosb]
 Lea Si,Palette                 ; Plasma+font pal
 Mov Cx,243*3                   ; RGB            
 Mov Dx,3C8h                    ; Pal reg index  
 And Al,0                       ; Eg: Xor Al,Al / Sub Al,Al
 Out Dx,Al                      ; Start with 1st color
 Inc Dl                         ; Pal reg data [write only]
@Out:                                                      
 Mov Al,Byte Ptr Ds:[Si]        ; Get R/G/B Val
 Out Dx,Al                      ; Store it in vga reg
 Inc Si                         ; Next
 Loop @Out
 Ret                                                        
SetVgaStuff     Endp                                       
                                                           
Do_Plasma       proc                                       
 Push Bx Cx Dx Bp               ; Save [maybe to many] regs
 Mov Di,60+320*63               ; Plasma pos [x,y=60,16]
 Mov Cl,Byte Ptr Ds:[Co1]       ; Vertical cosine start values
 Mov Ch,Byte Ptr Ds:[Co2]
 Mov Ah,80                      ; 80 vertical lines
@Outer_Plasma:                                               
 Push Ax                                                
 Mov Dl,Byte Ptr Ds:[Co3]       ; Horizontal cosine start values
 Mov Dh,Byte Ptr Ds:[Co4]                             
 Mov Ah,100                     ; 200 horizontal lines [YES: 200!]
@Inner_Plasma:                  
 Xor al,Al                          
 Xor bh,bh                          
 Mov Bl,Dl                      ; Add 4 cosine values
 Add Al,Byte Ptr Ds:[Cosine+Bx]     
 Mov Bl,Dh                          
 Add Al,Byte Ptr Ds:[Cosine+Bx]  
 Mov Bl,Cl                       
 Add Al,Byte Ptr Ds:[Cosine+Bx]  
 Mov Bl,Ch                       
 Add Al,Byte Ptr Ds:[Cosine+Bx]  
 And Al,01111111b                
 Mov Byte Ptr Es:[Di],Al        ; Store Color on Vga
 Inc Di                         ; Leave 1 pixel black
 Inc Di                         ; Thats why we have 200 horizontal pixels
 Add Dl,1                                                                 
 Add Dh,2                       
 Dec Ah                         ; Next pixel on horizontal line
 Jnz @Inner_Plasma                                 
 Add Cl,3                                          
 Add Ch,4                                          
 Add Di,120                     
 Pop Ax                                            
 Dec Ah                         ; Next horizontal line
 Jnz @Outer_Plasma                                 
 Sub [Co1],4                                       
 Add [Co2],3                                       
 Sub [Co3],2                                       
 Add [Co4],1                                       
 Pop Bp Dx Cx Bx                
 Ret                                               
Do_Plasma       endp                              
                   
MakeBar Proc                     
 Mov Bx,16                      ; 16 shades
@MakeIt:                                                     
 Mov Cx,320                     ; Guess...
 Rep Stosb                       
 Add Al,4                       ; Next color
 Dec Bx                         ; Bx=counter
 Jnz @MakeIt                                 
 Ret                                         
MakeBar Endp             
          
DispAnsi        Proc            ; I figured this out - all by myself! :-)
 Push Cs                        ; So..
 Pop Ds                         ; Ds=cs
 Mov Al,0ah                     ; Index [cursor]
 Mov Ah,100000b                 ; Bit 5 (6) [cursor 0=on 1=off]
 Mov Dx,3D4h                    
 Out Dx,Ax                      
 Mov Ax,0B800h                  ; Color text seg
 Mov Es,Ax                                                     
 Mov Cx,4000                    ; Just to be save
 Xor Ax,Ax                      ; 000000000etc...
 Cld                             
 Rep Stosw                      ; Clear 2 pages
 Mov Ax,501h                    ; Select page 1 [normally we have page 0]
 Int 10h
 Cli                            ; Don't want any interrupts to..interrupt :)
 WaitVRT                        ; Otherwise we'll get to see the logo for a very short time
 Xor Di,Di                      ; Page 0:0
 Lea Si,Ansi                    ; My own ansi
 Mov Cx,80*15                   ; 15 lines long
 Rep Movsw                      ; Put in on page 0
 Mov Bx,80*15                   ; Set the screen offset just below the ansi!
 Call SetMemAdd                 ; Cuz we want to scroll it down
 Mov Cx,15                      ; Ansi hight!
@RowLoop:                       
 Push Cx                                
 Sub Bx,80                      ; Next Row
 Call SetMemAdd                 ; In display memory
 WaitVRT                                
 Mov Ax,0f08h                   ; Display last pixel of chars
 Mov Dx,3D4h                    ; Vga Reg !!!
 Out Dx,Ax                              
 Dec Ah                         ; Display one more pixel
 Mov Cx,15                      ; Cuz We have set the 1st, and now there are
@PixelLoop:                     ; 15 to go [vgafont: 8x16]
 WaitVRT                        ; Wait until Vertical Retrace!
 Mov Dx,3D4h                    ; I hope this works on all adaptors..
 Mov Al,8                                                             
 Out Dx,Ax                                                            
 Dec Ah                         
 Loop @PixelLoop                ; Next Pixel
 Pop Cx                                      
 Loop @RowLoop                  ; Next row
 Sti                            ; Turn on interrupts
 Mov Ax,500h                    ; Turn on page 0
 Int 10h                                         
 Mov Ax,0B0Ah                   ; Start cursor scanline
 Out Dx,Ax                              
 Mov Ax,0D0Bh                   ; End cursor scanline
 Out Dx,Ax                              
 Ret                                    
DispAnsi        Endp                            
                                                
SetMemAdd       Proc                            
 Push Ax                                         
 Mov Dx,3D4h                    ; ...Vga reg!
 Mov Al,0Ch                                   
 Mov Ah,Bh                      ; High address
 Out Dx,Ax                      
 Inc Al                                          
 Mov Ah,Bl                      ; Low address
 Out Dx,Ax                                     
 Pop Ax                                       
 Ret                                          
SetMemAdd       Endp                         
                                                             
;[][][][][][][][][][][][][][][][][][]DATA[][][][][][][][][][][][][][][][][][]
IntereorTxt     Label   Byte               
        Db 'INTEREOR WHQ BBS      '        
        Db '(+45) 367-012-19      '          
        Db 'CALL NOW?              '; ?=! ! [forget it..You'll notice :)]
        Db '                        '                                 
        Db 'SYSOP: ZYARK       '                                      
        Db 'LOTS OF XM/MOD, DEMOS, ETC...      '                      
        Db '                        '                                 
        Db 'GREETS: VULTURE/OT       '
        Db 'MOTIVE/INTEREOR         ' 
        Db 'NARCOID/SMERSH       '                                    
        Db '                        '                                 
        Db 'INTEREOR WHQ BBS      '                                   
        Db '(+45) 367-012-19      '                                   
        Db 'CALL NOW?              '                                  
        Db '                       '                                  
        Db 'CODE: CYPOXL/INTEREOR    '                                
        Db 'GRAPHICS: CYPOXL    '                                     
        Db 'FONT: SECTOR/INTEREOR      '
        Db '                        '                                 
        Db 0                    ; DONE
                                                                      
Label Palette Byte                                                        
 I = 0                                                                
Rept 32                         ; 32 increasing colors of white
        Db I,I,I                                                      
 I = I + 1                            
Endm                                  
                                      
Rept 32                         ; 32 decreasing colors of white
        Db I,I,I                                                  
 I = I - 1                            
Endm         
             
Rept 32                         ; 32 increasing colors of blue
        Db 0,0,I                                                 
 I = I + 1                                                   
Endm         
Rept 32                         ; What could tjis beeee?
        Db 0,0,I                                 
 I = I - 1                                       
Endm                                             
;Font colors:                                    
        Db 3 Dup (3Fh)          ; White
        Db 3 Dup (1Eh)          ; Less white
        Db 3 Dup (0Eh)          ; Less than less white
Include Logo.pal                ; logo.pal
                                                      
OldIRQs Db ?                    ; Old IRQ settings    
                                                      
Co1     Db ?                    ; 4 different angles  
Co2     Db ?
Co3     Db ?                                     
Co4     Db ?                                     
Include cosine.dat              ; Cosine Values for plasma
Include it-font.inc             ; Intereor font by Sector
Include logo.inc                ; Intereor logo [by me - and my raytracer-, 
                                ; hehe]
Include ansi.inc                ; Ansi logo [also by me :)]
Code Ends                                                                        
End Intro