'Atari 8-bit "Archimedes Spiral" demo - FOUND!
'If InitSprite() And OpenWindow(0,0,0,640,480,"SineWave",#PB_Window_SystemMenu) And OpenWindowedScreen(WindowID(0),0,0,640,480,0,0,0)
'  Repeat
'StartDrawing(ScreenOutput())

SCREEN 13
xf = .03272492438555#
t = 0!
DO
CLS
PRINT "t ="; t
FOR zi = -64 TO 64
  zs = zi * zi * 2.25 * 2.25    '5.0625
  xl = INT(SQR(144 * 144 - zs))

  FOR xi = -xl TO xl    '0-xl
    xt = SQR(xi * xi + zs) * xf
    yy = (SIN(xt) + SIN(xt * 3) * .4) * 56
    x1 = xi + zi + 160
    y1 = 90 - yy + zi * COS(t) + xi * SIN(t) / 2
    PSET (x1, y1), 32 + (64 - zi) / 2   '12     'RGB(255,0,0))
    LINE (x1, y1 + 1)-(x1, 191), 0
  NEXT xi
NEXT zi

DO: k$ = INKEY$: LOOP WHILE k$ = ""
IF k$ = CHR$(27) THEN EXIT DO
IF k$ = CHR$(0) + CHR$(72) THEN t = t + .1
IF k$ = CHR$(0) + CHR$(80) THEN t = t - .1
LOOP
END

'        StopDrawing()
'      FlipBuffers()
'  Repeat:Until WindowEvent()=#PB_Event_CloseWindow
'EndIf
' IDE Options = PureBasic 4.60 (Windows - x86)
' CursorPosition = 11

