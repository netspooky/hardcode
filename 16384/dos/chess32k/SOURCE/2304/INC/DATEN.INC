;<<<---Daten--->>>
.DATA
Copyright db 'Chess32k by SpaceCommander / ByTeGeiZ$'
Configdatei db 'Chess32k.cfg',0
Men0 db 'ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»$'
Men1 db '³                                       ³$'
Men2 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´$'
Men3 db '³               1  Spieler              ³$'
Men4 db '³               2  Spieler              ³$'
Men5 db '³                Optionen               ³$'
Men6 db '³                 Regeln                ³$'
Men7 db '³                  Info                 ³$'
Men8 db '³                  Ende                 ³$'
Men9 db 'ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼$'
Schachbrett1 db 'ÉÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍËÍÍÍ»$'
Schachbrett2 db 'º   ³   ³   ³   ³   ³   ³   ³   º$'
Schachbrett3 db 'ÌÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ¹$'
Schachbrett4 db 'ÈÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍÊÍÍÍ¼$'
Spielername1 db 'ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»$'
Spielername2 db '³ Bitte Spielernamen eingeben ³$'
Spielername3 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´$'
Spielername4 db '³  Weiss  :                   ³$'
Spielername5 db '³ Schwarz :                   ³$'
Spielername6 db 'ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼$'
Spielername7 db '³ Spieler :                   ³$'
Optionen0 db 'ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»$'
Optionen1 db '³               Optionen              ³$'
Optionen2 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´$'
Optionen3 db '³         Koordinaten anzeigen        ³$'
Optionen4 db '³            Namen anzeigen           ³$'
Optionen5 db '³          Schachuhr anzeigen         ³$'
Optionen6 db '³         Zugnotation anzeigen        ³$'
Optionen7 db '³     Geschlagene Figuren anzeigen    ³$'
Optionen8 db '³         Bemerkungen anzeigen        ³$'
Optionen9 db '³    Optionen automatisch speichern   ³$'
OptionenA db '³               Hauptmen             ³$'
OptionenB db 'ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼$'
Info0 db 'ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»$'
Info1 db '³              Info               ³$'
Info2 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´$'
Info3 db '³   Code + Idee: SpaceCommander   ³$'
Info5 db '³          Version: 0.85P         ³$'
Info6 db '³ Source: 150 kB Asm, 7500 Zeilen ³$'
Info4 db '³    Betatester: MK2K , Kilroy    ³$'
Info7 db '³ ByTeGeiZ sucht neue Mitglieder! ³$'
Info8 db '³ Homepage: http://go.to/ByTeGeiZ ³$'
Info9 db 'ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼$'
Geschlagene_Figuren_Fenster0 db 'ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»$'
Geschlagene_Figuren_Fenster1 db '³ Geschlagene Figuren ³$'
Geschlagene_Figuren_Fenster2 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´$'
Geschlagene_Figuren_Fenster3 db '³                     ³$'
Geschlagene_Figuren_Fenster4 db '³                     ³$'
Geschlagene_Figuren_Fenster5 db 'ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼$'
Zugnotation_Fenster0 db 'ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»$'
Zugnotation_Fenster1 db '³ Zugnotation      ³$'
Zugnotation_Fenster2 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´$'
Zugnotation_Fenster3 db '³                  ³$'
Zugnotation_Fenster4 db 'ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼$'
Schachuhr0 db 'ÉÄÄÄÄÄÄÄÄÄÄ»$'
Schachuhr1 db '³ 00:00:00 ³$'
Schachuhr2 db 'ÈÄÄÄÄÄÄÄÄÄÄ¼$'
Seitenwahl0 db 'ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»$'
Seitenwahl1 db '³ Welche Farbe? ³$'
Seitenwahl2 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´$'
Seitenwahl3 db '³    Zufall     ³$'
Seitenwahl4 db '³     Weiá      ³$'
Seitenwahl5 db '³    Schwarz    ³$'
Seitenwahl6 db 'ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼$'
Kommentar_Fenster0 db 'ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»$'
Kommentar_Fenster1 db '³               ³$'
Kommentar_Fenster2 db '³               ³$'
Kommentar_Fenster3 db '³               ³$'
Kommentar_Fenster4 db '³               ³$'
Kommentar_Fenster5 db 'ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼$'
Spielende_Fenster0 db 'ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»$'
Spielende_Fenster1 db '³ Du hast          ³$'
Spielende_Fenster2 db 'ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼$'
Spielende_gewonnen db 'gewonnen$'
Spielende_verloren db 'verloren$'
Cursor_sicherung db 10
Spieler1 db 17 dup (20h),'$'
Spieler2 db 17 dup (20h),'$'
Spieler3 db 17 dup (20h),'$'
Notation_String db 16 dup (20h),'$'
Computer_Name db 'Chess32k         $'
Spieler1_Namensl„nge dw 0
Spieler2_Namensl„nge dw 0
Spieler3_Namensl„nge dw 0
Letzte_Sekunde db 0
Einspielermodus db 0
Farbe_ausgew„hlt db 0
Bemerkung_leer db '                   $'
Bemerkung1 db 'Patt!$'
Bemerkung2 db 'Du gibst auf?$'
Bemerkung3 db 'Hast du Angst?$'
Bemerkung4 db 'Hosen voll?$'
Bemerkung5 db 'Keine Lust mehr?$'
Bemerkung6 db 'Und Gluck weg isser$'
Bemerkung7 db 'Einer weniger$'
Bemerkung8 db 'Die anderen folgen$'
Bemerkung9 db 'Der N„chste bitte$'
Bemerkung10 db 'Schl„fst du?$'
Bemerkung11 db 'Der war zuviel hier$'
Bemerkung12 db 'Schade eigentlich$'
Bemerkung13 db 'Schade um ihn$'
Bemerkung14 db 'Gut gemacht$'
Bemerkung15 db 'Oh$'
Bemerkung16 db 'Achso$'
Bemerkung17 db 'Warum nicht$'
Bemerkung18 db 'Hm$'
Bemerkung19 db 'Nicht schlecht$'
Bemerkung20 db 'Oh weija$'
Bemerkung21 db 'Macht nix$'
;<<<---Optionen--->>>
Koordinaten_anzeigen db 0
Namen_anzeigen db 0
Schachuhr_anzeigen db 0
Zugnotation_anzeigen db 0
Geschlagene_Figuren_anzeigen db 0
Bemerkungen_anzeigen db 0
Optionen_Autosafe db 1
Optionen_Ende db 2
;<<<---Includes--->>>
Include Inc\Font.dat
Include Inc\Text.inc
;<<<---Uninitialisierte Daten--->>>
Figur_ausgew„hlt dw ?
Am_Zug db ?
Figuren_Geschlagen_Z„hlerw dw ?
Figuren_Geschlagen_Z„hlers dw ?
Zug dw ?
Notation_Cursor dw ?
Notation_Cursor2 db ?
Rochade_durchgefhrt db ?
Spieler1_Uhr dw ?
Spieler2_Uhr dw ?
Anzahl_m”glicher_Zge dw ?
Anzahl_m”glicher_Schl„ge dw ?
Anzahl_m”glicher_Deckungen dw ?
Anzahl_ungedeckter_Figuren dw ?
Spielausgang db ?
Im_Schach db ?	;””
;<<<---Rochade--->>>
Turm1w_bewegt db ?
Turm2w_bewegt db ?
K”nigw_bewegt db ?
Turm1s_bewegt db ?
Turm2s_bewegt db ?
K”nigs_bewegt db ?
;<<<---Figuren weiss--->>>
Bauer1w dw ?
Bauer2w dw ?
Bauer3w dw ?
Bauer4w dw ?
Bauer5w dw ?
Bauer6w dw ?
Bauer7w dw ?
Bauer8w dw ?
Turm1w dw ?
Turm2w dw ?
Springer1w dw ?
Springer2w dw ?
L„ufer1w dw ?
L„ufer2w dw ?
Damew dw ?
Dame2w dw ?
Dame3w dw ?
Dame4w dw ?
Dame5w dw ?
Dame6w dw ?
Dame7w dw ?
Dame8w dw ?
Dame9w dw ?
K”nigw dw ?
;<<<---Figuren schwarz--->>>
Bauer1s dw ?
Bauer2s dw ?
Bauer3s dw ?
Bauer4s dw ?
Bauer5s dw ?
Bauer6s dw ?
Bauer7s dw ?
Bauer8s dw ?
Turm1s dw ?
Turm2s dw ?
Springer1s dw ?
Springer2s dw ?
L„ufer1s dw ?
L„ufer2s dw ?
Dames dw ?
Dame2s dw ?
Dame3s dw ?
Dame4s dw ?
Dame5s dw ?
Dame6s dw ?
Dame7s dw ?
Dame8s dw ?
Dame9s dw ?
K”nigs dw ?
;<<<---Cursor--->>>
Cursor db ?,?
Cursoralt db ?,?
;<<<---Puffer--->>>
Temp dw 50 dup(?)
Temp2 dw 50 dup(?)
Temp3 dw 50 dup(?)
Zugliste dw 500 dup(?)
Schlagliste dw 500 dup(?)
Deckungsliste dw 500 dup(?)
Bemerkungenbuffer dw 200 dup (?)