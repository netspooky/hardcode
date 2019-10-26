RANDOMIZE TIMER
SCREEN 13
    scale$ = "ABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGABCDEFGAB "
    PLAY "l16"
alustin:
jeesus = 0
Luku = 0
hinaaja:
LOCATE (12), 12
PRINT "Booting up demo..."
jeesus = 0
WHILE (jeesus < 320)
jeesus = jeesus + 2
LINE (INT(jeesus), 190)-(INT(jeesus), 200), 1
LINE (1 + INT(jeesus), 190)-(1 + INT(jeesus), 200), 1
FOR jee = 1 TO 2000:
NEXT jee
WEND
COLOR 0
LOCATE (12), 12
PRINT "Booting up demo..."
COLOR 7
jeesus = 0
WHILE (jeesus < 320)
jeesus = jeesus + 2
LINE (INT(jeesus), 190)-(INT(jeesus), 200), 0
LINE (1 + INT(jeesus), 190)-(1 + INT(jeesus), 200), 0
WEND
alku1:
jeesus = 0
WHILE (jeesus < 320)
x = rad * (SIN(deg)) + 50
y = rad * (COS(deg))
z = rad * (SIN(deg * 3))
rad = 20
IF (radi < 80) THEN
radi = radi + 4
END IF

soikeus = soikeus + .01
CIRCLE (100 + ABS(x), 70 + ABS(y)), ABS(z), 15, 1.5, 1.5, soikeus
CIRCLE (110 + ABS(x), 80 + ABS(y)), ABS(z), 5
CIRCLE (110 + ABS(x), 80 + ABS(y)), radi, 2
CIRCLE (110 + ABS(x) - z, 80 + ABS(y - z)), radi, 2

FOR jee = 1 TO 1000:
NEXT jee
CIRCLE (100 + ABS(x), 70 + ABS(y)), ABS(z), 0, 1.5, 1.5, soikeus
CIRCLE (110 + ABS(x), 80 + ABS(y)), ABS(z), 0
CIRCLE (110 + ABS(x), 80 + ABS(y)), radi, 0
CIRCLE (110 + ABS(x) - z, 80 + ABS(y - z)), radi, 0
deg = deg + .1
LOCATE (1), 1
PRINT "Pure QBasic"

jeesus = jeesus + .5
'vari = vari + 1
vari = 1
'LOCATE (3), 1
'PRINT vari
LINE (INT(jeesus), 190)-(INT(jeesus), 200), 1
LINE (1 + INT(jeesus), 190)-(1 + INT(jeesus), 200), vari
WEND
jeesus = 0
WHILE (jeesus < 320)
jeesus = jeesus + 2
LINE (INT(jeesus), 190)-(INT(jeesus), 200), 0
LINE (1 + INT(jeesus), 190)-(1 + INT(jeesus), 200), 0
WEND
COLOR 0
LOCATE (1), 1
PRINT "Pure QBasic"
COLOR 7

pomppu:
jeesus = 0
x1 = -17
x2 = 390
x3 = 90
x4 = 300
x5 = 47
y1 = 117
y2 = 185
y3 = 85
y4 = 15
y5 = 150
deltax1 = 1
deltax2 = -1
deltax3 = 1
deltax4 = -1
deltax5 = 1
deltay1 = 1
deltay2 = -1
deltay3 = 1
deltay4 = -1
deltay5 = -1
sade1 = 5
sade2 = 5
sade3 = 5
sade4 = 5
sade5 = 5
WHILE (jeesus < 320)



