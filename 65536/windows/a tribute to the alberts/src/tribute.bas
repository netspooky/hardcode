/'
 '
 ' a tribute to the alberts
 ' by projekt carnival
 ' made in FreeBASIC
 ' for tUM09
 ' should run on xp/vista/win7.
 '
 ' this is REALLY lame and bad code
 ' but I just couldn't be assed to do it better
 ' have fun.
 '
 '/

#Define UNICODE 'for speech synth
#Define main
#Include Once "disphelper/disphelper.bi"
#Include "ufmod.bi"
#Include "data.bi"
#Include Once "screen.bi"
#Include "starfield.bas"

'http://www.freebasic.net/forum/viewtopic.php?t=10893
Sub speak (ByRef text As String)
	Dim myt As Wstring * 512
	Dim As HRESULT hr

	DISPATCH_OBJ(tts)

	dhInitialize(TRUE)
	dhToggleExceptions(FALSE) 'set this TRUE to get error codes

	myt = "Sapi.SpVoice"
	hr = dhCreateObject(@myt, NULL, @tts)
	If hr <> 0 Then Exit Sub

	myt = text
	dhCallMethod(tts, ".Speak(%S)", @myt)

	SAFE_RELEASE(tts)
End Sub

uFMOD_PlaySong(@song(1), UBound(song)*4, XM_MEMORY)

Locate 1
ScreenSet 1, 0
ScreenLock
Print "Projekt  Carnival"
Print " p r e s e n t s"
For x As Integer = 0 To 135 'hardcoded values ftw
	For y As Integer = 0 To 15
		If(Point(x,y) <> RGB(0,0,0)) Then Line(x / 136 * sw, 20 + y / 16 * (sh - 20)) - ((x + 1) / 136 * sw, 20 + (y + 1) / 16 * (sh - 20)), -1, Bf
	Next
Next
Locate 1
Print "                 "
Print "                "
ScreenUnLock
ScreenSet 0, 0
Do
	Sleep 20
	If(InKey = Chr(27)) Then End
	If(LoWord(uFMOD_GetRowOrder()) >= 16) Then
		ScreenCopy 1, 0
	Else
		Dim As Integer col = (uFMOD_GetRowOrder() * 255 / 16) * Rnd
		Line(0, 0)-(sw - 1, sh - 1), RGB(col, col, col), BF
		ScreenSync
	EndIf
Loop Until LoWord(uFMOD_GetRowOrder()) >= 24
Randomize 0

Dim fadeimg As Any Ptr = ImageCreate(sw, sh)
Get (0, 0)-(sw - 1,sh - 1), fadeimg

'Fadeout
For i As Integer = 255 To 0 Step -1
	ScreenLock
	Cls
	Put(0, 0), fadeimg, Alpha, i
	ScreenUnLock 
	If(InKey = Chr(27)) Then End
	Sleep 20
Next

Cls

Locate 1
ScreenLock
Print "A tribute to"
Print "The Alberts :)"
For x As Integer = 0 To 119 'hardcoded values ftw
	For y As Integer = 0 To 15
		Dim As Integer col = (Point(x, y) And 255) * (y + 10) / 25 * (x + 50) / 249
		Line(x / 120 * sw, 20 + y / 15 * (sh - 20)) - ((x + 1) / 120 * sw, 20 + (y + 1) / 15 * (sh - 20)), RGB(col, col, col), Bf
	Next
Next
Locate 1
'lame code ahead!
Print "            "
Print "               "
ScreenUnLock
speak("A tribute to the Alberts")

'Dim As Integer pattern(1 To ...) = {5}
Dim As Integer pattern(1 To ...) = {1, 1, 0, 1, 3, 2, 4, 4, 2, 5,6}

For i As Integer = 1 To UBound(pattern)
	If(InKey = Chr(27)) Then Exit For
	ScreenLock
	Select Case pattern(i)
		Case 0
			Line(sw * Rnd, sh * Rnd)-(sw * Rnd, sh * Rnd), RGB(256 * Rnd, 256 * Rnd, 256 * Rnd)
			ScreenUnLock
			speak("Line")
		Case 1
			Circle(sw * Rnd, sh * Rnd), sw / 2, RGB(255 * Rnd, 255 * Rnd, 255 * Rnd)
			ScreenUnLock
			speak("Circle")
		Case 2
			For x As Integer = 0 To sw - 1
				For y As Integer = 0 To sh - 1
					PSet(x, y), RGB(x Xor y,0,0)
				Next
			Next
			ScreenUnLock
			speak("X Or Pattern")
		Case 3
			Line(sw * Rnd, sh * Rnd)-(sw * Rnd, sh * Rnd), RGB(256 * Rnd, 256 * Rnd, 256 * Rnd), bf
			ScreenUnLock
			speak("Box Fill")
		Case 4
			Circle(sw * Rnd, sh * Rnd), sw / 2, RGB(255 * Rnd, 255 * Rnd, 255 * Rnd), , , , f
			ScreenUnLock
			speak("Circle Fill")
		Case 5
			ScreenUnLock
			ScreenCopy 0, 1
			#Define max_scale 50
			uFMOD_Jump2Pattern(1)
			For scale As Integer = 1 To max_scale
				ScreenLock
				ScreenCopy 1, 0
				For x As Integer = 0 To 15
					For y As Integer = 0 To 15
						If(thumb(x*16+y) <> RGB(255,0,255)) Then
							Line(x / 16 * sh * scale / max_scale, y / 16 * sh * scale / max_scale)-((x + 1) / 16 * sh * scale / max_scale, (y + 1) / 16 * sh * scale / max_scale),thumb(x * 16 + y),bf
						EndIf
					Next
				Next
				ScreenUnLock
				Sleep 20
			Next
			uFMOD_Jump2Pattern(2)
			speak(" this is awesome!")
		Case 6
			ScreenUnLock
			uFMOD_Jump2Pattern(3)
			Starfield()
			uFMOD_StopSong()
			Exit For
	End Select
	Sleep 100
Next

' lol, hope you had fun
