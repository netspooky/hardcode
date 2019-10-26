Unit Picture;

Interface

Var
  MyPic, MyPal : Pointer;

Implementation

{$L PIC}
{$L PAL}
Procedure Pic; External;
Procedure Pal; External;

Begin
  MyPic := Ptr (Seg (@Pic^), Ofs (@Pic^));
  MyPal := Ptr (Seg (@Pal^), Ofs (@Pal^));
End.
