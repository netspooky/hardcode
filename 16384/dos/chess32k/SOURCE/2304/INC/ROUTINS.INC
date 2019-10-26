Farbe_weiss=15			;îî
Farbe_schwarz=9			;îî
;<<<Cursor_zeichnen>>>
;Aktualisiert Cursor auf dem Bildschirm
;Ein: -
;Aus: -
Cursor_zeichnen:
 pusha
 lea	bx,Cursoralt		;Alten Cursor lîschen
 mov	ax,[bx]			;Cursor auf alte Position setzen
 call	Zeichen_lesen
 mov	bl,ah			;Altes Zeichen ausgeben
 and	bl,1111b		;Hintergrund lîschen
 mov	ah,9
 mov	cx,1
 call	Retrace
 int	10h
 lea	bx,Cursor		;neuen Cursor zeichnen
 mov	ax,[bx]			;Cursor an neue Position setzen
 call	Zeichen_lesen
 mov	bl,ah			;Cursor ausgeben
 xor	bl,100000b		;grÅne Hintergrundfarbe anschalten
 mov	ah,9
 mov	cx,1
 int	10h
 mov	ax,word ptr[Cursor]	;Zeiger auf alten Cursor aktualisieren
 mov	word ptr[Cursoralt],ax
 popa
 ret

;<<<Retrace>>>
;Wartet auf Screenretrace
;Ein: -
;Aus: -
Retrace:
 pusha
 mov	dx,3DAh
Retrace_2:
 in	al,dx
 test	al,8
 jz	Retrace_2
 popa
 ret

;<<<Figuren_zeichnen>>>
;Zeichnet alle Figuren an ihren Positionen
;Ein: -
;Aus: -
Figuren_zeichnen:
 pusha
 lea	bx,Bauer1w
 mov	cx,8
 mov	al,1			;Bauer
 mov	dx,Farbe_weiss
 call	Figur_zeichnen
 mov	al,6			;Turm
 call	Figur_zeichnen
 mov	al,3			;Springer
 call	Figur_Zeichnen
 mov	al,2			;LÑufer
 call	Figur_Zeichnen
 mov	al,5			;Dame
 mov	cl,9
 call	Figur_Zeichnen
 mov	al,4			;Kînig
 dec	cx
 call	Figur_Zeichnen
 mov	cl,8
 mov	al,1			;Bauer
 mov	dx,Farbe_Schwarz
 call	Figur_zeichnen
 mov	al,6			;Turm
 call	Figur_zeichnen
 mov	al,3			;Springer
 call	Figur_Zeichnen
 mov	al,2			;LÑufer
 call	Figur_Zeichnen
 mov	al,5			;Dame
 mov	cl,9
 call	Figur_Zeichnen
 mov	al,4			;Kînig
 dec	cx
 call	Figur_Zeichnen
 popa
 ret

;<<<Figur_zeichnen>>>
;Zeichnet eine Figur
;Ein:	al=Asciicode von Figur,bx=Speicherstelle der Figur,cx=Wiederholungen,
;	dl=Farbe
;Aus:	cx=2	(Da die meisten Figuren 2 mal da sind, spart meistens ein mov)
Figur_zeichnen:
 push	bx
 push	cx
 push	dx
 push	ax
 mov	ax,[bx]
 test	ax,ax			;Figur ist nicht mehr da?
 jnz	Figur_Zeichnen_2
 pop	ax
 pop	dx
 jmp	Figur_Zeichnen_3
Figur_Zeichnen_2:
 xchg	al,ah			;Position berechnen
 call	Position_umrechnen
 mov	cx,1			;Cursor setzen
 mov	ah,2
 xor	bx,bx
 int	10h
 pop	ax
 pop	bx
 push	ax
 push	bx
 xor	bh,bh
 mov	ah,9			;Figur ausgeben
 int	10h
 pop	dx
 pop	ax
Figur_Zeichnen_3:
 pop	cx
 pop	bx
 inc	bx
 inc	bx
 loop	Figur_Zeichnen
 inc	cx
 inc	cx
 ret

;<<<Position_umrechnen>>>
;Rechnet Schachbrettkoordinaten in Bildschirmposition um
;Ein: ax=Schachbrettkoordinaten
;Aus: dx=Bildschirmposition
Position_umrechnen:
 push	ax
 mov	cl,2
 mul	cl
 add	al,3
 mov	dh,al
 pop	ax
 mov	al,ah
 shl	cl,1
 mul	cl
 add	al,21
 mov	dl,al
 ret

;<<<Schachbrett_zeichnen>>>
;Zeichnet leeres Schachbrett und Koordinaten, falls Option eingestellt ist
;Ein: -
;Aus: -
Schachbrett_zeichnen:
 pusha
 call	Cursor_aus
 mov	ah,2
 mov	dx,417h
 int	10h
 lea	dx,Schachbrett1
 mov	ah,9
 int	21h
 mov	di,7
Schachbrett_zeichnen_2:
 mov	ah,3
 int	10h
 dec	ah
 inc	dh
 mov	dl,17h
 int	10h
 lea	dx,Schachbrett2
 mov	ah,9
 int	21h
 mov	ah,3
 int	10h
 dec	ah
 inc	dh
 mov	dl,17h
 int	10h
 lea	dx,Schachbrett3
 mov	ah,9
 int	21h
 dec	di
 jnz	Schachbrett_Zeichnen_2
 mov	ah,2
 mov	dx,1317h
 int	10h
 lea	dx,Schachbrett2
 mov	ah,9
 int	21h
 mov	ah,2
 mov	dx,1417h
 int	10h
 lea	dx,Schachbrett4
 mov	ah,9
 int	21h
 cmp	[Koordinaten_anzeigen],0	;Koordinaten anzeigen?
 jnz	Schachbrett_Zeichnen_5
 mov	ah,2			;Buchstaben anzeigen
 mov	dx,1519h
 int	10h
 mov	ah,9
 mov	al,'A'
 mov	di,8
Schachbrett_Zeichnen_3:
 mov	bx,7
 mov	cx,1
 push	ax
 int	10h
 mov	ah,3
 int	10h
 dec	ah
 add	dl,4
 int	10h
 pop	ax
 inc	ax
 dec	di
 jnz	Schachbrett_Zeichnen_3
 mov	ah,2			;Zahlen anzeigen
 mov	dx,1315h
 int	10h
 mov	ah,9
 mov	al,'1'
 mov	di,8
Schachbrett_Zeichnen_4:
 mov	bx,7
 mov	cx,1
 push	ax
 int	10h
 mov	ah,3
 int	10h
 dec	ah
 sub	dh,2
 int	10h
 pop	ax
 inc	ax
 dec	di
 jnz	Schachbrett_Zeichnen_4
Schachbrett_Zeichnen_5:
 popa
 ret

;<<<Figuren_zurÅcksetzen>>>
;Setzt alle Figuren an ihre Startpositionen
;Ein: -
;Aus: -
Figuren_zurÅcksetzen:
 mov	[Bauer1s],201h
 mov	[Bauer2s],202h
 mov	[Bauer3s],203h
 mov	[Bauer4s],204h
 mov	[Bauer5s],205h
 mov	[Bauer6s],206h
 mov	[Bauer7s],207h
 mov	[Bauer8s],208h
 mov	[Turm1s],101h
 mov	[Turm2s],108h
 mov	[Springer1s],102h
 mov	[Springer2s],107h
 mov	[LÑufer1s],103h
 mov	[LÑufer2s],106h
 mov	[Dames],104h
 mov	[Dame2s],0
 mov	[Dame3s],0
 mov	[Dame4s],0
 mov	[Dame5s],0
 mov	[Dame6s],0
 mov	[Dame7s],0
 mov	[Dame8s],0
 mov	[Dame9s],0
 mov	[Kînigs],105h
 mov	[Bauer1w],701h
 mov	[Bauer2w],702h
 mov	[Bauer3w],703h
 mov	[Bauer4w],704h
 mov	[Bauer5w],705h
 mov	[Bauer6w],706h
 mov	[Bauer7w],707h
 mov	[Bauer8w],708h
 mov	[Turm1w],801h
 mov	[Turm2w],808h
 mov	[Springer1w],802h
 mov	[Springer2w],807h
 mov	[LÑufer1w],803h
 mov	[LÑufer2w],806h
 mov	[Damew],804h
 mov	[Dame2w],0
 mov	[Dame3w],0
 mov	[Dame4w],0
 mov	[Dame5w],0
 mov	[Dame6w],0
 mov	[Dame7w],0
 mov	[Dame8w],0
 mov	[Dame9w],0
 mov	[Kînigw],805h
 lea	di,Turm1w_bewegt
 xor	al,al
 mov	cl,6
 rep	stosb
 mov	[Figuren_Geschlagen_ZÑhlerw],153Bh
 mov	[Figuren_Geschlagen_ZÑhlers],43Bh
 mov	[Zug],0
 mov	[Notation_Cursor],702h
 mov	[Notation_Cursor2],5
 mov	[Rochade_durchgefÅhrt],0
 mov	[Spieler1_Uhr],0
 mov	[Spieler2_Uhr],0
 ret

;<<<MenÅ>>>
;Zeigt das HauptmenÅ an und behandelt Tastatureingaben
;Ein: -
;Aus: -
MenÅ:
 mov	sp,Stackgrî·e
 call	Cursor_aus
 call	Bildschirm_lîschen
 mov	al,[Cursor_sicherung]
 mov	[Cursor],al
 mov	[Cursoralt],al
 mov	ah,2			;MenÅ ausgeben
 mov	dx,614h
 xor	bx,bx
 int	10h
 lea	dx,MenÅ0
MenÅ_10:
 push	dx
 mov	ah,3			;Cursor eine Zeile runter setzen
 int	10h
 dec	ah
 inc	dh
 mov	dl,14h
 int	10h
 pop	dx
 mov	ah,9			;MenÅzeile ausgeben
 int	21h
 add	dx,42
 cmp	dx,Offset MenÅ9+42
 jnz	MenÅ_10
 mov	ah,2
 mov	dx,816h
 int	10h
 lea	dx,Copyright
 mov	ah,9
 int	21h
MenÅ_3:
 lea	bx,Cursoralt		;Weissen Hintergrund setzen
 mov	al,7
 call	Zeichenhintergrund_setzen
 mov	ah,2			;Alten ersten Cursor lîschen
 mov	dh,[Cursoralt]
 mov	dl,20h
 int	10h
 mov	ax,900h
 xor	bx,bx
 mov	cx,1
 int	10h
 mov	ah,2			;Alten zweiten Cursor lîschen
 mov	dh,[Cursoralt]
 mov	dl,31h
 int	10h
 mov	ax,900h
 xor	bx,bx
 mov	cx,1
 int	10h
 mov	ah,2			;Cursor ausgeben
 mov	dh,[Cursor]
 mov	dl,20h
 int	10h
 mov	ax,91Ah
 mov	bl,7
 int	10h
 mov	ah,2			;zweiten Cursor ausgeben
 mov	dh,[Cursor]
 mov	dl,31h
 int	10h
 mov	ax,91Bh
 mov	bl,7
 int	10h
 lea	bx,Cursor		;GrÅnen Hintergrund setzen
 mov	al,1010b
 call	Zeichenhintergrund_setzen
 xor	ax,ax			;Auf Tastendruck warten
 int	16h
 cmp	ah,50h			;Nach unten?
 jnz	MenÅ_5
 mov	al,[Cursor]
 mov	[Cursoralt],al
 cmp	al,15			;Unten angekommen?
 jnz	MenÅ_4
 mov	al,9
