;---------------------------------------------------------------------
; COPPER3 - 3 simultaneous copper bars, 79 bytes! - final version by
; Tylisha C. Andersen - notable contributions by T.Remmel and J.Neil
;---------------------------------------------------------------------

b       equ     <byte ptr>
w       equ     <word ptr>

.model  tiny
.code
org     100h

;---------------------------------------------------------------------

main:   pop     bx              ; zero bx by popping the return address
                                ;
m_1:    push    bx              ; write 3 positions and increments
        inc     bx              ; the jpo instruction jumps when there are
        push    bx              ; an odd number of set bits in the lower 8
        jpo     m_1             ; bits of the result;  this is true for
                                ; 1 (01b) and 2 (10b), but false for 3 (11b)

m_2:    cli                     ; disable interrupts
        mov     ah,8            ; ah = 8 for vertical retrace
        mov     cx,390          ; for each of 390 scanlines:
                                ;
m_3:    mov     dx,03DAh        ; dx = IS1 port, wait for retrace
m_4:    in      al,dx           ; retrace could be vertical or horizontal
        and     al,ah           ; due to the design of the VGA this ends in
        jnz     m_4             ; the horizontal retrace if ah = 01h, but in
m_5:    in      al,dx           ; the active vertical period if ah = 08h,
        and     al,ah           ; which is exactly what we need
        jz      m_5
        mov     dl,0C8h         ; dx = DAC write select port
        xchg    ax,bx           ; al = 0, select DAC register 0
        out     dx,al
        inc     dx

        mov     si,sp           ; si = ptr. to position data list
        mov     bl,3            ; for each of 3 colors:

m_6:    lodsw                   ; ax = increment - tricky use of loop,
        loop    m_7             ; jumps when cx <> 1 to test for last line
                                ; if on last scanline, then
        sub     [si],ax         ; add increment to position, if this puts it
        cmp     w [si],-263     ; out of range, then bounce
        ja      m_7             ; 263 is the max. position of the top of a
        neg     w [si-2]        ; bar without it going off the screen

m_7:    inc     cx              ; restore cx (it was decremented by 'loop')
        lodsw                   ; ax = position, si now = next color
        add     ax,cx           ; ax = line + position
        cmp     ax,127          ; if it's not inside the bar, then set the
        jbe     m_8             ; color to 0 (xor al,al);  otherwise...
        xor     al,al
m_8:    cmp     al,64           ; if it's greater than 64, this means it's
        jb      m_9             ; on the top part where it is fading out, so
        not     al              ; we negate it (the top 2 bits are ignored)

m_9:    out     dx,al           ; set color intensity, and loop (remember,
        dec     bx              ; parity is only on the lower 8 bits, so it
        jpo     m_6             ; doesn't matter what bh contains)

        mov     ah,1            ; ah = 01h for horiz. retrace, key check
        loop    m_3             ; loop
        int     16h             ; check for key press (enables interrupts)
        jz      m_2             ; loop while no key pressed
        int     20h             ; return to DOS

end     main
