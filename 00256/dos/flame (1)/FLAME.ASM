;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
; Program Name : FLAME.COM
; Programmer   : Duncan Chambers (Psyq)
; Assembler    : TASM flame - TLINK flame /t
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


.286P
.model  tiny


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Equates
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

vmode13         equ     13h     ; Video mode 320x200x256

INPUT_STATUS_1  equ 3DAh        ; DIA : Bits 5-4 : Diagnostic
                                ; VR  : Bit 3    : Vertical Retrace 1=VR Mode
                                ; LSW : Bit 2    : Light Pen Switch
                                ; LST : Bit 1    : Light Pen Strobe
                                ; DE  : Bit 0    : Display Enable NOT 1=Ret.Md

SEQ_ADDR_PORT   equ 3C4h        ; Address           -   3C4     3C4     -
                                ; Reset             0   3C5     3C5     -
                                ; Clocking Mode     1   3C5     3C5     -
                                ; Map Mask          2   3C5     3C5     -
                                ; Chr.Map.Select    3   3C5     3C5     -
                                ; Memory Mode       4   3C5     3C5     -

CRTC_ADDR_PORT  equ 3D4h        ; Address           -   3D4/3B4 3D4/3B4 -
                                ; Horizontal Total  0   3D5/3B5 3D5/3B5 -
                                ; Horiz.Disp.End    1   3D5/3B5 3D5/3B5 -
                                ; Start Horiz.Blank 2   3D5/3B5 3D5/3B5 -
                                ; End Horiz.Blank   3   3D5/3B5 3D5/3B5 -
                                ; Start Horiz.Retrc 4   3D5/3B5 3D5/3B5 -
                                ; End Horiz.Retrac  5   3D5/3B5 3D5/3B5 -
                                ; Vertical Total    6   3D5/3B5 3D5/3B5 -
                                ; Overflow          7   -       3D5/3B5 -
                                ; Preset Row Scan   8   3D5/3B5 3D5/3B5 -
                                ; Max Scan Line     9   3D5/3B5 3D5/3B5 -
                                ; Cursor Start      A   3D5/3B5 3D5/3B5 -
                                ; Cursor End        B   -       3D5/3B5 -
                                ; Start Address Hi  C   3D5/3B5 3D5/3B5 3D5/3B5
                                ; Start Address Low D   3D5/3B5 3D5/3B5 3D5/3B5
                                ; Cursor Locat.Hi   E   3D5/3B5 3D5/3B5 3D5/3B5
                                ; Cursor Locat.Low  F   3D5/3B5 3D5/3B5 3D5/3B5
                                ; Vert.Retr.Start   10  3D5/3B5 3D5/3B5 -
                                ; LightPen Hi(EGA)  10  -       -       3D5/3B5
                                ; Vert.Retr.Low     11  3D5/3B5 3D5/3B5 -
                                ; LightPen Low(EGA) 11  -       -       3D5/3B5
                                ; Vert.Display End  12  3D5/3B5 3D5/3B5 -
                                ; Offset            13  3D5/3B5 3D5/3B5 -
                                ; Underline Locat.  14  3D5/3B5 3D5/3B5 -
                                ; Start Vert.Blank  15  3D5/3B5 3D5/3B5 -
                                ; End Vert.Blank    16  3D5/3B5 3D5/3B5 -
                                ; Mode Control      17  3D5/3B5 3D5/3B5 -
                                ; Line Compare      18  3D5/3B5 3D5/3B5 -


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; COM file has code segment only
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

flame   segment para 'code'

        org     100h

        ASSUME  CS:flame, DS:flame, ES:flame, SS:flame

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Code Section
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

start:

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Setup the screen as 80x80x256 modex (36 bytes)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

        mov     ah,0Fh                  ; Get Current Display Mode Function
        int     10h                     ; BIOS Call
        push    ax                      ; Store video mode on stack

        mov     ax,vmode13              ; Set Video Mode 320x200x256 (13h)
        int     10h                     ; Automatically clears screen

        mov     dx,SEQ_ADDR_PORT        ; Memory Mode Register - Index 04h
        mov     ax,0604h                ; C4 =0 : Planes selected by MAP MASK
        out     dx,ax                   ; O/E=1 : Sys use sequent.addressing
                                        ; EM =1 : Extended memory present>64K
                                        ; A/G=0 : Select a graphics mode
        mov     ax,0F02h                ; Enable write to All Four Planes
        out     dx,ax
        mov     dx,CRTC_ADDR_PORT       ; Program CRT Controller
        mov     ax,00014h               ; DWORD Mode OFF
        out     dx,ax
        mov     ax,0e317h               ; BYTE Mode ON
        out     dx,ax
        mov     ax,00409h               ; Height of cell
        out     dx,ax


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Create 256 colour palette and display (121 bytes)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

        mov     di,offset end_of_code+2 ; End of program temp storage
        push    di                      ; Save for setting palette

        ; 216bytes = 0, 552bytes = 63
        mov     cx,72*3                 ; 0 value bytes
        mov     al,0
        rep     stosb
        mov     cx,184*3                ; 63 value bytes
        mov     al,63
        rep     stosb
        pop     di
        push    di

        ; Calculate black to blue to darkred (32 bytes)
        mov     bl,0
