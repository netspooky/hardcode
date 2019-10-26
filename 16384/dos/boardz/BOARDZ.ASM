;==============================================================================;
;                                                                              ;
;       Assembler program by Vulture.                                          ;
;       This program scrolls a text and displays a 3d-starfield.               ;
;       It's a BBS advertisement.                                              ;
;                                                                              ;
;       Current Date: 13-2-95         Vulture                                  ;
;                                                                              ;
;==============================================================================;

DOSSEG              ; Sort the segment using DOS standard CODE DATA STACK
.MODEL SMALL        ; Code is smaller than 64kB (code & data)
.STACK 200h         ; Specify stack
.286                ; Allow 80286 instructions
.CODE               ; Codesegment starts here
JUMPS               ; Let Tasm handle out of range jumps
ASSUME CS:@CODE     ; cs points to codesegment

; === DATA ===   

INCLUDE Font.dat    ; File with font data
INCLUDE Numbers.dat ; Include 500 random numbers between -200 and 200

Message  DB   13,10,"Code by Vulture.",13,10,"$"  ; Important message  :)

Star_Struc      STRUC   ; Format of star (like a record in Pascal)
     X   DW   0         ; X-position of star
     Y   DW   0         ; Y-position of star
     Z   DW   0         ; Z-position of star
     Old DW   0         ; Where to erase old star
     Col DB   0         ; Color of star
Star_Struc      ENDS

StarStrucSize = 9       ; Number of bytes per entry ( 4 wordz and a byte )

ScreenWidth   EQU 320   ; Obvious
ScreenHeight  EQU 200   ; Obvious
MaxStars      EQU 250   ; Maximum number of stars
MaxNumbers    EQU 500   ; Number of random numbers defined  
MaxZ          EQU 4096  ; StartZvalue for all stars
MinZ          EQU 0     ; If Z = 0 then star is dead

XIndex        DW  250   ; Index to X-numbers
YIndex        DW  125   ; Index to Y-numbers
WarpSpeed     DW  20    ; Speed of stars  
NumActive     DW  0     ; Number of stars active

Stars     Star_Struc MaxStars DUP (?)   ; Array of star-records

Palette DB 0,0,0        ; Palette info for first 5 colors (font)
        DB 0,0,0
        DB 52,0,0
        DB 42,0,0
        DB 32,0,0
        DB  0,0,0                     ; Base color black => R,G,B
    i=15                              ; 16 grey shades
    REPT  16
          DB  3*i,3*i,3*i
       i=i-1
    ENDM

PaletteArray  DB 768 DUP (?)          ; Array to hold the palette

Text    DB 'if u wanna experience some cewl boardz in the netherlands '
        DB 'call firehouse 058-661590    detonator 05111-4307   or   '
        DB 'mark of cain 058-672111      cu around. . . . . .'
        DB '                            ',0           ; Text to scroll

Order   DB 'abcdefghijklmnopqrstuvwxyz0123456789-. '  ; Order of characters

; === PROCEDURES ===

SetVGA PROC NEAR                ; Get into VGA mode
    mov     ax,0013h            ; Set the videomode 320*200*256
    int     10h                 ; Call VID interrupt
    ret
SetVGA ENDP

SetText PROC NEAR               ; Get into character mode
    mov     ax,0003h            ; Set 80x25x16 char mode
    int     10h                 ; Call VID interrupt
    ret
SetText ENDP

WaitVrt PROC NEAR               ; Waits for vertical retrace to reduce "snow"
    mov     dx,3dah
Vrt:
    in      al,dx
    test    al,8
    jnz     VRT                 ; Wait until Verticle Retrace starts
NoVrt:
    in      al,dx
    test    al,8
    jz      NoVRT               ; Wait until Verticle Retrace ends
    ret                         ; Return to main program
WaitVrt ENDP

SavePalette PROC NEAR           ; Saves entire palette in array
    cli                         ; Disable interrupts
    mov     bp,offset PaletteArray  ; Point to start of array
    mov     cx,768              ; Save all R,G,B registers
    mov     dx,03c7h            ; Read register
    mov     al,0                ; Start at 0
    out     dx,al               ; Write to port
    mov     dx,03c9h            ; Read data register
Grab:
    in      al,dx               ; Read value from port
    and     al,3fh              ; Mask of upper 2 bits
    mov     byte ptr [bp],al    ; Store the value in aray
    inc     bp                  ; Point to the next one
    loop    Grab                ; Loop until cx = 0
    sti                         ; Enable interrupts
    ret                         ; Return to main program
SavePalette ENDP

FadeOut PROC NEAR               ; Fades screen to black
    cli                         ; Disable interrupts
    mov     bp,offset PaletteArray  ; Point to start of array
    mov     cx,64               ; Repeat 64 times (0..63)
OneCycle:
    mov     bx,0                ; Set counter
Decrease:
    cmp     byte ptr [bp],0     ; Is it 0 already ?
    je      Fading              ; Yep => Do the next
    dec     byte ptr [bp]       ; Nope => Decrease by one
