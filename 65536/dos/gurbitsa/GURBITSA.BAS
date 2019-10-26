DECLARE SUB ChCol (y AS INTEGER, x AS INTEGER, c AS INTEGER)
DECLARE FUNCTION Col! (y AS INTEGER, x AS INTEGER)
DECLARE SUB GrowDevlp ()
DECLARE SUB HelloWorld ()
DECLARE SUB MultiColor ()
DECLARE SUB Particle ()
DECLARE SUB Smooth ()
DECLARE SUB VMS.ChangeFormat ()
DECLARE SUB VMS.ReadTrack ()
DECLARE SUB VMS.SetTrack (Tempo AS INTEGER, oc1 AS INTEGER, oc2 AS INTEGER, tHTrack1$, tHTrack2$)
DECLARE FUNCTION VMS.Spaceless$ (ch$)
DECLARE SUB Wt (Sec AS INTEGER)
DECLARE SUB VMS.Load (n AS INTEGER)
CLS : WIDTH 80, 50: TYPE Particle: x AS INTEGER
y AS INTEGER: xd AS INTEGER: yd AS INTEGER: END TYPE
DIM SHARED EndDemo AS INTEGER, PlayPoint AS INTEGER
DIM SHARED HTrack1$, HTrack2$, QBP1$, QBP2$
DIM SHARED HOct1 AS INTEGER, HOct2 AS INTEGER
: VMS.Load 1: HelloWorld: Smooth
: VMS.Load 2: MultiColor: Smooth
: VMS.Load 3: GrowDevlp: Smooth
: VMS.Load 4: Particle: Smooth
'J00 6URB1754

SUB ChCol (y AS INTEGER, x AS INTEGER, c AS INTEGER)
POKE ((x - 1) + (y - 1) * 80) * 2 + 1, c
END SUB

FUNCTION Col (y AS INTEGER, x AS INTEGER)
DEF SEG = &HB800
Col = PEEK(((x - 1) + (y - 1) * 80) * 2 + 1)
END FUNCTION

SUB GrowDevlp
STATIC a AS INTEGER, i AS INTEGER, c AS INTEGER, i2 AS INTEGER
b = TIMER: COLOR 0, 0: CLS : DEF SEG = &HB800: LOCATE 1, 1:
FOR i2 = 1 TO 49: FOR i = 1 TO 80: PRINT CHR$(219); : NEXT i:
NEXT i2: LOCATE 50, 1: PRINT STRING$(80, CHR$(219)); : DO:
a = INT(RND * 4000) * 2 + 1: c = PEEK(a) + 1: IF c > 15 THEN c = 0
POKE a, c: VMS.ReadTrack: LOOP UNTIL EndDemo: EndDemo = 0
END SUB

SUB HelloWorld
LOCATE 24, 34: PRINT "HELLO WORLD !!!"
Wt 3: DO: VMS.ReadTrack: COLOR INT(RND * 15) + 1
LOCATE INT(RND * 50) + 1, INT(RND * 66) + 1
PRINT "HELLO WORLD !!!"; : LOOP UNTIL EndDemo
EndDemo = 0
END SUB

SUB MultiColor
Range = 16: Plus = 1: DO: LOCATE 1, 1
Range = Range + (INT(RND * 2) - .5) * 2
IF Range > 16 THEN Range = 16
IF Range < 1 THEN Range = 1
Plus = Plus + (INT(RND * 2) - .5) * 2
IF Plus + Range > 16 THEN Plus = 16 - Range
IF Plus < 1 THEN Plus = 1
FOR i2 = 1 TO 49: FOR i = 1 TO 80: COLOR INT(RND * Range) + Plus
PRINT CHR$(219); : NEXT i: NEXT i2: VMS.ReadTrack
LOOP UNTIL EndDemo: EndDemo = 0
END SUB

