;<<<Computer_ziehen>>>
;Der Computer macht einen Zug
;Ein: -
;Aus: -
Computer_ziehen:
 pusha
 mov	[Im_Schach],0
 call	Zugliste_erstellen
 call	Schlagliste_Bauern
 call	Schachuhr_Zeit_zeichnen_6
 mov	ax,[Anzahl_mîglicher_SchlÑge]
 test	ax,ax			;Keine gegnerische Figur schlagbar?
 jz	Computer_ziehen_4
 call	Schlagliste_beste_Mîglichkeit	;îîî
 mov	cx,fs
 test	cx,cx			;GÅnstige Schlagmîglichkeit entdeckt?
 jz	Computer_ziehen_11
 mov	si,fs
 jmp	Computer_ziehen_12
Computer_ziehen_11:
 lea	si,Schlagliste
 xchg	ax,bx			;îî ZufÑllige Figur schlagen
 call	Zufallszahl2
 shl	ax,2
 add	si,ax
Computer_ziehen_12:
 lodsw
 mov	[Figur_ausgewÑhlt],ax
 lodsw
 mov	word ptr[Cursor],ax
 call	Figur_Bauer
 test	ax,ax
 jnz	Computer_ziehen_7
 call	Bauernumwandlung
Computer_ziehen_7:
 popa
 call	Bemerkung_Schlagen
 jmp	Figur_lîschen		;Figur schlagen
Computer_ziehen_4:
 mov	ax,[Anzahl_mîglicher_ZÅge]
 test	ax,ax			;Patt?
 jnz	Computer_ziehen_6
 lea	dx,Bemerkung1
 call	Bemerkung_zeichnen
 jmp	Spielende
Computer_ziehen_6:
 call	Deckungsliste_auswerten
 call	Deckungsliste_sortieren
 lea	si,Zugliste
 xchg	ax,bx			;îî ZufÑlligen Zug machen
 call	Zufallszahl2
 shl	ax,2
 add	si,ax
 lodsw
 mov	[Figur_ausgewÑhlt],ax
 lodsw
 mov	word ptr[Cursor],ax
 call	Figur_Bauer
 test	ax,ax
 jnz	Computer_ziehen_8
 call	Bauernumwandlung
Computer_ziehen_8:
 lea	bx,Cursor
 call	Figur_suchen
 cmp	si,Offset Turm1s
 jnz	Computer_ziehen_5
 mov	[Turm1s_bewegt],1
 jmp	Computer_ziehen_3
Computer_ziehen_5:
 cmp	si,Offset Turm2s
 jnz	Computer_ziehen_9
 mov	[Turm2s_bewegt],1
 jmp	Computer_ziehen_3
Computer_ziehen_9:
 cmp	si,Offset Kînigs
 jnz	Computer_ziehen_3
 mov	[Kînigs_bewegt],1
; mov	ax,[si]
; mov	bx,[Cursor]
; cmp	ax,bx
; ja	Computer_ziehen_10
; xchg	ax,bx
;Computer_ziehen_10:
; sub	ax,bx
; cmp	ax,2			;Rochade?
;îîî
Computer_ziehen_3:
 popa
 jmp	Ein_Spieler_20		;Figur rÅcken
Computer_ziehen_2:
 popa
 call	Anderer_Spieler
 jmp	Ein_Spieler_2

;<<<Stellungsbewertung>>>	:îî FÅr unterschiedliche Farben machen
;Bewertet die zentrale Stellung der Figuren
;Ein: -
;Aus: bx=Stellungspunkte
Stellungsbewertung:
 lea	si,Bauer1w
 xor	bx,bx
Stellungsbewertung_2:
 lodsw
 test	ax,ax			;Figur existiert nicht mehr?
 jz	Stellungsbewertung_3
 dec	al
 jz	Stellungsbewertung_3
 dec	ah
 jz	Stellungsbewertung_3
 dec	al
 jz	Stellungsbewertung_6
 dec	ah
 jz	Stellungsbewertung_6
 dec	al
 jz	Stellungsbewertung_5
 dec	ah
 jz	Stellungsbewertung_5
 inc	bx
 inc	bx
Stellungsbewertung_5:
 inc	bx
Stellungsbewertung_6:
 inc	bx
Stellungsbewertung_3:
 cmp	si,Offset Cursor	;Alle Figuren bewertet?
 jnz	Stellungsbewertung_2
 ret

