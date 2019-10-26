{ How to get the plasma... "Easy".                                     }
{                                                                      }
{ To find the main draw :                                              }
{   Sqrt((CntX)*(CntX)+(CntY)*(CntY))                                  }
{     This makes a big circle.. but try to add a CntX Sin or something }
{     like that, and you will get a beatiful plasma. You can try to    }
{     get the best formula if you have enough time.                    }
{  My formula was                                                      }
{   43*(sin(0.0734*û(13+CntXý+CntYý))+(Cos(CntX/70)-4)*2.58));         }
{  Now I can`t remember all I did to speed up.                         }
{                                                                      }
{ To get the palette you must degrade from RGB color to the same color }
{ in the range of the plasma draw.                                     }
{                                                                      }
{ To draw the plasma in the screen you get colours from the original   }
{ in a circle increment, obtaining the movement sensation.             }
{                                                                      }
{ I coded a faster plasma, but it would be too much difficult to       }
{ understand it. Optimize this plasma yourself.                        }
{ In my computer, this plasma has 18 frames/second (486/33&Trident).   }
{ You can get more than 35 frames/second  ð:)                          }
{                                                                      }
{                                       Mitra / Spanish Lords  May 94  }

uses crt,math,memory;


var
 { This is the buffer for the full plasma draw. }
   PBuffer    : Pointer;
   SBuffer    : Word;

   PAux       : Pointer;
   SAux       : Word;

   CntX,CntY  : Word;
   CntBeg     : Word;
   Cnt        : Byte;

   OldMode    : byte;


Procedure SetVMode(What:Byte); assembler;

   asm
      xor   ah,ah
      mov   al,What
      int   10h
   end;

Function GetVMode:Byte; assembler;

   asm
      mov   ah,0Fh
      int   10h
   end;

Procedure SetRGBColor(Col,R,G,B:Byte);

begin
   Port[$3C8]:=Col;
   Port[$3C9]:=R;
   Port[$3C9]:=G;
   Port[$3C9]:=B;
end;


Procedure DrawPlasma(Where:Word); assembler;

var
   CntBeg : Word;

   asm
       mov   CntBeg,0
       mov   ax,Where
       mov   es,ax
       xor   di,di

       mov   CntY,0
      @BucleY:
          mov   CntX,0
         @BucleX:
             mov   si,CntX
             shl   si,1
             shl   si,1
             add   si,OFFSET Squaretable
             mov   ax,[si]
             mov   dx,[si+2]

             mov   si,CntY
             shl   si,1
             shl   si,1
             add   si,OFFSET Squaretable
             add   ax,[si]
             adc   dx,[si+2]

             push  0
             push  380
             push  dx
             push  ax
             call  FSqrt

             shl   ax,1
             shl   ax,1

             push  ax
             call  FSin

             sar   ax,1
             sar   ax,1

             mov   si,CntX
             shl   si,1
             add   si,OFFSET TblSinCos
             add   si,180
             mov   bx,[si]
             sar   bx,1

             add   ax,bx

{ Dividiendo entre 4, obtenemos un efecto extra¤¡simo pero precioso. }
             shr   al,2
{ Si hacemos un AND, obtenemos el plasma original. }
{               and   al,3Fh}
             mov   di,CntBeg
             add   di,CntX
             mov   es:[di],al
             inc   di

          inc   CntX
          cmp   CntX,320
          jne   @BucleX

       add   CntBeg,320
       inc   CntY
       cmp   CntY,200
       jne   @BucleY
   end;


Procedure DoPlasma;

var
  CntX,CntY        : Word;
 { These are the variables used to make the circle movement. }
  circle1          : Word;
  circle2          : Word;
  circle3          : Word;
  circle4          : Word;
  circle5          : Word;
  circle6          : Word;
  circle7          : Word;
  circle8          : Word;

  Add              : Array [1..8] of byte;

{ Word values to add in the showed plasma. These are calculated from circle }
{ values.                                                                   }
  x1               : Word;
  y1               : Word;
  x2               : Word;
  y2               : Word;
  x3               : Word;
  y3               : Word;
  x4               : Word;
  y4               : Word;

  CntStep          : Byte;
  Cnt              : Byte;


begin
   CntStep:=0;
   Circle1:=0; Circle2:=0; Circle3:=0; Circle4:=0;
   Circle5:=0; Circle6:=0; Circle7:=0; Circle8:=0;
   For Cnt:=1 to 8 do Add[Cnt]:=Random(11);
   Repeat
      X1:=(80*FSin(Circle3) div 256)+80; Y1:=(50*FCos(Circle4) div 256)+50;
      X2:=(80*FSin(Circle1) div 256)+80; Y2:=(50*FCos(Circle2) div 256)+50;
      X3:=(80*FSin(Circle5) div 256)+80; Y3:=(50*FCos(Circle6) div 256)+50;
      X4:=(80*FSin(Circle7) div 256)+80; Y4:=(50*FCos(Circle8) div 256)+50;
      X1:=Y1*320+X1; X2:=Y2*320+X2; X3:=Y3*320+X3; X4:=Y4*320+X4;
      Inc(Circle1,8);Inc (Circle2,7);
      Inc(Circle3,6);Inc (Circle4,5);
      Inc(Circle5,4);Inc (Circle6,1);
      Inc(Circle7,2);Inc (Circle8,3);
      If Circle1>360 then Circle1:=Circle1-360;
      If Circle2>360 then Circle2:=Circle2-360;
      If Circle3>360 then Circle3:=Circle3-360;
      If Circle4>360 then Circle4:=Circle4-360;
      If Circle5>360 then Circle5:=Circle5-360;
      If Circle6>360 then Circle6:=Circle6-360;
      If Circle7>360 then Circle7:=Circle7-360;
      If Circle8>360 then Circle8:=Circle8-360;
      If CntStep>10 then
         begin
            For Cnt:=1 to 8 do Add[Cnt]:=Random(11);
            CntStep:=0;
         end;
      asm
         push   ds

         mov    ax,SAux
         mov    es,ax
         xor    di,di

         mov    ax,SBuffer
         mov    ds,ax
         xor    si,si

         mov    CntY,100

       @bucleY:
         mov    CntX,160
       @bucleX:

         mov    si,X1
         mov    ax,[si]
         mov    si,X2
         add    ax,[si]
         mov    si,X3
         add    ax,[si]
         mov    si,X4
         add    ax,[si]

         and    al,3Fh
         mov    ah,al

         mov    es:[di    ],ax
         mov    es:[di+320],ax

         add    di,2
         inc    X1
         inc    X2
         inc    X3
         inc    X4
         dec    CntX
         jnz    @bucleX

         add    di,320

         add    X1,160
         add    X2,160
         add    X3,160
         add    X4,160
         dec    CntY
         jnz    @BucleY

         mov    dx,$3da
       @NoV:
         in     al,dx
         test   al,8
         jnz    @NoV
       @SiV:
         in     al,dx
         test   al,8
         jz     @SiV
       @NoB:
         in     al,dx
         test   al,1
         jnz    @NoB
       @SiB:
         in     al,dx
         test   al,1
         jz     @SiB

         mov    ax,es
         mov    ds,ax
         xor    si,si

         mov    ax,0A000h
         mov    es,ax
         xor    di,di

         mov    cx,16000
db 66h;  rep    movsw     { rep movsd ;) }

         pop    ds
      end;
      Inc(CntStep);
   until KeyPressed;
end;

begin
 { We get the necessary memory for the buffers. }
   PBuffer:=MemAllocSeg(64000);
   SBuffer:=Seg(PBuffer^);
   PAux:=MemAllocSeg(64000);
   SAux:=Seg(PAux^);

   OldMode:=GetVMode;
   SetVMode(19);
 { Draw the plasma in the buffer. }
   DrawPlasma(SBuffer);
  { This is magenta. <rom likes it, but I think it`s really horrible. }
{   for Cnt:=0 to 32 do begin
     setRGBColor(Cnt   ,30+Cnt,0,30+Cnt);
     setRGBColor(64-Cnt,30+Cnt,0,30+Cnt);
   end;}
  { Blue is my favourite color :) }
   for Cnt:=0 to 32 do begin
     setRGBColor(Cnt ,0,0,30+Cnt);
     setRGBColor(64-Cnt,0,0,30+Cnt);
   end;
 { Begin the movement. }
   DoPlasma;
 { Free all mem. }
   FreeMem  (PAux   ,64000);
   FreeMem  (PBuffer,64000);
 { Restore video mode. }
   SetVmode(OldMode);
end.