SUB Particle
DIM Dot(1 TO 3000) AS Particle
STATIC i AS INTEGER, i2 AS INTEGER
LOCATE 1, 1: FOR i2 = 1 TO 49: FOR i = 1 TO 80
COLOR 0, 0: PRINT CHR$(219); : NEXT i: NEXT i2
FOR i = 1 TO 2000: Dot(i).x = 40: Dot(i).xd = -2 + INT(RND * 5)
Dot(i).y = 25: Dot(i).yd = -2 + INT(RND * 5): NEXT i
DO: FOR i = 1 TO 2000: VMS.ReadTrack
ChCol Dot(i).y, Dot(i).x, Col(Dot(i).y, Dot(i).x) - 1
Dot(i).x = Dot(i).x + Dot(i).xd - 1 + INT(RND * 3)
Dot(i).y = Dot(i).y + Dot(i).yd - 1 + INT(RND * 3)
IF Dot(i).x < 1 THEN Dot(i).x = 1: Dot(i).xd = -Dot(i).xd
IF Dot(i).x > 80 THEN Dot(i).x = 80: Dot(i).xd = -Dot(i).xd
IF Dot(i).y < 1 THEN Dot(i).y = 1: Dot(i).yd = -Dot(i).yd
IF Dot(i).y > 50 THEN Dot(i).y = 50: Dot(i).yd = -Dot(i).yd
ChCol Dot(i).y, Dot(i).x, Col(Dot(i).y, Dot(i).x) + 1
NEXT i: LOOP UNTIL EndDemo: EndDemo = 0
END SUB

SUB Smooth
STATIC i AS INTEGER, i2 AS INTEGER, c AS INTEGER, c1 AS INTEGER
STATIC c2 AS INTEGER, c3 AS INTEGER, c4 AS INTEGER, sm AS INTEGER
DIM Array(1 TO 50, 1 TO 80) AS INTEGER: DEF SEG = &HB800
FOR i2 = 1 TO 50: FOR i = 1 TO 80
Array(i2, i) = PEEK(((i - 1) + (i2 - 1) * 80) * 2 + 1): NEXT i: NEXT i2
FOR sm = 1 TO 16: FOR i2 = 1 TO 50: FOR i = 1 TO 80: c = Array(i2, i)
IF i > 1 THEN c1 = Array(i2, i - 1) ELSE c1 = 0
IF i < 80 THEN c2 = Array(i2, i + 1) ELSE c2 = 0
IF i2 > 1 THEN c3 = Array(i2 - 1, i) ELSE c3 = 0
IF i2 < 50 THEN c4 = Array(i2 + 1, i) ELSE c4 = 0
Array(i2, i) = INT((c * 8 + c1 + c2 + c3 + c4) / 12)
NEXT i: NEXT i2: FOR i2 = 1 TO 50: FOR i = 1 TO 80
POKE ((i - 1) + (i2 - 1) * 80) * 2 + 1, Array(i2, i): NEXT i: NEXT i2
t = TIMER: DO: LOOP UNTIL TIMER - t > .01: NEXT sm
END SUB

SUB SquareFade

END SUB

SUB VMS.ChangeFormat

STATIC i AS INTEGER

c1$ = VMS.Spaceless$(QBP1$)
c2$ = VMS.Spaceless$(QBP2$)

FOR i = 1 TO LEN(c1$)
IF MID$(c1$, i, 1) = "-" THEN
  SELECT CASE MID$(c1$, i - 1, 1)
  CASE "d"
    MID$(c1$, i - 1, 1) = "d"
  CASE "e"
    MID$(c1$, i - 1, 1) = "d"
  CASE "a"
    MID$(c1$, i - 1, 1) = "g"
  CASE "b"
    MID$(c1$, i - 1, 1) = "a"
  END SELECT
MID$(c1$, i, 1) = "+"
END IF
NEXT i

IF LEN(c1$) > LEN(c2$) THEN c2$ = c2$ + SPACE$(LEN(c1$) - LEN(c2$))
IF LEN(c1$) < LEN(c2$) THEN c1$ = c1$ + SPACE$(LEN(c2$) - LEN(c1$))