;<<<Koordinaten_mîglich>>>
;PrÅft ob Koordinaten auf dem Schachbrett liegen
;Ein: ax=Koordinaten
;Aus: ax=0 wenn wahr
Koordinaten_mîglich:
 push	cx
 mov	cx,2
Koordinaten_mîglich_3:
 test	al,al
 jz	Koordinaten_mîglich_2
 cmp	al,8
 ja	Koordinaten_mîglich_2
 xchg	al,ah
 loop	Koordinaten_mîglich_3
 xor	ax,ax
 jmp	Koordinaten_mîglich_4
Koordinaten_mîglich_2:
 dec	ax
Koordinaten_mîglich_4:
 pop	cx
 ret

;<<<Mîgliche_ZÅge_Bauers>>>
;Erstellt eine Liste aller mîglichen ZÅge der schwarzen Bauern
;Ein: di=Zeiger auf Puffer
;Aus: -
Mîgliche_ZÅge_Bauers:
 lea	si,Bauer1s
 mov	cx,8			;8 Bauern
Mîgliche_ZÅge_Bauers_3:
 lodsw
 test	ax,ax			;Figur existiert nicht mehr?
 jz	Mîgliche_ZÅge_Bauers_2
 stosw
 inc	ah
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld vor Bauern ist nicht besetzt?
 jz	Mîgliche_ZÅge_Bauers_4
 dec	di
 dec	di
 pop	si
 jmp	Mîgliche_ZÅge_Bauers_2
Mîgliche_ZÅge_Bauers_4:
 pop	si
 stosw
 cmp	ah,3			;An Startposition?
 jnz	Mîgliche_ZÅge_Bauers_2
 inc	ah
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;zweites Feld vor Bauern ist nicht besetzt?
 jnz	Mîgliche_ZÅge_Bauers_5
 pop	si
 push	ax
 sub	ah,2
 stosw
 pop	ax
 stosw
 push	si
Mîgliche_ZÅge_Bauers_5:
 pop	si
Mîgliche_ZÅge_Bauers_2:
 loop	Mîgliche_ZÅge_Bauers_3
 ret

;<<<Mîgliche_ZÅge_gerade>>>
;Erstellt Liste aller geraden ZÅge einer Figur
;Ein: di=Puffer fÅr ZÅge,si=Zeiger auf Koordinaten der Figur
;Aus: -
Mîgliche_ZÅge_gerade:
 lodsw
 mov	bp,ax
 test	ax,ax			;Figur existiert nicht mehr?
 jz	Mîgliche_ZÅge_gerade_5
Mîgliche_ZÅge_gerade_3:
 inc	ah			;nach unten prÅfen
 cmp	ah,8			;unten angekommen?
 ja	Mîgliche_ZÅge_gerade_2
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_gerade_4
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_gerade_2
Mîgliche_ZÅge_gerade_4:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
 jmp	Mîgliche_ZÅge_gerade_3
Mîgliche_ZÅge_gerade_2:
 mov	ax,[si-2]
Mîgliche_ZÅge_gerade_6:
 dec	ah			;nach oben prÅfen
 test	ah,ah			;oben angekommen?
 jz	Mîgliche_ZÅge_gerade_7
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_gerade_8
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_gerade_7
Mîgliche_ZÅge_gerade_8:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
 jmp	Mîgliche_ZÅge_gerade_6
Mîgliche_ZÅge_gerade_7:
 mov	ax,[si-2]
Mîgliche_ZÅge_gerade_9:
 inc	ax			;nach rechts prÅfen
 cmp	al,8			;rechts angekommen?
 ja	Mîgliche_ZÅge_gerade_10
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_gerade_11
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_gerade_10
Mîgliche_ZÅge_gerade_11:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
 jmp	Mîgliche_ZÅge_gerade_9
Mîgliche_ZÅge_gerade_10:
 mov	ax,[si-2]
Mîgliche_ZÅge_gerade_12:
 dec	ax			;nach links prÅfen
 test	al,al			;links angekommen?
 jz	Mîgliche_ZÅge_gerade_5
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_gerade_13
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_gerade_5
Mîgliche_ZÅge_gerade_13:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
 jmp	Mîgliche_ZÅge_gerade_12
Mîgliche_ZÅge_gerade_5:
 ret

;<<<Mîgliche_ZÅge_schrÑg>>>
;Erstellt Liste aller schrÑgen ZÅge einer Figur
;Ein: di=Puffer fÅr ZÅge,si=Zeiger auf Koordinaten der Figur
;Aus: -
Mîgliche_ZÅge_schrÑg:
 lodsw
 mov	bp,ax
 test	ax,ax			;Figur existiert nicht mehr?
 jz	Mîgliche_ZÅge_schrÑg_5