MenÅ_4:
 inc	ax
 mov	[Cursor],al
 jmp	MenÅ_3
MenÅ_5:
 cmp	ah,48h			;Nach oben?
 jnz	MenÅ_6
 mov	al,[Cursor]
 mov	[Cursoralt],al
 cmp	al,10			;Oben angekommen?
 jnz	MenÅ_7
 mov	al,16
MenÅ_7:
 dec	ax
 mov	[Cursor],al
 jmp	MenÅ_3
MenÅ_6:
 mov	al,[Cursor]
 mov	[Cursor_Sicherung],al	;MenÅposition sichern
 cmp	ah,1Ch			;Enter?
 jnz	MenÅ_9
 cmp	al,10			;1 Spieler?
 jz	Ein_Spieler
 cmp	al,11			;2 Spieler?
 jz	Zwei_Spieler
 cmp	al,12			;Optionen?
 jz	Optionen
 cmp	al,13			;Regeln?
 jz	MenÅ_12
 cmp	al,14			;Info?
 jz	Info
 jmp	Ende			;Dann kann es nur Ende sein
MenÅ_9:
 cmp	ah,1			;ESC?
 jz	Ende
 jmp	MenÅ_3
MenÅ_12:
 jmp	Regeln

;<<<Ende>>>
;Lîscht Bildschirm, gibt Copyright aus und beendet das Programm
;Ein: -
;Aus: -
Ende:
 call	Optionen_speichern
 mov	ax,3
 int	10h
 jmp	Endlogo_anzeigen

;<<<Cursor_aus>>>
;Macht Cursor unsichtbar
;Ein: -
;Aus: -
Cursor_aus:
 pusha
 mov	cx,100h			;Cursor ausschalten
 mov	ah,1
 xor	bx,bx
 int	10h
 push	ds			;Font laden
 pop	es
 mov	ax,1100h
 lea	bp,Font
 mov	ch,1
 xor	dx,dx
 mov	bx,1000h
 int	10h
 popa
 ret

;<<<Cursor_an>>>
;Zeigt Cursor
;Ein: -
;Aus: -
Cursor_an:
 pusha
 mov	cx,607h			;Cursor anschalten
 mov	ah,1
 xor	bx,bx
 int	10h
 popa
 ret

;<<<Bildschirm_lîschen>>>
;Lîscht Bildschirm im Textmodus
;Aus: -
Bildschirm_lîschen:
 pusha
 mov	ah,2			;Cursor links oben setzen
 xor	bx,bx
 xor	dx,dx
 int	10h
 push	es
 push	0B800h			;weiches Bildschirm lîschen
 pop	es
 mov	ax,720h
 mov	cx,4000
 xor	di,di
 call	Retrace
 rep	stosw
 pop	es
 popa
 ret

;<<<Zeichen_lesen>>>
;Liest Zeichen an bestimmter Schachbrettposition
;Ein: ax=Schachbrettkoordinaten
;Aus: ax=Attribut,Asciizeichen
Zeichen_lesen:			;Liest Zeichen und Attribut an Brettposition AX
 xchg	al,ah
 call	Position_umrechnen
 mov	ah,2
 xor	bx,bx
 int	10h
 mov	ah,8			;Zeichen lesen
 int	10h
 ret

;<<<Figur_suchen>>>
;Sucht die Speicherstelle der Figur, die an einer bestimmten Brettposition steht
;Ein: bx=Speicherstelle, wo Position steht
;Aus: si=Speicherstelle der Figur
Figur_suchen:
 mov	bx,[bx]
 lea	si,Bauer1w
Figur_suchen_2:
 lodsw
 cmp	ax,bx
 jnz	Figur_suchen_2
 dec	si
 dec	si
 ret

;<<<Figur_entfernen>>>
;Entfernt eine Figur vom Schachbrett
;Ein: [Figur_ausgewÑhlt]=Position des zu lîschenden Feldes
;Aus: -
Figur_entfernen:
 pusha
 lea	bx,Figur_ausgewÑhlt
 mov	al,' '
 mov	cx,1
 mov	dl,0
 call	Figur_zeichnen
 popa
 ret

;<<<Figur_andere>>>
;PrÅft, ob versucht wird eine eigene Figur zu schlagen
;Ein: [Cursor] und [Figur_ausgewÑhlt] beinhalten die Cursorpositionen
;Aus: ax=0, wenn Figuren unterschiedlich sind
Figur_andere:
 xor	di,di
 cmp	si,Offset Kînigw
 ja	Figur_andere_2
 inc	di
Figur_andere_2:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 xor	cx,cx
 cmp	si,Offset Kînigw
 ja	Figur_andere_3
 inc	cx
Figur_andere_3:
 xor	ax,ax
 cmp	di,cx			;Beide Figuren gleich?
 jnz	Figur_andere_4
 inc	ax
Figur_andere_4:
 ret

;<<<Figur_Bauer>>>
;Testet, ob die ausgewÑhlte Figur ein Bauer ist
;Ein: -
;Aus: ax=0 wenn wahr
Figur_Bauer:
 call	Figur_Bauerw
 test	ax,ax
 jz	Figur_Bauer_2
 call	Figur_Bauers
Figur_Bauer_2:
 ret

;<<<Figur_Bauerw>>>
;Testet, ob die ausgewÑhlte Figur ein weisser Bauer ist
;Ein: -
;Aus: ax=0 wenn wahr
Figur_Bauerw:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 cmp	si,Offset Bauer8w
 ja	Figur_Bauerw_2
 xor	ax,ax
Figur_Bauerw_2:
 ret

;<<<Figur_Bauers>>>
;Testet, ob die ausgewÑhlte Figur ein schwarzer Bauer ist
;Ein: -
;Aus: ax=0 wenn wahr
Figur_Bauers:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 cmp	si,Offset Kînigw
 jna	Figur_Bauers_2
 cmp	si,Offset Bauer8s
 ja	Figur_Bauers_2
 xor	ax,ax
Figur_Bauers_2:
 ret

;<<<Figur_Turm>>>
;Testet, ob die ausgewÑhlte Figur ein Turm ist
;Ein: -
;Aus: ax=0 wenn wahr
Figur_Turm:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 cmp	si,Offset Turm1w
 jz	Figur_Turm_2
 cmp	si,Offset Turm2w
 jz	Figur_Turm_2
 cmp	si,Offset Turm1s
 jz	Figur_Turm_2
 cmp	si,Offset Turm2s
 jz	Figur_Turm_2
 ret
Figur_Turm_2:
 xor	ax,ax
 ret

;<<<Figur_Dame>>>
;Testet, ob die ausgewÑhlte Figur eine Dame ist
;Ein: -
;Aus: ax=0 wenn wahr
Figur_Dame:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 cmp	si,Offset Kînigw	;Weisse Figuren?
 ja	Figur_Dame_4
 cmp	si,Offset LÑufer2w
 jna	Figur_Dame_2
 cmp	si,Offset Dame9w
 ja	Figur_Dame_2
 jmp	Figur_Dame_3
Figur_Dame_4:
 cmp	si,Offset LÑufer2s
 jna	Figur_Dame_2
 cmp	si,Offset Dame9s
 ja	Figur_Dame_2
Figur_Dame_3:
 xor	ax,ax
Figur_Dame_2:
 ret

;<<<Figur_gerade_ziehen>>>
;PrÅft, ob die Figur waagerecht oder senkrecht gezogen wurde
;Ein: -
;Aus: ax=0 wenn wahr
Figur_gerade_ziehen:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 mov	bx,word ptr[Cursor]
 cmp	ah,bh			;senkrecht laufen?
 jz	Figur_gerade_ziehen_2
 cmp	al,bl			;waagerecht laufen?
 jz	Figur_gerade_ziehen_2
 ret
Figur_gerade_ziehen_2:
 xor	ax,ax
 ret

;<<<Figur_lîschen>>>
;Lîscht eine Figur, die geschlagen wurde
;Ein: -
;Aus: -
Figur_lîschen:
 call	Anderer_Spieler
 lea	bx,Cursor
 call	Figur_suchen
 call	Geschlagene_Figur_in_Fenster_zeichnen
 call	Zugnotation
 mov	word ptr[si],0		;Figur lîschen
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 mov	ax,word ptr[Cursor]
 mov	word ptr[si],ax
 xchg	al,ah			;Figur langsam wegbeamen
 call	Position_umrechnen
 pusha
 mov	ah,2
 xor	bx,bx
 int	10h
 popa
 mov	di,0Dh
Figur_lîschen_2:
 mov	ax,di
 mov	ah,9
 mov	bx,4
 mov	cx,1
 int	10h
 pusha
 xor	di,di
 xor	si,si
Figur_lîschen_3:
 xor	ah,ah
 int	1Ah
 xor	dh,dh
 cmp	dx,di
 jz	Figur_lîschen_3
 mov	di,dx
 inc	si
 cmp	si,2
 jnz	Figur_lîschen_3
 popa
 inc	di
 cmp	di,11h			;Alle Zoomstufen durch?
 jna	Figur_lîschen_2
 pop	ax			;Stack sÑubern
 pop	ax
 call	Figur_entfernen
 call	Figuren_zeichnen
 mov	[Figur_ausgewÑhlt],0
 mov	al,[Einspielermodus]
 test	al,al
 jz	Zwei_Spieler_2
 jmp	Ein_Spieler_2

;<<<Figur_dazwischen>>>
;PrÅft, ob zwischen zwei Punkten eine Figur steht
;Ein: [Cursor] Punkt1, [Figur_ausgewÑhlt] Punkt2
;Aus: ax=0 wenn keine Figur dazwischen
Figur_dazwischen:
 mov	ax,word ptr[Cursor]
 mov	bx,[Figur_ausgewÑhlt]
Figur_dazwischen_12:
 cmp	al,bl			;waagerecht gleich? 
 jnz	Figur_dazwischen_4
 cmp	ah,bh
 ja	Figur_dazwischen_5
 xchg	ax,bx
Figur_dazwischen_5:
 inc	bh
 cmp	ax,bx			;Punkt1 und Punkt2 sind nur ein Zeichen entfernt?
 jz	Figur_dazwischen_6
