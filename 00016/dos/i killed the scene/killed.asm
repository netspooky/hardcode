; I killed the scene by Traction
;
; Dedicated to Emmanuel Poirier

.model tiny
.data
.code
org 100h

START:
        mov al, 13h ; can I assume AH is zero?
        int 10h

        @wait:
                mov ah, 01
                int 16h
                jz @wait
        mov ax, 3h
        int 10h

        ret


END START
