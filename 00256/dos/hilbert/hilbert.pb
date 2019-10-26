Global level.b=7;;-5
Global x1.w=0,x2.w=0,y1.w=0,y2.w=0

Procedure Hilbert(r1.b,r2.b)
 level=level-1

;  // Cuadrante 1
If (level > 0)
  Hilbert (r2,r1);
EndIf
  x2 =x2+r1
  y2 =y2+r2;     // Nos desplazamos hacia la derecha (r1>0, r2=0)
  LineXY(x1,y1,x2,y2,RGB(255,0,0));DIBClipLine (x1, y1, x2, y2, 0x0000FF, pMainDIB);  // Azul
  x1 = x2
  y1 = y2;

;// Cuadrante 2
If (level > 0)
  Hilbert (r1,r2);
EndIf
  x2 =x2+ r2
  y2 =y2+ r1;     // Nos desplazamos hacia abajo (r1>0, r2=0)
  LineXY(x1,y1,x2,y2,RGB(255,0,0));DIBClipLine (x1, y1, x2, y2, 0x00FF00, pMainDIB);  // Verde
  x1 = x2
  y1 = y2;

;  // Cuadrante 3
If (level > 0)
  Hilbert (r1,r2);
EndIf
  x2 =x2- r1
  y2 =y2- r2;     // Nos desplazamos hacia la izquierda (r1>0, r2=0)
  LineXY(x1,y1,x2,y2,RGB(255,0,0));DIBClipLine (x1, y1, x2, y2, 0xFF0000, pMainDIB);  // Rojo
  x1 = x2
  y1 = y2;
  
;  // Cuadrante 4
If (level > 0)
  Hilbert (-r2,-r1); // Si no nos están depurando
EndIf
  level=level+1
EndProcedure

If InitSprite() And OpenWindow(0,0,0,640,480,"Hilbert Curve",#PB_Window_SystemMenu) And OpenWindowedScreen(WindowID(0),0,0,640,480,0,0,0) 
    ;    Sleep_(1) 
    StartDrawing(ScreenOutput())
    hilbert(5,0);;Hilbert(r1.i,r2.i)
    StopDrawing()
      FlipBuffers() 
Repeat:  Until WindowEvent()=#PB_Event_CloseWindow 
EndIf

; IDE Options = PureBasic 4.60 (Windows - x86)
; CursorPosition = 37
; Folding = -