Figur_dazwischen_2:
 push	ax
 mov	[Temp],bx
 lea	bx,Temp
 call	Figur_suchen
 pop	ax
 cmp	si,Offset Temp		;Stelle besetzt?
 jnz	Figur_dazwischen_3
 cmp	ax,bx			;Ende?
 jnz	Figur_dazwischen_12
Figur_dazwischen_6:
 xor	ax,ax
Figur_dazwischen_3:
 ret
Figur_dazwischen_4:
 cmp	ah,bh			;schrÑg ziehen?
 jnz	Figur_dazwischen_9
 cmp	al,bl
 ja	Figur_dazwischen_7
 xchg	ax,bx
Figur_dazwischen_7:
 inc	bx
 cmp	ax,bx			;Punkt1 und Punkt2 sind nur ein Zeichen entfernt?
 jz	Figur_dazwischen_6
Figur_dazwischen_8:
 push	ax
 mov	[Temp],bx
 lea	bx,Temp
 call	Figur_suchen
 pop	ax
 cmp	si,Offset Temp		;Stelle besetzt?
 jnz	Figur_dazwischen_3
 inc	bx			;îî Fehler???
 cmp	ax,bx			;Ende?
 jnz	Figur_dazwischen_12
 jmp	Figur_dazwischen_6
Figur_dazwischen_9:
 cmp	bh,ah
 ja	Figur_dazwischen_10
 inc	bh
 inc	bh
Figur_dazwischen_10:
 dec	bh
 cmp	bl,al
 ja	Figur_dazwischen_11
 inc	bx
 inc	bx
Figur_dazwischen_11:
 dec	bx
 cmp	ax,bx			;Ende?
 jz	Figur_dazwischen_6
 push	ax
 mov	[Temp],bx
 lea	bx,Temp
 call	Figur_suchen
 pop	ax
 cmp	si,Offset Temp		;Stelle besetzt?
 jnz	Figur_dazwischen_3
 cmp	ax,bx			;Ende?
 jnz	Figur_dazwischen_12
 jmp	Figur_dazwischen_6

;<<<Figur_LÑufer>>>
;Testet, ob die ausgewÑhlte Figur ein LÑufer ist
;Ein: -
;Aus: ax=0 wenn wahr
Figur_LÑufer:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 cmp	si,Offset LÑufer1w
 jz	Figur_LÑufer_2
 cmp	si,Offset LÑufer2w
 jz	Figur_LÑufer_2
 cmp	si,Offset LÑufer1s
 jz	Figur_LÑufer_2
 cmp	si,Offset LÑufer2s
 jz	Figur_LÑufer_2
 ret
Figur_LÑufer_2:
 xor	ax,ax
 ret

;<<<Figur_schrÑg_ziehen>>>
;PrÅft, ob die Figur schrÑg gezogen wurde
;Ein: -
;Aus: ax=0 wenn wahr
Figur_schrÑg_ziehen:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 mov	bx,word ptr[Cursor]
 cmp	ah,bh
 jna	Figur_schrÑg_ziehen_2
 xchg	ah,bh
Figur_schrÑg_ziehen_2:
 cmp	al,bl
 jna	Figur_schrÑg_ziehen_3
 xchg	al,bl
Figur_schrÑg_ziehen_3:
 sub	bx,ax
 cmp	bl,bh
 jnz	Figur_schrÑg_ziehen_4
 xor	ax,ax
Figur_schrÑg_ziehen_4:
 ret

;<<<Figur_Kînig>>>
;Testet, ob die ausgewÑhlte Figur ein Kînig ist
;Ein: -
;Aus: ax=0 wenn wahr
Figur_Kînig:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 cmp	si,Offset Kînigw
 jz	Figur_Kînig_2
 cmp	si,Offset Kînigs
 jz	Figur_Kînig_2
 ret
Figur_Kînig_2:
 xor	ax,ax
 ret

;<<<Figur_Feld_weiter>>>
;PrÅft, ob die Figur ein Feld weiter gerÅckt wurde
;Ein: -
;Aus: ax=0, wenn wahr
Figur_Feld_weiter:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 mov	bx,word ptr[Cursor]
 cmp	al,bl
 ja	Figur_Feld_weiter_2
 xchg	al,bl
Figur_Feld_weiter_2:
 sub	al,bl
 cmp	ah,bh
 ja	Figur_Feld_weiter_3
 xchg	ah,bh
Figur_Feld_weiter_3:
 sub	ah,bh
 cmp	al,1
 ja	Figur_Feld_weiter_4
 cmp	ah,1
 ja	Figur_Feld_weiter_4
 xor	ax,ax
Figur_Feld_weiter_4:
 ret

;<<<Figur_Springer>>>
;Testet, ob die ausgewÑhlte Figur ein Springer ist
;Ein: -
;Aus: ax=0 wenn wahr
Figur_Springer:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 cmp	si,Offset Springer1w
 jz	Figur_Springer_2
 cmp	si,Offset Springer2w
 jz	Figur_Springer_2
 cmp	si,Offset Springer1s
 jz	Figur_Springer_2
 cmp	si,Offset Springer2s
 jz	Figur_Springer_2
 ret
Figur_Springer_2:
 xor	ax,ax
 ret

;<<<Figur_Ecksprung>>>
;PrÅft, ob die Figur einen Ecksprung gemacht hat
;Ein: -
;Aus: ax=0, wenn wahr
Figur_Ecksprung:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 mov	bx,word ptr[Cursor]
 cmp	al,bl
 ja	Figur_Ecksprung_2
 xchg	al,bl
Figur_Ecksprung_2:
 sub	al,bl
 cmp	ah,bh
 ja	Figur_Ecksprung_3
 xchg	ah,bh
Figur_Ecksprung_3:
 sub	ah,bh
 cmp	al,ah
 ja	Figur_Ecksprung_4
 xchg	al,ah
Figur_Ecksprung_4:
 cmp	ax,102h			;Ecksprung?
 jnz	Figur_Ecksprung_5
 xor	ax,ax
Figur_Ecksprung_5:
 ret

;<<<Figur_schlagen>>>
;PrÅft, ob das Schlagen der Figur an Cursorposition erlaubt ist
;Ein: -
;Aus: -
Figur_schlagen:
 pusha
 call	Figur_andere		;Es wird versucht eigene Figur zu schlagen?
 test	ax,ax
 jnz	Figur_schlagen_3
 call	Figur_Bauerw		;wei·er Bauer?
 test	ax,ax
 jz	Figur_Schlagen_2
 call	Figur_Bauers		;Scharzer Bauer?
 test	ax,ax
 jz	Figur_schlagen_5
 call	Figur_Turm		;Turm?
 test	ax,ax
 jz	Figur_schlagen_7
 call	Figur_LÑufer		;LÑufer?
 test	ax,ax
 jz	Figur_schlagen_8
 call	Figur_Dame		;Dame?
 test	ax,ax
 jz	Figur_schlagen_9
 call	Figur_Kînig		;Kînig?
 test	ax,ax
 jz	Figur_schlagen_11
 call	Figur_Ecksprung		;Dann kann es nur Springer sein
 test	ax,ax
 jnz	Figur_schlagen_3
 popa
 call	Bemerkung_schlagen2
 jmp	Figur_lîschen
Figur_schlagen_3:		;Schlagen nicht mîglich
 popa				;Stack sÑubern
 ret
Figur_schlagen_2:
 call	Bauernumwandlung
 mov	ax,word ptr[Cursor]
 mov	bx,[Figur_ausgewÑhlt]
 sub	bx,101h
 cmp	ax,bx			;SchrÑg nach links oben schlagen?
 jnz	Figur_schlagen_4
 popa
 jmp	Figur_lîschen
Figur_schlagen_4:
 mov	bx,[Figur_ausgewÑhlt]
 dec	bh
 inc	bx
 cmp	ax,bx			;SchrÑg nach rechts oben schlagen?
 jnz	Figur_schlagen_3
 popa
 jmp	Figur_lîschen
Figur_schlagen_5:
 call	Bauernumwandlung
 mov	ax,word ptr[Cursor]
 mov	bx,[Figur_ausgewÑhlt]
 inc	bh
 dec	bx
 cmp	ax,bx			;SchrÑg nach links unten schlagen?
 jnz	Figur_schlagen_6
 popa
 jmp	Figur_lîschen
Figur_schlagen_6:
 mov	bx,[Figur_ausgewÑhlt]
 inc	bh
 inc	bx
 cmp	ax,bx			;SchrÑg nach rechts unten schlagen?
 jnz	Figur_schlagen_3
 popa
 jmp	Figur_lîschen
Figur_schlagen_7:
 call	Figur_gerade_ziehen
 test	ax,ax			;Waagerecht oder senkrecht schlagen?
 jnz	Figur_schlagen_3
 call	Figur_dazwischen
 test	ax,ax
 jnz	Figur_schlagen_3
 popa
 jmp	Figur_lîschen
Figur_schlagen_8:
 call	Figur_schrÑg_ziehen
 test	ax,ax
 jnz	Figur_schlagen_3
 call	Figur_dazwischen
 test	ax,ax
 jnz	Figur_schlagen_3
 popa
 jmp	Figur_lîschen
Figur_schlagen_9:
 call	Figur_gerade_ziehen
 test	ax,ax
 jz	Figur_schlagen_10
 call	Figur_schrÑg_ziehen
 test	ax,ax
 jnz	Figur_schlagen_3
Figur_schlagen_10:
 call	Figur_dazwischen
 test	ax,ax
 jnz	Figur_schlagen_3
 popa
 jmp	Figur_lîschen
Figur_schlagen_11:
; call	Figur_Feld_weiter	;îîî
 test	ax,ax
 jnz	Figur_schlagen_3
 popa
 jmp	Figur_lîschen

;<<<Anderer_Spieler>>>
;Setzt Flag, das anderer Spieler an der Reihe ist
;Ein: -
;Aus: -
Anderer_Spieler:
 cmp	[Am_Zug],0
 jz	Anderer_Spieler_2
 sub	[Am_Zug],2
Anderer_Spieler_2:
 inc	[Am_Zug]
 call	Spieler_Namen_ausgeben
 ret

;<<<Cursor_weiter>>>
;Setzt den Cursor ein Zeichen weiter
;Ein: -
;Aus: -
Cursor_weiter:
 pusha
 xor	bx,bx
 mov	ah,3
 int	10h
 dec	ah
 inc	dx
 int	10h
 popa
 ret

;<<<Cursor_Zeile_tiefer>>>
;Setzt den Cursor eine Zeile weiter runter
;Ein: -
;Aus: -
Cursor_Zeile_tiefer:
 pusha
 xor	bx,bx
 mov	ah,3
 int	10h
 dec	ah
 inc	dh
 int	10h
 popa
 ret

