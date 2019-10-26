;<<<Ein Spieler Modus>>>
Ein_Spieler:
 call	Spieler_Name_einlesen
; call	Farbe_wÑhlen		;îî
 call	Figuren_zurÅcksetzen
 call	Schachbrett_zeichnen
 call	Figuren_zeichnen
 call	Geschlagene_Figuren_Fenster_zeichnen
 call	Zugnotation_Fenster_zeichnen
 call	Schachuhr_zeichnen
 call	Bemerkungen_Fenster_zeichnen
 mov	[Figur_ausgewÑhlt],0
 mov	[Spielausgang],0
 mov	[Am_Zug],0		;Weiss fÑngt an
 mov	[Einspielermodus],1
 call	Spieler_Namen_ausgeben
 mov	ax,804h			;Cursor setzen (unten Mitte)
 mov	word ptr[Cursor],ax
 mov	word ptr[Cursoralt],ax
Ein_Spieler_2:
 mov	sp,Stackgrî·e
 call	Cursor_Zeichnen
Ein_Spieler_2_2:
 call	Schachuhr_Zeit_zeichnen
 mov	al,[Farbe_AusgewÑhlt]	;Ist Computer am Zug?
 cmp	al,[Am_Zug]
 jz	Ein_Spieler_42
 jmp	Computer_ziehen
Ein_Spieler_42:
 mov	ah,1			;Auf Tastendruck warten
 int	16h
 jz	Ein_Spieler_2_2
 xor	ax,ax
 int	16h
 cmp	ah,50h			;Nach unten?
 jnz	Ein_Spieler_4
 mov	al,[Cursor+1]
 cmp	al,8			;Unten angekommen?
 jnz	Ein_Spieler_3
 xor	ax,ax
Ein_Spieler_3:
 inc	ax
 mov	[Cursor+1],al
 jmp	Ein_Spieler_2
Ein_Spieler_4:
 cmp	ah,48h			;Nach oben?
 jnz	Ein_Spieler_6
 mov	al,[Cursor+1]
 cmp	al,1			;Oben angekommen?
 jnz	Ein_Spieler_5
 mov	al,9
Ein_Spieler_5:
 dec	ax
 mov	[Cursor+1],al
 jmp	Ein_Spieler_2
Ein_Spieler_6:
 cmp	ah,1			;ESC?
 jnz	Ein_Spieler_7
 mov	[Spielausgang],1	;Spiel abbrechen und damit verloren
 mov	bl,4
 call	Zufallszahl
 lea	dx,Bemerkung2
 test	al,al
 jz	Ein_Spieler_43
 lea	dx,Bemerkung3
 dec	ax
 jz	Ein_Spieler_43
 lea	dx,Bemerkung4
 dec	ax
 jz	Ein_Spieler_43
 lea	dx,Bemerkung5
Ein_Spieler_43:
 call	Bemerkung_zeichnen
 jmp	Spielende
Ein_Spieler_7:
 cmp	ah,4Dh			;Nach rechts?
 jnz	Ein_Spieler_9
 mov	al,[Cursor]
 cmp	al,8			;Rechts angekommen?
 jnz	Ein_Spieler_8
 xor	ax,ax
Ein_Spieler_8:
 inc	ax
 mov	[Cursor],al
 jmp	Ein_Spieler_2
Ein_Spieler_9:
 cmp	ah,4Bh			;Nach links?
 jnz	Ein_Spieler_11
 mov	al,[Cursor]
 cmp	al,1			;Links angekommen?
 jnz	Ein_Spieler_10
 mov	al,9
Ein_Spieler_10:
 dec	ax
 mov	[Cursor],al
 jmp	Ein_Spieler_2
Ein_Spieler_11:
 cmp	ah,1			;ESC?
 jnz	Ein_Spieler_12
 jmp	MenÅ			;Zum HauptmenÅ
Ein_Spieler_12:
 cmp	ah,1Ch			;Enter?
 jz	Ein_Spieler_36
 cmp	ah,39h			;Leertaste?
 jnz	Ein_Spieler_2_2
Ein_Spieler_36:
 cmp	byte ptr[Figur_ausgewÑhlt],0	;Schon eine Figur ausgewÑhlt?
 jz	Ein_Spieler_15
 mov	ax,word ptr[Cursor]
 cmp	ax,[Figur_ausgewÑhlt]	;ausgewÑhlte Figur ist an Cursorposition?
 jnz	Ein_Spieler_16
 call	Figuren_Zeichnen	;Keine Figur auswÑhlen
 mov	[Figur_ausgewÑhlt],0
 jmp	Ein_Spieler_2
