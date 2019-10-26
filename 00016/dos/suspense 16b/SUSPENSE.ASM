;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Suspense 16B
;; Whizart, September 2013
;; Compile with: nasm -o suspense.com suspense.asm
;; Tested under DOSBox 0.74, running Windows 7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org  100h

les  bx, [bx]
mov  al, 13h
int  10h

endless:
   dec  bx

   screen:
      in ax, 41h
      adc ax, bx
      stosw
      loop screen
   
   jmp endless
    
