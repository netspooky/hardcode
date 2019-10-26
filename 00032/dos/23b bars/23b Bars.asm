;лллллллллллллллллллллллл 23b Bars лллллллллллллллллллллллл
org 100h                ; com file entry point
mov al,13h              ; enter graphics mode
int 10h                 ; video interrupt
mov bh,0A0h             ; graphics buffer offset (bx = 0A000h)
mov es,bx               ; point segment to graphics buffer
draw:                   ; entry point for drawing loop
    ror  bx,01          ; change the colour a little
    mov  ah,bl          ; update al with new colour
    mov  cl,160         ; fill one line (with words)
    rep  stosw          ; draw one scanline
    mov  ah,01h         ; key check without waiting
    int  16h            ; bios call
    jz   draw           ; either do it all over again
    ret                 ; or get out of here