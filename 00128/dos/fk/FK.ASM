.MODEL tiny
.386
locals
jumps
codeseg
startupcode
start:                ; This would be known as the start of the program

     mov ax,13h
     int 10h          ; Init GFX mode (320x200x256) (Like Duh!)

     mov dx,03c8h
     mov al,1
     out dx,al
     mov ah,1
     inc dx
     mov cx,32
@palloop:
     xor al,al
     out dx,al
     out dx,al
     mov al,ah
     out dx,al
     add ah,2
     dec cx
     jnz @palloop     ; Set up palette

     dec dx
     mov al,255-63
     out dx,al
     inc dx
     mov cx,63
@palloop2:
     xor al,al
     out dx,al
     mov al,ah
     out dx,al
     out dx,al
     add ah,1
     dec cx
     jnz @palloop2    ; Set up palette 2


     mov bl,128
     push 0a000h
     pop es
     xor di,di

       @vloop:
         mov al,bl
         shr al,2
         mov ah,bl
         and ah,1     ; ah is toggled between 0 and 1 as bl increases
         add ah,al    ; Luverly dithering here
         mov cx,160
         rep stosw
         dec bl
       jnz @vloop     ; This does an absolutely fabulous dithered shade

     mov bx,72
     mov di,126*320
     mov al,255-63
     mov ah,al
@groundloop:
     mov cx,160
     inc ax
     xchg ah,al
     rep stosw
     dec bx
     jnz @groundloop  ; Fill bottom half with dithered "ground"

     ; WOW !!! Two different "dithering" methods are used above :)

     ; Do something here :)

     xor ax,ax
     int 16h          ; Wait for, and read a key

     mov ax,03h
     int 10h          ; Init TXT mode (80x25x16) (Like Duh!)

     mov ah,04Ch
     int 21h          ; Kill it! - End of Program

END start