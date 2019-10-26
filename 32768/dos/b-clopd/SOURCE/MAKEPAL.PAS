USES Crt,Dos,ModiGraf,PCXVModi;
VAR Buf:^tScreen;
    Pal:PAL_ARRAY;
    I,K,M:LongInt;
    F:FILE;
BEGIN
  New(Buf);
  LoadPCX(Buf^,Pal,'DATA\0492.PCX',0);
  Assign(F,'DATA\Palette.Dat');
  ReWrite(F,1);
  BlockWrite(F,Pal,768);
  Close(F);
END.