;<<<Cursor_Zeile_Umbruch>>>
;Setzt den Cursor auf den Anfang der nÑchsten eine Zeile
;Ein: -
;Aus: -
Cursor_Zeile_Umbruch:
 pusha
 xor	bx,bx
 mov	ah,3
 int	10h
 dec	ah
 inc	dh
 xor	dl,dl
 int	10h
 popa
 ret

;<<<Cursor_zurÅck>>>
;Setzt den Cursor ein Zeichen zurÅck
;Ein: -
;Aus: -
Cursor_zurÅck:
 pusha
 xor	bx,bx
 mov	ah,3
 int	10h
 dec	ah
 dec	dx
 int	10h
 popa
 ret

;<<<String_einlesen>>>
;Liest einen String ein
;Ein: di=Speicherstelle, si=maximale LÑnge
;Aus: -
String_einlesen:
 mov	cx,word ptr[Cursor]
 test	ax,ax			;String schon vorhanden?
 jz	String_einlesen_2
String_einlesen_8:
 call	Cursor_weiter
 inc	di
 loop	String_einlesen_8
String_einlesen_2:
 xor	ax,ax			;Auf Tastendruck warten
 int	16h
 cmp	ah,1			;ESC?
 jnz	String_einlesen_3
 ret
String_einlesen_3:
 cmp	ah,1Ch			;Enter?
 jz	String_einlesen_4
 cmp	ah,0Eh			;RÅcktaste?
 jnz	String_einlesen_5
 cmp	[Cursor],0		;Anfang des Strings erreicht?
 jz	String_einlesen_2
 call	Cursor_zurÅck
 mov	ax,920h
 mov	bx,7
 mov	cx,1
 int	10h			;Zeichen in String lîschen
 stosb
 dec	di
 dec	di
 dec	[Cursor]
 jmp	String_einlesen_2
String_einlesen_5:
 cmp	ah,53h			;Entf?
 jnz	String_einlesen_7
 cmp	[Cursor],0		;Anfang des Strings erreicht?
 jz	String_einlesen_2
 xor	bx,bx			;String auf Bildschirm lîschen
 mov	ah,3
 int	10h
 dec	ah
 mov	dl,25h
 int	10h
 mov	ax,920h
 mov	bx,7
 mov	cx,17
 int	10h
 std
 mov	cl,[Cursor]
 dec	di
 rep	stosb			;String lîschen
 mov	[Cursor],cl
 cld
 inc	di
 jmp	String_einlesen_2
String_einlesen_7:
 cmp	al,31			;gÅltiges Asciizeichen?
 jna	String_einlesen_2
 cmp	word ptr[Cursor],si	;maximale StringlÑnge erreicht?
 jz	String_einlesen_2
 stosb				;Zeichen sichern
 mov	ah,9			;Zeichen ausgeben
 mov	bx,7
 mov	cx,1
 int	10h
 call	Cursor_weiter
 inc	[Cursor]
 jmp	String_einlesen_2
String_einlesen_4:
 cmp	byte ptr[Cursor],0	;Kein Namen eingegeben?
 jz	String_einlesen_2
 xor	ax,ax
 ret

;<<<Spieler_Namen_einlesen>>>
;Fragt die Namen der zwei Spieler ab
;Ein: -
;Aus: -
Spieler_Namen_einlesen:
 pusha
 call	Cursor_an
 call	Bildschirm_lîschen
 mov	ah,2			;Fenster fÅr Namenseingabe ausgeben
 mov	dx,919h
 xor	bx,bx
 int	10h
 lea	dx,Spielername1
Spieler_Namen_einlesen_2:
 push	dx
 mov	ah,3			;Cursor eine Zeile tiefer
 int	10h
 dec	ah
 mov	dl,19h
 inc	dh
 int	10h
 pop	dx
 mov	ah,9			;Fensterstring ausgeben
 int	21h
 add	dx,32
 cmp	dx,Offset Spielername6+32
 jnz	Spieler_Namen_einlesen_2
 mov	ah,2			;Cursor auf erstes Eingabefeld setzen
 mov	dx,0D25h
 int	10h
 lea	dx,Spieler2		;Alten Namen ausgeben
 mov	ah,9
 int	21h
 mov	ah,2			;Cursor auf zweites Eingabefeld setzen
 mov	dx,0E25h
 int	10h
 lea	dx,Spieler1		;Alten Namen ausgeben
 mov	ah,9
 int	21h
 mov	ah,2			;Cursor auf erstes Eingabefeld setzen
 mov	dx,0D25h
 int	10h
 lea	di,Spieler2
 mov	si,17
 push	si
 mov	ax,[Spieler2_NamenslÑnge]
 mov	word ptr[Cursor],ax
 call	String_einlesen
 sub	di,Offset Spieler2	;StringlÑnge sichern
 mov	[Spieler2_NamenslÑnge],di
 cmp	ah,1			;Die Namenseingabe wurde abgebrochen?
 jz	MenÅ
 mov	ah,2			;Cursor auf zweites Eingabefeld setzen
 mov	dx,0E25h
 int	10h
 pop	si
 lea	di,Spieler1
 mov	ax,[Spieler1_NamenslÑnge]
 mov	word ptr[Cursor],ax
 call	String_einlesen
 sub	di,Offset Spieler1	;StringlÑnge sichern
 mov	[Spieler1_NamenslÑnge],di
 cmp	ah,1			;Die Namenseingabe wurde abgebrochen?
 jz	MenÅ
 call	Cursor_aus
 popa
 ret

;<<<Farbe_wÑhlen>>>
;Zeigt das Fenster zur Auswahl einer Farbe an
;Ein: -
;Aus: -
Farbe_wÑhlen:
 pusha
 call	Bildschirm_lîschen
 mov	[Cursor],11
 mov	[Cursoralt],0
 mov	ah,2			;Farbe_wÑhlen ausgeben
 mov	dx,71Fh
 xor	bx,bx
 int	10h
 lea	dx,Seitenwahl0
Farbe_wÑhlen_10:
 push	dx
 mov	ah,3			;Cursor eine Zeile runter setzen
 int	10h
 dec	ah
 inc	dh
 mov	dl,1Fh
 int	10h
 pop	dx
 mov	ah,9			;Zeile ausgeben
 int	21h
 add	dx,18
 cmp	dx,Offset Seitenwahl6+18
 jnz	Farbe_wÑhlen_10
Farbe_wÑhlen_3:
 lea	bx,Cursoralt		;Weissen Hintergrund setzen
 mov	al,7
 call	Zeichenhintergrund_setzen3
 mov	ah,2			;Alten ersten Cursor lîschen
 mov	dh,[Cursoralt]
 mov	dl,21h
 int	10h
 mov	ax,900h
 xor	bx,bx
 mov	cx,1
 int	10h
 mov	ah,2			;Alten zweiten Cursor lîschen
 mov	dh,[Cursoralt]
 mov	dl,2Dh
 int	10h
 mov	ax,900h
 xor	bx,bx
 mov	cx,1
 int	10h
 mov	ah,2			;Cursor ausgeben
 mov	dh,[Cursor]
 mov	dl,21h
 int	10h
 mov	ax,91Ah
 mov	bl,7
 int	10h
 mov	ah,2			;zweiten Cursor ausgeben
 mov	dh,[Cursor]
 mov	dl,2Dh
 int	10h
 mov	ax,91Bh
 mov	bl,7
 int	10h
 lea	bx,Cursor		;GrÅnen Hintergrund setzen
 mov	al,1010b
 call	Zeichenhintergrund_setzen3
 xor	ax,ax			;Auf Tastendruck warten
 int	16h
 cmp	ah,50h			;Nach unten?
 jnz	Farbe_wÑhlen_5
 mov	al,[Cursor]
 mov	[Cursoralt],al
 cmp	al,13			;Unten angekommen?
 jnz	Farbe_wÑhlen_4
 mov	al,10
Farbe_wÑhlen_4:
 inc	ax
 mov	[Cursor],al
 jmp	Farbe_wÑhlen_3
Farbe_wÑhlen_5:
 cmp	ah,48h			;Nach oben?
 jnz	Farbe_wÑhlen_6
 mov	al,[Cursor]
 mov	[Cursoralt],al
 cmp	al,11			;Oben angekommen?
 jnz	Farbe_wÑhlen_7
 mov	al,14
Farbe_wÑhlen_7:
 dec	ax
 mov	[Cursor],al
 jmp	Farbe_wÑhlen_3
Farbe_wÑhlen_6:
 mov	al,[Cursor]
 cmp	ah,1Ch			;Enter?
 jnz	Farbe_wÑhlen_9
 cmp	al,12			;Weiss?
 jnz	Farbe_wÑhlen_2
 mov	[Farbe_ausgewÑhlt],0
Farbe_wÑhlen_2:
 cmp	al,13			;Schwarz?
 jnz	Farbe_wÑhlen_8
 mov	[Farbe_ausgewÑhlt],1
Farbe_wÑhlen_8:
 cmp	al,11			;Zufall?
 jnz	Farbe_wÑhlen_11
 mov	bl,1
 call	Zufallszahl
 mov	[Farbe_ausgewÑhlt],al
Farbe_wÑhlen_11:
 popa
 call	Bildschirm_lîschen
 ret
Farbe_wÑhlen_9:
 cmp	ah,1			;ESC?
 jz	MenÅ
 jmp	Farbe_wÑhlen_3

;<<<Spieler_Namen_ausgeben>>>
;Gibt die Namen der Spieler Åber und unter dem Schachbrett aus
;Ein: -
;Aus: -
Spieler_Namen_ausgeben:
 pusha
 cmp	[Namen_anzeigen],0	;Option ausgeschalten?
 jnz	Spieler_Namen_ausgeben_6
 xor	bx,bx			;LÑnge des Spielernamens herausfinden
 cmp	[Einspielermodus],0
 jz	Spieler_Namen_ausgeben_7
 cmp	[Farbe_ausgewÑhlt],0
 jnz	Spieler_Namen_ausgeben_15
 lea	si,Spieler1_NamenslÑnge-2
 jmp	Spieler_Namen_ausgeben_8
Spieler_Namen_ausgeben_15:
 lea	si,Notation_String-2
 jmp	Spieler_Namen_ausgeben_8
Spieler_Namen_ausgeben_7:
 lea	si,Spieler2-2
Spieler_Namen_ausgeben_8:
 std
 dec	bx
Spieler_Namen_ausgeben_2:
 lodsb
 inc	bx
 cmp	al,20h
 jz	Spieler_Namen_ausgeben_2
 mov	ax,17			;Namen auf Bildschirm zentrieren
 sub	ax,bx
 shr	ax,1
 mov	ah,2
 mov	dx,227h
 sub	dl,al
 int	10h
 mov	ax,920h			;Weisse Farbe fÅr die Stringzeichen ausgeben
 mov	bx,7
 mov	cx,18
 int	10h
 cmp	[Am_Zug],0
 jz	Spieler_Namen_ausgeben_4
 mov	ax,920h			;Rote Farbe fÅr die Stringzeichen ausgeben
 mov	bx,4
 mov	cx,18
 int	10h