Mîgliche_ZÅge_schrÑg_3:
 inc	ah			;nach rechts unten prÅfen
 inc	ax
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_schrÑg_2
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_schrÑg_4
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_schrÑg_2
Mîgliche_ZÅge_schrÑg_4:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
 jmp	Mîgliche_ZÅge_schrÑg_3
Mîgliche_ZÅge_schrÑg_2:
 mov	ax,[si-2]
Mîgliche_ZÅge_schrÑg_6:
 dec	ah			;nach links oben prÅfen
 dec	ax
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_schrÑg_7
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_schrÑg_8
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_schrÑg_7
Mîgliche_ZÅge_schrÑg_8:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
 jmp	Mîgliche_ZÅge_schrÑg_6
Mîgliche_ZÅge_schrÑg_7:
 mov	ax,[si-2]
Mîgliche_ZÅge_schrÑg_9:
 dec	ah			;nach rechts oben prÅfen
 inc	ax
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_schrÑg_10
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_schrÑg_11
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_schrÑg_10
Mîgliche_ZÅge_schrÑg_11:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
 jmp	Mîgliche_ZÅge_schrÑg_9
Mîgliche_ZÅge_schrÑg_10:
 mov	ax,[si-2]
Mîgliche_ZÅge_schrÑg_12:
 inc	ah			;nach links unten prÅfen
 dec	ax
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_schrÑg_5
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_schrÑg_13
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_schrÑg_5
Mîgliche_ZÅge_schrÑg_13:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
 jmp	Mîgliche_ZÅge_schrÑg_12
Mîgliche_ZÅge_schrÑg_5:
 ret

;<<<Mîgliche_ZÅge_Turms>>>
;Erstellt eine Liste aller mîglichen ZÅge der schwarzen TÅrme
;Ein: di=Zeiger auf Puffer
;Aus: -
Mîgliche_ZÅge_Turms:
 lea	si,Turm1s
 call	Mîgliche_ZÅge_gerade
 call	Mîgliche_ZÅge_gerade
 ret

;<<<Mîgliche_ZÅge_LÑufers>>>
;Erstellt eine Liste aller mîglichen ZÅge der schwarzen LÑufer
;Ein: di=Zeiger auf Puffer
;Aus: -
Mîgliche_ZÅge_LÑufers:
 lea	si,LÑufer1s
 call	Mîgliche_ZÅge_schrÑg
 call	Mîgliche_ZÅge_schrÑg
 ret

;<<<Mîgliche_ZÅge_Dames>>>
;Erstellt eine Liste aller mîglichen ZÅge der schwarzen Dame
;Ein: di=Zeiger auf Puffer
;Aus: -
Mîgliche_ZÅge_Dames:
 lea	si,Dames
 mov	cx,8
Mîgliche_ZÅge_Dames_2:
 push	cx
 call	Mîgliche_ZÅge_gerade
 dec	si
 dec	si
 call	Mîgliche_ZÅge_schrÑg
 pop	cx
 loop	Mîgliche_ZÅge_Dames_2
 ret

;<<<Mîgliche_ZÅge_Kînigs>>>
;Erstellt eine Liste aller mîglichen ZÅge des schwarzen Kînigs
;Ein: di=Zeiger auf Puffer
;Aus: -
Mîgliche_ZÅge_Kînigs:
 lea	si,Kînigs
 call	Mîgliche_ZÅge_Feld_weiter	;îîî
; mov	ax,[Kînigs]
; mov	word ptr[Figur_ausgewÑhlt],ax
; lea	bx,Cursor
; mov	word ptr[bx],103h
; call	Figur_suchen
; call	Rochade
; test	ax,ax			;Rochade durchfÅhrbar?
; jnz	Mîgliche_ZÅge_Kînigs_2
; mov	ax,[Kînigs]
; stosw
; mov	ax,103h
; stosw
;Mîgliche_ZÅge_Kînigs_2:
; lea	bx,Cursor
; mov	word ptr[bx],107h
; call	Figur_suchen
; call	Rochade
; test	ax,ax			;Rochade durchfÅhrbar?
; jnz	Mîgliche_ZÅge_Kînigs_3
; mov	ax,[Kînigs]
; stosw
; mov	ax,107h
; stosw
Mîgliche_ZÅge_Kînigs_3:
 ret