Ein_Spieler_16:
 lea	bx,Cursor
 call	Figur_suchen
 cmp	si,Offset Cursor	;Position nicht besetzt?
 jz	Ein_Spieler_21
 call	Figur_schlagen
 jmp	Ein_Spieler_2_2
Ein_Spieler_34:
 push	si
 call	Rochade			;Auf Rochade testen
 pop	si
 test	ax,ax
 jnz	Ein_Spieler_35
 jmp	Ein_Spieler_2
Ein_Spieler_21:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen		;Auf korrekten Zug prÅfen,Figur an alter Position lîschen
 cmp	si,Offset Kînigw	;Wenn Kînig ausgewÑhlt, dann RochadenprÅfung
 jz	Ein_Spieler_34
 cmp	si,Offset Kînigs
 jz	Ein_Spieler_34
Ein_Spieler_35:
 cmp	si,Offset Kînigw	;Weisse Figuren?
 ja	Ein_Spieler_19
 cmp	si,Offset Bauer8w	;Bauer ausgewÑhlt?
 ja	Ein_Spieler_22
 dec	bh
 cmp	bx,word ptr[Cursor]	;1 Zeichen weiter rÅcken?
 jnz	Ein_Spieler_37
 call	Bauernumwandlung
 jmp	Ein_Spieler_20
Ein_Spieler_37:
 dec	bh
 cmp	bx,word ptr[Cursor]	;2 Zeichen weiter rÅcken?
 jnz	Ein_Spieler_2_2
 cmp	bh,5			;An Startposition?
 jnz	Ein_Spieler_2_2
 call	Figur_dazwischen
 test	ax,ax
 jnz	Ein_Spieler_2_2
 jmp	Ein_Spieler_20
Ein_Spieler_19:
 cmp	si,Offset Bauer8s	;Bauer ausgewÑhlt?
 ja	Ein_Spieler_22
 inc	bh
 cmp	bx,word ptr[Cursor]	;1 Zeichen weiter rÅcken?
 jnz	Ein_Spieler_41
 call	Bauernumwandlung
 jmp	Ein_Spieler_20
Ein_Spieler_41:
 inc	bh
 cmp	bx,word ptr[Cursor]	;2 Zeichen weiter rÅcken?
 jnz	Ein_Spieler_2_2
 cmp	bh,4			;An Startposition?
 jnz	Ein_Spieler_2_2
 call	Figur_dazwischen
 test	ax,ax
 jnz	Ein_Spieler_2_2
Ein_Spieler_20:			;Figur rÅcken
 call	Anderer_Spieler
 call	Zugnotation
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 xchg	al,ah
 call	Position_umrechnen
 mov	ah,2
 xor	bx,bx
 int	10h
 xor	bx,bx
 mov	ax,920h
 mov	cx,1
 int	10h
 mov	ax,word ptr[Cursor]	;Neue Figurposition speichern
 mov	[si],ax
 call	Figuren_Zeichnen
 mov	[Figur_ausgewÑhlt],0	;Keine Figur auswÑhlen
 jmp	Ein_Spieler_2
Ein_Spieler_15:
 lea	bx,Cursor		;Suchen, ob eine Figur am aktueller Cursor steht
 call	Figur_suchen
 cmp	si,Offset Cursor	;Steht eine Figur da?
 jz	Ein_Spieler_14
 cmp	si,Offset Kînigw	;Weisse Figuren?
 ja	Ein_Spieler_28
 cmp	[Am_Zug],0		;Weiss am Zug?
 jnz	Ein_Spieler_2_2
 jmp	Ein_Spieler_29
Ein_Spieler_28:
 cmp	[Am_Zug],1		;Schwarz am Zug?
 jnz	Ein_Spieler_2_2
Ein_Spieler_29:
 mov	[Figur_ausgewÑhlt],ax	;Flag,das Figur ausgewÑhlt wurde
 call	Zeichen_lesen
 mov	bl,ah
 mov	bl,4			;Rote Farbe setzen
 mov	ah,9
 mov	cx,1
 int	10h
Ein_Spieler_14:
 jmp	Ein_Spieler_2
Ein_Spieler_22:
 call	Figur_Turm
 test	ax,ax			;Ist ausgewÑhlte Figur ein Turm?
 jnz	Ein_Spieler_23
 call	Figur_gerade_ziehen
 test	ax,ax
 jnz	Ein_Spieler_2_2
 call	Figur_dazwischen
 test	ax,ax			;Figur dazwischen?
 jnz	Ein_Spieler_2_2
 lea	bx,Figur_ausgewÑhlt	;Rochadeflags setzen
 call	Figur_suchen
 cmp	si,Offset Turm1w
 jnz	Ein_Spieler_30
 mov	[Turm1w_bewegt],1
 jmp	Ein_Spieler_20