Spieler_Namen_ausgeben_4:
 cmp	[Einspielermodus],0
 jz	Spieler_Namen_ausgeben_11
 cmp	[Farbe_ausgewÑhlt],0
 jnz	Spieler_Namen_ausgeben_16
 lea	dx,Computer_Name
 jmp	Spieler_Namen_ausgeben_12
Spieler_Namen_ausgeben_16:
 lea	dx,Spieler3
 jmp	Spieler_Namen_ausgeben_12
Spieler_Namen_ausgeben_11:
 lea	dx,Spieler1
Spieler_Namen_ausgeben_12:
 mov	ah,9
 int	21h
 xor	bx,bx			;LÑnge des Spielernamens herausfinden
 cmp	[Einspielermodus],0
 jz	Spieler_Namen_ausgeben_9
 cmp	[Farbe_ausgewÑhlt],0
 jnz	Spieler_Namen_ausgeben_17
 lea	si,Notation_String-2
 jmp	Spieler_Namen_ausgeben_10
Spieler_Namen_ausgeben_17:
 lea	si,Spieler1_NamenslÑnge-2
 jmp	Spieler_Namen_ausgeben_10
Spieler_Namen_ausgeben_9:
 lea	si,Spieler3-2
Spieler_Namen_ausgeben_10:
 dec	bx
Spieler_Namen_ausgeben_3:
 lodsb
 inc	bx
 cmp	al,20h
 jz	Spieler_Namen_ausgeben_3
 mov	ax,17			;Namen auf Bildschirm zentrieren
 sub	ax,bx
 shr	ax,1
 mov	ah,2
 mov	dx,1727h
 sub	dl,al
 int	10h
 mov	ax,920h			;Weisse Farbe fÅr die Stringzeichen ausgeben
 mov	bx,7
 mov	cx,18
 int	10h
 cmp	[Am_Zug],1
 jz	Spieler_Namen_ausgeben_5
 mov	ax,920h			;Rote Farbe fÅr die Stringzeichen ausgeben
 mov	bx,4
 mov	cx,18
 int	10h
Spieler_Namen_ausgeben_5:
 cmp	[Einspielermodus],0
 jz	Spieler_Namen_ausgeben_13
 cmp	[Farbe_ausgewÑhlt],0
 jnz	Spieler_Namen_ausgeben_18
 lea	dx,Spieler3
 jmp	Spieler_Namen_ausgeben_14
Spieler_Namen_ausgeben_18:
 lea	dx,Computer_Name
 jmp	Spieler_Namen_ausgeben_14
Spieler_Namen_ausgeben_13:
 lea	dx,Spieler2
Spieler_Namen_ausgeben_14:
 mov	ah,9
 int	21h
 cld
Spieler_Namen_ausgeben_6:
 popa
 ret

;<<<Optionen>>>
;Zeigt das OptionenmenÅ an und behandelt Tastatureingaben
;Ein: -
;Aus: -
Optionen:
 call	Bildschirm_lîschen
 mov	[Cursor],10
 mov	ah,2			;OptionenmenÅ ausgeben
 mov	dx,614h
 xor	bx,bx
 int	10h
 lea	dx,Optionen0
Optionen_16:
 push	dx
 mov	ah,3			;Cursor eine Zeile runter setzen
 int	10h
 dec	ah
 mov	dl,14h
 inc	dh
 int	10h
 pop	dx
 mov	ah,9			;Optionenstring ausgeben
 int	21h
 add	dx,40
 cmp	dx,Offset OptionenB+40
 jnz	Optionen_16
Optionen_13:
 lea	si,[Koordinaten_anzeigen]	;Einstellungen als KÑsten ausgeben
 mov	ah,2
 mov	dx,916h
 xor	bx,bx
 int	10h
Optionen_2:
 call	Cursor_Zeile_tiefer
 lodsb
 cmp	al,2
 jz	Optionen_3		;Alle Optionen gelesen?
 push	ax
 mov	ax,90Ch
 mov	bx,7
 mov	cx,1
 int	10h 
 pop	ax
 test	al,al
 jz	Optionen_2
 mov	ax,90Bh
 int	10h 
 jmp	Optionen_2
Optionen_3:
 lea	bx,Cursoralt		;Weissen Hintergrund setzen
 mov	al,7
 call	Zeichenhintergrund_setzen2
 lea	bx,Cursor		;GrÅnen Hintergrund setzen
 mov	al,1010b
 call	Zeichenhintergrund_setzen2
 xor	ax,ax			;Auf Tastendruck warten
 int	16h
 cmp	ah,50h			;Nach unten?
 jnz	Optionen_5
 mov	al,[Cursor]
 mov	[Cursoralt],al
 cmp	al,17			;Unten angekommen?
 jnz	Optionen_4
 mov	al,9
Optionen_4:
 inc	ax
 mov	[Cursor],al
 jmp	Optionen_3
Optionen_5:
 cmp	ah,48h			;Nach oben?
 jnz	Optionen_7
 mov	al,[Cursor]
 mov	[Cursoralt],al
 cmp	al,10			;Oben angekommen?
 jnz	Optionen_6
 mov	al,18
Optionen_6:
 dec	ax
 mov	[Cursor],al
 jmp	Optionen_3
Optionen_7:
 mov	al,[Cursor]
 cmp	ah,1Ch			;Enter?
 jz	Optionen_9
 cmp	ah,39h			;Leertaste?
 jz	Optionen_9
 cmp	ah,4Bh			;nach links?
 jz	Optionen_9
 cmp	ah,4Dh			;nach rechts?
 jz	Optionen_9
 cmp	ah,1			;ESC?
 jz	MenÅ
 jmp	Optionen_3
Optionen_9:
 cmp	al,10			;Koordinaten anzeigen?
 jz	Optionen_8
 cmp	al,11			;Namen anzeigen?
 jz	Optionen_10
 cmp	al,12			;Schachuhr anzeigen?
 jz	Optionen_11
 cmp	al,13			;Zugnotation anzeigen?
 jz	Optionen_17
 cmp	al,14			;Geschlagene Figuren anzeigen?
 jz	Optionen_14
 cmp	al,15			;Bemerkungen anzeigen?
 jz	Optionen_18
 cmp	al,16			;Optionen automatisch speichern?
 jz	Optionen_15
 jmp	MenÅ			;Dann kann es nur noch HauptmenÅ sein

Optionen_18:
 lea	bx,Bemerkungen_anzeigen
 mov	al,[bx]
 mov	byte ptr[bx],0
 test	al,al
 jnz	Optionen_13
 inc	ax
 mov	[bx],al
 jmp	Optionen_13
Optionen_17:
 lea	bx,Zugnotation_anzeigen
 mov	al,[bx]
 mov	byte ptr[bx],0
 test	al,al
 jnz	Optionen_13
 inc	ax
 mov	[bx],al
 jmp	Optionen_13
Optionen_14:
 lea	bx,Geschlagene_Figuren_anzeigen
 mov	al,[bx]
 mov	byte ptr[bx],0
 test	al,al
 jnz	Optionen_13
 inc	ax
 mov	[bx],al
 jmp	Optionen_13
Optionen_15:
 lea	bx,Optionen_Autosafe
 mov	al,[bx]
 mov	byte ptr[bx],0
 test	al,al
 jnz	Optionen_13
 inc	ax
 mov	[bx],al
 call	Optionen_speichern_4	;Optionen speichern, damit Autosafe immer aus ist
 jmp	Optionen_13
Optionen_8:
 lea	bx,Koordinaten_anzeigen
 mov	al,[bx]
 mov	byte ptr[bx],0
 test	al,al
 jnz	Optionen_13
 inc	ax
 mov	[bx],al
 jmp	Optionen_13
Optionen_10:
 lea	bx,Namen_anzeigen
 mov	al,[bx]
 mov	byte ptr[bx],0
 test	al,al
 jnz	Optionen_13
 inc	ax
 mov	[bx],al
 jmp	Optionen_13
Optionen_11:
 lea	bx,Schachuhr_anzeigen
 mov	al,[bx]
 mov	byte ptr[bx],0
 test	al,al
 jnz	Optionen_13
 inc	ax
 mov	[bx],al
 jmp	Optionen_13
Optionen_12:
 jmp	Optionen_3

;<<<Optionen_lesen>>>
;Liest gespeicherte Optionen aus einer Configdatei
;Ein: -
;Aus: -
Optionen_lesen:
 pusha
 mov	ax,3D00h		;Configdatei zum Lesen îffnen
 lea	dx,Configdatei
 int	21h
 jc	Optionen_lesen_2	;Datei nicht gefunden?
 xchg	ax,bx			;Datei einlesen
 mov	cx,100
 mov	ah,3Fh
 lea	dx,Temp
 mov	si,dx
 int	21h 
 mov	ah,3Eh			;Datei schlie·en
 int	21h
 lea	di,Koordinaten_anzeigen	;Optionen einlesen
 mov	cl,7			;Anzahl der Optionen
 rep	movsb
 lea	di,Spieler1_NamenslÑnge	;Optionen einlesen
 mov	cl,3
 rep	movsw
 lea	di,Spieler1		;Spielernamen einlesen
 mov	cl,18
 rep	movsb
 lea	di,Spieler2
 mov	cl,18
 rep	movsb
 lea	di,Spieler3
 mov	cl,18
 rep	movsb
Optionen_lesen_2:
 popa
 ret

;<<<Optionen_speichern>>>
;Speichert Optionen in eine Configdatei
;Ein: -
;Aus: -
Optionen_speichern:
 pusha
 cmp	[Optionen_Autosafe],0	;Option eingeschalten?
 jnz	Optionen_speichern_2
 jmp	Optionen_speichern_3
Optionen_speichern_4:		;Optionen wirklich speichern (umgeht Option)
 pusha
Optionen_speichern_3:
 mov	ah,3Ch			;Configdatei erzeugen
 lea	dx,Configdatei
 xor	cx,cx
 int	21h
 xchg	ax,bx			;Datei schlie·en
 mov	ah,3Eh
 int	21h
 mov	ax,3C01h		;Configdatei zum Schreiben îffnen
 lea	dx,Configdatei
 int	21h
 push	ax
 lea	si,Koordinaten_anzeigen	;Optionen einlesen
 lea	di,Temp
 push	di			;Puffer lîschen
 xor	ax,ax
 mov	cx,50
 rep	stosw
 pop	di
 mov	cl,7			;Anzahl der Optionen
 rep	movsb
 lea	si,Spieler1_NamenslÑnge
 mov	cl,3
 rep	movsw
 lea	si,Spieler1		;Spielernamen einlesen
 mov	cl,18
 rep	movsb
 lea	si,Spieler2
 mov	cl,18
 rep	movsb
 lea	si,Spieler3
 mov	cl,18
 rep	movsb
 pop	bx			;Datei schreiben
 mov	cx,100
 mov	ah,40h
 lea	dx,Temp
 int	21h 
 mov	ah,3Eh			;Datei schlie·en
 int	21h