pal_black2blue2dred:
        inc     di                      ; black to blue : red=0
        inc     di                      ; black to blue : green=0
        mov     al,bl
        shl     al,1
        stosb                           ; black to blue : blue=2*AL
        add     di,7*3
        stosb                           ; blue to dred  : red=2*AL
        inc     di                      ; blue to dred  : green=0
        sub     al,16
        neg     al
        stosb                           ; blue to dred  : blue=16-2*AL
        sub     di,8*3
        inc     bl
        cmp     bl,8
        jl      short pal_black2blue2dred
        add     di,8*3

        ; Calculate darkred to lightred & yellow to white (36 bytes)
        mov     bl,0
pal_dred2lred_yell2wht:
        mov     al,47
        mul     bl
        mov     cl,24
        div     cl
        add     al,16
        stosb                           ; dred to lred    : red=16+47*BL/24
        add     di,55*3+4               ; dred to lred    : green=0, blue=0
                                        ; yellow to white : red=63, green=63
        mov     al,21
        mul     bl
        shr     ax,3
        stosb                           ; yellow to white : blue=21*BL/8
        sub     di,56*3
        inc     bl
        cmp     bl,24
        jl      short pal_dred2lred_yell2wht

        ; Calculate lightred to yellow (20 bytes)
        mov     bl,0
pal_lightred2yellow:
        mov     al,31
        mul     bl
        shl     ax,4                    ; /16, but just move into top byte
        mov     al,63
        stosw                           ; red=63, green=31*BL/16
        inc     di                      ; blue=0
        inc     bl
        cmp     bl,32
        jl      short pal_lightred2yellow

        ; Set 256 colour palette (13 bytes)
        mov     al,0                    ; Palette 0
        mov     dx,3c8h
        out     dx,al
        pop     si                      ; Offset of 256 colour palette
        inc     dx                      ; DX=3C9h
        mov     cx,256*3                ; RGB for each colour
        rep     outsb                   ; Output colours to palette 0


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Set ES and clear video screen (14 bytes)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

        push    0A000h                  ; Set ES to video segment
        pop     es

        mov     di,0                    ; Clear video
        mov     al,0
        mov     cx,88*80
        rep     stosb

loop_here:

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Keep flame alive (18 bytes)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

        mov     di,86*80
        mov     cl,26
new_flame_loop:
        in      ax,40h                  ; Random value
        and     ax,3f3fh                ; AH & AL not over 63
        add     es:[di],ax              ; Add to keep flame alive
        add     di,3                    ; Next flame start position
        loop    short new_flame_loop

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Flame FX (44 bytes)
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

        mov     di,0
        mov     cx,86*80
flame_effect_loop:
        mov     ax,es:[di+79]           ; Get the average of the 4 nearest
        add     al,ah                   ; pixel colours below current pixel.
        mov     ah,0
        rcl     ah,1
        add     al,es:[di+81]
        adc     ah,0
        add     al,es:[di+2*80]
        adc     ah,0
        sub     ax,4
        sar     ax,2
        jge     short flame_ok          ; Flame OK height, jump..!
        mov     al,0
flame_ok:
        stosb
        loop    short flame_effect_loop



;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Check for ANY key being pressed (6 bytes)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

        mov     ah,1
        int     16h                     ; Any key pressed..?
        je      short loop_here         ; No..!

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
; Exit program here
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

exit:


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Setup screen as old mode before exit (5 bytes)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

        pop     ax                      ; Set old video mode
        mov     ah,00h
        int     10h                     ; Call BIOS

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Exit program (4 bytes)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

        mov     ah,4Ch                  ; Exit
        int     21h

end_of_code:    ; Here to find end of program address for temp storage

flame   ENDS
END     start
