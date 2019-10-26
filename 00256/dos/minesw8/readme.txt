;MINESW8 - Minesweeper game in 2^8 Bytes
; Released for the Function 2005 party held in Budapest, Hungary!
; By: -=thE /P.A.P.+O./ (BraiN)KiLLeR=-
; [[other aliases: B_KiLLeR, KiLLeR, --> bkil <--, kil, k]]
; http://en.wikipedia.org/wiki/User:Bkil
; Killer gszi et net posta ditt net.
;
; (does NOT output any author information)
;
; ABOUT THE GAME
; Your objective is to hack every location that has no underlying
; mine (ie. that is "empty"). You can mark mine-fishy places for your
; convenience. Hacked empty locations show the number of surronding
; mines from one to eight, or show blank, if this amount is zero.
; A game ending with a mine (*) shown at your location indicates that
; you've lost. Otherwise, you have successfully completed the mission!
;
; CONTROLS:  MOVE          HACK   MARK   ESC
;                  up
;                5            4    6     exit
;             1  2   3
;          left down right
;
; HINTS
; Try to reveal the bottom of the map first. ;-)
; Start with hacking corners, then follow chains.
;
; IMPORTANT NOTE
; The screen is NOT wrap-around for your cursor, despite the fact that
; the display suggests otherwise!! I repeat: NO range checking is
; implemented for movement! The mines however do consider the map
; to be endless to the left and right, the wrapping can be understood
; from the source. In brief: a mine at (0,2) is considered to be
; at location (80,1), where (x,y) are coordinates of the mine,
; and x e [0,79], y e [0,24].
;
; INSPIRATION
; A friend of mine likes to "mine" a lot, so I've made him
; a version which he could put in a bootsector... :-)
;
; GREETINGS
; robigszi, TomBucZman, "LamXtra :-) UnDeCoder"
;
;     ,.";;:,::;,,
;   ,;,;:;::";,;;.;,
;  .,';" ;';:;:':";;, 
;  ;,; ";''';:'';"';;,
;  ..;:;,':';.;',"';;.
;  :;:             ;::
;  ,;: ,,,,   ,,,, ;:,
;  '; ' __     __ ' ;'
;  /|  (_")   (_")  |\
; |(|      / \      |)|
; | |     /___\     | |
;  \|     .,.,.     |/
;   |     _____     |
;    \    \___/    /
;    |\    ,,,    /|
;    |  \_::;;:_/  |
;    |    ';:;'    |
;         -bkil-
;