Fading:
    inc     bp                  ; Point to next value
    inc     bx                  ; Increase counter
    cmp     bx,768              ; Have we reached the end ?
    jl      Decrease            ; No => Do another one
    push    cx                  ; Save 1st loop counter
    call    WaitVrt             ; Wait for retrace
    sub     bp,768              ; Point to start
    mov     bx,0                ; Reset counter
    mov     cx,768              ; Do all colors
    mov     dx,03c8h            ; Write register
    mov     al,0                ; Start at 0
    out     dx,al               ; Write to port
    inc     dx                  ; Writing => 03c8h + 1 = 03c9h
WriteAll:
    mov     al,byte ptr [bp]    ; Store value in al
    out     dx,al               ; Give it to the VGA
    inc     bp                  ; Point to next one
    inc     bx                  ; Increase counter
    loop    WriteAll            ; Loop while cx > 0
    pop     cx                  ; Restore 1st loop counter
    sub     bp,768              ; Point to start
    loop    OneCycle            ; Loop while cx > 0
    sti                         ; Enable interrupts
    ret                         ; Return to main program
FadeOut ENDP

CalcStar PROC NEAR
    pusha                               ; Put all registers on stack
    mov     si,0                        ; si points to first star
StartCalc:                              ; Start searching for empty slots
    cmp     [NumActive],MaxStars        ; Check for room
    jae     NoEmptySpace                ; No room => exit

SearchSlot:
    cmp     word ptr [Stars.Z+si],MinZ  ; If Z = 0 then slot is empty
    je      FillSlot

    add     si,StarStrucSize            ; si points to next star
    cmp     si,StarStrucSize*MaxStars   ; Have we done entire array ?
    jb      SearchSlot                  ; No => search again
    jmp     NoEmptySpace                ; Yes => exit

FillSlot:
    mov     di,[XIndex]                 ; Grab Xindex and put it in di
    add     di,di                       ; Make WORD index
    mov     ax,[Numbers+di]             ; Get the number
    shl     ax,3                        ; Multiply by 8   
    mov     [Stars.X+si],ax             ; Save the number

    mov     di,[YIndex]                 ; Do the same for Y
    add     di,di
    mov     ax,[Numbers+di]
    shl     ax,3
    mov     [Stars.Y+si],ax

    mov     [Stars.Z+si],MaxZ           ; Give star the Z offset
    mov     al,0                        ; Also give it basecolor 0 (black)   
    mov     [Stars.Col+si],al           ; Store the color

    inc     [NumActive]                 ; Increase star counter

    inc     [XIndex]                    ; Increase the X index
    cmp     [XIndex],MaxNumbers         ; Have we reached the end of the list?
    jb      XindNotMax                  ; No => continue
    mov     [XIndex],0                  ; Yes => go to start of list

XindNotMax:
    inc     [YIndex]                    ; Increase the Y index   
    cmp     [YIndex],MaxNumbers         ; Have we reached the end of the list?
    jb      StartCalc                   ; No => continue
    mov     [YIndex],0                  ; Yes => go to start of list
    
NoEmptySpace:
    popa                                ; Restore all registers
    ret                                 ; Return to main program   
CalcStar ENDP

ShowStars PROC NEAR
    pusha                        ; Save all registers
    mov     si,0                 ; si points to first record
ShowLoop:
    mov     cx,[Stars.Z+si]      ; Grab Z value of star
    cmp     cx,0                 ; If Z = 0 then exit
    je      ContinueStar         ; Do the next star

    mov     di,[Stars.Old+si]    ; Get old position of star
    mov     byte ptr es:[di],0   ; Erase the old star

    mov     ax,[Stars.X+si]      ; Grab X value of star
    mov     dx,256               ; Multiply X with 256
    imul    dx
    idiv    cx                   ; Divide by Z
    add     ax,ScreenWidth/2     ; Add 160 to center it on the screen
    mov     di,ax                ; di = X
    cmp     di,ScreenWidth       ; Is the star in range ?
    jae     TermStar             ; No => Do next star

    mov     ax,[Stars.Y+si]      ; Grab an Y value
    mov     dx,256               ; Multiply Y with 256
    imul    dx
    idiv    cx                   ; Divide by Z (a bit slow but who carez)
    add     ax,ScreenHeight/2    ; Add 100 to center it on the screen
    cmp     ax,ScreenHeight      ; Is the star in range ?
    jae     TermStar             ; No => Do next star
    cmp     ax,90                ; Do not affect scroller
    jl      InRange
    cmp     ax,100               ; Text scrolls between 90 & 100
    ja      InRange
    jmp     TermStar             ; Star affects scroller so terminate it
InRange:
    imul    ax,ScreenWidth       ; ax = Y * ScreenWidth
    add     di,ax                ; di = X + (Y * 320) 

    mov     [Stars.Old+si],di    ; Save the position

    add     ch,cs:[Stars.Col+si] ; Divide Z by 256 & add basecolor 0
    mov     al,ch                ; Move color into al
    add     al,5d                ; Add 5 to avoid fontcolors

    mov     byte ptr es:[di],al  ; Place the dot on the screen

    mov     ax,[WarpSpeed]
    sub     cx,ax                ; Decrease Z with WarpSpeed
    mov     [Stars.Z+si],cx      ; Save the new Z

    jmp     ContinueStar         ; Do the next star

