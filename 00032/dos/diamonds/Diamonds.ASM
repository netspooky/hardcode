org 100h	 ; com file

init:les si,[bx] ; load the value 0A000h into es
     mov al,13h  ; enter graphics mode
     int 10h	 ; mode 13h (320x200, 256 colours)

main:mov ax,di	 ; get a sequencial value
     add al,ch	 ; add the high portion of cx which is counting down
     sub al,bh	 ; take away bh this changes colours nicely
     xor al,cl	 ; take the difference between low portion of count down
     xor al,bl	 ; and the low portion of slow count up (nicer colours)
     stosb	 ; store that to screen
     loop main	 ; count down iteratians
     inc  bx	 ; slower count up

exit:in al,60h	 ; keyboard check
     dec al	 ; check for esc key
     jnz main	 ; only escape key will allow execution to fall through
     mov al,03h  ; enter textmode
     int 10h	 ; mode 03h (80x25, 16 colours)
     ret	 ; exit cleanly in text mode