Ein_Spieler_30:
 cmp	si,Offset Turm2w
 jnz	Ein_Spieler_31
 mov	[Turm2w_bewegt],1
 jmp	Ein_Spieler_20
Ein_Spieler_31:
 cmp	si,Offset Turm1s
 jnz	Ein_Spieler_32
 mov	[Turm1s_bewegt],1
 jmp	Ein_Spieler_20
Ein_Spieler_32:
 mov	[Turm2s_bewegt],1
 jmp	Ein_Spieler_20
Ein_Spieler_23:
 call	Figur_Dame
 test	ax,ax			;Ist ausgewÑhlte Figur eine Dame?
 jnz	Ein_Spieler_24
 call	Figur_gerade_ziehen
 test	ax,ax
 jz	Ein_Spieler_25
 call	Figur_schrÑg_ziehen
 test	ax,ax
 jnz	Ein_Spieler_2_2
Ein_Spieler_25:
 call	Figur_dazwischen	;Figur dazwischen?
 test	ax,ax
 jnz	Ein_Spieler_2_2
 jmp	Ein_Spieler_20
Ein_Spieler_24:
 call	Figur_LÑufer		;Ist ausgewÑhlte Figur ein LÑufer?
 test	ax,ax
 jnz	Ein_Spieler_26
 call	Figur_schrÑg_ziehen	;SchrÑg ziehen?
 test	ax,ax
 jnz	Ein_Spieler_2_2
 call	Figur_dazwischen
 test	ax,ax			;Figur dazwischen?
 jnz	Ein_Spieler_2_2
 jmp	Ein_Spieler_20
Ein_Spieler_26:
 call	Figur_Kînig
 test	ax,ax
 jnz	Ein_Spieler_27		;Dann kann es nur noch der Springer sein
 call	Figur_Feld_weiter
 test	ax,ax
 jnz	Ein_Spieler_2_2
 cmp	si,Offset Kînigw	;Rochadeflags setzen
 jnz	Ein_Spieler_33
 mov	[Kînigw_bewegt],1
 jmp	Ein_Spieler_20
Ein_Spieler_33:
 mov	[Kînigs_bewegt],1
 jmp	Ein_Spieler_20
Ein_Spieler_27:
 call	Figur_Ecksprung
 test	ax,ax
 jnz	Ein_Spieler_2_2
 jmp	Ein_Spieler_20

;<<<Zwei Spieler Modus>>>
Zwei_Spieler:
 call	Spieler_Namen_einlesen
 call	Figuren_zurÅcksetzen
 call	Schachbrett_zeichnen
 call	Figuren_zeichnen
 call	Geschlagene_Figuren_Fenster_zeichnen
 call	Zugnotation_Fenster_zeichnen
 call	Schachuhr_zeichnen
 call	Bemerkungen_Fenster_zeichnen
 mov	[Figur_ausgewÑhlt],0
 mov	[Am_Zug],0		;Weiss fÑngt an
 mov	[Einspielermodus],0
 call	Spieler_Namen_ausgeben
 mov	ax,804h			;Cursor setzen (unten Mitte)
 mov	word ptr[Cursor],ax
 mov	word ptr[Cursoralt],ax
Zwei_Spieler_2:
 call	Cursor_Zeichnen
Zwei_Spieler_2_2:
 call	Schachuhr_Zeit_zeichnen
 mov	ah,1			;Auf Tastendruck warten
 int	16h
 jz	Zwei_Spieler_2_2
 xor	ax,ax
 int	16h
 cmp	ah,50h			;Nach unten?
 jnz	Zwei_Spieler_4
 mov	al,[Cursor+1]
 cmp	al,8			;Unten angekommen?
 jnz	Zwei_Spieler_3
 xor	ax,ax
Zwei_Spieler_3:
 inc	ax
 mov	[Cursor+1],al
 jmp	Zwei_Spieler_2
Zwei_Spieler_4:
 cmp	ah,48h			;Nach oben?
 jnz	Zwei_Spieler_6
 mov	al,[Cursor+1]
 cmp	al,1			;Oben angekommen?
 jnz	Zwei_Spieler_5
 mov	al,9
Zwei_Spieler_5:
 dec	ax
 mov	[Cursor+1],al
 jmp	Zwei_Spieler_2
Zwei_Spieler_6:
 cmp	ah,1			;ESC?
 jnz	Zwei_Spieler_7
 jmp	MenÅ			;Zum HauptmenÅ