TermStar:
    mov     [Stars.Z+si],MinZ    ; Set Z to 0 => Star is terminated
    dec     [NumActive]          ; Decrease number of active stars

ContinueStar:
    add     si,StarStrucSize     ; si points to next record
    cmp     si,StarStrucSize*MaxStars  ; Reached end of array ?
    jb      ShowLoop             ; Continue with next star

    popa                         ; Restore all registers
    ret                          ; Return to main program
ShowStars ENDP


; === MAIN PROGRAM ===

START:

    cli                         ; Clear interrupt flag
    call    SetVGA              ; Get in GFX-mode

; === Set the palette ===
    mov     ax,cs               ; Move CS into AX
    mov     es,ax               ; es points to codesegment
    mov     ax,1012h            ; Select write palette function
    mov     bx,0                ; Start at color 0
    mov     cx,23               ; Write 23 colors
    mov     dx,offset Palette   ; es:dx points to palette data
    int     10h                 ; Call VID interrupt & set palette
    call    SavePalette         ; And save palette into array

; === Initialize pointers ===
    mov     ax,0a000h
    mov     es,ax               ; es points to VGA
    mov     ax,cs
    mov     ds,ax               ; ds points to codesegment (data)

; === Start scroll ===
Reset:
    lea     si,Text             ; si points to start of Text
Mainthing:                      ; Main loop
    lodsb                       ; Load a character in al    (si increased)
    cmp     al,0                ; Have we reached the end of da text ?
    je      Reset               ; Yep => Start over
    push    si                  ; Save character-offset on stack
    mov     bx,ax               ; Save the character into bx
    mov     cx,0                ; Set character-counter for position in font
    lea     si,Order            ; si points to offset Order
Again:
    lodsb                       ; Load the order-character (abcdef etc...)
    cmp     ax,bx               ; Is it da same letter/character ?
    je      Found               ; Yeah => Found it. . .
    inc     cx                  ; Nope => Increase character-counter
    jmp     Again               ; Compare with next character
Found:
    mov     ax,8                ; 7 pixels + black pixel = 8 pixels
    mul     cx                  ; ax=ax*cx    (e.g:  E := 4 * 10;)

    mov     bx,4                ; Draw 4 * 2 vertical lines
Hloop:
    lea     si,Font             ; si points to start of Font
    add     si,ax               ; si now points to character
    mov     di,320*91           ; di points to startposition on VGA
    mov     cx,9                ; Write 9 horizontal
Vloop:
    push    cx                  ; Save first loop-counter
    mov     cx,2                ; Draw 2 new horizontal pixels
    repz    movsb               ; And go !
    add     di,318              ; Point to next location on VGA
    add     si,318              ; Point to next source-location
    pop     cx                  ; Restore loop-counter
    loop    Vloop               ; Loop 9 times
; === Scroll the text and improve stars ===
    push    ds ax               ; Save pointer to character + ds
    mov     ax,0a000h           ; VGA-segment
    mov     ds,ax               ; ds points to VGA
    mov     si,320*90+2         ; Destination offset
    mov     di,320*90           ; Source offset
    mov     cx,10*320           ; Repeat factor => Number of bytes to copy
    rep     movsb               ; And go ! (Hint: why not use words instead)

    mov     di,320*101          ; On some slow VGA-cards we have to plot
    mov     cx,5                ; 5 black pixels just below the scroller
    mov     al,0                ; on the left on the screen. Erase this
    rep     stosb               ; code to see what I mean.

    call    WaitVrt             ; Wait for vertical retrace
    call    CalcStar            ; Calculate new stars
    call    ShowStars           ; Show all stars on VGA

; === Want to quit ? ===
    in      al,60h              ; Was ESCAPE pressed ?
    cmp     al,1
    je      QuitNow             ; If so, quit now. . .

; === No quit ? then continue ===
    pop     ax ds               ; Restore pointer to character + ds
    add     ax,2                ; And add 2 to point to next 2 vertical lines
    dec     bx                  ; Decrease line-counter
    jnz     Hloop               ; If it's 0 then jump
    pop     si                  ; Restore character-offset to do next char
    jmp     Mainthing           ; And start over again

QuitNow:                        ; Quit everything
    call    FadeOut             ; Fade da screen to black
    call    SetText             ; Get in TXT-mode
    mov     ax,cs
    mov     ds,ax               ; ds points to codesegment (data)
    lea     dx,Message          ; Load offset message
    mov     ah,9                ; Select function 9 (print string)
    int     21h                 ; Print the message
    mov     ax,4c00h            ; Quit program
    int     21h

END START                       ; End Of C<><>L Program !!!



; Code by Vulture.
; Thanx to Draeden of VLA for example code.
; Don't be lame. Don't just rip the code.
; Give credit where it should be. I did.
; See ya in the next release.

