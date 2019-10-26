; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;             The Pulptro Series #1 - Live...... or sumthin'
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Programmed by:
;    Kim Holviala a.k.a Kimmy/PULP Productions
;    Aladininkatu 7 B 19
;    49400 Hamina
;    FINLAND

; Email:
;    kimmy@iki.fi          (preferred)
;    kimmy@planet.fi

; URL:
;    http://www.iki.fi/kimmy/


; ---------------------------------------------------------------------------

; To compile with Turbo Assembler v3.0+:
;    TASM /m9 intro
;    TLINK /t /3 intro


; To compile with full debug data:
;    TASM /m /zi /ddebug intro
;    TLINK /v /3 intro


; ---------------------------------------------------------------------------

; This all is (of course) size-optimized, so some of the stuff here is
; totally unreadable..... Luckily that's your problem, not mine.....

; I'm using a lot of string instructions in a loop to save a lot
; of precious bytes. It's not very fast on modern new processors,
; but since I'm only using flat-shading, it really doesn't matter.
; Everything is fast enough as it is.

; The basic princples behind all the subroutines are:

;    - all routines are responsible to save all segmentregisters
;    - no other registers need to be saved except if noted (like drawPoly)

; If you use any of these routines in your own productios, go ahead...
; Just don't forget to greet me!

;    Copyright (c) 1995, 1996 Kim Holviala a.k.a Kimmy/PULP Productions



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Defines
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

OBJECT_SIZE     EQU     8               ; Size of the 3D-scene

CAM_HEIGHT      EQU     100             ; Minimum height of the camera

XMAX            EQU     319             ; Clipping values
YMAX            EQU     199

BUFFER_WIDTH    EQU     320             ; Width of the screen

XY_RATIO        EQU     78643           ; Fix for the incorrect x/y-ratio

Z_CLIP          EQU     100             ; Z-clipping limit

MIX_RATIO       EQU     15              ; Lenght of the blur (0-32)

ENABLE_TIMER    EQU     1               ; 0 = No timer , 1 = Use timer
PIT_FREQUENCY   EQU     19000           ; New frequency of PIT (timer)

ENABLE_MUSIC    EQU     1               ; 0 = No music, 1 = Play music

TEXTPOSITION    EQU     187*320+315     ; Position of the text

MONOMONITOR     EQU     0               ; Use the other monitor too


; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Code
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

IDEAL                                   ; MASM syntax must die!

MODEL TINY                              ; One segment should be enough :-)

P486                                    ; Hey, what else....


