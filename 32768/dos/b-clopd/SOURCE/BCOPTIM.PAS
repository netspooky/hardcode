{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 16384,0,200000}
USES Crt,Dos;
CONST DataFile='DATAGES.PAS';
      DataOut='DATAFILE.PAS';
      MaxProcs=20;
      MaxZeilen=1000;
TYPE tOrder=ARRAY[1..MaxProcs]OF Word;
     tContent=ARRAY[1..MaxZeilen]OF STRING[50];
VAR ProcName:ARRAY[1..MaxProcs]OF STRING;
    ProcCont:ARRAY[1..MaxProcs]OF ^tContent;
    ProcCAnz:ARRAY[1..MaxProcs]OF LongInt;
    Order:tOrder;
    I,K,M:LongInt;
    GAnz,Anz:LongInt;
    Procs:LongInt;
    Best:LongInt;
    BestOrder:tOrder;

PROCEDURE ReadProcs;
VAR R,T:Text;
    St:STRING;
    M,C:LongInt;
BEGIN
  Assign(T,DataFile);
  ReSet(T);
  WHILE NOT EoF(T) DO BEGIN
    ReadLn(T,ST);
    IF Pos('PROCEDURE',St)<>0 THEN BEGIN
      Delete(St,Length(St)-10+1,10);
      Inc(Procs);
      ProcName[Procs]:=St;
    END;
  END;
  Close(T);

  FOR M:=1 TO Procs DO BEGIN
    Assign(R,DataFile);
    ReSet(R);
    REPEAT
      ReadLn(R,St);
    UNTIL Pos(ProcName[M],St)<>0;
    C:=0;
    REPEAT
      ReadLn(R,St);
      Inc(C);
    UNTIL Pos('END',St)<>0;
    ProcCAnz[M]:=C;
    Close(R);
  END;

  FOR M:=1 TO Procs DO BEGIN
    GetMem(ProcCont[M],ProcCAnz[M]*51);
    Assign(R,DataFile);
    ReSet(R);
    REPEAT
      ReadLn(R,St);
    UNTIL Pos(ProcName[M],St)<>0;
    C:=0;
    REPEAT
      Inc(C);
      ReadLn(R,ProcCont[M]^[C]);
    UNTIL Pos('END',ProcCont[M]^[C])<>0;
    Close(R);
  END;
END;

FUNCTION Possible:Boolean;
VAR Test:ARRAY[1..MaxProcs]OF Boolean;
    I:LongInt;
BEGIN
  Possible:=True;
  FOR I:=1 TO Procs DO Test[I]:=False;
  FOR I:=1 TO Procs DO Test[Order[I]]:=True;
  FOR I:=1 TO Procs DO IF Test[I]=False THEN Possible:=False;
END;

PROCEDURE TestIt(Order:tOrder);
VAR T,R:Text;
    I,K,M:LongInt;
    St:STRING;
    F:FILE;
BEGIN
  Assign(T,DataOut);
  ReWrite(T);
  WriteLn(T,'UNIT DataFile;');
  WriteLn(T,'INTERFACE');
  FOR I:=1 TO Procs DO
    WriteLn(T,ProcName[I]);
  WriteLn(T,'IMPLEMENTATION');
  FOR I:=1 TO Procs DO BEGIN
    M:=Order[I];
    WriteLn(T,ProcName[M]+'ASSEMBLER;');
    FOR K:=1 TO ProcCAnz[M] DO
      WriteLn(T,ProcCont[M]^[K]);
  END;
  WriteLn(T,'BEGIN');
  WriteLn(T,'END.');
  Close(T);
  Exec('tpc.exe',
'-B b-clopd.pas -$A+ -$B- -$D- -$E- -$F+ -$G+ -$I- -$L- -$N- -$O- -$P- -$Q- -$R- -$S- -$T- -$V+ -$X+ -$Y-');
  Exec('upx.exe','b-clopd.exe -9 -q');
  Assign(F,'B-Clopd.Exe');
  ReSet(F,1);
  IF FileSize(F)<Best THEN BEGIN
    Best:=FileSize(F);
    BestOrder:=Order;
  END;
  Close(F);
END;

PROCEDURE TestAll(Order:tOrder;Pos:LongInt);
VAR I,K,M:LongInt;
BEGIN
  Inc(Anz);
{  IF Anz MOD 10 = 0 THEN BEGIn}
    GotoXY(1,1);
    ClrEol;
    WriteLn(Anz,' / ',GAnz);
    ClrEol;
    WriteLn('Best so far : ',Best);
    ClrEol;
    FOR I:=1 TO Procs DO Write(BestOrder[I],', ');
    WriteLn;
    IF KeyPressed AND (ReadKey=#27) THEN Halt(0);
{  END;}
  TestIt(Order);
{      WriteLn;
      Write('Testing ');
      FOR I:=1 TO Procs DO Write(Order[I],', ');
      WriteLn;}
  IF Pos<Procs THEN
  FOR I:=Pos+1 TO Procs DO BEGIN
    M:=Order[Pos];
    Order[Pos]:=Order[I];
    Order[I]:=M;
    TestAll(Order,Pos+1);
    M:=Order[Pos];
    Order[Pos]:=Order[I];
    Order[I]:=M;
  END;
END;

BEGIN
  Procs:=0;
  ReadProcs;
  FOR I:=1 TO Procs DO Order[I]:=I;
  Anz:=0;
  Ganz:=1;
  FOR I:=2 TO Procs DO GAnz:=Ganz*I;
  ClrScr;
  Best:=100000;
  TestAll(Order,1);

END.