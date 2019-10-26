; English forum:
; Author: merendo (updated for PB4.00 by blbltheworm)
; Date: 30. May 2003
; OS: Windows
; Demo: No

If InitSprite() And OpenWindow(0,0,0,256,192,"SineWave",#PB_Window_SystemMenu) And OpenWindowedScreen(WindowID(0),0,0,256,192,0,0,0) 
  Dim s.b(255)
  
  For i=0 To 255
    s(i)=Int(64*Sin(i*3.1415927/128))
  Next i
  
  d.f=0
  Repeat 
    StartDrawing(ScreenOutput())
    Box(0,0,256,192,0)
    For x=0 To 255
      For y=0 To 191
        ;sin(x/(x^2+y^2))>sin(y/(x^2+y^2))
        x1=x-128
        y1=y-96
        tt=x1*x1+y1*y1+1
        If Sin(255*x1/tt+d)>Sin(255*y1/tt+d);x1,y1!
        ;cc=Int(255*Sin(255*x/tt))
          Plot(x,y,RGB (255,0,0))
        EndIf
      Next y
    Next x
    d=d+0.1
    StopDrawing() 
    
      FlipBuffers() 
  Until WindowEvent()=#PB_Event_CloseWindow 
EndIf

; IDE Options = PureBasic 4.60 (Windows - x86)
; CursorPosition = 23