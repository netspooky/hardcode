.MODEL TINY
.CODE

STARTUPCODE
    mov  al,13h
    int  10h

PutPixel:
   mov ah,0Ch
   mov al,dl
   int 10h

   inc	dx
   add	cx,dx

   jmp PutPixel

   END
P.S. This intro with out exit.