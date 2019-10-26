;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
IDEAL
MODEL TINY
DATASEG
Shitty  db      "Shitty by Muad'Dib",0dh,0ah,"$"        ; string
Filler  db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;stuff to make
        db      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0           ; 128 bytes
CODESEG
org 100h

Main:
        push    cs                      ; put the code segment on ds
        pop     ds
        push 0a000h                     ; vga section
        pop es                          ; on to es
        mov     ax,0013h                ; 320x200x256 mode
        int     10h                     ; interrupt
        mov dl,01011011b                ; random bits for color
looper:
        inc dl                          ; inc color bits
        mov cx,0FA01h                   ; number of pixels to plot - 1
                                        ; this is so it gets the last pixel
                                        ; as well
looper2:
        mov ax,01000h                   ; pause for 1 clock tick (1 MS)
        int 15h                         ; 
        mov bx,cx                       ; move position to BX so we can access
                                        ; es
        mov es:[bx-1],dl                ; change color
        dec cx                          ; change position
        rol dl,1                        ; rotate color bits
jnz looper2                             ; jump if cx != 0

        mov     ah,1                    ; wait for key
        int     16h
        jz looper                       ; if no key continue
        mov     ax,0003h                ; go back to text mode
        int     10h                     ; interrupt
        mov ah,9                        ; print text
        mov dx,offset Shitty            ; move offset of string here
        int 21h                         ; interrupt
        mov     ax,4C00h                ; to DOS
        int     21h                     ; interrupt

End Main
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
