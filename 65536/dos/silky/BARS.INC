Procedure DeltaPal; assembler;
asm
   push ds
   push si
   push cx

   call waitretrace;

   lea si,t
   mov  cx,768
   mov dx,3c8h
   mov al,0
   out dx,al
   inc dx
   rep outsb
   pop  cx
   pop  si
   pop  ds
end;



Procedure Drawit;
Var
   Loop2,Loop : Integer;
   F : File;

Begin
   For Loop2 := 1 to 89 do
      For Loop := 0 to 319 do
         PutPixel(Loop,Loop2,Loop2+150);
   Value := 1;
   Value2 := 1;
   Value3 := 1;
   Count := 0;
   Count2 := 10;
   Count3 := 20;

   
End;

Procedure RotPal2;
Var
    Loop,loop2 : Byte;
    Tmp : Array[1..16] of RGBt;
Begin
   For Loop := 1 to 16 do
   Tmp[Loop] := T[112+Loop];
   move(T[1],T[17],336);
   For Loop := 1 to 16 do
   T[Loop] := Tmp[17-Loop];
End;


Procedure RotPal3;
Var
    Loop,loop2 : Byte;
    Tmp : Array[1..16] of RGBt;
begin
   For Loop := 1 to 16 do
   Tmp[Loop] := T[Loop];
   move(T[17],T[1],336);
   For Loop := 1 to 16 do
   T[112+Loop] := Tmp[17-Loop];
end;

Procedure RotPal0;
Var
    Tmp : Rgbt;
Begin
   tmp := t[16];
   move(t[1],t[2],15*3);
   t[1] := tmp;

   tmp := t[32];
   move(t[17],t[18],15*3);
   t[17] := tmp;

   tmp := t[48];
   move(t[33],t[34],15*3);
   t[33] := tmp;

   tmp := t[64];
   move(t[49],t[50],15*3);
   t[49] := tmp;

   tmp := t[80];
   move(t[65],t[66],15*3);
   t[65] := tmp;

   tmp := t[96];
   move(t[81],t[82],15*3);
   t[81] := tmp;

   tmp := t[112];
   move(t[97],t[98],15*3);
   t[97] := tmp;

   tmp := t[128];
   move(t[113],t[114],15*3);
   t[113] := tmp;
End;

Procedure RotPal1;
Var
    Tmp : Rgbt;
Begin
   tmp := t[1];
   move(t[2],t[1],15*3);
   t[16] := tmp;

   tmp := t[17];
   move(t[18],t[17],15*3);
   t[32] := tmp;

   tmp := t[33];
   move(t[34],t[33],15*3);
   t[48] := tmp;

   tmp := t[49];
   move(t[50],t[49],15*3);
   t[64] := tmp;

   tmp := t[65];
   move(t[66],t[65],15*3);
   t[80] := tmp;

   tmp := t[81];
   move(t[82],t[81],15*3);
   t[96] := tmp;

   tmp := t[97];
   move(t[98],t[97],15*3);
   t[112] := tmp;

   tmp := t[113];
   move(t[114],t[113],15*3);
   t[128] := tmp;
end;


Procedure rotpal;
begin
   inc(GlobCount);
   case globcount of
         1..200 : rotpal0;
      201..320 : rotpal2;
      321..520 : rotpal1;
      521..640 : rotpal3;
   end;
   If GlobCount = 640 then GlobCount := 0;
end;



Procedure PlayPal;
Var
    Loop : Integer;
Begin

      For Loop := 1 to 5 do
      Begin
         T[150+Loop+count].r := PalCol[Loop];
         T[150+Loop+count].g := 0;
         T[150+Loop+count].b := 0;
      End;
      For Loop := 1 to 5 do
      Begin
         T[150+Loop+Count+5].r := PalCol[6-Loop];
         T[150+Loop+Count+5].g := 0;
         T[150+Loop+Count+5].b := 0;
      End;

      For Loop := 1 to 5 do
      Begin
         T[150+Loop+Count2].r := 0;
         T[150+Loop+Count2].g := 0;
         T[150+Loop+Count2].b := PalCol[Loop];
      End;
      For Loop := 1 to 5 do
      Begin
         T[150+Loop+Count2+5].r := 0;
         T[150+Loop+Count2+5].g := 0;
         T[150+Loop+Count2+5].b := PalCol[6-Loop];
      End;

      For Loop := 1 to 5 do
      Begin
         T[150+Loop+Count3].r := 0;
         T[150+Loop+Count3].g := PalCol[Loop];
         T[150+Loop+Count3].b := 0;
      End;
      For Loop := 1 to 5 do
      Begin
         T[150+Loop+Count3+5].r := 0;
         T[150+Loop+Count3+5].g := PalCol[6-Loop];
         T[150+Loop+Count3+5].b := 0;
      End;


      If Count > 75 then Value := -1;
      If Count < 1 then Value := 1;
      If Count2 > 75 then Value2 := -1;
      If Count2 < 1 then Value2 := 1;
      If Count3 > 75 then Value3 := -1;
      If Count3 < 1 then Value3 := 1;

      Inc(Count,Value);
      Inc(Count2,Value2);
      Inc(Count3,Value3);

End;

{
   PalCol : Array[1..5] of Byte =
      (0,30,40,50,60);
}


Procedure StartPal;
Var
   Loop : Integer;
   ifeellikeit : Boolean;
   count : WOrd;
Begin
   gotoscnpos;
   ifeellikeit := false;
   FIllchar(palcol,Sizeof(palcol),0);
   count := 0;
   repeat

      playpal;
      rotpal;
      deltapal;
      inc(Count);

      If Count > 15 then
      Begin
         if palcol[2] < 30 then inc(palcol[2],1) else palcol[2] := 30;
         if palcol[3] < 40 then inc(palcol[3],2) else palcol[3] := 40;
         if palcol[4] < 50 then inc(palcol[4],3) else palcol[4] := 50;
         if palcol[5] < 60 then inc(palcol[5],4) else palcol[5] := 60;
         if palcol[2] = 30 then ifeellikeit := true;

         Count := 0;
      End;


   until ifeellikeit;

End;



