unit MousePtr;
interface
uses
   GRect, General, GraphFns,
   Common,
   Copy;

const
   MouseSizeX =    9;
   MouseSizeY =    13;

   MouseStepX =    3;
   MouseStepY =    2;

   MousePos        :TGPoint= (X:8; Y:8);
   MouseDest       :TGPoint= (X:8; Y:8);
   MouseVisible    :Integer= 0;
   MouseLock       :Integer= 0;
   MouseMoveCnt    :Integer= 0;
   MouseRnd        :Boolean= True;

var
   MouseBack       :Array [1..4+MouseSizeX*MouseSizeY] of Byte;

procedure DoShowMouse(Buffer, Save     :Pointer);
procedure DoHideMouse(Buffer, Save     :Pointer);

procedure ShowMouse;
procedure HideMouse;

function  MouseStopped                           :Boolean;
procedure MoveMouse;

implementation

{$L mouseptr}
procedure _MousePtr; external;

procedure DoShowMouse;
var
   SaveBuffer      :Pointer;
begin
   SaveBuffer:=BufferPtr; BufferPtr:=Buffer;
   GetImage(MousePos.X, MousePos.Y, MouseSizeX, MouseSizeY, Save);
   PutBlock(MousePos.X, MousePos.Y, @_MousePtr);
   BufferPtr:=SaveBuffer;
end;

procedure DoHideMouse;
var
   SaveBuffer      :Pointer;
begin
   SaveBuffer:=BufferPtr; BufferPtr:=Buffer;
   PutImage(MousePos.X, MousePos.Y, Save);
   BufferPtr:=SaveBuffer;
end;

procedure ShowMouse;
begin
   if MouseVisible=0 then DoShowMouse(@VM, @MouseBack);
   Inc(MouseVisible);
end;

procedure HideMouse;
begin
   Dec(MouseVisible);
   if MouseVisible=0 then DoHideMouse(@VM, @MouseBack);
end;

function  MouseStopped;
begin
   MouseStopped:=(LongInt(MousePos)=LongInt(MouseDest));
end;

procedure MoveMouse;

function  CalcStep1(Pos, Dest, MaxStep           :Integer) :Integer;
var
   Step            :Integer;
begin
   Step:=Dest-Pos;
   if Step> MaxStep then Step:= MaxStep;
   if Step<-MaxStep then Step:=-MaxStep;
   CalcStep1:=Step;
end;

function  CalcStep2(Pos, Dest, MaxStep,
                    Pos1, Dest1, MaxStep1        :Integer) :Integer;
var
   Step            :Integer;
begin
   if Dest1<>Pos1
   then Step:=CalcStep1(Pos1, Dest1, MaxStep1)*(Dest-Pos) div (Dest1-Pos1)
   else Step:=MaxInt;
   if (Step>MaxStep) or (Step<-MaxStep) then Step:=MaxInt;
   CalcStep2:=Step;
end;

var
   Step1, Step2,
   MoveNum         :Integer;

begin
   if MouseStopped then Exit;
   if MouseLock>0 then
   begin
      Inc(MouseMoveCnt); Exit;
   end;

   HideMouse;
   for MoveNum:=0 to MouseMoveCnt do
   begin
      Step1:=CalcStep2(MousePos.X, MouseDest.X, MouseStepX, MousePos.Y, MouseDest.Y, MouseStepY);
      Step2:=CalcStep2(MousePos.Y, MouseDest.Y, MouseStepY, MousePos.X, MouseDest.X, MouseStepX);

      if (Step1=MaxInt) and (Step2=MaxInt) then
         Step1:=CalcStep1(MousePos.X, MouseDest.X, MouseStepX);

      if Step1<Step2 then
      begin
         Inc(MousePos.X, Step1); Inc(MousePos.Y, CalcStep1(MousePos.Y, MouseDest.Y, MouseStepY));
      end else
      begin
         Inc(MousePos.Y, Step2); Inc(MousePos.X, CalcStep1(MousePos.X, MouseDest.X, MouseStepX));
      end;
   end;
   MouseMoveCnt:=0;
   ShowMouse;
end;

end.