Optionen_speichern_2:
 popa
 ret

;<<<Info>>>
;Zeigt das Infofenster an
;Ein: -
;Aus: -
Info:
 call	Bildschirm_lîschen
 mov	ah,2
 mov	dx,617h
 xor	bx,bx
 int	10h
 lea	dx,Info0
Info_2:
 push	dx
 mov	ah,3			;Cursor eine Zeile runter setzen
 int	10h
 dec	ah
 inc	dh
 mov	dl,17h
 int	10h
 pop	dx
 mov	ah,9			;Optionenstring ausgeben
 int	21h
 add	dx,36
 cmp	dx,Offset Info9+36
 jnz	Info_2
 xor	ax,ax
 int	16h
 jmp	MenÅ

;<<<Rochade>>>
;PrÅft, ob eine Rochade durchgefÅhrt wurde
;Ein: -
;Aus: ax=0, wenn wahr
Rochade:
 push	ax
 push	si
 call	Figur_dazwischen
 pop	si
 xchg	ax,bx
 pop	ax
 test	bx,bx
 jnz	Rochade_2
 cmp	si,Offset Kînigw	;Weisser Kînig ausgewÑhlt?
 jnz	Rochade_5
 cmp	[Kînigw_bewegt],0	;Kînig schon mal bewegt?
 jnz	Rochade_2
 mov	cx,ax
 lea	bx,Cursor
 call	Figur_suchen
 cmp	ax,807h			;Kurze Rochade?
 jnz	Rochade_4
 cmp	[Turm2w_bewegt],0	;Rechten Turm schon mal bewegt?
 jnz	Rochade_2
 mov	[Rochade_durchgefÅhrt],1
 call	Anderer_Spieler
 call	Zugnotation
 mov	[Kînigw],807h
 call	Figur_entfernen
 mov	[Figur_ausgewÑhlt],808h
 call	Figur_entfernen
 mov	[Turm2w],806h
 inc	[Kînigw_bewegt]
 inc	[Turm2w_bewegt]
 jmp	Rochade_3
Rochade_4:
 cmp	ax,803h			;Lange Rochade?
 jnz	Rochade_2
 cmp	[Turm1w_bewegt],0	;Linken Turm schon mal bewegt?
 jnz	Rochade_2
 mov	[Rochade_durchgefÅhrt],2
 call	Anderer_Spieler
 call	Zugnotation
 mov	[Kînigw],803h
 call	Figur_entfernen
 mov	[Figur_ausgewÑhlt],801h
 call	Figur_entfernen
 mov	[Turm1w],804h
 inc	[Kînigw_bewegt]
 inc	[Turm1w_bewegt]
 jmp	Rochade_3
Rochade_5:
 cmp	[Kînigs_bewegt],0	;Kînig schon mal bewegt?
 jnz	Rochade_2
 mov	cx,ax
 lea	bx,Cursor
 call	Figur_suchen
 cmp	ax,107h			;Kurze Rochade?
 jnz	Rochade_6
 cmp	[Turm2s_bewegt],0	;Rechten Turm schon mal bewegt?
 jnz	Rochade_2
 cmp	[Einspielermodus],0
 jnz	Rochade_3
 mov	[Rochade_durchgefÅhrt],1
 call	Anderer_Spieler
 call	Zugnotation
 mov	[Kînigs],107h
 call	Figur_entfernen
 mov	[Figur_ausgewÑhlt],108h
 call	Figur_entfernen
 mov	[Turm2s],106h
 inc	[Kînigs_bewegt]
 inc	[Turm2s_bewegt]
 jmp	Rochade_3
Rochade_6:
 cmp	ax,103h			;Lange Rochade?
 jnz	Rochade_2
 cmp	[Turm1s_bewegt],0	;Linken Turm schon mal bewegt?
 jnz	Rochade_2
 cmp	[Einspielermodus],0
 jnz	Rochade_3
 mov	[Rochade_durchgefÅhrt],2
 call	Anderer_Spieler
 call	Zugnotation
 mov	[Kînigs],103h
 call	Figur_entfernen
 mov	[Figur_ausgewÑhlt],101h
 call	Figur_entfernen
 mov	[Turm1s],104h
 inc	[Kînigs_bewegt]
 inc	[Turm1s_bewegt]
Rochade_3:
 call	Figuren_zeichnen
 mov	[Figur_ausgewÑhlt],0
 xor	ax,ax
Rochade_2:
 ret

;<<<Geschlagene_Figuren_Fenster_zeichnen>>>
;Zeichnet die Fenster fÅr die geschlagenen Figuren
;Ein: -
;Aus: -
Geschlagene_Figuren_Fenster_zeichnen:
 cmp	[Geschlagene_Figuren_anzeigen],0	;Option ausgeschalten?
 jnz	Geschlagene_Figuren_Fenster_zeichnen_2
 mov	ah,2
 mov	dx,139h
 xor	bx,bx
 int	10h
 lea	dx,Geschlagene_Figuren_Fenster0-24
Geschlagene_Figuren_Fenster_zeichnen_3:
 add	dx,24
 push	dx
 mov	ah,3			;Cursor eine Zeile runter setzen
 int	10h
 dec	ah
 mov	dl,39h
 int	10h
 pop	dx
 mov	ah,9			;String ausgeben
 int	21h
 cmp	dx,Offset Geschlagene_Figuren_Fenster5
 jnz	Geschlagene_Figuren_Fenster_zeichnen_3
 mov	ah,2
 mov	dx,1239h
 xor	bx,bx
 int	10h
 lea	dx,Geschlagene_Figuren_Fenster0-24
Geschlagene_Figuren_Fenster_zeichnen_4:
 add	dx,24
 push	dx
 mov	ah,3			;Cursor eine Zeile runter setzen
 int	10h
 dec	ah
 mov	dl,39h
 int	10h
 pop	dx
 mov	ah,9			;String ausgeben
 int	21h
 cmp	dx,Offset Geschlagene_Figuren_Fenster5
 jnz	Geschlagene_Figuren_Fenster_zeichnen_4
Geschlagene_Figuren_Fenster_zeichnen_2:
 ret

;<<<Geschlagene_Figur_in_Fenster_zeichnen>>>
;Zeichnet die geschlagene Figur in dem Fenster fÅr die geschlagenen Figuren
;Ein: -
;Aus: -
Geschlagene_Figur_in_Fenster_zeichnen:
 pusha
 cmp	[Geschlagene_Figuren_anzeigen],0	;Option eingeschalten?
 jnz	Geschlagene_Figur_in_Fenster_zeichnen_2
 call	Zeichen_lesen		;Figur lesen, die geschlagen wird
 push	ax
 cmp	si,Offset Kînigw	;Weisse Figuren?
 ja	Geschlagene_Figur_in_Fenster_zeichnen_3
 mov	ah,2
 mov	dx,[Figuren_Geschlagen_ZÑhlerw]
 xor	bx,bx
 int	10h
 pop	ax
 mov	ah,9
 mov	bl,Farbe_Weiss
 mov	cx,1
 int	10h
 inc	dx
 inc	dx
 cmp	dl,79			;Fensterende erreicht?
 jnz	Geschlagene_Figur_in_Fenster_zeichnen_4
 inc	dh
 mov	dl,3Bh
Geschlagene_Figur_in_Fenster_zeichnen_4:
 mov	[Figuren_Geschlagen_ZÑhlerw],dx
 jmp	Geschlagene_Figur_in_Fenster_zeichnen_2
Geschlagene_Figur_in_Fenster_zeichnen_3:
 mov	ah,2
 mov	dx,[Figuren_Geschlagen_ZÑhlers]
 xor	bx,bx
 int	10h
 pop	ax
 mov	ah,9
 mov	bl,Farbe_Schwarz
 mov	cx,1
 int	10h
 inc	dx
 inc	dx
 cmp	dl,79			;Fensterende erreicht?
 jnz	Geschlagene_Figur_in_Fenster_zeichnen_5
 inc	dh
 mov	dl,3Bh
Geschlagene_Figur_in_Fenster_zeichnen_5:
 mov	[Figuren_Geschlagen_ZÑhlers],dx
Geschlagene_Figur_in_Fenster_zeichnen_2:
 popa
 ret

;<<<Zugnotation_Fenster_zeichnen>>>
;Zeigt das Zugnotationsfenster an
;Ein: -
;Aus: -
Zugnotation_Fenster_zeichnen:
 pusha
 cmp	[Zugnotation_anzeigen],0	;Option ausgeschalten?
 jnz	Zugnotation_Fenster_zeichnen_4
 mov	ah,2			;Fenster ausgeben
 mov	dx,300h
 xor	bx,bx
 int	10h
 lea	dx,Zugnotation_Fenster0-21
 mov	cx,13
Zugnotation_Fenster_zeichnen_2:
 add	dx,21
Zugnotation_Fenster_zeichnen_3:
 push	cx
 push	dx
 mov	ah,3			;Cursor eine Zeile runter setzen
 int	10h
 dec	ah
 inc	dh
 xor	dl,dl
 int	10h
 pop	dx
 pop	cx
 mov	ah,9			;String ausgeben
 int	21h
 cmp	dx,Offset Zugnotation_Fenster3
 jnz	Zugnotation_Fenster_zeichnen_2
 loop	Zugnotation_Fenster_zeichnen_3
 mov	ah,3
 int	10h
 dec	ah
 inc	dh
 xor	dl,dl
 int	10h
 mov	ah,9
 lea	dx,Zugnotation_Fenster4
 int	21h
Zugnotation_Fenster_zeichnen_4:
 popa
 ret

;<<<Zugnotation>>>
;Zeigt die Zugnotation in einem Fenster an
;Ein: -
;Aus: -
Zugnotation:
 pusha
 cmp	[Zugnotation_anzeigen],0	;Option ausgeschalten?
 jnz	Zugnotation_2
 cmp	[Am_Zug],0		;Schwarz am Zug?
 jz	Zugnotation_7
 call	Zug_notieren
 jmp	Zugnotation_2
Zugnotation_7:
 inc	[Zug]			;ZÑhler erhîhen
 lea	di,Notation_String
 push	di
 mov	ax,[Zug]		;ZÑhler in eine Dezimalzahl umwandeln
 mov	cx,3
 add	di,2
 mov	word ptr[di+1],' .'
 mov	bx,10
Zugnotation_3:
 xor	dx,dx
 div	bx
 add	dl,'0'
 mov	byte ptr [di],dl
 dec	di
 loop	Zugnotation_3
 mov	ah,2
 lea	di,Notation_Cursor
 mov	dx,[di]
 int	10h
 cmp	dh,20			;Ende des Notationsfensters erreicht?
 jz	Zugnotation_5
 inc	dh
 mov	[di],dx
 jmp	Zugnotation_6
