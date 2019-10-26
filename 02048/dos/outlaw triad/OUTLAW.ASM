
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²² INFO ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;       Better write some info on this source...
;
;       An Outlaw Triad intro. Introduces the Outlaw Triad team.
;       Coded in 100% assembler and in high resolution 640*480*16.
;       Fully commented but knowledge of vga programming is required.
;
;       Major thanks go to Troop / Chiparus / Outlaw Triad! I couldn't
;       have made this without his help. Design was done by him. Thanks!
;
;       Characters are written to the screen using the Bit Mask register.
;       Thus, only 16 MOV commands are needed to write the character to
;       the screen which makes it pretty fast. Man, it sure was hard to
;       code this stringwriter. I think it is up for major improvement.
;       It's way too complex to my taste but well, I got it to work. But
;       if you see a way to improve it, please do! In fact, this intro
;       can be optimized quite a lot, me thinks... :-)
;
;       If you decide to use this, go ahead. But don't just change the
;       text and release it again. That would be lame. Instead, use this
;       to learn. And, greet Outlaw Triad in your future productions.
;       That's all. Is that cheap or what? :-)
;
;         Feel like chatting? E-mail me at: comma400@tem.nhl.nl
;
;           Later,
;
;             -Vulture / Outlaw Triad-
;
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

DOSSEG              ; Sort segment like high level languages do
.MODEL SMALL        ; Code & data seperate segments, both < 64kB & near
.STACK 200h         ; 512 byte stack
.286                ; Allow 286 instructions
.DATA               ; Datasegment starts here (empty)
.CODE               ; Codesegment starts here (code & data in codesegment)
JUMPS               ; Let tasm handle out of range jumps

ASSUME cs:@code;ds:@code        ; Let cs and ds point to code segment

; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²² Various data ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

INCLUDE Text.dat                ; Text to show
INCLUDE Pal.dat                 ; Palette data

Label Credits Byte
     DB 13,10,"Ü  ÜÜ  ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ  ÜÜ  Ü"
     DB 13,10,"                    - An Outlaw Triad Production (c) 1996 -",13,10
     DB 13,10,"                             CodeùùùùùùùùùùVulture" ,13,10
     DB 13,10,"                            -=ð Outlaw Triad is ð=-",13,10
     DB 13,10,"         Vulture(code) þ Dazl(artist) þ Troop(sysop) þ Xplorer(artist)",13,10
     DB 13,10,"ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ",13,10,"$"

Font_Seg  DW    0               ; Font segment
Font_Off  DW    0               ; Font offset in segment

Xsize     EQU   1               ; 1 byte (8 pixels)
Ysize     EQU   16              ; 16 bytes

TextPos   EQU   80*108          ; Y position of text

CharColor DB    15              ; Color of char (what else, eh? ;-) )
Char_Off  DW    0               ; Which char to start with
Char_X    DW    0
Char_Y    DW    TextPos
NewChar_X DW    0
NewChar_Y DW    0

; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²² Code 'n stuff ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

WaitVrt PROC NEAR               ; Waits for vertical retrace to reduce "snow"
    mov     dx,3dah
Vrt:
    in      al,dx
    test    al,1000b
    jnz     Vrt                 ; Wait until Verticle Retrace starts
NoVrt:
    in      al,dx
    test    al,1000b
    jz      NoVrt               ; Wait until Verticle Retrace ends
    ret                         ; Return to main program
WaitVrt ENDP

ResetRGB PROC NEAR              ; Resets number of colors to black
    mov     cx,16*3             ; Number of colors (16)
    mov     dx,03c8h            ; Write register
    xor     al,al               ; Start at 0
    out     dx,al               ; Write to port
    inc     dx                  ; Data register 03c9h
    xor     al,al
ResetLoop:
    out     dx,al
    loop    ResetLoop
    ret
ResetRGB ENDP

FadeUp PROC NEAR
    mov     cx,64                ; Range from 0..63
OuterRGB:
    xor     si,si                ; Real colors
    xor     bx,bx                ; Fading colors
    push    cx
    mov     cx,16*3              ; Do # colors
InnerRGB:
    mov     ah,[Palette+si]      ; Load real value
    mov     al,[EmptyPalette+bx] ; Load fading value
    cmp     al,ah                ; Compare
    je      NextRGB
    inc     al
    mov     [EmptyPalette+bx],al
