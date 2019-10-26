;SWAT final version, quit-with-ESC variant. :)
;Optimizations based on code courtesy of Pirx.
;Doesn't return to text mode (run from win32).

         mov al,13h
         int 10h
         les bp,[bx]
DRAW     stosb
         xchg ax,di       ;xchg before adc: clever move to use jnz with adc.
         adc ax,di
         jnz DRAW         ;Perform a check for keypress only if ax is zero.
         in al,60h        ;Read value from port 60h (keyboard) into al.
         dec ax           ;See if al was one (BIOS scan code for ESC key).
         jnz DRAW         ;If it wasn't, keep going.
         ret              ;If it was, die.