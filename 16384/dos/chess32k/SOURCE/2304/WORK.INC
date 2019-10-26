;<<<Deckungsliste_sortieren>>>
;Sortiert die Deckungsliste nach Wichtigkeit der zu deckenden Figuren
;Ein: -
;Aus: -
Deckungsliste_sortieren:
 ret	;îîî

 pusha
 lea	dx,Temp2
 lea	bp,Temp3
 mov	cx,[Anzahl_ungedeckter_Figuren]
Deckungsliste_sortieren_2:
 mov	bx,dx
 call	Figur_suchen
 call	Figurenwert
 mov	[bp],ax
 inc	dx
 inc	dx
 inc	bp
 inc	bp
 loop	Deckungsliste_sortieren_2

;îîî
 lea	ax,Temp3		;Listen nach Bubblesortverfahren sortieren
 mov	di,ax
 add	di,[Anzahl_ungedeckter_Figuren]
 dec	di
 mov	si,ax
 mov	bx,si
 inc	bx

 mov	ax,[bx]
 cmp	[si],ax
 jna	Deckungsliste_sortieren_3
 nop				;Werte vertauschen
Deckungsliste_sortieren_3:

 popa
 ret



;<<<Bemerkung_Schlagen2>>>
;Zeigt eine Bemerkung beim Schlagen der Figur des Spielers an
;Ein: -
;Aus: -
Bemerkung_Schlagen2:
 pusha
 mov	bl,7
 call	Zufallszahl
 lea	dx,Bemerkung14
 test	al,al
 jz	Bemerkung_Schlagen2_2
 lea	dx,Bemerkung15
 dec	ax
 jz	Bemerkung_Schlagen2_2
 lea	dx,Bemerkung16
 dec	ax
 jz	Bemerkung_Schlagen2_2
 lea	dx,Bemerkung17
 dec	ax
 jz	Bemerkung_Schlagen2_2
 lea	dx,Bemerkung18
 dec	ax
 jz	Bemerkung_Schlagen2_2
 lea	dx,Bemerkung19
 dec	ax
 jz	Bemerkung_Schlagen2_2
 lea	dx,Bemerkung20
 dec	ax
 jz	Bemerkung_Schlagen2_2
 lea	dx,Bemerkung21
Bemerkung_Schlagen2_2:
 call	Bemerkung_zeichnen
 popa
 ret


;<<<Im_Schach_PrÅfung>>>
;PrÅft, ob Spieler im Schach steht
;Ein: -
;Aus: ax=0 wenn wahr
Im_Schach_PrÅfung:


 ret
