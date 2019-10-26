' the only decent effect in this "demo" has its own file \o/
Const scroller =  "So that's it, our lousy contribution to tUM09. Done in a hurry and with absolutely no style! Annoying and lame! We still hope that you had some fun with it, though. This was made using FreeBASIC, ufmod, kkrunchy and a lot of coffee. You may press ESC now..."

#Define star_amount 5000
Type star_type
	As Single x,y,vx,vy
End Type

#Ifndef main
#Include Once "screen.bi"
#EndIf

Sub Starfield()
	Dim As star_type stars (1 To star_amount)
	For i As Integer = 1 To star_amount
		With stars(i)
			While .vx = 0 OrElse .vy = 0
				.vx = Rnd / 100 * IIf(Rnd < 0.5, -1, 1)
				.vy = Rnd / 100 * IIf(Rnd < 0.5, -1, 1)

				.x = .vx * 100 * Rnd
				.y = .vy * 100 * Rnd
			Wend
		End With
	Next

	Dim As Integer scrollw = Len(scroller) * 8
	Dim As Integer scrollh = 8
	Dim As Single scrollz = sh / scrollh / 10

	Dim As Any Ptr Scrollbuffer = ImageCreate(scrollw,scrollh, 0)
	Draw String Scrollbuffer,(0,0), scroller

	Dim As Single scrollpos = 1

	Dim As Double start = Timer, framestart = start
	Do
		ScreenLock
		Cls
		For i As Integer = 1 To star_amount
			With stars(i)
				Dim As Single delta = (Timer - framestart) * 100
				.x += .vx * delta
				.y += .vy * delta
				If(Abs(.x) > 1 OrElse Abs(.y) > 1) Then
					.x = 0
					.y = 0
				EndIf
				Dim As Integer col = Sqr(.x*.x+.y*.y)*300
				If col > 255 Then col = 255
				'PSet(.x * (sw / 2) + sw / 2, .y * (sh / 2) + sh / 2), RGB(col, col, col)
				Line(.x * (sw / 2) + sw / 2, .y * (sh / 2) + sh / 2)-(.x * (sw / 2) + sw / 2 - .vx  * sw / 10, .y * (sh / 2) + sh / 2 - .vy  * sh / 10), RGB(col, col, col)
			End With
		Next

		Dim As Integer done = 1
		For i As Single = 0 To scrollw - 1
			Dim dSine As single = Sin((scrollpos * 1000 + i) * 0.02)
			Dim cx As Integer = scrollpos * sw + i * scrollz + IIf(dSine < 0, CInt(dSine * sw / 20), 0)
			If(cx > sw) Then Exit For
			If(cx < 0) Then Continue For
			done = 0
			For y As Integer= 0 To scrollh - 1
				Dim cy As Integer = sh / 2 + dSine * (sh / 10) + y * scrollz
				If(Point(i, y, Scrollbuffer)) Then
					Line(cx, cy)-(cx+scrollz, cy+scrollz),RGB(y / scrollh * 255, Abs(i / scrollw * 510 - 255), Abs((i Mod 510) - 255)),bf
				EndIf
			Next
		Next
		'scrollpos -= 0.005
		scrollpos = 1 - (Timer - start) / 3
		#Ifdef main
		If done AndAlso uFMOD_GetRowOrder() = &H00050000 Then Exit Do
		#Endif

		ScreenUnLock
		framestart = Timer
		ScreenSync
		Sleep 1

		If(InKey = Chr(27)) Then Exit Do
	Loop
End Sub

#Ifndef main
Starfield()
#EndIf
