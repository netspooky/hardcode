;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Crapulousness 16B
;; Whizart, September 2013
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org  100h

mov dx,0x331          ; set MPU to UART mode
mov al,0x3f
out dx, al
dec dx

playanote: 
    in al, 40h        ; read some crap
    out dx, al        ; play some crap
    out dx, al
    out dx, al

    L:  loop L        ; wait for a while...
    jmp playanote     ; a loop is a loop is a ...
