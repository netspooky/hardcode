;---------------------------------------------------------------------
; FADE - Clear screen by fading out, 78 bytes! - Tylisha C. Andersen
;---------------------------------------------------------------------

.model  tiny
.code
.186
org     100h

;---------------------------------------------------------------------

main:   mov     bp,300h         ; bp = 300h (number of bytes, buffer offset)

        call    vret            ; wait for vertical retrace
        mov     di,bp           ; di = buffer
        mov     dl,0C7h         ; dx = DAC read select port
        xor     al,al           ; select DAC register 0
        out     dx,al
        mov     dl,0C9h         ; dx = DAC data port
        mov     cx,bp           ; read 768 bytes from the DAC data port into
        rep     insb            ; the buffer (read the original palette)

        mov     bx,63           ; 63 iterations always clear all colors
m_1:    mov     si,bp           ; si, di = buffer
        mov     di,bp
        mov     cx,bp           ; for each of 768 data bytes:

m_2:    lodsb                   ; load byte
        cmp     al,1            ; if it's greater than zero, reduce it by 1
        adc     al,-1
        stosb                   ; store byte
        loop    m_2             ; loop

        mov     cl,4            ; wait for vertical retrace 4 times
m_3:    call    vret            ; for a delay of about 0.06 seconds
        loop    m_3
        mov     si,bp           ; si = buffer
        mov     dl,0C8h         ; dx = DAC write select port
        xor     al,al           ; select DAC register 0
        out     dx,al
        inc     dx              ; dx = DAC data port
        mov     cx,bp           ; send 768 bytes from the buffer to the DAC
        rep     outsb           ; data port (set the current palette)

        dec     bx              ; loop
        jnz     m_1

        mov     ax,3            ; set video mode 3 (clears the screen)
        int     10h
        ret                     ; return

;---------------------------------------------------------------------

vret:   mov     dx,03DAh        ; dx = IS1 port, waiting for retrace
v_1:    in      al,dx           ; wait for bit 3 to go off (active period)
        test    al,8
        jnz     v_1
v_2:    in      al,dx           ; wait for bit 3 to come on (retrace period)
        test    al,8
        jz      v_2
        ret                     ; return

end     main
