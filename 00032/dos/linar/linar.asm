;   linar - 32b intro - 2006 by Quasimodo
;        - compile with nasm -
;       i am new and know nobody,
; so i greet all demosceners around the world!!!
;        mail me: qua-mod@web.de 

         mov al,13h
         int 10h
         push 0a000h
         pop ds
SCREEN:  mov bx,63999
PIXEL:   mov al,bh
         imul bl
         sub ah,[fs:046ch]
         ;and ah,00111100b ;use this line to choose your favourite
                           ;colors and get the intro >32b  ;]
         mov [bx],ah
         dec bx
         jnz PIXEL

         in al,60h  
         dec al     
         jnz SCREEN 
         ret        

         