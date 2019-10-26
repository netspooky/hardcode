; FLAME.ASM - A Flame Generator for 320x200x256 VGAMode within 256bytes  |
;-------------------------------------------------------------------------+
;   This is Freeware by Magnesium (Michael Goddard). It's meant for others
; to learn the art of compact programming (although this isn't really that
; special or a good example). It's partially commented but not optimised
; for size or speed fully, I just used the easiest way I could think of.
; If you can't get it to compile / are looking for a coder for your group
; or just feel like it then email me in magnesium@hehe.com and/or
; cgoddard@ozemail.com.au (The later is my ISP account, the other should
; forward to my current email) Oh yeah, the code was written in 'bout half
; an hour just to see if I could do it, why not try to make one yourself?
;
;  Just a note about the program, it is a _responsible_ 256b file and when
; writing yours make sure it leaves the user in Video Mode 3 and clears the
; keyboard buffer if many keys can be pressed and space is available as this
; one does. I just say this as it gets really annoying to run DOS DEBUG just
; so I can read the screen again, that's unless you prefer watching the BIOS
; counter, yay.
;
;                      Have fun and MERRY XMAS/Happy New Year! (26th Dec '97)
;

.286       ; Long-Shifts are used which XT's don't support

Code Segment Use16 ; 16-bit segment for DOS-COM file

 ; COM File-style header
 Assume CS:Code, DS:Code, ES:Code
 Org 100h

; Therez no point in this really, I just usually do it
Start:

  ; Make VirtualScreen Buffer - End-Of-Code withint 64k of COM file
  Mov Ax, Cs
  Add Ax, 16+16+1
  Mov [VGA_VirSeg+2], Ax

  ; Set Graphics Mode 320x200x256
  Mov Ax, 13h
  Int 10h

  ; Set RGB-Palette Index to 0
  Mov Dx, 03C8h
  Xor Ax, Ax
  Out Dx, Al
  Inc Dx

  ; Set Palette Colours directly through the DAC's R-G-B-R-G-B . . . thingy

  ; Fade from Black to Red (0..63)
  Mov Cx, 64
  @Pal_01:
   Out Dx, Al
   Push Ax
    Mov Al, 0
    Out Dx, Al
    Out Dx, Al
   Pop Ax
   Inc Ax
  Loop @Pal_01

  ; Fade from Red to Yellow (64..127)
  Mov Cx, 64
  @Pal_02:
   Push Ax
    Mov Al, 63
    Out Dx, Al
   Pop Ax
    Out Dx, Al
   Push Ax
    Mov Al, 0
    Out Dx, Al
   Pop Ax
   Inc Ax
  Loop @Pal_02

  ; Fade from Yellow to White (128..191)
  Mov Cx, 64
  @Pal_03:
   Push Ax
    Mov Al, 63
    Out Dx, Al
    Out Dx, Al
   Pop Ax
    Out Dx, Al
   Inc Ax
  Loop @Pal_03

  ; Fill the rest of the colours with White (192..255)
  Mov Cx, 64 * 3
  Mov Al, 63
  @LoopyWhitePal:
   Out Dx, Al
  Loop @LoopyWhitePal


  ; Clear Screen
   Mov Es, [VGA_VirSeg+2]
   Xor Di, Di
   Xor Ax, Ax
   Mov Cx, 32000
   Rep Stosw

 @NextFrame:

;  RandSeed - It's not really needed and size is important here
;  Mov Ah, 2Ch
;  Int 21h
;  Mov Word ptr [randseed], dx

; Draw Random coloured line at bottom (CFh..0FFh)   |
;---------------------------------------------------+

   Mov Di, 199*320+320
   Mov Cx, 320
  @NextRLine:

   ; Quick random number generator - Word version of TP's DWord one
   Mov Ax, 33797
   Mul word ptr [randseed]
   inc ax
   Mov word ptr [randseed], ax

   ; Clip number to CFh..FFh
   And Ah, 03Fh
   Add Ah, 0CFh
   ; Put tha pixel on the virtual-screen (ES:)
   Mov ES:[DI], Ah
   ; Loop for next dot
   Inc Di
   Loop @NextRLine


; Smooth the screen and move it up  |
;-----------------------------------+

   Mov Cx, 64000
   Mov Di, 320
  @ScrLoop:
   Xor Ax, Ax
   Xor Bx, Bx
   Mov Al, ES:[DI+320]
   Shl Ax, 2

   Mov Bl, ES:[DI+319]
   Add Ax, Bx
   Mov Bl, ES:[DI+321]
   Add Ax, Bx
   Mov Bl, ES:[DI+0]
   Add Ax, Bx
   Mov Bl, ES:[DI+640]
   Add Ax, Bx
   Shr Ax, 3

   Dec Al
   jnz @DontZeroIt
    Mov Al, 1
   @DontZeroIt:
   Mov ES:[DI], Al

   Inc Di
  Loop @ScrLoop


; Copy Buffer  |
;--------------+

  Push ES
  Push DS
   Push ES
    Mov ES, [VideoSeg]
   Pop DS
   Xor Di, Di
   Xor Si, Si
   Mov Cx, 320*198/2
   Rep Movsw
  Pop DS
  Pop ES

; Wait for Video Retrace  |
;-------------------------+

  Mov Dx, 03DAh
  @Retrace2:
  In Al, Dx
  Test Al, 8
  Jnz @Retrace2


; Check for key and loop if <ESC> isn't being pressed  |
;------------------------------------------------------+

  In  Al, 060h
  Cmp Al, 1
  Jne @NextFrame

  ; Read the key so it's not printed when we exit

 @ReadNextKey:
  Xor Ax, Ax
  Int 16h
  ; Check if more keys
  Mov Ah,0Bh
  Int 21h
  Cmp Al, 0
  jne @ReadNextKey

  ; Back to TextMode
  Mov Ax, 3h
  Int 10h

  ; Display a little message (This takes up space but what the heck)
  Mov Dx, Offset Message
  Mov Ah, 9
  Int 21h

  ; Return to DOS the COM style, DON'T use this on EXE's as it's not garunteed to work
  Ret



Message db 'Flame by Magnesium :-)',10,'$'
VideoSeg    dw 0A000h
;VGA_VirSeg  dw 0A000h
RandSeed LABEL  ; We don't need to preset this so it saves two bytes this way
VGA_VirSeg LABEL

code ends
end start
