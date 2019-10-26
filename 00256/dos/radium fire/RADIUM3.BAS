DECLARE SUB radium ()
SCREEN 13:PRINT "ZEN":radium
a$ = "prg_type: _________Qbasic_greetz________ http://fan333.narod.ru e-mail:zen333@mail.ru Vladivostok GReeTZ: Farbrausch Haujobb Aardbei 3SC T-Rex Tbl you ALL..."
FOR i = 1 TO LEN(a$):b$ = MID$(a$, i, 1):COLOR i: PRINT b$;:IF b$ = " " THEN PRINT : SLEEP (1)
NEXT i

SUB radium
maxlng = 200
maxx = 320
maxy = 200
xcntr = maxx / 2 + 20
ycntr = maxy / 2
maxgrad = 360 * 3
pi = 3.14
grd = (2 * pi) / maxgrad
FOR i = 0 TO maxgrad
a = grd * i
x = xcntr
y = ycntr
FOR j = 1 TO maxlng
jg = j * grd * 2
dx = SIN(i / j)'a + jg)
dy = COS(i / j)'a + jg)
x = x + dx ' + SIN(jg)
y = y + dy   ' + COS(jg)
PSET (x, y), i
NEXT j
NEXT i
END SUB

