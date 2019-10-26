RANDOMIZE TIMER
CLS

v = 0
a = 40
maxa = 30000

SCREEN 0

DO
SOUND a + 2, 1
nun = INT(RND * (200))
v = v + 1
a = a + 1
IF v = 16 THEN v = 0
COLOR v
SOUND a, 1
PRINT CHR$(nun),
IF a = maxa THEN END
LOOP UNTIL INKEY$ = CHR$(27)