NextRGB:
    inc     si
    inc     bx
    loop    InnerRGB

    call    WaitVrt

    lea     si,EmptyPalette
    mov     dx,03c8h
    xor     al,al
    out     dx,al
    inc     dx
    mov     cx,16*3             ; 16 colors (shayded)
RGBLoop1:
    lodsb
    out     dx,al
    loop    RGBLoop1            ; Using a loop is saver than "rep outsb"

    pop     cx
    loop    OuterRGB            ; Next run (for 0..63 rgb values)
    ret
FadeUp ENDP

FadeDown PROC NEAR
    mov     cx,64                ; Range from 0..63
OuterRGB2:
    xor     si,si                ; Real colors
    xor     bx,bx                ; Fading colors
    push    cx
    mov     cx,16*3              ; Do # colors
InnerRGB2:
    mov     ah,[EmptyPalette+si] ; Load real value
    cmp     ah,0                 ; Compare
    je      NextRGB2
    dec     ah
    mov     [EmptyPalette+bx],ah
NextRGB2:
    inc     si
    inc     bx
    loop    InnerRGB2

    call    WaitVrt

    lea     si,EmptyPalette
    mov     dx,03c8h
    xor     al,al
    out     dx,al
    inc     dx
    mov     cx,16*3              ; 16 colors (shayded)
RGBLoop2:
    lodsb
    out     dx,al
    loop    RGBLoop2             ; Using a loop is saver than "rep outsb"

    pop     cx
    loop    OuterRGB2            ; Next run (for 0..63 rgb values)
    ret
FadeDown ENDP

SetColor PROC NEAR              ; Needs: cx=color (0 to 15)
    mov     dx,3ceh             ; Graphic Controller address register port
    mov     ax,0f01h            ; Index 01h  (enable set/reset register)
    out     dx,ax
    xor     al,al               ; Index 00h  (set/reset register)
    mov     ah,cl               ; Color (0 to 15)
    out     dx,ax               ; Set color
    ret
SetColor ENDP

TestEsc PROC NEAR
    in      al,60h              ; Was ESCAPE pressed ?
    cmp     al,1
    je      QuitNow             ; Yes => quit now. . .
    ret
TestEsc ENDP

WaitHere PROC NEAR              ; Simple waitroutine
    mov     cx,250
WaitLoop:
    call    WaitVrt
    call    TestEsc             ; Check for escape
    loop    WaitLoop
    ret
ENDP WaitHere

SetLines PROC NEAR
    mov     cx,10               ; Color of lines
    call    SetColor
    mov     dx,3ceh             ; Graphic Controller address register port
    mov     ah,0ffh
    mov     al,08h
    out     dx,ax
    mov     al,ah
    mov     di,(80*45)+5
    mov     cx,70
    rep     stosb
    mov     di,(80*47)+5
    mov     cx,70
    rep     stosb
    mov     di,(80*435)+5
    mov     cx,70
    rep     stosb
    mov     di,(80*437)+5
    mov     cx,70
    rep     stosb
    ret
SetLines ENDP

DeleteText PROC NEAR            ; Guess what this does, eh?  :-)
    xor     cx,cx
    call    SetColor            ; Set background color
    mov     di,80*50
    mov     cx,80
HoriLoop:
    push    di
    mov     al,0ffh
    mov     bx,380              ; # of scanlines
VertiLoop:
    mov     byte ptr es:[di],al
    add     di,80               ; Next scanline
    dec     bx
    jnz     VertiLoop
    pop     di
    inc     di                  ; Next position
    call    WaitVrt
    loop    HoriLoop
    ret
DeleteText ENDP

WriteChar PROC NEAR
    push    ds

; === Select the char ===
    mov     ds,[Word Ptr cs:Font_Seg]
    mov     si,[Word Ptr cs:Font_Off]   ; ds:[si] => offset to font
    xor     dx,dx               ; Empty dx
    mov     dl,al               ; dl=char to print
    shl     dx,4                ; *16 (number of bytes per char)
    add     si,dx               ; ds:[si] points to chardata

; === Set color of char ===
    mov     dx,3ceh             ; Graphic Controller address register port
    mov     ax,0f01h            ; Index 01h  (enable set/reset register)
    out     dx,ax
    xor     al,al               ; Index 00h  (set/reset register)
    mov     ah,CharColor        ; Color (0 to 15)
    out     dx,ax               ; Set color

; === Draw the char ===
    mov     cx,Ysize            ; If bit=0, don't draw
