' setup screen size

Dim Shared As Integer sw, sh
ScreenInfo sw, sh
' if supplied, use command line arguments
If(CInt(Command(1)) And CInt(Command(2))) Then
	sw = CInt(Command(1))
	sh = CInt(Command(2))
EndIf
ScreenRes sw, sh, 32, 2, IIf(Lcase(Command(3)) = "w", 0, 1)
SetMouse ,,0