;<<<Mîgliche_ZÅge_Springers>>>
;Erstellt eine Liste aller mîglichen ZÅge der schwarzen Springer
;Ein: di=Zeiger auf Puffer
;Aus: -
Mîgliche_ZÅge_Springers:
 lea	si,Springer1s
 call	Mîgliche_ZÅge_Ecksprung
 call	Mîgliche_ZÅge_Ecksprung
 ret

;<<<Mîgliche_ZÅge_Feld_weiter>>>
;Erstellt Liste aller ZÅge auf die benachbarten Felder einer Figur
;Ein: di=Puffer fÅr ZÅge,si=Zeiger auf Koordinaten der Figur
;Aus: -
Mîgliche_ZÅge_Feld_weiter:
 lodsw
 mov	bp,ax
 test	ax,ax			;Figur existiert nicht mehr?
 jz	Mîgliche_ZÅge_Feld_weiter_2
 inc	ax			;nach rechts prÅfen
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Feld_weiter_3
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Feld_weiter_4
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Feld_weiter_3
Mîgliche_ZÅge_Feld_weiter_4:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Feld_weiter_3:
 mov	ax,[si-2]
 dec	ax			;nach links prÅfen
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Feld_weiter_5
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Feld_weiter_6
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Feld_weiter_5
Mîgliche_ZÅge_Feld_weiter_6:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Feld_weiter_5:
 mov	ax,[si-2]
 inc	ah			;nach unten prÅfen
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Feld_weiter_7
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Feld_weiter_8
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Feld_weiter_7
Mîgliche_ZÅge_Feld_weiter_8:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Feld_weiter_7:
 mov	ax,[si-2]
 dec	ah			;nach oben prÅfen
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Feld_weiter_9
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Feld_weiter_10
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Feld_weiter_9
Mîgliche_ZÅge_Feld_weiter_10:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Feld_weiter_9:
 mov	ax,[si-2]
 dec	ah			;nach oben rechts prÅfen
 inc	ax
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Feld_weiter_11
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Feld_weiter_12
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Feld_weiter_11
Mîgliche_ZÅge_Feld_weiter_12:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Feld_weiter_11:
 mov	ax,[si-2]
 dec	ah			;nach oben links prÅfen
 dec	ax
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Feld_weiter_13
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Feld_weiter_14
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Feld_weiter_13
Mîgliche_ZÅge_Feld_weiter_14:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Feld_weiter_13:
 mov	ax,[si-2]
 inc	ah			;nach unten rechts prÅfen
 inc	ax
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Feld_weiter_15
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Feld_weiter_16
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Feld_weiter_15
Mîgliche_ZÅge_Feld_weiter_16:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Feld_weiter_15:
 mov	ax,[si-2]
 inc	ah			;nach unten links prÅfen
 dec	ax
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Feld_weiter_2
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Feld_weiter_18
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Feld_weiter_2
Mîgliche_ZÅge_Feld_weiter_18:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Feld_weiter_2:
 ret