Zwei_Spieler_7:
 cmp	ah,4Dh			;Nach rechts?
 jnz	Zwei_Spieler_9
 mov	al,[Cursor]
 cmp	al,8			;Rechts angekommen?
 jnz	Zwei_Spieler_8
 xor	ax,ax
Zwei_Spieler_8:
 inc	ax
 mov	[Cursor],al
 jmp	Zwei_Spieler_2
Zwei_Spieler_9:
 cmp	ah,4Bh			;Nach links?
 jnz	Zwei_Spieler_11
 mov	al,[Cursor]
 cmp	al,1			;Links angekommen?
 jnz	Zwei_Spieler_10
 mov	al,9
Zwei_Spieler_10:
 dec	ax
 mov	[Cursor],al
 jmp	Zwei_Spieler_2
Zwei_Spieler_11:
 cmp	ah,1			;ESC?
 jnz	Zwei_Spieler_12
 jmp	MenÅ			;Zum HauptmenÅ
Zwei_Spieler_12:
 cmp	ah,1Ch			;Enter?
 jz	Zwei_Spieler_36
 cmp	ah,39h			;Leertaste?
 jnz	Zwei_Spieler_2_2
Zwei_Spieler_36:
 cmp	byte ptr[Figur_ausgewÑhlt],0	;Schon eine Figur ausgewÑhlt?
 jz	Zwei_Spieler_15
 mov	ax,word ptr[Cursor]
 cmp	ax,[Figur_ausgewÑhlt]	;ausgewÑhlte Figur ist an Cursorposition?
 jnz	Zwei_Spieler_16
 call	Figuren_Zeichnen	;Keine Figur auswÑhlen
 mov	[Figur_ausgewÑhlt],0
 jmp	Zwei_Spieler_2
Zwei_Spieler_16:
 lea	bx,Cursor
 call	Figur_suchen
 cmp	si,Offset Cursor	;Position besetzt?
 jz	Zwei_Spieler_21
 call	Figur_schlagen
 jmp	Zwei_Spieler_2_2
Zwei_Spieler_34:
 push	si
 call	Rochade			;Auf Rochade testen
 pop	si
 test	ax,ax
 jnz	Zwei_Spieler_35
 jmp	Zwei_Spieler_2
Zwei_Spieler_21:
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen		;Auf korrekten Zug prÅfen,Figur an alter Position lîschen
 cmp	si,Offset Kînigw	;Wenn Kînig ausgewÑhlt, dann RochadenprÅfung
 jz	Zwei_Spieler_34
 cmp	si,Offset Kînigs
 jz	Zwei_Spieler_34
Zwei_Spieler_35:
 cmp	si,Offset Kînigw	;Weisse Figuren?
 ja	Zwei_Spieler_19
 cmp	si,Offset Bauer8w	;Bauer ausgewÑhlt?
 ja	Zwei_Spieler_22
 dec	bh
 cmp	bx,word ptr[Cursor]	;1 Zeichen weiter rÅcken?
 jnz	Zwei_Spieler_37
 call	Bauernumwandlung
 jmp	Zwei_Spieler_20
Zwei_Spieler_37:
 dec	bh
 cmp	bx,word ptr[Cursor]	;2 Zeichen weiter rÅcken?
 jnz	Zwei_Spieler_2_2
 cmp	bh,5			;An Startposition?
 jnz	Zwei_Spieler_2_2
 call	Figur_dazwischen
 test	ax,ax
 jnz	Zwei_Spieler_2_2
 jmp	Zwei_Spieler_20
Zwei_Spieler_19:
 cmp	si,Offset Bauer8s	;Bauer ausgewÑhlt?
 ja	Zwei_Spieler_22
 inc	bh
 cmp	bx,word ptr[Cursor]	;1 Zeichen weiter rÅcken?
 jnz	Zwei_Spieler_41
 call	Bauernumwandlung
 jmp	Zwei_Spieler_20
Zwei_Spieler_41:
 inc	bh
 cmp	bx,word ptr[Cursor]	;2 Zeichen weiter rÅcken?
 jnz	Zwei_Spieler_2_2
 cmp	bh,4			;An Startposition?
 jnz	Zwei_Spieler_2_2
 call	Figur_dazwischen
 test	ax,ax
 jnz	Zwei_Spieler_2_2
