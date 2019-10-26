{$G+,R-,S-,Q-}
{$M 4096,262144,655360}
uses
   General,
   Common,
   Morphing,
   Windows, TxtWin,
   Startup, MousePtr,
   Smooth, Edge, Gray, Copy,
   Credits, Greetz;

var
   WinS, WinE,
   WinC, WinG,
   WinF            :TWindow;
   WinTC, WinTG    :TTextWindow;

begin
   InitIntro;
   Timer:=75;

   ShowMouse;
   repeat
      if Timer<300 then
      begin
         if Timer>100 then WinF.Init(40, 15, 240, 175, 'Full Size', Mouse, CopyArea);
         if Timer>140 then WinC.Init(20, 67, 90, 70, 'Simple Morphing', MouseS, CopyArea);
         if Timer>180 then WinE.Init(80, 110, 90, 70, 'Edge Detection', MouseS, EdgeArea);
         if Timer>220 then WinS.Init(205, 105, 90, 70, 'Smoothing', MouseS, SmoothArea);
         if Timer>260 then WinG.Init(200, 25, 90, 70, 'Grayscale', MouseS, GrayArea);
      end;

      if Timer>400 then WinC.Done;
      if Timer>440 then WinE.Done;
      if Timer>480 then WinS.Done;
      if Timer>520 then WinG.Done;

      if Timer>880 then WinTG.Done else
      if Timer>560 then WinTG.Init(166, 77, 150, 120, 'Greetz', GreetzList);

      if Timer>1220 then WinTC.Done else
      if Timer>920 then WinTC.Init(4, 3, 180, 80, 'Credits', CreditsList);

      if Timer>1300 then WinF.Done;

      if Timer>1340 then Break;

      DrawWindows;

      MorphStep(Mouse);

      UpdateScreen;

      if MouseStopped then
      if WinTG.Initialized and (WinTG.TextPos<=WinTG.TextCount) then
      begin
         MouseDest.X:=WinTG.X+Random(WinTG.W -8);
         MouseDest.Y:=WinTG.Y+20+WinTG.TextPos shl 3;
      end else
      if WinTC.Initialized and (WinTC.TextPos>=3) and (WinTC.TextPos<=6) then
      begin
         MouseDest.X:=WinTC.X+Random(WinTC.W);
         MouseDest.Y:=WinTC.Y+20+4*8;
      end else
      begin
         MouseDest.X:=8+Random(300); MouseDest.Y:=4+Random(180);
         MouseRnd:=True;
      end;

      while Timer=LTimer do;
      LTimer:=Timer;
   until Stop;

   DoneIntro;
end.
