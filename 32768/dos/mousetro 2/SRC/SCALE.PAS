{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Bitmap Scaling Routine                          }
{                                                       }
{       Copyright (c) 1995 by Solar Designer            }
{                                                       }
{*******************************************************}

{.$Define Wide}         { Use if image may be more than 255 pixels wide }
{.$Define Transparent}  { Enable transparent images }

unit Scale;
{$G+,R-,S-,I-,Q-,N-,E-}
interface
uses
   Objects, GRect;

const
   VideoSeg        :Word =   $A000;
{$IfDef Transparent}
   NullColor =     255;
{$EndIf}

{$IfDef Transparent}
procedure DrawScaledImage(Image        :PGPoint;
                          var Bounds   :TGRect;
                          CheckNull    :Boolean);
{$Else}
procedure DrawScaledImage(Image        :PGPoint;
                          var Bounds   :TGRect);
{$EndIf}

procedure ScaleImage(Source, Target    :PGPoint;
                     NewSize           :TGPoint);

implementation

var
   ScreenX,
   ImageXK         :Integer;

procedure InitScale(IW, SW             :Integer);
assembler;
asm
   mov  ax,IW

{$IfDef Wide}
   mov  dx,100h
   mul  dx
{$Else}
   cwd
   xchg al,ah
{$EndIf}

   mov  cx,SW
   div  cx

   mov  ScreenX,cx
   mov  ImageXK,ax
end;

{$IfDef Transparent}
procedure ScaleLine(Source, Target     :Pointer;
                    CheckNull          :Boolean);
{$Else}
procedure ScaleLine(Source, Target     :Pointer);
{$EndIf}
assembler;
asm
{$IfDef Transparent}
   push word ptr cs:@@CheckNull
   cmp  CheckNull,0
   jnz  @@LeaveCheckNull
   mov  word ptr cs:@@CheckNull,0C089h
@@LeaveCheckNull:
{$EndIf}

   les  di,Target
   cld

   xor  bx,bx
   mov  cx,ScreenX

   mov  ax,ImageXK

   push ds
   lds  si,Source

   push bp
   mov  bp,ax

   xor  dx,dx

@@InnerLoop:
   mov  ax,dx
   add  dx,bp
   mov  bl,ah
   mov  al,[si+bx]

{$IfDef Wide}
   adc  bh,0
{$EndIf}

{$IfDef Transparent}
   cmp  al,NullColor
@@CheckNull:
   je   @@SkipNull
{$EndIf}

   stosb
   loop @@InnerLoop

{$IfDef Transparent}
   jmp  @@Exit

@@SkipNull:
   inc  di
   loop @@InnerLoop

@@Exit:
{$EndIf}

   pop  bp
   pop  ds

{$IfDef Transparent}
   pop  word ptr cs:@@CheckNull
{$EndIf}
end;

procedure DrawScaledImage;
var
   ScreenY, y, yi  :Integer;
begin
   InitScale(Image^.X, Bounds.SizeX);
   ScreenY:=Bounds.SizeY; yi:=0;
   for y:=Bounds.A.Y to Bounds.B.Y do
   begin
{$IfDef Transparent}
      ScaleLine(
         PChar(Image)+4+Word(Image^.X)*Word(LongDiv(LongMul(yi, Image^.Y), ScreenY)),
         Ptr(VideoSeg, Word(y)*320+Word(Bounds.A.X)), CheckNull);
{$Else}
      ScaleLine(
         PChar(Image)+4+Word(Image^.X)*Word(LongDiv(LongMul(yi, Image^.Y), ScreenY)),
         Ptr(VideoSeg, Word(y)*320+Word(Bounds.A.X)));
{$EndIf}
      Inc(yi);
   end;
end;

procedure ScaleImage;
var
   y               :Integer;
begin
   InitScale(Source^.X, NewSize.X);
   for y:=0 to NewSize.Y-1 do
{$IfDef Transparent}
   ScaleLine(
      PChar(Source)+4+Word(Source^.X)*Word(LongDiv(LongMul(y, Source^.Y), NewSize.Y)),
      PChar(Target)+4+Word(y)*Word(NewSize.X), False);
{$Else}
   ScaleLine(
      PChar(Source)+4+Word(Source^.X)*Word(LongDiv(LongMul(y, Source^.Y), NewSize.Y)),
      PChar(Target)+4+Word(y)*Word(NewSize.X));
{$EndIf}
   Target^:=NewSize;
end;

end.
