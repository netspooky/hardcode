;; Crap Scroll by Whizart / 06 September 2013
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lds   dx, [bx] 
mov   al, 13h
int   10h

mov   ah, 9
int   21h

scroll:
   xchg  al, [si]
   dec   si
   jmp   scroll