Zugnotation_5:			;Bildschirmausschnitt aufwÑrts scrollen
 mov	ax,601h
 mov	bh,7
 mov	cx,702h
 mov	dx,130Ah
 int	10h
 mov	ah,2
 mov	dx,1302h
 xor	bx,bx
 int	10h
Zugnotation_6:
 call	Zug_notieren
 mov	[Notation_Cursor2],5
 lea	bx,Notation_String-1	;Nullen am Anfang nicht mit ausgeben
Zugnotation_4:
 inc	bx
 cmp	byte ptr[bx],'0'
 jnz	Zugnotation_8
 mov	byte ptr[bx],' '
 jmp	Zugnotation_4
Zugnotation_8:
 lea	dx,Notation_String
 mov	ah,9
 int	21h
 pop	di
 mov	al,' '			;Notationsstring lîschen
 mov	cx,16
 rep	stosb
Zugnotation_2:
 popa
 ret

;<<<Zug_notieren>>>
;Speichert den aktuellen Zug im Notationsstring
;Ein: -
;Aus: -
Zug_notieren:
 pusha
 mov	al,[Rochade_durchgefÅhrt]
 cmp	al,1
 jnz	Zug_notieren_2
 call	Zug_notieren_kurze_Rochade
 jmp	Zug_notieren_3
Zug_notieren_2:
 cmp	al,2
 jnz	Zug_notieren_4
 call	Zug_notieren_lange_Rochade
 jmp	Zug_notieren_3
Zug_notieren_4:
 mov	bl,[Notation_Cursor2]
 xor	bh,bh
 add	bx,Offset Notation_String
 mov	al,byte ptr[Figur_ausgewÑhlt]
 add	al,'A'-1
 mov	[bx],al
 inc	bx
 mov	al,'9'
 sub	al,byte ptr[Figur_ausgewÑhlt+1]
 mov	[bx],al
 inc	bx
 mov	byte ptr[bx],'-'
 inc	bx
 mov	al,[Cursor]
 add	al,'A'-1
 mov	[bx],al
 inc	bx
 mov	al,'9'
 sub	al,[Cursor+1]
 mov	[bx],al
 inc	bx
 inc	bx
 sub	bx,Offset Notation_String
 mov	[Notation_Cursor2],bl
Zug_notieren_3:
 mov	[Rochade_durchgefÅhrt],0
 popa
 ret

;<<<Zug_notieren_kurze_Rochade>>>
;Speichert die kurze Rochade im Notationsstring
;Ein: -
;Aus: -
Zug_notieren_kurze_Rochade:
 mov	bl,[Notation_Cursor2]
 xor	bh,bh
 add	bx,Offset Notation_String
 mov	byte ptr[bx],'0'
 inc	bx
 mov	byte ptr[bx],'-'
 inc	bx
 mov	byte ptr[bx],'0'
 add	bx,4
 sub	bx,Offset Notation_String
 mov	[Notation_Cursor2],bl
 ret

;<<<Zug_notieren_lange_Rochade>>>
;Speichert die lange Rochade im Notationsstring
;Ein: -
;Aus: -
Zug_notieren_lange_Rochade:
 mov	bl,[Notation_Cursor2]
 xor	bh,bh
 add	bx,Offset Notation_String
 mov	byte ptr[bx],'0'
 inc	bx
 mov	byte ptr[bx],'-'
 inc	bx
 mov	byte ptr[bx],'0'
 inc	bx
 mov	byte ptr[bx],'-'
 inc	bx
 mov	byte ptr[bx],'0'
 inc	bx
 inc	bx
 sub	bx,Offset Notation_String
 mov	[Notation_Cursor2],bl
 ret

;<<<Schachuhr_zeichnen>>>
;Zeigt die Schachuhren an
;Ein: -
;Aus: -
Schachuhr_zeichnen:
 pusha
 cmp	[Schachuhr_anzeigen],0	;Option ausgeschalten?
 jnz	Schachuhr_zeichnen_4
 mov	ah,2			;Fenster ausgeben
 xor	dx,dx
 xor	bx,bx
 int	10h
 mov	cx,2
Schachuhr_zeichnen_5:
 push	cx
 lea	dx,Schachuhr0-13
Schachuhr_zeichnen_2:
 add	dx,13
 push	dx
 mov	ah,3			;Cursor eine Zeile runter setzen
 int	10h
 dec	ah
 inc	dh
 xor	dl,dl
 int	10h
 pop	dx
 mov	ah,9			;String ausgeben
 int	21h
 cmp	dx,Offset Schachuhr2
 jnz	Schachuhr_zeichnen_2
 mov	ah,2			;Zweite Schachuhr anzeigen
 mov	dx,1400h
 xor	bx,bx
 int	10h
 pop	cx
 loop	Schachuhr_zeichnen_5
Schachuhr_zeichnen_4:
 popa
 ret

;<<<Schachuhr_Zeit_zeichnen>>>
;Zeigt die Zeit in den Schachuhren an
;Ein: -
;Aus: -
Schachuhr_Zeit_zeichnen:
 pusha
 cmp	[Schachuhr_anzeigen],0	;Option ausgeschalten?
 jnz	Schachuhr_Zeit_zeichnen_2
 mov	ah,2			;Uhrzeit lesen
 int	1Ah
 and	dh,1111b		;Oberes Zeichen der Sekunden lîschen
 cmp	dh,[Letzte_Sekunde]	;Eine Sekunde verstrichen?
 jz	Schachuhr_Zeit_zeichnen_2
 mov	[Letzte_Sekunde],dh
 jmp	Schachuhr_Zeit_zeichnen_5
Schachuhr_Zeit_zeichnen_6:
 pusha
Schachuhr_Zeit_zeichnen_5:
 cmp	[Am_Zug],0		;Weiss am Zug?
 jz	Schachuhr_Zeit_zeichnen_3
 inc	[Spieler1_Uhr]
 mov	ah,2
 mov	dx,202h
 xor	bx,bx
 int	10h
 mov	ax,[Spieler1_Uhr]
 jmp	Schachuhr_Zeit_zeichnen_4
Schachuhr_Zeit_zeichnen_3:
 inc	[Spieler2_Uhr]
 mov	ah,2
 mov	dx,1602h
 xor	bx,bx
 int	10h
 mov	ax,[Spieler2_Uhr]
Schachuhr_Zeit_zeichnen_4:
 mov	bx,60			;Die einzelnen Zeiteinheiten aus dem ZÑhler extrahieren
 xor	dx,dx
 div	bx
 push	dx
 xor	dx,dx
 div	bx
 push	dx
 xor	dx,dx
 div	bx
 xchg	ax,dx
 lea	di,Temp
 call	Dez_zu_char
 add	di,3
 pop	ax
 call	Dez_zu_char
 add	di,3
 pop	ax
 call	Dez_zu_char
 mov	byte ptr[Temp+8],'$'
 mov	ah,9
 lea	dx,Temp
 int	21h
Schachuhr_Zeit_zeichnen_2:
 popa
 ret

;<<<Dez_zu_Char>>>
;Wandelt eine 16 Bit Zahl in eine Asciidezimalzahl um
;Ein: ax=Zahl, di=Zeiger auf Puffer
;Aus: -
Dez_zu_Char:
 pusha
 mov	cx,2
 inc	di
 mov	word ptr[di+1],' :'	;FÅr die Stopuhr
 mov	bx,10
Dez_zu_Char_2:
 xor	dx,dx
 div	bx
 add	dl,'0'
 mov	byte ptr [di],dl
 dec	di
 loop	Dez_zu_Char_2
 popa
 ret

;<<<Spieler_Name_einlesen>>>
;Fragt den Namen des Spielers ab
;Ein: -
;Aus: -
Spieler_Name_einlesen:
 pusha
 call	Cursor_an
 call	Bildschirm_lîschen
 mov	ah,2			;Fenster fÅr Namenseingabe ausgeben
 mov	dx,919h
 xor	bx,bx
 int	10h
 lea	dx,Spielername1
Spieler_Name_einlesen_2:
 push	dx
 mov	ah,3			;Cursor eine Zeile tiefer
 int	10h
 dec	ah
 mov	dl,19h
 inc	dh
 int	10h
 pop	dx
 mov	ah,9			;Fensterstring ausgeben
 int	21h
 add	dx,32
 cmp	dx,Offset Spielername3+32
 jnz	Spieler_Name_einlesen_2
 mov	ah,3			;Cursor eine Zeile tiefer
 int	10h
 dec	ah
 mov	dl,19h
 inc	dh
 int	10h
 mov	ah,9			;Fensterstring ausgeben
 lea	dx,Spielername7
 int	21h
 mov	ah,3			;Cursor eine Zeile tiefer
 int	10h
 dec	ah
 mov	dl,19h
 inc	dh
 int	10h
 mov	ah,9			;Fensterstring ausgeben
 lea	dx,Spielername6
 int	21h
 mov	ah,2			;Cursor auf erstes Eingabefeld setzen
 mov	dx,0D25h
 int	10h
 lea	dx,Spieler3		;Alten Namen ausgeben
 mov	ah,9
 int	21h
 mov	ah,2			;Cursor auf erstes Eingabefeld setzen
 mov	dx,0D25h
 int	10h
 lea	di,Spieler3
 mov	si,17
 mov	ax,[Spieler3_NamenslÑnge]
 mov	word ptr[Cursor],ax
 call	String_einlesen
 sub	di,Offset Spieler3	;StringlÑnge sichern
 mov	[Spieler3_NamenslÑnge],di
 cmp	ah,1			;Die Namenseingabe wurde abgebrochen?
 jz	MenÅ
 call	Cursor_aus
 popa
 ret

;<<<Zeichenhintergrund_setzen>>>
;Setzt den Hintergrund einer bestimmten Anzahl von Zeichen auf eine Farbe
;Ein: bx=Speicherstelle, an der die Zeile steht, al=Farbe
;Aus: -
Zeichenhintergrund_setzen:
 push	es
 push	0B800h
 pop	es
 push	ax
 mov	al,[bx]
 xor	ah,ah
 mov	bx,160
 mul	bx
 add	ax,65
 mov	di,ax
 mov	cx,18
 pop	ax
 xor	ah,ah
Zeichenhintergrund_setzen_2:
 stosb
 inc	di
 loop	Zeichenhintergrund_setzen_2
 pop	es
 ret

;<<<Zeichenhintergrund_setzen2>>>
;Setzt den Hintergrund einer bestimmten Anzahl von Zeichen auf eine Farbe
;Ein: bx=Speicherstelle, an der die Zeile steht, al=Farbe
;Aus: -
Zeichenhintergrund_setzen2:
 push	es
 push	0B800h
 pop	es
 push	ax
 mov	al,[bx]
 xor	ah,ah
 mov	bx,160
 mul	bx
 add	ax,45
 mov	di,ax
 mov	cx,34
 pop	ax
 xor	ah,ah