;<<<Mîgliche_ZÅge_Ecksprung>>>
;Erstellt Liste aller EcksprungzÅge einer Figur
;Ein: di=Puffer fÅr ZÅge,si=Zeiger auf Koordinaten der Figur
;Aus: -
Mîgliche_ZÅge_Ecksprung:
 lodsw
 mov	bp,ax
 test	ax,ax			;Figur existiert nicht mehr?
 jz	Mîgliche_ZÅge_Ecksprung_2
 dec	ax			;Zwei links eins hoch prÅfen
 dec	ax
 dec	ah
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Ecksprung_3
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Ecksprung_4
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Ecksprung_3
Mîgliche_ZÅge_Ecksprung_4:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Ecksprung_3:
 mov	ax,[si-2]
 dec	ax			;Eins links zwei hoch prÅfen
 sub	ah,2
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Ecksprung_5
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Ecksprung_6
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Ecksprung_5
Mîgliche_ZÅge_Ecksprung_6:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Ecksprung_5:
 mov	ax,[si-2]
 inc	ax			;Eins rechts zwei hoch prÅfen
 sub	ah,2
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Ecksprung_7
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Ecksprung_8
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Ecksprung_7
Mîgliche_ZÅge_Ecksprung_8:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Ecksprung_7:
 mov	ax,[si-2]
 inc	ax			;Zwei rechts eins hoch prÅfen
 inc	ax
 dec	ah
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Ecksprung_9
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Ecksprung_10
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Ecksprung_9
Mîgliche_ZÅge_Ecksprung_10:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Ecksprung_9:
 mov	ax,[si-2]
 dec	ax			;Zwei links eins runter prÅfen
 dec	ax
 inc	ah
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Ecksprung_11
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Ecksprung_12
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Ecksprung_11
Mîgliche_ZÅge_Ecksprung_12:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Ecksprung_11:
 mov	ax,[si-2]
 dec	ax			;Eins links zwei runter prÅfen
 add	ah,2
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Ecksprung_13
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Ecksprung_14
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Ecksprung_13
Mîgliche_ZÅge_Ecksprung_14:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Ecksprung_13:
 mov	ax,[si-2]
 inc	ax			;Eins rechts zwei runter prÅfen
 add	ah,2
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Ecksprung_15
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Ecksprung_16
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Ecksprung_15
Mîgliche_ZÅge_Ecksprung_16:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Ecksprung_15:
 mov	ax,[si-2]
 inc	ax			;Zwei rechts eins runter prÅfen
 inc	ax
 inc	ah
 mov	bx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Mîgliche_ZÅge_Ecksprung_2
 xchg	ax,bx
 lea	bx,Cursor
 mov	[bx],ax
 push	si
 call	Figur_suchen
 cmp	si,Offset Cursor	;Feld ist nicht besetzt?
 jz	Mîgliche_ZÅge_Ecksprung_18
 call	Schlagliste_erweitern
 pop	si
 jmp	Mîgliche_ZÅge_Ecksprung_2
Mîgliche_ZÅge_Ecksprung_18:
 pop	si
 mov	ax,[si-2]
 stosw
 xchg	ax,bx
 stosw
Mîgliche_ZÅge_Ecksprung_2:
 ret

;<<<Zugliste_erstellen>>>
;Erstellt eine Liste aller mîglichen ZÅge
;Ein: -
;Aus: -
Zugliste_erstellen:
 mov	[Anzahl_mîglicher_SchlÑge],0
 mov	[Anzahl_mîglicher_Deckungen],0
 lea	di,Zugliste
 push	word ptr[Cursor]
 push	[Figur_ausgewÑhlt]
 call	Mîgliche_ZÅge_Bauers	;îî Anordnung verÑndern fÅr anderes Spiel
 call	Mîgliche_ZÅge_Springers
 call	Mîgliche_ZÅge_LÑufers
 call	Mîgliche_ZÅge_Turms
 call	Mîgliche_ZÅge_Dames
 call	Mîgliche_ZÅge_Kînigs
 pop	[Figur_ausgewÑhlt]
 pop	word ptr[Cursor]
 mov	ax,di			;Anzahl der mîglichen ZÅge herausfinden
 sub	ax,Offset Zugliste
 shr	ax,2
 mov	[Anzahl_mîglicher_ZÅge],ax
 ret

;<<<Schlagliste_erweitern>>>
;FÅgt der Schlagliste oder Deckungsliste eine weitere Mîglichkeit hinzu
;Ein: -
;Aus: -
Schlagliste_erweitern:
 pusha
 push	bx
 lea	bx,Cursor
 call	Figur_weiss
 pop	bx
 mov	cl,[Farbe_ausgewÑhlt]
 cmp	al,cl			;gegnerische Figur wird bedroht?
 jz	Schlagliste_erweitern_2
 lea	di,Deckungsliste
 mov	ax,[Anzahl_mîglicher_Deckungen]
 inc	ax
 mov	[Anzahl_mîglicher_Deckungen],ax
 jmp	Schlagliste_erweitern_3
Schlagliste_erweitern_2:
 lea	di,Schlagliste
 mov	ax,[Anzahl_mîglicher_SchlÑge]
 inc	ax
 mov	[Anzahl_mîglicher_SchlÑge],ax
Schlagliste_erweitern_3:
 dec	ax
 shl	ax,2
 add	di,ax
 mov	ax,bp
 stosw
 xchg	ax,bx
 stosw
 popa
 ret

;<<<Schlagliste_Bauern>>>
;Erstellt Schlagliste aller Bauern
;Ein: -
;Aus: -
Schlagliste_Bauern:		;îî FÅr beide Farben machen
 pusha
 lea	bp,Bauer1s
