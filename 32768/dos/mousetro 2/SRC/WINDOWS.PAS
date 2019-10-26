unit Windows;
interface
uses
   Objects,
   Common, General,
   GRect, GraphFns,
   MousePtr,
   Copy;

procedure DrawFrame (x, y, w, h        :Integer;
                     const Title       :String);

procedure DrawWindow(x, y, w, h        :Integer;
                     const Title       :String);

procedure DrawWindows;

type
   TVideoOp =      procedure(x, y, w, h :Integer; S, T :Word);

   PWindow =       ^TWindow;
   TWindow =
   object(TObject)
      Next, Prev   :PWindow;
      Initialized  :Boolean;

      x, y, w, h   :Integer;
      Title        :^String;
      Image        :PGPoint;
      Op           :TVideoOp;

      constructor Init(Ax, Ay, Aw, Ah  :Integer;
                       const ATitle    :String;
                       AnImage         :PGPoint;
                       AnOp            :TVideoOp);

      destructor Done; virtual;

      procedure Draw; virtual;
   end;

const
   WindowsList     :PWindow= nil;

const
   cLight =        231;
   cShadow =       244;
   cBorder =       227;
   cBack =         111;
   cClose =        25;
   cCloseFrameL =  28;
   cCloseFrameS =  24;
   cCloseDash =    0;
   cTitleBack =    233;
   cTitle =        0;

   fWidth =        3;

implementation
uses
   Morphing;

procedure DrawButton(x, y, w, h, c1, c2:Integer);
begin
   Rectangle(x, y, w, h, c1);
   Bar(x+1, y+h, w, 1, c2);
   Bar(x+w, y+1, 1, h, c2);
end;

procedure DrawFrame;
begin
   DrawButton(x, y, w, h, cLight, cShadow);
   Rectangle(x+1, y+1, w-2, h-2, cBorder);
   DrawButton(x+(fWidth-1), y+(fWidth-1), w-2*(fWidth-1), h-2*(fWidth-1), cShadow, cLight);
   if Title<>'' then
   begin
      Bar(x+fWidth, y+fWidth, w-(2*fWidth-1), 6+1, cTitleBack);
      Bar(x+fWidth, y+(fWidth+6+1), w-(2*fWidth-1), 1, cShadow);

      Bar(x+fWidth, y+fWidth, 8, 7, cClose);
      Rectangle(x+fWidth, y+fWidth, 7, 6, cCloseFrameL);
      Bar(x+(fWidth+1), y+(fWidth+6), 6, 1, cCloseFrameS);
      Bar(x+(fWidth+7), y+(fWidth+1), 1, 6, cCloseFrameS);
      Bar(x+(fWidth+2), y+(fWidth+3), 4, 1, cCloseDash);

      OutTextC(x+3+w shr 1, y+(fWidth+3+1), cTitle, Title);
   end;
end;

procedure DrawWindow;
begin
   Bar(x, y, w, h, cBack);
   DrawFrame(x, y, w-1, h-1, Title);
end;

procedure DrawWindows;
var
   Current, Last   :PWindow;
begin
   Current:=WindowsList; Last:=nil;
   while Current<>nil do
   begin
      Last:=Current;
      Current:=Current^.Next;
   end;
   Current:=Last;
   while Current<>nil do
   begin
      Current^.Draw; Current:=Current^.Prev;
   end;
end;

{ TWindow }

constructor TWindow.Init;
begin
   if Initialized then Exit;

   x:=Ax; y:=Ay; w:=Aw; h:=Ah;
   Title:=@ATitle;
   Draw;
   Image:=AnImage;
   Op:=AnOp;

   Next:=WindowsList;
   if WindowsList<>nil then WindowsList^.Prev:=@Self;
   WindowsList:=@Self;

   Initialized:=True;
end;

destructor TWindow.Done;
var
   CloseRect       :TGRect;
begin
   if not Initialized then Exit;

   CloseRect.A.X:=x+fWidth; CloseRect.A.Y:=y+fWidth;
   CloseRect.B.X:=x+(fWidth+7); CloseRect.B.Y:=y+(fWidth+7);

   if not CloseRect.Contains(MousePos) then
   begin
      if MouseRnd then CloseRect.GetCenter(MouseDest);
      MouseRnd:=False;
      Exit;
   end;

   if WindowsList=@Self then
   begin
      WindowsList:=Next;
      if WindowsList<>nil then WindowsList^.Prev:=nil;
   end else
   begin
      Prev^.Next:=Next;
      if Next<>nil then Next^.Prev:=Prev;
   end;
   CopyArea(x, y, w, h, PtrRec(BackPtr).Seg, PtrRec(FinalBuffer).Seg);

   Initialized:=False;
end;

procedure TWindow.Draw;
var
   SaveBuffer      :Pointer;
begin
   SaveBuffer:=BufferPtr; BufferPtr:=FinalBuffer;
   DrawWindow(x, y, w, h, Title^);
   BufferPtr:=SaveBuffer;

   DrawWindow(x, y, w, h, Title^);
   if Image<>nil then
   begin
      Morph(x+w shr 1, y+h shr 1 +4, Image, PtrRec(BufferPtr).Seg);
      Op(x+(fWidth+1), y+(fWidth+1+8), w-2*(fWidth+1), h-(2*(fWidth+1)+8), PtrRec(BufferPtr).Seg, PtrRec(FinalBuffer).Seg);
   end;
end;

end.