YLiner:
    mov     al,08h              ; Index 08h (Bit Mask Register)
    mov     ah,byte ptr ds:[si] ; Load the pattern (8 bits)
    out     dx,ax               ; Pattern selected (if bit=1 then it's drawn)
    mov     al,byte ptr es:[di] ; Dummy read from vga
    mov     byte ptr es:[di],ah ; Draw scanline
    add     di,80               ; Next scanline (draw scanline twice)
    mov     al,byte ptr es:[di]
    mov     byte ptr es:[di],ah
    add     di,80
    inc     si
    loop    YLiner

    pop     ds
    ret
WriteChar ENDP

WriteText PROC NEAR             ; Kinda complex writer... but it works :-)
StartWrite:
    mov     si,offset Text1
    add     si,Char_Off         ; Character offset
    inc     Char_Off
    mov     di,Char_Y
    add     di,Char_X           ; VGA position
    mov     CharColor,12

    lodsb                       ; Get char (from ds:[si])

    cmp     al,254              ; Reached end of line?
    je      UpdatePos1
    cmp     al,255
    je      WaitNow
    cmp     al,0                ; Reached end of da text?
    jne     OkChar1             ; If not, do the char
    call    WaitHere            ; Else reset intro
    call    DeleteText
    mov     Char_Off,0
    mov     Char_X,0
    mov     Char_Y,80*125
    jmp     StartWrite

OkChar1:
    push    si
    call    WriteChar
    pop     si
    inc     Char_X
    jmp     ShayedWrite

UpdatePos1:
    mov     Char_X,0
    add     Char_Y,80*(Ysize*2)
    jmp     ShayedWrite

WaitNow:
    call    WaitHere
    call    DeleteText
    mov     Char_X,0
    mov     Char_Y,TextPos
    jmp     StartWrite

ShayedWrite:
    call    WaitVrt
    call    TestEsc

    mov     ax,Char_X
    mov     bx,Char_Y
    mov     NewChar_X,ax
    mov     NewChar_Y,bx        ; Switch X,Y values

    mov     CharColor,11
    mov     cx,11
MainWrite:
    push    cx
    mov     di,NewChar_Y
    add     di,NewChar_X        ; VGA position
    lodsb                       ; Get char (from ds:[si])
    cmp     al,254              ; Reached end of line?
    je      UpdatePos2
    cmp     al,255
    jne     LastCheck
    pop     cx
    jmp     StartWrite
LastCheck:
    cmp     al,0                ; Reached end of da text?
    jne     OkChar2
    pop     cx
    jmp     StartWrite          ; Jump to start of writer !!!

OkChar2:
    push    si
    call    WriteChar
    pop     si
    dec     CharColor
    inc     NewChar_X
    jmp     Continue1

UpdatePos2:
    mov     NewChar_X,0
    add     NewChar_Y,80*(Ysize*2)

Continue1:
    pop     cx
    loop    MainWrite
    jmp     StartWrite

    ret
WriteText ENDP

; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²² Main Program ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

START:

    mov     ax,cs
    mov     ds,ax               ; ds points to codesegment

; === Select the charset ===
    mov     al,30h              ; Return seg/ofs on selected charset in BH
    mov     ah,011h             ; Load character generator BIOS routines
    mov     bh,06h              ; Select 8*16 characterset
    int     10h
    mov     Font_Seg,es         ; Return segment of charset
    mov     Font_Off,bp         ; Return offset of charset

; === Init vga ===
    mov     ax,0012h            ; 640x480x16 vgamode
    int     10h

    mov     ax,0a000h
    mov     es,ax               ; es points to vga

; === Palette setup (code by Iguana!) ===
    mov     dx,3c0h		; Create a Linear Palette instead of EGA-Palette
    xor     al,al               ; Index 00h & data 00h
    mov     cx,16
LinPal:
    out     dx,al   	        ; Output index.
    out     dx,al       	; Out to vga => value = index
    inc     al
    loop    LinPal

    mov     al,34h  		; Redo it, activating the VGA along
    out     dx,ax
    xor     al,al
    out     dx,al          	; Force DAC index bits p4-p7 to 0

; === Setup screen ===
    call    ResetRGB
    call    SetLines
    call    FadeUp

; === Print text ===
    lea     si,Text1
    call    WriteText

; === Back to DOS ===
QuitNow:
    call    FadeDown
    mov     ax,0003h
    int     10h                 ; Textmode
    lea     dx,Credits
    mov     ah,09h
    int     21h                 ; Write string
    mov     ax,4c00h
    int     21h                 ; Return control to DOS

END START




; Code by Vulture / Outlaw Triad...