IFDEF debug                             ; .EXE must have an stack
   
        STACK   500h                    ; (size doesn't matter...)

ENDIF


CODESEG
STARTUPCODE


; Initialize everything -----------------------------------------------------

IFDEF debug

; Actually this shouldn't work.... But since it does, who cares ;-D.
; It makes debugging much easier as the memory layout is identical
; to the final .COM-file.

        mov     ax,cs                   ; Emulate a .COM-file while
        mov     ds,ax                   ; debuging
        mov     es,ax

        mov     ss,ax                   ; Move stack to the same segment
        mov     sp,0fff0h

ENDIF

        cld                             ; Just to be sure

        mov     ax,cs                   ; Calculate and store segments

        add     ax,1000h                ; Virtualbuffer
        mov     [virtualBuffer],ax

        add     ax,1000h                ; Table for color-mixing
        mov     [colorMixTable],ax      ; (requires full 64Kb's)

        add     ax,1000h                ; Segment for the displacement-map
        mov     [displaceMap],ax        ; (requires full 64Kb's)

        mov     dx,OFFSET gmidiQueryMsg ; Ask for the baseport
        mov     ah,9                    ; DOS - Print string
        int     21h

        mov     ah,0                    ; Wait for a keypress
        int     16h

        cbw                             ; AX = ASCII-code of the key
        sub     ax,'0'                  ; Calculate the baseport
        imul    ax,10h
        add     ax,300h
        mov     [gmidiPort],ax          ; Store it

        mov     di,OFFSET fontData      ; Get EGA 8x14 font
        call    getEGAfont

        call    createSincosTable       ; Create sincos-table

        mov     si,OFFSET keyframe1     ; Start from keyframe 1
        mov     di,OFFSET morphedFrame
        mov     cx,142*9
        rep movsb

        mov     ax,13h                  ; Set mode 13h (320x200/256)
        int     10h

        mov     di,OFFSET realPalette   ; Get the default VGA palette
        push    di
        call    getPalette              ; (hope it's same with every card...)

        pop     di                      ; Make the necessary changes
        call    modifyPalette           ; to the palette

        mov     si,OFFSET realPalette   ; Set the modified palette
        call    setPalette

        mov     di,OFFSET currPalette   ; Copy the modified palette here
        call    getPalette

        push    0a000h                  ; Print "Calculating..."
        pop     es
        call    printCurrentText
        mov     [currString],bx

        mov     es,[displaceMap]        ; Calculate the displacement-map
        call    calcDisplaceMap

        mov     es,[colorMixTable]      ; Destination segment
        mov     si,OFFSET realPalette   ; Offset of the current palette
        call    calcMixTable            ; Calculate the color-mixing table

        push    cs                      ; Restore es
        pop     es

        mov     si,OFFSET realPalette   ; Calculate the grayscale-table
        mov     di,OFFSET grayScaleTable ; Destination offset
        call    calcGrayTable


IF ENABLE_MUSIC EQ 1

        call    gmidiInitialize         ; Initialize GMIDI device

ENDIF

IF ENABLE_TIMER EQ 1

        mov     ax,PIT_FREQUENCY        ; New PIT frequency
        mov     bx,cs                   ; New address of the handler
        shl     ebx,16
        mov     bx,OFFSET timerHandler

        call    installTimerhandler     ; Install new timer-interrupt

ENDIF

        call    initFlash               ; Flash the screen



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Main loop
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

main_loop:

IF ENABLE_TIMER EQ 0

        mov     [frameCounter],1        ; Advance one frame (if no timer)
        inc     [tickCounter]           ; Advance tickcounter
        call    updateStuff             ; Update stuff :-)

IF ENABLE_MUSIC EQ 1

        call    playMusic               ; Play a tick of music (if no timer)

ENDIF
ENDIF

        cmp     [frameCounter],0        ; Don't draw the same frame twice
        je      main_loop               ; on _fast_ machines

frame_loop:
        call    moveEverything          ; Move the scene

        dec     [frameCounter]          ; Skip frames on slower (= normal)
        jnz     frame_loop              ; machines

        cmp     [tickCounter],6624      ; Time to quit?
        ja      exit2dos                ; Yepp -> Quit

        call    calculateStuff          ; Do misc. stuff

        mov     es,[virtualBuffer]      ; Draw to this segment

        call    drawBackground          ; Draw the background

        mov     si,OFFSET morphedFrame  ; Draw the scene
        call    draw3DScene

IF MONOMONITOR EQ 1

        call    monoFlip                ; Draw to the second monitor

ENDIF

        call    printCurrentText        ; Draw the current textstring

        cmp     [fadeInProgress],0      ; Is fade in progress?
        je      nofade                  ; Nope -> Skip it

        mov     si,OFFSET currPalette   ; Yes -> Offset to the palette

        call    wait4VR                 ; Wait for a vertical retrace
        call    setPalette              ; Set the new palette

nofade:
        call    [flipScreen]            ; Show hidden buffer and effects

        push    cs                      ; Restore es
        pop     es

        mov     ah,1                    ; Check for a keypress
        int     16h

        jz      main_loop               ; No keys pressed -> Keep looping



; Cleanup & exit ------------------------------------------------------------

exit2dos:

IF ENABLE_TIMER EQ 1

        xor     ax,ax                   ; Restore PIT frequency
        mov     ebx,[oldTimerHandler]   ; And the old INT 08 -handler
        call    installTimerHandler

ENDIF

IF ENABLE_MUSIC EQ 1

        call    gmidiShutUp             ; Turn off all notes

ENDIF

        mov     ax,3                    ; Back to textmode
        int     10h

        mov     dx,OFFSET endMessage    ; Print exit-message
        mov     ah,9                    ; DOS - Print string
        int     21h

        mov     ax,4c00h
        int     21h                     ; Exit 2 DOS



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  All external code
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


INCLUDE "initcode.inc"                  ; Code needed for intialization
INCLUDE "midicode.inc"                  ; Code needed for GMIDI music
INCLUDE "3dcode.inc"                    ; Code needed for 3D-gfx



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  New interrupt-handler for INT 08h
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Since this is supposed to be short, we don't bother calling the
; old handler at all. BIOS time will not be updated during the intro,
; but who cares..... :-D


IF ENABLE_TIMER EQ 1

PROC timerHandler

        pushad                          ; Save all regs
        push    ds                      ; Save ds & es
        push    es

        mov     ax,cs                   ; Make sure ds & es = cs
        mov     ds,ax
        mov     es,ax

        cld                             ; Make sure we go forward

        inc     [frameCounter]          ; Increase counters
        inc     [tickCounter]

        call    updateStuff             ; Update stuff ;-D

        mov     al,20h                  ; Acknowledge the interrupt
        out     20h,al

IF ENABLE_MUSIC EQ 1

        call    playMusic               ; Play one tick of music

ENDIF

        pop     es                      ; Restore es & ds
        pop     ds
        popad                           ; Restore regs

        iret                            ; Return from interrupt

ENDP

ENDIF



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Install a handler for the timer-interrupt
;
;  Input:
;      AX  - New frequency for the PIT
;      EBX - Address of the new handler (seg:off)
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


IF ENABLE_TIMER EQ 1

PROC installTimerHandler

        push    ax                      ; Save frequency

        mov     al,34h                  ; Set PIT channel 0 frequency
        out     43h,al

        pop     ax                      ; Set low byte
        out     40h,al

        mov     al,ah                   ; Set high byte
        out     40h,al

        push    es                      ; Save es

        xor     ax,ax                   ; es = 0000
        mov     es,ax

        mov     eax,[es:0020h]          ; Get old handler address
        mov     [oldTimerHandler],eax

        mov     [es:0020h],ebx          ; Put in the new handler's address

        pop     es                      ; Restore es

        ret

ENDP

ENDIF



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Move the scene, life and everything
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Advances the movement of the camera, as well as the fading.


PROC moveEverything

        add     [moveRotX],56           ; Rotate the vertex that controls
        add     [moveRotY],33           ; the movement of the camera
        add     [moveRotZ],47

        mov     si,OFFSET morphedFrame  ; Morph the scene from one keyframe
        mov     di,[morphDest]          ; to another
        mov     cx,56*9

        call    morphArray              ; Morph da scene

        cmp     [fadeInProgress],0      ; Is palettefade in progress?
        je      @@quit                  ; Nope -> Skip it

        mov     si,OFFSET currPalette   ; Current palette
        mov     di,OFFSET realPalette   ; Fade to this palette
        mov     cx,768                  ; Fade 768 values

        call    morphArray              ; Fade palette

        cmp     ax,0                    ; Was the fade complete?
        je      @@quit

        mov     [fadeInProgress],0      ; Yes -> Clear the flag

@@quit:
        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Handle text and effect updating + keyframe direction change
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC updateStuff

        mov     ax,[tickCounter]        ; Get ticks
        mov     bp,ax                   ; Save it
        cwd                             ; Prepare for a division
        mov     cx,96                   ; Change texts every 96 tics

        idiv    cx                      ; Divide

        dec     dx                      ; Check the remainder
        jns     @@effect                ; Not 0 -> Skip this part

        mov     ax,[nextString]         ; Offset to the next textstring
        mov     [currString],ax

@@effect:
        mov     ax,bp                   ; Get ticks
        cwd                             ; Prepare for a division
        mov     cx,768                  ; Flash every 768 tics

        idiv    cx                      ; Divide

        dec     dx                      ; Check the remainder
        jns     @@keyframe              ; Not 0 -> Skip this part

        call    initFlash               ; Initialize the "flash"

        mov     bx,[effectNumber]       ; Get effect number
        shl     bx,1

        mov     ax,[effectOffset+bx]    ; Get offset to the new effect
        mov     [flipScreen],ax         ; Use it

        inc     [effectNumber]          ; Next effect

@@keyframe:
        mov     ax,bp                   ; Get ticks
        cwd                             ; Prepare for a division
        mov     cx,12                   ; Change direction every 12 tics

        idiv    cx                      ; Divide

        dec     dx                      ; Check the remainder
        jns     @@quit                  ; Not 0 -> Skip this part

        cmp     [morphDest],OFFSET keyframe1 ; Which keyframe in use now?
        je      @@here

        mov     [morphDest],OFFSET keyframe1 ; Switch direction
        jmp     @@quit

@@here:
        mov     [morphDest],OFFSET keyframe2 ; Likewise

@@quit:
        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Print the current textstring
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC printCurrentText

        mov     bx,[currString]         ; Draw the current textstring
        mov     di,TEXTPOSITION+321
        mov     dl,25
        call    drawString              ; Draw the shadow

        mov     bx,[currString]
        mov     di,TEXTPOSITION
        mov     dl,31
        call    drawString              ; Draw the string on top of shadow

        mov     [nextString],bx         ; Save offset to the next string

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Draw a textstring
;
;  Input:
;      BX - Offset to the ASCIIZ string
;      DI - Position of the text
;      DL - Color
;      ES - Segment to draw to
;
;  Returns:
;      BX - Offset to the next string (offset of da 0-byte + 1)
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC drawString

@@loop:
        movzx   si,[BYTE bx]            ; Get one char from da string
        inc     bx                      ; Advance source

        cmp     si,0                    ; Was the char 0?
        je      @@quit                  ; Yepp -> Quit

        imul    si,14                   ; Calculate offset to the char's
        add     si,OFFSET fontData      ; fontdata

        mov     cl,14                   ; Loop through 14 rows

        push    di                      ; Save destination offset

@@charloop:
        lodsb                           ; Get one row of fontdata

        mov     ch,8                    ; Loop through 8 pixels

@@rowloop:
        shl     al,2                    ; Get one pixel of fontdata
        jnc     @@nopixel               ; Check bit's value

        mov     [es:di],dl              ; Was 1 -> Draw one pixel

@@nopixel:
        inc     di                      ; Advance destination

        dec     ch                      ; Loop through this row
        jnz     @@rowloop

        add     di,320-8                ; DI to the start of next row

        dec     cl                      ; Loop through all rows
        jnz     @@charloop

        pop     di                      ; Restore destination offset
        sub     di,7                    ; Next char

        jmp     @@loop                  ; Loop through the string

@@quit:
        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Calculate matrix for the camera and the y-coordinate of the horizont
;
;  Input:
;      A bunch of memoryvariables....
;
;  Returns:
;      BX - y-coordinate of the horizont
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC calculateStuff

; This part is for the camera -----------------------------------------------

; The position of the camera is based on the vertex "moveCamera".
; Don't ask how it works, it just does......


        mov     ax,[moveRotX]           ; Get rotation-counters
        mov     [rotX],ax               ; for moveCamera

        mov     ax,[moveRotY]
        mov     [rotY],ax

        mov     ax,[moveRotZ]
        add     ax,16000
        mov     [rotZ],ax

        mov     di,OFFSET matrix        ; Calculate matrix for it
        call    calculateMatrix

        mov     ax,OFFSET matrix
        mov     si,OFFSET moveCamera    ; Source vertex
        mov     di,OFFSET moveX         ; Destination vertex
        call    rotateVertex            ; Rotate


; Now we have a vertex in moveX/Y/Z. We'll just take the coords
; and use them to move the camera.


        movsx   eax,[moveY]             ; Calculate distance of the camera
        imul    eax,100                 ; based on moveY
        add     eax,0500000h
        mov     [distance],eax

        mov     ax,[moveX]              ; Calculate rotation around the
        sar     ax,2                    ; x-axis based on moveX
        add     ax,22500
        mov     [rotX],ax

        mov     [rotY],0                ; Don't ask... ;-D

        mov     ax,[moveZ]              ; More weird stuff
        mov     [rotZ],ax

        mov     di,OFFSET cameraMatrix  ; Calculate matrix for the camera
        call    calculateMatrix


; Handle the horizont -------------------------------------------------------

; The y-coordinate of the horizont will simply be taken from the
; y-coordinate of a vertex very far away. But since we can't rotate
; that vertex around the z-axis (or the vertex wouldn't always be
; in the distance), we'll have to calculate a new matrix for it.

        mov     [rotZ],0                ; Don't rotate around the z-axis

        mov     di,OFFSET matrix        ; Calculate new matrix
        call    calculateMatrix

        mov     si,OFFSET horizVertex   ; Source offset
        mov     di,OFFSET horizX        ; Destination offset
        mov     ax,OFFSET matrix        ; Offset to the matrix
        call    rotateProjectVertex     ; Rotate & project the vertex

        mov     bx,[horizY]             ; Take the y-coordinate of vertex
        add     bx,20                   ; Lower the horizont a bit

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Set palette
;
;  Input:
;      SI - Source offset to the full palette (768 bytes)
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Sets the full 256-color palette. Some people say that you shouldn't use
; rep outsb as a few really cheap and crappy VLB-cards supposedly can't
; handle it.... Dunno, so I'm using it here anyway as it's short and fast.


PROC setPalette

        mov     dx,3c8h                 ; Start from color 0
        xor     al,al
        out     dx,al

        inc     dx                      ; Output to port 3C9
        mov     cx,768                  ; Set 768 registers

        rep outsb                       ; Set all DAC:s

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Initialize the "flash"-effect
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC initFlash

        mov     cx,256                  ; Modify the whole palette
        mov     eax,3fh                 ; Set all colors to red
        mov     di,OFFSET currPalette   ; Modify this palette

@@palette_loop:
        stosd                           ; Set RGB
        dec     di                      ; Advance DI only by 3, not by 4

        loop    @@palette_loop          ; Loop through the palette

        mov     [fadeInProgress],1      ; Set the fade-flag

        add     [moveRotX],9748         ; Shake the camera a bit
        add     [moveRotY],21733
        add     [moveRotZ],15389

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Draw the background
;
;  Input:
;      BX - Y-coordinate of the horizon
;      ES - Destination segment
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC drawBackground

        xor     di,di                   ; Initial offset
        mov     eax,02020202h           ; Ground color
        mov     cx,16000                ; Draw 16000 dwords

        rep stosd                       ; Draw the ground

        cmp     bx,1                    ; Draw the sky?
        jl      @@quit                  ; No -> Quit

        imul    bx,320                  ; Initial offset to
        mov     di,bx                   ; the start of the horizont
        sub     di,2

        mov     ax,0dfdfh               ; Initial color for the sky

        mov     dl,3                    ; Draw three rows/color

        std                             ; We'll be drawing backwards

@@skyloop:
        mov     cx,BUFFER_WIDTH/2       ; Lenght of one row in words

        rep stosw                       ; Draw one row

        cmp     ax,0c1c1h               ; Don't go beyound this color
        jb      @@nochange

        dec     dl                      ; Time to change the color?
        jnz     @@nochange

        sub     ax,0101h                ; Yepp -> Next color
        mov     dl,3                    ; Draw three rows/color

@@nochange:
        cmp     di,64000                ; Sky done?
        jb      @@skyloop               ; Nope -> Loop

@@quit:
        cld                             ; Restore direction

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Wait for the next vertical retrace
;
;  Input:
;      ES - Source segment
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

PROC wait4VR
	
        mov     dx,3dah                 ; Use port 3D4

@@off:
        in      al,dx                   ; Get vertical retrace state
	
        test    al,08h
        jnz     @@off                   ; Loop until it's off

@@on:
        in      al,dx                   ; Get vertical retrace state
	
        test    al,08h
        jz      @@on                    ; Loop until it's on

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Flip virtual buffer to VGA memory using the displacement-map
;
;  Input:
;      ES - Source segment
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC displaceFlip

        push    ds                      ; Save ds

        push    es                      ; Move source segment to fs
        pop     fs

        mov     ds,[displaceMap]        ; Segment of the map to ds

        mov     ax,0a000h               ; Destination segment
        mov     es,ax

        xor     di,di                   ; Initial offsets
        xor     si,si
        mov     cx,64000                ; Loopcounter


@@loop:
        mov     al,[di-320]             ; Get the 4 surrounding pixels
        mov     bl,[di-1]
        mov     ah,[di+320]
        mov     bh,[di+1]

        sub     al,ah                   ; Calculate the direction of the
        sub     bl,bh                   ; normal
        cbw           
        movsx   bx,bl
        imul    ax,320
        add     bx,ax

        mov     al,[fs:bx+di]           ; Get pixel from source
        stosb                           ; Store it

        loop    @@loop                  ; Loop

        pop     ds                      ; Restore ds

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Flip virtual buffer to the second monitor (mono)
;
;  Input:
;      ES - Source segment
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


IF MONOMONITOR EQ 1

PROC monoFlip


IFDEF debug

        ret                             ; Don't use this while debugging

ENDIF

        push    ds                      ; Save ds
        push    es                      ; Save es

        push    es                      ; Source segment to ds
        pop     ds

        mov     ax,0b000h               ; Destination segment (monotext)
        mov     es,ax

        xor     di,di                   ; Initial offsets
        xor     si,si

        mov     dx,25                   ; Handle 25 rows

@@loop:
        mov     cx,80                   ; Handle 80 columns

@@inner:
        lodsb                           ; Get pixel

        movzx   bx,al                   ; Convert color to grayscale
        mov     bl,[cs:bx+grayScaleTable]

        shr     bx,2                    ; Table gives us 0-63, we want 0-15
        mov     al,[cs:bx+dotChars]     ; Convert grayscale to char

        mov     ah,2                    ; Set attribute
        stosw                           ; Draw character

        add     si,3                    ; Skip some source pixels

        loop    @@inner                 ; Loop through this row

        add     si,7*320                ; Skip some rows

        dec     dx                      ; Loop through all rows
        jnz     @@loop

        pop     es                      ; Restore es
        pop     ds                      ; Restore ds

        ret

ENDP

ENDIF



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Flip virtual buffer to VGA using multiple screens
;
;  Input:
;      ES - Source segment
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


PROC splitFlip

        push    ds                      ; Save ds

        push    es                      ; es = ds
        pop     ds

        mov     ax,0a000h               ; Destination segment to es
        mov     es,ax

        xor     di,di                   ; Draw upper left screen
        call    @@normal

        mov     di,160                  ; Draw upper right screen
        call    @@gray

        mov     di,320*100              ; Draw lower left screen
        call    @@gray

        mov     di,320*100+160          ; Draw lower right screen
        call    @@normal

        pop     ds

        ret


; Draw 1/4 screen using normal colors ---------------------------------------

@@normal:
        mov     dx,100                  ; Loop through 100 rows
        mov     cx,160                  ; Loop through 160 columns
        xor     si,si                   ; Initial source

@@nloop:
        lodsb                           ; Get one pixel
        inc     si                      ; Skip one source pixel
        stosb                           ; Store pixel

        loop    @@nloop                 ; Loop through the row

        mov     cx,160                  ; New loopcounter
        add     si,320                  ; Skip one full row
        add     di,160                  ; Adjust destination ptr

        dec     dx                      ; Loop
        jnz     @@nloop

        ret


; Draw 1/4 screen using other than normal colors.... ------------------------

@@gray:
        mov     dx,100                  ; Loop through 100 rows
        mov     cx,160                  ; Loop through 160 columns
        xor     si,si                   ; Initial source

@@gloop:
        lodsb
        inc     si

        movzx   bx,al                   ; Convert color to grayscale
        mov     bl,[cs:bx+grayScaleTable]

        shr     bx,1                    ; Table gives us 0-63, we want 0-31

        mov     al,192                  ; Convert to an nice color
        add     al,bl

        stosb                           ; Store pixel

        loop    @@gloop                 ; Loop through the row

        mov     cx,160                  ; New loopcounter
        add     si,320                  ; Skip one full row
        add     di,160                  ; Adjust destination ptr

        dec     dx                      ; Loop
        jnz     @@gloop

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Flip virtual buffer to VGA memory with motion-blur
;
;  Input:
;      ES - Source segment
;      AX - Segmentaddress of the color-mixing table
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

PROC blurFlip

        push    ds                      ; Save ds
        mov     ds,[colorMixTable]      ; Color-mixing table to ds

        push    es                      ; Source segment to fs
        pop     fs

        mov     ax,0a000h               ; Destination segment to es
        mov     es,ax

        xor     di,di                   ; Initial offset
        mov     [count],16000           ; Loopcounter

@@mainloop:
        mov     ecx,[es:di]             ; Read four old pixels
        mov     edx,[fs:di]             ; Read four new pixels

        mov     si,4                    ; Handle 4 pixels in a loop

@@loop:
        mov     bl,cl                   ; Get one old pixel to bl

        ror     eax,8                   ; Move the mixed pixel up in eax

        mov     bh,dl                   ; Get one new pixel to bh

        shr     ecx,8                   ; Next pixel to cl

        mov     al,[bx]                 ; Mix the two pixels in bx

        shr     edx,8                   ; Next pixel to dl

        dec     si                      ; Loop
        jnz     @@loop

        ror     eax,8                   ; Fix eax
        stosd                           ; Store pixels & advance di

        dec     [count]                 ; Loop
        jnz     @@mainloop

        pop     ds                      ; Restore ds

        ret

ENDP



; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  Morph an array of bytes
;
;  Input:
;      SI - Offset to first array (this array will be morphed)
;      DI - Offset to second array (these are the destination values)
;      CX - Lenght of the array
;
;  Reuturns:
;      AX - 0 = Morph not complete, 1 = Morph complete
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

; Morphs an array of bytes. When all bytes of the first array are
; equal to the bytes in the second array, returns 1 in ax.
; This can be used for fading, morphing of 3D-objects etc....


PROC morphArray

        mov     ax,1                    ; Assume morph is complete
        inc     cx                      ; Fix counter

@@loop:
        repe    cmpsb                   ; Find non-equal bytes

        jcxz    @@quit                  ; End of the array?

        jg      @@here                  ; Decide what to do....

        xor     ax,ax                   ; Morph was not complete
        inc     [BYTE si-1]             ; Byte was less -> Increase it

        jmp     @@loop                  ; Loop

@@here:
        xor     ax,ax                   ; Morph was not complete
        dec     [BYTE si-1]             ; Byte was greater -> Decrease it

        jmp     @@loop                  ; Loop

@@quit:
        ret


ENDP


; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
;  All data
;
; ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


INCLUDE "data.inc"


END

   
        That's all folks...