FOR i = 1 TO LEN(c1$)

  SELECT CASE MID$(c1$, i, 1)
  CASE "c", "d", "e", "f", "g", "a", "b"
    IF MID$(c1$, i + 1, 1) = "+" THEN
      lenght = 64 / VAL(MID$(c1$, i + 2, 2))
        IF lenght > 1 THEN
          HTrack1$ = HTrack1$ + STRING$(lenght - 1, UCASE$(MID$(c1$, i, 1))) + " "
        ELSE
          HTrack1$ = HTrack1$ + STRING$(lenght, UCASE$(MID$(c1$, i, 1)))
        END IF
    ELSE
      lenght = 64 / VAL(MID$(c1$, i + 1, 2))
        IF lenght > 1 THEN
          HTrack1$ = HTrack1$ + STRING$(lenght - 1, MID$(c1$, i, 1)) + " "
        ELSE
          HTrack1$ = HTrack1$ + STRING$(lenght, MID$(c1$, i, 1))
        END IF
    END IF
  CASE "<"
    HTrack1$ = HTrack1$ + "<"
  CASE ">"
    HTrack1$ = HTrack1$ + ">"
  CASE "p"
    lenght = VAL(MID$(c1$, i + 1, 2))
    HTrack1$ = HTrack1$ + SPACE$(64 / lenght)
  END SELECT

  SELECT CASE MID$(c2$, i, 1)
  CASE "c", "d", "e", "f", "g", "a", "b"
    IF MID$(c2$, i + 1, 1) = "+" THEN
      lenght = 64 / VAL(MID$(c2$, i + 2, 2))
        IF lenght > 1 THEN
          HTrack2$ = HTrack2$ + STRING$(lenght - 1, UCASE$(MID$(c2$, i, 1))) + " "
        ELSE
          HTrack2$ = HTrack2$ + STRING$(lenght, UCASE$(MID$(c2$, i, 1)))
        END IF
    ELSE
      lenght = 64 / VAL(MID$(c2$, i + 1, 2))
        IF lenght > 1 THEN
          HTrack2$ = HTrack2$ + STRING$(lenght - 1, MID$(c2$, i, 1)) + " "
        ELSE
          HTrack2$ = HTrack2$ + STRING$(lenght, MID$(c2$, i, 1))
        END IF
    END IF
  CASE "<"
    HTrack2$ = HTrack2$ + "<"
  CASE ">"
    HTrack2$ = HTrack2$ + ">"
  CASE "p"
    lenght = VAL(MID$(c2$, i + 1, 2))
    HTrack2$ = HTrack2$ + SPACE$(64 / lenght)
  END SELECT

NEXT i

IF LEN(HTrack1$) > LEN(HTrack2$) THEN HTrack2$ = HTrack2$ + SPACE$(LEN(HTrack1$) - LEN(HTrack2$))
IF LEN(HTrack1$) < LEN(HTrack2$) THEN HTrack1$ = HTrack1$ + SPACE$(LEN(HTrack2$) - LEN(HTrack1$))

DO
StillOctave = 0
FOR i = 1 TO LEN(HTrack1$)
  IF MID$(HTrack1$, i, 1) = ">" AND MID$(HTrack2$, i, 1) <> "-" THEN HTrack2$ = LEFT$(HTrack2$, i - 1) + "-" + MID$(HTrack2$, i, LEN(HTrack2$) - i + 1): StillOctave = 1: EXIT FOR
  IF MID$(HTrack1$, i, 1) = "<" AND MID$(HTrack2$, i, 1) <> "-" THEN HTrack2$ = LEFT$(HTrack2$, i - 1) + "-" + MID$(HTrack2$, i, LEN(HTrack2$) - i + 1): StillOctave = 1: EXIT FOR
  IF MID$(HTrack2$, i, 1) = ">" AND MID$(HTrack1$, i, 1) <> "-" THEN HTrack1$ = LEFT$(HTrack1$, i - 1) + "-" + MID$(HTrack1$, i, LEN(HTrack1$) - i + 1): StillOctave = 1: EXIT FOR
  IF MID$(HTrack2$, i, 1) = "<" AND MID$(HTrack1$, i, 1) <> "-" THEN HTrack1$ = LEFT$(HTrack1$, i - 1) + "-" + MID$(HTrack1$, i, LEN(HTrack1$) - i + 1): StillOctave = 1: EXIT FOR
NEXT i
LOOP UNTIL StillOctave = 0

IF LEN(HTrack1$) > LEN(HTrack2$) THEN HTrack2$ = HTrack2$ + SPACE$(LEN(HTrack1$) - LEN(HTrack2$))
IF LEN(HTrack1$) < LEN(HTrack2$) THEN HTrack1$ = HTrack1$ + SPACE$(LEN(HTrack2$) - LEN(HTrack1$))

END SUB

SUB VMS.Load (n AS INTEGER)
SELECT CASE n
CASE 1
  s1$ = "c4f4g4a12g12f12g2. a12g12f12g4 a12g12f12g4 f12e12d12e1"
  s1$ = s1$ + "c4f4g4a12g12f12g2. a12g12f12g4 a12g12f12g4 f12e12d12c1"
  s2$ = "c4f4g4a12g12f12g2. a12g12f12g4 a12g12f12g4 f12e12d12e1"
  s2$ = s2$ + "c4f4g4a12g12f12g2. a12g12f12g4 a12g12f12g4 f12e12d12c1"
