.MODEL Large
.386                  ; .386 _AFTER_ .MODEL so the code segments aren't 32 bit
.STACK 100h           ; Inc/Decrease this accordingly
.DATA
assume ds:@DATA       ; Err, data goes here... Duh!

.CODE
assume cs:@CODE       ; Err, code goes here... Duh! (Data can also go here)

start:                ; This would be known as the start of the program

     mov ax,0013h
     int 10h

     mov ax,0a000h
     mov es,ax
     xor di,di

     mov al,5
     mov ah,5
     aad 10    ; Multiplies 5 by 10 and adds 5

     mov cx,320*5
     rep stosb

     mov al,55
     mov cx,320*5
     rep stosb

@loope:
          XOR     AX,AX
          MOV     ES,AX
          MOV     AX,ES:[41Ah]            ; Tran's way to kbhit().
          CMP     AX,ES:[41Ch]            ; Sure it's better than INT 16h.
jz @loope

     mov ax,0003h
     int 10h

     mov ah,04Ch
     int 21h          ; Kill it! - End of Program

END start