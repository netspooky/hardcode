;I'll only comment the lines that are not already commented in swat.asm. :)
;I tried to do this in one sourcefile with %define and %ifdef and such, but
;then I realised it would be unnecessarily difficult to comment. Oh, well.

        mov al,13h
        int 10h

        les bp,[bx]


DRAW    stosb
        adc ax,di

        jnz NEXT            ;I'll perform a check for keypress every time ax
                            ;equals zero (if I did it all the time everything
                            ; would be too slow, even for Assembly. :P ), and
                            ;I'll skip the check otherwise

        push ax             ;I don't want to mess with al, so I'll store ax.

        in al,60h           ;Read from port 60h (keyboard) and store in al
                            ; (the BIOS scan code, NOT THE ASCII CODE)

        dec al              ;It's important to distinguish between the BIOS
                            ;scan code and the ASCII code. I only care about
                            ;the ESC key, which is 1bh in ASCII but 1h in
                            ;BIOS scan. That means I can detect it by
                            ;decreasing al and then checking for a zero...

        jz QUIT             ;... Which I do now. Quit if ESC was pressed.

        pop ax              ;Retrieve ax.

NEXT    xchg ax,di
        jmp short DRAW

QUIT    pop ax              ;I missed the last one when I jumped.
        mov al,03h          ;Take me back to text mode.
        int 10h             ;Video interrupt request.
        mov ah,4ch          ;Terminate with return code.
        int 21h             ;DOS interrupt request.