Zwei_Spieler_20:		;Figur rÅcken
 call	Anderer_Spieler
 call	Zugnotation
 lea	bx,Figur_ausgewÑhlt
 call	Figur_suchen
 xchg	al,ah
 call	Position_umrechnen
 mov	ah,2
 xor	bx,bx
 int	10h
 xor	bx,bx
 mov	ax,920h
 mov	cx,1
 int	10h
 mov	ax,word ptr[Cursor]	;Neue Figurposition speichern
 mov	[si],ax
 call	Figuren_Zeichnen
 mov	[Figur_ausgewÑhlt],0	;Keine Figur auswÑhlen
 call	Im_Schach_PrÅfung
;îîî
 jmp	Zwei_Spieler_2
Zwei_Spieler_15:
 lea	bx,Cursor		;Suchen, ob eine Figur am aktueller Cursor steht
 call	Figur_suchen
 cmp	si,Offset Cursor	;Steht eine Figur da?
 jz	Zwei_Spieler_14
 cmp	si,Offset Kînigw	;Weisse Figuren?
 ja	Zwei_Spieler_28
 cmp	[Am_Zug],0		;Weiss am Zug?
 jnz	Zwei_Spieler_2_2
 jmp	Zwei_Spieler_29
Zwei_Spieler_28:
 cmp	[Am_Zug],1		;Schwarz am Zug?
 jnz	Zwei_Spieler_2_2
Zwei_Spieler_29:
 mov	[Figur_ausgewÑhlt],ax	;Flag,das Figur ausgewÑhlt wurde
 call	Zeichen_lesen
 mov	bl,ah
 mov	bl,4			;Rote Farbe setzen
 mov	ah,9
 mov	cx,1
 int	10h
Zwei_Spieler_14:
 jmp	Zwei_Spieler_2
Zwei_Spieler_22:
 call	Figur_Turm
 test	ax,ax			;Ist ausgewÑhlte Figur ein Turm?
 jnz	Zwei_Spieler_23
 call	Figur_gerade_ziehen
 test	ax,ax
 jnz	Zwei_Spieler_2_2
 call	Figur_dazwischen
 test	ax,ax			;Figur dazwischen?
 jnz	Zwei_Spieler_2_2
 lea	bx,Figur_ausgewÑhlt	;Rochadeflags setzen
 call	Figur_suchen
 cmp	si,Offset Turm1w
 jnz	Zwei_Spieler_30
 mov	[Turm1w_bewegt],1
 jmp	Zwei_Spieler_20
Zwei_Spieler_30:
 cmp	si,Offset Turm2w
 jnz	Zwei_Spieler_31
 mov	[Turm2w_bewegt],1
 jmp	Zwei_Spieler_20
Zwei_Spieler_31:
 cmp	si,Offset Turm1s
 jnz	Zwei_Spieler_32
 mov	[Turm1s_bewegt],1
 jmp	Zwei_Spieler_20
Zwei_Spieler_32:
 mov	[Turm2s_bewegt],1
 jmp	Zwei_Spieler_20
Zwei_Spieler_23:
 call	Figur_Dame
 test	ax,ax			;Ist ausgewÑhlte Figur eine Dame?
 jnz	Zwei_Spieler_24
 call	Figur_gerade_ziehen
 test	ax,ax
 jz	Zwei_Spieler_25
 call	Figur_schrÑg_ziehen
 test	ax,ax
 jnz	Zwei_Spieler_2_2
Zwei_Spieler_25:
 call	Figur_dazwischen	;Figur dazwischen?
 test	ax,ax
 jnz	Zwei_Spieler_2_2
 jmp	Zwei_Spieler_20
Zwei_Spieler_24:
 call	Figur_LÑufer		;Ist ausgewÑhlte Figur ein LÑufer?
 test	ax,ax
 jnz	Zwei_Spieler_26
 call	Figur_schrÑg_ziehen	;SchrÑg ziehen?
 test	ax,ax
 jnz	Zwei_Spieler_2_2
 call	Figur_dazwischen
 test	ax,ax			;Figur dazwischen?
 jnz	Zwei_Spieler_2_2
 jmp	Zwei_Spieler_20
Zwei_Spieler_26:
 call	Figur_Kînig
 test	ax,ax
 jnz	Zwei_Spieler_27		;Dann kann es nur noch der Springer sein
; call	Figur_Feld_weiter	;îîî
; test	ax,ax
; jnz	Zwei_Spieler_2_2
 cmp	si,Offset Kînigw	;Rochadeflags setzen
 jnz	Zwei_Spieler_33
 mov	[Kînigw_bewegt],1
 jmp	Zwei_Spieler_20
Zwei_Spieler_33:
 mov	[Kînigs_bewegt],1
 jmp	Zwei_Spieler_20
Zwei_Spieler_27:
 call	Figur_Ecksprung
 test	ax,ax
 jnz	Zwei_Spieler_2_2
 jmp	Zwei_Spieler_20

