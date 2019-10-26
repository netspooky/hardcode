; CYBERNETIC ASTEROID ATTACK 3000
; Copyright (C) 2004 Andy Sherwood
;
; Press mouse button and hit asteroid to destroy it
; and win, or something
;
; Compiled with NASM 0.98.36

; Constants
SCRWIDTH    EQU 320
SCRHEIGHT   EQU 200
IMGWIDTH    EQU 8
IMGHEIGHT   EQU 8
NUMIMGS     EQU 2

_images     EQU 8000h

org     100h

; 320x200x256 mode    
    mov     ax, 0013h
    int     10h

; Reset mouse - doesn't seem to matter tho    
    xor     ax,ax
    int     33h    

; Draw game images...
    mov     ax, 1300h
    mov     bx, 0FFh
    mov     cx, NUMIMGS
    xor     dx, dx
    mov     bp, _imagechars
    int     10h

; ...and store them for later on
    push    0A000h
    pop     ds
    xor     si,si
    mov     di, _images
    mov     cx, SCRWIDTH * IMGHEIGHT / 4
    rep     movsd

; Load FS with off screen buffer, which is one segment away
    mov     ax, cs
    add     ax, 1000h
    push    ax
    pop     fs

; Main loop of program
Main:
    push    cs
    pop     ds

; Clear off screen buffer
    mov     cx, SCRWIDTH * SCRHEIGHT / 4
    xor     bx, bx
ClearOSB:
    mov     DWORD [fs:bx], 0
    add     bx, 4
    loop    ClearOSB

; Draw asteroid
    mov     bx, [_enemyPos]
    mov     BYTE [_color], 06h
    xor     dx, dx
    call    BitBlt
    add     bx, 1
    mov     [_enemyPos], bx

; Get mouse position and buttons
    mov     ax, 3
    int     33h
    and     bl, 1
    add     bl, 0Eh
    mov     BYTE [_color], bl

    mov     ax, dx
    mul     WORD [_scrwidth]
    shr     cx, 1
    add     ax, cx
    mov     bx, ax

; Draw ship
    mov     dx, 1
    call    BitBlt

; Check for collision when button is pressed
    mov     bl, BYTE [_color]
    cmp     bl,0Fh
    jne     NoHit
    mov     al, BYTE [_collision]
    and     al, 0FFh
    jnz     Over

; Copy off screen buffer to display
NoHit:
    push    0A000h
    pop     es
    xor     edi, edi
    push    fs
    pop     ds
    xor     esi, esi
    
    mov     dx, 03DAh
RetraceIn: 
    in      al,dx
    and     al, 8
    jnz     RetraceIn
RetraceOut:
    in      al, dx
    and     al, 8
    jz      RetraceOut

    mov     ecx, SCRWIDTH * SCRHEIGHT / 4
    rep     movsd

    jmp     Main    

Over:
; All done - restore video mode and die
    mov     ax, 0003h
    int     10h
    int     20h

; Bit blt image and collision check
; bx = offset to top left of image in OSB
; dx = image to blt
; [color] = color for image
BitBlt:
    mov     BYTE [_collision], 0
    shl     dx, 3
    mov     si, dx
    add     si, _images
    mov     cx,IMGHEIGHT
LineCopy:
    push    cx
    mov     cx, IMGWIDTH
ColCopy:
    mov     al, BYTE [fs:bx]
    or      [_collision], al
    mov     al, BYTE [ds:si]
    and     al, [_color]
    mov     BYTE [fs:bx], al
    add     bx, 1
    add     si, 1
    Loop    ColCopy
    pop     cx
    add     bx, SCRWIDTH-IMGWIDTH
    add     si, SCRWIDTH-IMGWIDTH
    loop    LineCopy
    ret

; Variables
_color      db  0
_scrwidth   dw  SCRWIDTH
_imagechars db  'O'
_collision  db  0
_enemyPos   dw  28000
_initials   db 'AJS'
