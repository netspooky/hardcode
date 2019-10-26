;----------------------------------------------------------------------------
; MAGIC-EYE! 128 (original idea/C code by CrASH_Man) 18 Jan 2000
; Copyright (C) 2000 Barubary and CrASH_Man
;----------------------------------------------------------------------------
; Assembles with TASM.
;
; For the #ASM compo #3 - 128 byte demo
;
; Email: barubary@lfx.org
;        crashman@affinix.com
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; You may find the newest version of the GPL at
;  http://www.gnu.org/copyleft/gpl.html

    LOCALS @@
    .MODEL TINY
    .CODE
    .386

    ORG 00100h

; Constants (modify them at will)

PERIOD      EQU 48                      ; Run length of period in magic eye
DEPTH       EQU 2                       ; The higher, the flatter (power of 2)

RADIUS      EQU 75                      ; Radius of the hemisphere (pixels)
CENTER_X    EQU 136                     ; Center of hemisphere on screen (X)
CENTER_Y    EQU 100                     ;                                (Y)

start:
    fninit                              ; Initialize FPU (for square root)

    mov     ax, 00013h                  ; Set video mode
    int     010h                        ;

    mov     ah, 000h                    ; Get tick count (for lame random)
    int     01Ah                        ;
    mov     word ptr [Rnd + 1], dx      ;

    push    0A000h                      ; Video segment
    pop     ds                          ;

    xor     di, di                      ; y
    mov     cx, -CENTER_Y

draw_y:
                                        ; Start first X for loop
    xor     bx, bx                      ; x
draw_first_x:

Rnd:                                    ; Random routine from CrASH (TI-82)
    mov     si, 00000h                  ;
    add     word ptr cs:[Rnd+1], 0FF01h
    add     dl, [si]                    ; dx is intentionally not initialized
    add     dx, si                      ;
    sub     dl, dh                      ;

    mov     [di + bx], dl               ; Write to VRAM

    inc     bx                          ; Repeat until PERIOD
    cmp     bl, PERIOD                  ;
    jnz     draw_first_x                ; End of first X for loop

draw_second_x:

    mov     ax, cx                      ; ty (note: negative from C code)
    lea     dx, [bx-CENTER_X-PERIOD]    ; tx (negative); -PERIOD for x2
    imul    ax, ax                      ; Signed-squaring removes negatives
    imul    dx, dx                      ;

    add     ax, dx                      ; tmp
    sub     ax, RADIUS * RADIUS         ; ax = -tmp now

                                        ; Masking (to prevent sqrt of negs)
    cwd                                 ; If tmp positive (ax neg), dx=FFFF
    and     ax, dx                      ; Zero if tmp is negative
    neg     ax                          ; Need tmp, not -tmp

    mov     [sqrt_temp], ax             ; Square root
    fild    word ptr [sqrt_temp]        ;
    fsqrt                               ;
    fistp   word ptr [sqrt_temp]        ;
    mov     si, [sqrt_temp]             ;

    shr     si, DEPTH                   ; Divide by 4 (end fn())

    lea     bp, [si + bx - PERIOD]      ; Nasty code.  x2 + x
    mov     al, ds:[di + bp]            ; getpixel with x2 + y + fn()
    mov     [di + bx], al               ; Write to x + y

    inc     bx                          ; Repeat until 320
    cmp     bx, 320                     ;
    jnz     draw_second_x               ; End of second X for loop

    inc     cx                          ; Increment Y coordinate
    add     di, bx                      ; Increment Y-offset by 320 (bx=320)
    cmp     di, 64000                   ; Repeat until 64000
    jnz     draw_y                      ; End of Y for loop

    xor     ah, ah                      ; Wait for key
    int     016h                        ;

    mov     ax, 00003h                  ; Text mode
    int     010h                        ;

    ret                                 ; End of proggie

sqrt_temp   dw 0                        ; 2 extra bytes to fill in 128 :P

end start