CASE 2
  s1$ = "d4g4a4b12a12g12a2. b12a12g12a4 b12a12g12a4 g12f+12e12f+1"
  s1$ = s1$ + "d4g4a4b12a12g12a2. b12a12g12a4 b12a12g12a4 g12f+12e12d1"
  s2$ = "d4g4a4b12a12g12a2. b12a12g12a4 b12a12g12a4 g12f+12e12f+1"
  s2$ = s2$ + "d4g4a4b12a12g12a2. b12a12g12a4 b12a12g12a4 g12f+12e12d1"
CASE 3
  s1$ = "g2.a+4a3.a+3.mn g2. ml g6a+12 > d2 < a+2 mn g+1 ml g+2 f2"
  s2$ = "g2.a+4a3.a+3.mn g2. ml g6a+12 > d2 < a+2 mn g+1 ml g+2 f2"
END SELECT
  VMS.SetTrack 220, 2, 1, s1$, s2$
IF n = 4 THEN
  aaaa$ = "d4f4a4 > d8e16f16g16f16e16d16c+4 a8d16f16a16f16d8 a+4 g8c16e16g16e16c8 a4 f8 < a+16 > d16f16d16 < a+8 > g4 e8 < a16 > c+16e16c+16 < a8 > f4 e16f16e16d16c+8f8 e16f16e16d16 <a8> d8 c+16d16e16d16d4<"
  bbbb$ = "d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4"
  VMS.SetTrack 140, 2, 1, aaaa$, bbbb$
END IF
END SUB

SUB VMS.ReadTrack

PLAY "mb"
WHILE PLAY(0) < 4 AND PlayPoint < LEN(HTrack1$)
PlayPoint = PlayPoint + 1
  SELECT CASE MID$(HTrack1$, PlayPoint, 1)
  CASE "<"
    HOct1 = HOct1 - 1
  CASE ">"
    HOct1 = HOct1 + 1
  CASE " "
    PLAY "p64"
  CASE "-"
  CASE ELSE
    PLAY "o" + STR$(HOct1)
      IF ASC(MID$(HTrack1$, PlayPoint, 1)) < 97 THEN
        PLAY MID$(HTrack1$, PlayPoint, 1) + "+64"
      ELSE
        PLAY MID$(HTrack1$, PlayPoint, 1) + "64"
      END IF
  END SELECT

  SELECT CASE MID$(HTrack2$, PlayPoint, 1)
  CASE "<"
    HOct2 = HOct2 - 1
  CASE ">"
    HOct2 = HOct2 + 1
  CASE " "
    PLAY "p64"
  CASE "-"
  CASE ELSE
    PLAY "o" + STR$(HOct2)
      IF ASC(MID$(HTrack2$, PlayPoint, 1)) < 97 THEN
        PLAY MID$(HTrack2$, PlayPoint, 1) + "+64"
      ELSE
        PLAY MID$(HTrack2$, PlayPoint, 1) + "64"
      END IF
  END SELECT
WEND
IF PlayPoint >= LEN(HTrack1$) THEN PlayPoint = 0: EndDemo = -1

END SUB

SUB VMS.SetTrack (Tempo AS INTEGER, oc1 AS INTEGER, oc2 AS INTEGER, tHTrack1$, tHTrack2$)

HTrack1$ = "": HTrack2$ = ""
PLAY "t" + STR$(Tempo)
HOct1 = oc1: HOct2 = oc2
QBP1$ = tHTrack1$: QBP2$ = tHTrack2$
VMS.ChangeFormat

END SUB

FUNCTION VMS.Spaceless$ (ch$)

DO
StillSpace = 0
  FOR i = 1 TO LEN(ch$)
    IF MID$(ch$, i, 1) = " " THEN ch$ = LEFT$(ch$, i - 1) + MID$(ch$, i + 1): StillSpace = 1
  NEXT i
LOOP UNTIL StillSpace = 0

VMS.Spaceless$ = ch$

END FUNCTION

SUB Wt (Sec AS INTEGER)
a = TIMER: DO: LOOP UNTIL TIMER - a >= Sec
END SUB