IF ((x1 = 1 + sade1 AND deltax1 < 0)) THEN deltax1 = deltax1 * -1
IF ((x1 = 320 - sade1 AND deltax1 > 0)) THEN deltax1 = deltax1 * -1
IF ((x2 = 1 + sade2 AND deltax2 < 0)) THEN deltax2 = deltax2 * -1
IF ((x2 = 320 - sade2 AND deltax2 > 0)) THEN deltax2 = deltax2 * -1
IF ((x3 = 1 + sade3 AND deltax3 < 0)) THEN deltax3 = deltax3 * -1
IF ((x3 = 320 - sade3 AND deltax3 > 0)) THEN deltax3 = deltax3 * -1
IF ((x4 = 1 + sade4 AND deltax4 < 0)) THEN deltax4 = deltax4 * -1
IF ((x4 = 320 - sade4 AND deltax4 > 0)) THEN deltax4 = deltax4 * -1
IF ((x5 = 1 + sade5 AND deltax5 < 0)) THEN deltax5 = deltax5 * -1
IF ((x5 = 320 - sade5 AND deltax5 > 0)) THEN deltax5 = deltax5 * -1
IF ((y1 = 0 + sade1 AND deltay1 < 0)) THEN deltay1 = deltay1 * -1
IF ((y1 = 190 - sade1 AND deltay1 > 0)) THEN deltay1 = deltay1 * -1
IF ((y2 = 0 + sade2 AND deltay2 < 0)) THEN deltay2 = deltay2 * -1
IF ((y2 = 190 - sade2 AND deltay2 > 0)) THEN deltay2 = deltay2 * -1
IF ((y3 = 0 + sade3 AND deltay3 < 0)) THEN deltay3 = deltay3 * -1
IF ((y3 = 190 - sade3 AND deltay3 > 0)) THEN deltay3 = deltay3 * -1
IF ((y4 = 0 + sade4 AND deltay4 < 0)) THEN deltay4 = deltay4 * -1
IF ((y4 = 190 - sade4 AND deltay4 > 0)) THEN deltay4 = deltay4 * -1
IF ((y5 = 0 + sade5 AND deltay5 < 0)) THEN deltay5 = deltay5 * -1
IF ((y5 = 190 - sade5 AND deltay5 > 0)) THEN deltay5 = deltay5 * -1

x1 = x1 + deltax1
x2 = x2 + deltax2
x3 = x3 + deltax3
x4 = x4 + deltax4
x5 = x5 + deltax5
y1 = y1 + deltay1
y2 = y2 + deltay2
y3 = y3 + deltay3
y4 = y4 + deltay4
y5 = y5 + deltay5
CIRCLE (x1, y1), sade1, 7
CIRCLE (x2, y2), sade2, 4
CIRCLE (x3, y3), sade3, 2
CIRCLE (x4, y4), sade4, 3
CIRCLE (x5, y5), sade5, 6
jeesus = jeesus + .25
vari = 1
LINE (INT(jeesus), 190)-(INT(jeesus), 200), 1
LINE (1 + INT(jeesus), 190)-(1 + INT(jeesus), 200), 1
FOR jee = 1 TO 1000:
NEXT jee

CIRCLE (x1, y1), sade1, 0
CIRCLE (x2, y2), sade2, 0
CIRCLE (x3, y3), sade3, 0
CIRCLE (x4, y4), sade4, 0
CIRCLE (x5, y5), sade5, 0
WEND

GOTO tappaja
kassit:
jeesus = 0
WHILE (jeesus < 320)


FOR jee = 1 TO 1000:
NEXT jee
jeesus = jeesus + .5
LINE (INT(jeesus), 190)-(INT(jeesus), 200), 1
LINE (1 + INT(jeesus), 190)-(1 + INT(jeesus), 200), 1
WEND

'tyhjennys
jeesus = 0
WHILE (jeesus < 320)
jeesus = jeesus + 2
LINE (INT(jeesus), 190)-(INT(jeesus), 200), 0
LINE (1 + INT(jeesus), 190)-(1 + INT(jeesus), 200), 0
WEND

tappaja:
SCREEN 0
LOCATE 1, 1
PRINT "by HST"
PRINT "made with Pure Basic"
PRINT ""
PRINT "gfx: cytict"
PRINT "gfx: guzze"
PRINT "music: dj Sepi"
PRINT "support: enigma, juke"

        PLAY "O" + STR$(i%)
        PLAY "X" + VARPTR$(scale$)


