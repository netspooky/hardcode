;Atari 8-bit "Archimedes Spiral" demo - FOUND!
If InitSprite() And OpenWindow(0,0,0,640,480,"SineWave",#PB_Window_SystemMenu) And OpenWindowedScreen(WindowID(0),0,0,640,480,0,0,0) 
;  Repeat 
StartDrawing(ScreenOutput()) 
XF.f=0.03272492438555
For ZI.w=-64 To 64
  ZS.f=zi*zi*5.0625
XL.w=Int(Sqr(20736-ZS))

For XI.w=-XL To XL;0-xl
 XT.f=Sqr(XI*XI+ZS)*XF
 YY.f=(Sin(XT)+Sin(XT*3)*0.4)*56
 X1.w=XI+ZI+160
 Y1.w=90-YY+ZI
 Plot(X1,Y1,RGB(255,0,0))
 LineXY(X1,Y1+1,X1,191,0)
Next XI
Next ZI

        StopDrawing() 
      FlipBuffers() 
  Repeat:Until WindowEvent()=#PB_Event_CloseWindow 
EndIf

; IDE Options = PureBasic 4.60 (Windows - x86)
; CursorPosition = 11