unit Backgnd;
interface
uses
   Common;

procedure DrawBackground;

implementation

{$L back}
procedure _Back; external;

procedure DrawBackground;
assembler;
asm
   push ds
   les  di,BufferPtr
   push cs
   pop  ds
   mov  si,offset _Back
   cld

   mov  dx,320
@@NextY:
   mov  ax,10
@@NextSprX:
   push si
   mov  cx,32/4
   rep
   db   66h
   movsw
   pop  si
   dec  ax
   jnz  @@NextSprX

   add  si,32
   cmp  si,offset _Back+32*20
   jb   @@SameSprY
   mov  si,offset _Back
@@SameSprY:

   dec  dx
   jnz  @@NextY

   pop  ds
end;

end.
