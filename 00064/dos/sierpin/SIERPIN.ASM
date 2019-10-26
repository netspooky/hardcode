;---------------------------------------------------------------------
; SIERPIN - Sierpinski's Triangle, 56 bytes! - Tylisha C. Andersen
;---------------------------------------------------------------------

.model tiny
.code
.186
org 100h

;---------------------------------------------------------------------

main:   mov     al,12h          ; set video mode 12h
        int     10h
        mov     di,3            ; set di = 3 for divide, video mode

m_1:    imul    bp,9421         ; generate random number
        inc     bp 
        mov     ax,bp           ; dx:ax = random number
        xor     dx,dx
        div     di              ; divide by 3
        dec     dx              ; check result, go to top left if 0,
        jz      m_3             ; top right if 1, and bottom if -1
        jg      m_2

        add     si,480          ; move to bottom part:
        sub     cx,320          ; x = x + 0.5, y = y + 1

m_2:    add     cx,640          ; move to top right part:  x = x + 1

m_3:    shr     cx,1            ; shrink by a factor of 2
        shr     si,1

        mov     ax,0C0Fh        ; put pixel at (x, y) in white
        mov     dx,si           ; using BIOS call - slow, but works
        int     10h
        mov     ah,1            ; check for key press
        int     16h
        jz      m_1             ; loop while no key pressed

        xchg    ax,di           ; restore text mode
        int     10h
        ret                     ; return to DOS

end     main