Schlagliste_Bauern_2:
 mov	si,bp
 lodsw
 mov	bp,si
 test	ax,ax			;Die Figur gibt es nicht mehr?
 jz	Schlagliste_Bauern_3
 mov	bx,ax
 inc	ax			;links unten
 inc	ah
 mov	cx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Schlagliste_Bauern_3
 push	bx
 lea	bx,Cursor
 mov	[bx],cx
 call	Figur_suchen
 pop	bx
 cmp	si,Offset Cursor	;keine Figur bedroht?
 jz	Schlagliste_Bauern_3
 pusha
 mov	bp,bx
 xchg	ax,bx
 call	Schlagliste_erweitern
 popa
Schlagliste_Bauern_3:
 mov	ax,bx
 inc	ah			;rechts unten
 dec	ax
 mov	cx,ax
 call	Koordinaten_mîglich
 test	ax,ax
 jnz	Schlagliste_Bauern_4
 push	bx
 lea	bx,Cursor
 mov	[bx],cx
 call	Figur_suchen
 pop	bx
 cmp	si,Offset Cursor	;keine Figur bedroht?
 jz	Schlagliste_Bauern_4
 pusha
 mov	bp,bx
 xchg	ax,bx
 call	Schlagliste_erweitern
 popa
Schlagliste_Bauern_4:
 cmp	bp,Offset Turm1s	;Alle Bauern geprÅft?
 jnz	Schlagliste_Bauern_2
 popa
 ret

;<<<Deckungsliste_auswerten>>>
;Erstellt Liste mit allen ungedeckten Figuren
;Ein: -
;Aus: -
Deckungsliste_auswerten:
 pusha
 lea	si,Deckungsliste
 lea	di,Temp
 lea	dx,Temp2
 xor	cx,cx
 mov	[Anzahl_ungedeckter_Figuren],cx
Deckungsliste_auswerten_2:
 lodsw
 call	Koordinaten_mîglich
 test	ax,ax			;Kein gÅltiger Wert?
 jnz	Deckungsliste_auswerten_3
 lodsw
 stosw
 inc	cx
 jmp	Deckungsliste_auswerten_2
Deckungsliste_auswerten_3:
 lea	si,Bauer1s
 mov	bp,cx
Deckungsliste_auswerten_5:
 lodsw
 test	ax,ax			;Figur existiert nicht mehr?
 jz	Deckungsliste_auswerten_5
 lea	di,Temp
 mov	cx,bp
 cmp	ax,[Kînigs]		;Kînig nicht mit machen
 jz	Deckungsliste_auswerten_7
Deckungsliste_auswerten_4:
 mov	bx,[di]
 inc	di
 inc	di
 cmp	ax,bx			;Figur ist gedeckt?
 jz	Deckungsliste_auswerten_6
 loop	Deckungsliste_auswerten_4
 mov	bx,dx
 mov	[bx],ax
 inc	dx
 inc	dx
Deckungsliste_auswerten_6:
 cmp	si,Offset Dame8s-1	;Alle Figuren gecheckt? (Kînig braucht nicht
 jna	Deckungsliste_auswerten_5	; gedeckt zu werden)
Deckungsliste_auswerten_7:
 sub	dx,Offset Temp2
 shr	dx,1
 mov	[Anzahl_ungedeckter_Figuren],dx
 popa
 ret

;<<<Schlagliste_beste_Mîglichkeit>>>
;Sucht aus der Schlagliste den gÅnstigsten von Punktwerten her heraus
;Ein: -
;Aus: fs=Speicherstelle des Schlags,sonst 0
Schlagliste_beste_Mîglichkeit:
 push	ax
 push	bx
 xor	ax,ax
 mov	fs,ax
 mov	ax,[Anzahl_mîglicher_SchlÑge]
 test	ax,ax			;Nichts zu schlagen?
 jz	Schlagliste_beste_Mîglichkeit_2
 xchg	ax,cx
 lea	bp,Schlagliste+2
 xor	di,di
Schlagliste_beste_Mîglichkeit_4:
 mov	bx,bp
 call	Figur_suchen
 call	Figurenwert
 cmp	ax,di			;Die Figur ist mehr wert?
 jna	Schlagliste_beste_Mîglichkeit_3
 mov	di,ax
 dec	bp
 dec	bp
 mov	fs,bp
 inc	bp
 inc	bp
Schlagliste_beste_Mîglichkeit_3:
 add	bp,4
 loop	Schlagliste_beste_Mîglichkeit_4
Schlagliste_beste_Mîglichkeit_2:
 pop	bx
 pop	ax
 ret

