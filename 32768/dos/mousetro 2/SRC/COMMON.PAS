unit Common;
interface

type
   TVideoMem =     Array [0..199, 0..319] of Byte;

var
   VM              :TVideoMem absolute $A000:0;

var
   BackPtr,
   BufferPtr,
   FinalBuffer     :^TVideoMem;

const
   Timer           :Word =   0;
var
   LTimer          :Word;

procedure UpdateScreen;

implementation
uses
   General, MousePtr;

procedure UpdateScreen;
const
   BlkCnt =        8;
var
   Blk, Y          :Integer;
begin
   Y:=0;
   for Blk:=0 to BlkCnt-1 do
   begin
      Inc(MouseLock);
      DoShowMouse(FinalBuffer, @MouseBack);
      Move(FinalBuffer^[Y], VM[Y], 320*200 div BlkCnt);
      DoHideMouse(FinalBuffer, @MouseBack);
      Dec(MouseLock);
      if MouseMoveCnt>0 then
      begin
         Dec(MouseMoveCnt);
         MoveMouse;
      end;
      Inc(Y, 200 div BlkCnt);
   end;
end;

end.
