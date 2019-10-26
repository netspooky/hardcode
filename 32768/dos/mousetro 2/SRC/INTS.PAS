unit Ints;
{$G+,R-,S-,I-,Q-}
interface
uses
   DOS,
   MousePtr;

procedure InitInts;
procedure DoneInts;

implementation
uses
   Common;

procedure Int8;
assembler;
asm
   push	ds
   push	40h
   pop	ds
   push	si
   push	di
   mov	si,6Ch
   mov	di,6Eh
   inc	word ptr [si]
   jnz	@@1
   inc	word ptr [di]
@@1:
   cmp	word ptr [di],18h
   jne	@@2
   cmp	word ptr [si],0B0h
   jne	@@2
   mov	word ptr [si],0
   mov	word ptr [di],0
   mov	byte ptr [di+2],1
@@2:
   pop	di
   pop	si
   push ax
   push	dx
   dec	byte ptr [40h]
   jnz	@@3
   mov	dx,3F2h
   mov	al,0Ch
   and	byte ptr [3Fh],0F0h
   out	dx,al
@@3:

   push seg @DATA
   pop  ds
   inc  Timer

   db   66h
   pusha
   push es

   call MoveMouse

   pop  es
   db   66h
   popa

   mov	al,20h
   out	20h,al
   pop	dx
   pop	ax
   pop	ds
   iret
end;

const
   IRET            :Byte =   $CF;

   Count =         3;

   List            :Array [0..Count-1] of
   record
      Number       :Byte;
      New          :^LongInt;
      Check        :LongInt;
   end = (
   (Number:$05; New:@IRET),
   (Number:$08; New:@Int8),
   (Number:$09; New:Ptr($F000, $E987); Check:$50BD4CE9));

var
   Last            :Array [0..Count-1] of Pointer;
   i               :Integer;
   Rate, LastRate  :Word;

procedure InitInts;
begin
   asm
      mov  bx,50
      xor  dx,dx
      cli

@@Try:
      mov  ax,0FFFFh

@@Wait:
      mov  cx,ax
      mov  al,00000110b
      out  43h,al
      in   al,40h
      mov  ah,al
      in   al,40h
      xchg al,ah
      cmp  ax,cx
      jb   @@Wait

      cmp  ax,dx
      jb   @@Bad
      mov  dx,ax
@@Bad:

      cmp  ax,1193
      ja   @@Done

      dec  bx
      jnz  @@Try

@@Done:
      sti

      cmp  dh,0FFh
      jb   @@Fast
      xor  dx,dx
@@Fast:

      mov  Rate,dx

      cli
      mov  al,00110110b
      out  43h,al
      xor  ax,ax
      out  40h,al
      out  40h,al
      sti
   end;

   for i:=Low(List) to High(List) do
   with List[i] do
   begin
      GetIntVec(Number, Last[i]);
      if (Check=0) or (New^=Check) then
         SetIntVec(Number, New);
   end;
end;

procedure DoneInts;
begin
   for i:=Low(List) to High(List) do
   SetIntVec(List[i].Number, Last[i]);

   asm
      cli
      mov  al,00110110b
      out  43h,al
      mov  ax,Rate
      out  40h,al
      mov  al,ah
      out  40h,al
      sti
   end;
end;

end.