Zeichenhintergrund_setzen2_2:
 stosb
 inc	di
 loop	Zeichenhintergrund_setzen2_2
 pop	es
 ret

;<<<Zeichenhintergrund_setzen3>>>
;Setzt den Hintergrund einer bestimmten Anzahl von Zeichen auf eine Farbe
;Ein: bx=Speicherstelle, an der die Zeile steht, al=Farbe
;Aus: -
Zeichenhintergrund_setzen3:
 push	es
 push	0B800h
 pop	es
 push	ax
 mov	al,[bx]
 xor	ah,ah
 mov	bx,160
 mul	bx
 add	ax,67
 mov	di,ax
 mov	cx,13
 pop	ax
 xor	ah,ah
Zeichenhintergrund_setzen3_2:
 stosb
 inc	di
 loop	Zeichenhintergrund_setzen3_2
 pop	es
 ret

;<<<Bauernumwandlung>>>
;PrÅft, ob eine Bauernumwandlung stattgefunden hat
;Ein: -
;Aus: -
Bauernumwandlung:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 cmp	si,Offset Kînigw	;Weisse Figuren?
 ja	Bauernumwandlung_2
 cmp	[Cursor+1],1		;Bauernumwandlung?
 jnz	Bauernumwandlung_4
 mov	ax,[si]
 mov	word ptr[si],0
 lea	bx,LÑufer2w		;NÑchste freie Dame suchen
Bauernumwandlung_3:
 inc	bx
 inc	bx
 cmp	byte ptr[bx],0
 jnz	Bauernumwandlung_3
 mov	[bx],ax
Bauernumwandlung_4:
 ret
Bauernumwandlung_2:
 cmp	[Cursor+1],8		;Bauernumwandlung?
 jnz	Bauernumwandlung_4
 mov	ax,[si]
 mov	word ptr[si],0
 lea	bx,LÑufer2s		;NÑchste freie Dame suchen
Bauernumwandlung_5:
 inc	bx
 inc	bx
 cmp	byte ptr[bx],0
 jnz	Bauernumwandlung_5
 mov	[bx],ax
 ret

;<<<Figur_weiss>>>
;PrÅft, ob eine Figur weiss ist
;Ein: bx=Speicherstelle der Koordinaten
;Aus: ax=0 wenn wahr
Figur_weiss:
 push	si
 call	Figur_suchen
 xor	ax,ax
 cmp	si,Offset Kînigw
 jna	Figur_weiss_2
 inc	ax
Figur_weiss_2:
 pop	si
 ret

;<<<Regeln>>>
;Gibt die Regeln auf dem Bildschirm aus (mit Scroller)
;Ein: -
;Aus: -
Regeln:
 lea	di,Regeltext+1
 mov	bp,di
Regeln_2:
 call	Bildschirm_lîschen
 mov	cx,24			;24 Zeilen ausgeben
Regeln_5:
 push	cx
Regeln_6:
 xor	ax,ax
 scasb
 jc	Regeln_7
 call	Cursor_Zeile_Umbruch
 pop	cx
 jmp	Regeln_8
Regeln_7:
 mov	al,[di-1]
 mov	ah,9
 mov	bx,7
 mov	cx,1
 int	10h
 call	Cursor_weiter
 jmp	Regeln_6
Regeln_8:
 loop	Regeln_5
Regeln_2_2:
 xor	ax,ax			;Auf Tastendruck warten
 int	16h
 cmp	ah,50h			;nach unten?
 jnz	Regeln_3
 xor	ax,ax
 mov	di,bp
 mov	cx,80
 repnz	scasb
 cmp	di,Offset Textende	;unten angekommen?
 jz	Regeln_2_2
 mov	bp,di
 jmp	Regeln_2
Regeln_3:
 cmp	ah,48h			;nach oben?
 jnz	Regeln_4
 xor	ax,ax
 mov	di,bp
 cmp	di,Offset Regeltext+1	;oben angekommen?
 jz	Regeln_2_2
 dec	di
 dec	di
 mov	cx,80
 std
 repnz	scasb
 inc	di
 inc	di
 cld
 mov	bp,di
 jmp	Regeln_2
Regeln_4:
 cmp	ah,1			;ESC gedrÅckt?
 jnz	Regeln_2_2
 jmp	MenÅ

;<<<Bemerkungen_Fenster_zeichnen>>>
;Zeigt das Fenster fÅr Bemerkungen an
;Ein: -
;Aus: -
Bemerkungen_Fenster_zeichnen:
 pusha
 cmp	[Bemerkungen_anzeigen],0	;Option ausgeschalten?
 jnz	Bemerkungen_Fenster_Fenster_zeichnen_2
 mov	ah,2
 mov	dx,739h
 xor	bx,bx
 int	10h
 lea	dx,Geschlagene_Figuren_Fenster0
 mov	ah,9
 int	21h
 lea	dx,Geschlagene_Figuren_Fenster3
 pusha
 mov	ah,3
 int	10h
 dec	ah
 mov	dl,39h
 int	10h
 popa
 mov	ah,9
 int	21h
 mov	ah,3
 int	10h
 dec	ah
 mov	dl,39h
 int	10h
 mov	ah,9
 lea	dx,Geschlagene_Figuren_Fenster5
 int	21h
Bemerkungen_Fenster_Fenster_zeichnen_2:
 popa
 ret

;<<<Spielende>>>
;Zeigt das Spielergebnis an und kehrt zum HauptmenÅ zurÅck
;Ein: -
;Aus: -
Spielende:
 call	Figuren_zeichnen	;Damit der Cursor Åbermalt wird
 mov	ah,2
 mov	dx,0A1Eh
 xor	bx,bx
 int	10h
 lea	si,Spielende_Fenster0
Spielende_2:
 mov	ah,3			;Cursor eine Zeile runter setzen
 int	10h
 dec	ah
 inc	dh
 mov	dl,1Eh
 int	10h
Spielende_3:
 mov	ah,9
 lodsb
 cmp	al,'$'			;Stringende?
 jz	Spielende_4
 mov	ah,9
 mov	bx,4
 mov	cx,1
 int	10h
 call	Cursor_weiter
 jmp	Spielende_3
Spielende_4:
 cmp	si,Offset Spielende_Fenster2+21
 jnz	Spielende_2
 mov	ah,2
 mov	dx,0C28h
 xor	bx,bx
 int	10h
 lea	si,Spielende_gewonnen	
 cmp	[Spielausgang],0	;Spiel wurde gewonnen?
 jz	Spielende_5
 lea	si,Spielende_verloren
Spielende_5:
 lodsb				;Wird nicht Åber Int 21 wegen Farbe ausgegeben
 cmp	al,'$'			;Stringende?
 jz	Spielende_6
 mov	ah,9
 mov	bx,4
 mov	cx,1
 int	10h
 call	Cursor_weiter
 jmp	Spielende_5
Spielende_6:
 xor	ax,ax
 int	16h
 jmp	MenÅ

;<<<Bemerkung_zeichnen>>>
;Zeichnet eine Bemerkung in das Bemerkungsfenster
;Ein: dx=Offset des Bemerkungsstrings
;Aus: -
Bemerkung_zeichnen:
 pusha
 cmp	[Bemerkungen_anzeigen],0
 jnz	Bemerkung_zeichnen_2
 mov	ah,2			;Alten Fensterinhalt lîschen
 mov	dx,83Bh
 xor	bx,bx
 int	10h
 mov	ah,9
 lea	dx,Bemerkung_leer
 int	21h
 mov	ah,2
 mov	dx,83Bh
 xor	bx,bx
 int	10h
 popa
 pusha
 mov	ah,9			;String ausgeben
 int	21h
Bemerkung_zeichnen_2:
 popa
 ret

;<<<Zufallszahl>>>
;Liefert eine Zufallszahl in einem bestimmten Wertebereich zurÅck
;Ein: bl=Grî·tmîgliche Zahl
;Aus: al=Zufallszahl von 0 bis bl
Zufallszahl:
 push	cx
 push	dx
 xor	ax,ax			;Clockticks lesen
 int	1Ah
 xchg	ax,dx
 xor	bh,bh
Zufallszahl_4:
 cmp	ax,bx			;Zufallszahl Åberschreitet Wertebereich?
 jna	Zufallszahl_3
 sub	ax,bx
 jmp	Zufallszahl_4
Zufallszahl_3:
 pop	dx
 pop	cx
 ret

;<<<Zufallszahl2>>>
;Liefert eine Zufallszahl fÅr ZufallszÅge zurÅck (bugbedingt)
;Ein: bl=Grî·tmîgliche Zahl
;Aus: al=Zufallszahl von 0 bis bl
Zufallszahl2:
 call	Zufallszahl
 test	ax,ax			;Wert korrigieren
 jz	Zufallszahl2_2
 dec	ax
Zufallszahl2_2:
 ret

;<<<Bemerkung_Schlagen>>>
;Zeigt eine Bemerkung beim Schlagen der Figur des Spielers an
;Ein: -
;Aus: -
Bemerkung_Schlagen:
 pusha
 mov	bl,7
 call	Zufallszahl
 lea	dx,Bemerkung6
 test	al,al
 jz	Bemerkung_Schlagen_2
 lea	dx,Bemerkung7
 dec	ax
 jz	Bemerkung_Schlagen_2
 lea	dx,Bemerkung8
 dec	ax
 jz	Bemerkung_Schlagen_2
 lea	dx,Bemerkung9
 dec	ax
 jz	Bemerkung_Schlagen_2
 lea	dx,Bemerkung10
 dec	ax
 jz	Bemerkung_Schlagen_2
 lea	dx,Bemerkung11
 dec	ax
 jz	Bemerkung_Schlagen_2
 lea	dx,Bemerkung12
 dec	ax
 jz	Bemerkung_Schlagen_2
 lea	dx,Bemerkung13
Bemerkung_Schlagen_2:
 call	Bemerkung_zeichnen
 popa
 ret

;<<<Figurenwert>>>
;Berechnet den Wert einer Figur
;Ein: si=Zeiger auf die Figur
;Aus: ax=Figurwert
Figurenwert:
 push	bp
 push	[Figur_ausgewÑhlt]
 mov	ax,[si]
 mov	[Figur_ausgewÑhlt],ax
 xor	bp,bp
 call	Figur_Bauer
 test	ax,ax
 jz	Figurenwert_2
 inc	bp
 call	Figur_Springer
 test	ax,ax
 jz	Figurenwert_2
 inc	bp
 call	Figur_LÑufer
 test	ax,ax
 jz	Figurenwert_2
 inc	bp
 call	Figur_Turm
 test	ax,ax
 jz	Figurenwert_2
 inc	bp			;Dann muss es eine Dame sein
Figurenwert_2:
 pop	[Figur_ausgewÑhlt]
 mov	ax,bp
 pop	bp
 ret

