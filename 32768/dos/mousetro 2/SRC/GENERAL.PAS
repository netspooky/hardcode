unit General;
interface
{$L general}

procedure Move      (var Source, Dest;
                     Count             :Word);

procedure FillChar  (var Buffer;
                     Count             :Word;
                     Value             :Byte);

function  Min(A, B                     :Integer) :Integer;
function  Max(A, B                     :Integer) :Integer;

procedure SwapInts   (var A, B         :Integer);

procedure ArrangeInts(var A, B         :Integer);
{ Make A<=B }

implementation

procedure Move; external;
procedure FillChar; external;

function  Min;
assembler;
asm
   mov  ax,A
   cmp  ax,B
   jle  @@1
   mov  ax,B
@@1:
end;

function  Max;
assembler;
asm
   mov  ax,A
   cmp  ax,B
   jg   @@1
   mov  ax,B
@@1:
end;

procedure SwapInts;
assembler;
asm
   push ds
   lds  si,A
   les  di,B
   mov  ax,[si]
   mov  dx,es:[di]
   mov  es:[di],ax
   mov  [si],dx
   pop  ds
end;

procedure ArrangeInts;
assembler;
asm
   push ds
   lds  si,A
   les  di,B
   mov  ax,[si]
   mov  dx,es:[di]
   cmp  ax,dx
   jle  @@1
   mov  es:[di],ax
   mov  [si],dx
@@1:
   pop  ds
end;

end.
