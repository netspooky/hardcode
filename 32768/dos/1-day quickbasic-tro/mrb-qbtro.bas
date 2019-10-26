' Mike Burke / mrb / erdrick
' mrburke@gmail.com
' http://erdrick.com
'
' 1-day QuickBasic-tro
' Done the day of the demo compo
' for blockparty 2008

DIM colorbrand(0 TO 9) AS INTEGER
colorbrands = 8
curcolorbrand = 0
colorbrand(0) = 1
colorbrand(1) = 9
colorbrand(2) = 3
colorbrand(3) = 11
colorbrand(4) = 14
colorbrand(5) = 6
colorbrand(6) = 3
colorbrand(7) = 7
colorbrand(8) = 9
colorbrand(9) = 10
'colorbrand = ( 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 )

octave = 1

line1$ = " > L16 C P16 C P16 < G A > C < A"
line2$ = " > C P16 C P16 < G A > C < G"
line3$ = " A P16 A P16 E A P16 E"
line4$ = " A P16 A P16 E P16 L8 G"

main1$ = " > L16 C P16 > L8 E F E F E C D"
main2$ = " L4 E L8 < E > L4 D L8 < G A A#"
main3$ = " L16 B P16 L16 > G P16 L8 G L16 E P16 L8 F E D C"
main4$ = " E < C C D E G# A G#"

chorus1$ = " O1 L16 A P16 > A P16 L8 A E A < A > C D"
chorus2$ = " E F E L4 D C L8 < B"
chorus3$ = " > L16 E P16 F P16 E P16 L4 E L48 D# L4 E L40 D L8 E"
chorus4$ = " L16C P16 < L32 C P32 < G P32 A P32 > C P32 P16 L32 C P32 P4 L4 < G"

bridge1$ = " > L16 F P16 F P16 E F P16 E < E > P16 E P16 D E D C"
bridge2$ = " < A P16 A P16 A G A B > C P16 C P16 D C D E"
bridge3$ = " L16 G P16 F P16 G F P16 D < E > P16 E P16 E D C < B"
bridge4$ = " A P16 B P16 > C < B > C < A > E P16 C P16 D E D P16 < "
bridge5$ = bridge1$
bridge6$ = bridge2$
bridge7$ = bridge3$
bridge8$ = " A P16 B P16 > C < B > C D E P16 C P16 A P16 P16 P16 < "

playstr$ = " O0" + line1$ + line2$ + line3$ + line4$
playstr$ = playstr$ + playstr$
playstr$ = playstr$ + main1$ + main2$ + main3$ + main4$
playstr$ = playstr$ + chorus1$ + chorus2$ + chorus3$ + chorus4$

playstr$ = playstr$ + bridge1$ + bridge2$ + bridge3$ + bridge4$ + bridge5$ + bridge6$ + bridge7$ + bridge8$

playstr$ = playstr$ + playstr$

'PLAY playstr$
lastone = 1
nextone = 0

CLS

   'top border
     COLOR 8
     PRINT CHR$(213);
     FOR i = 1 TO 76
        PRINT CHR$(205);
     NEXT
     PRINT CHR$(184)

quit = 0
WHILE quit = 0
  nextone = INSTR(lastone + 1, playstr$, " ")
  IF nextone = 0 THEN GOTO exi
  IF INKEY$ <> "" THEN GOTO exi
  
  segment$ = MID$(playstr$, lastone + 1, nextone - lastone)
  PLAY segment$
  
  char$ = MID$(segment$, 1, 1)
 
  'PRINT char$
  IF (char$ = ">") THEN octave = octave + 1
  IF (char$ = "<") THEN octave = octave - 1
  'IF (Char$ = "P") THEN
  '   COLOR 8
  '   PRINT CHR$(198);
  '   FOR i = 1 TO 76
  '      PRINT CHR$(205);
  '   NEXT
  '   PRINT CHR$(181)
  'END IF

  IF (ASC(char$) >= 65 AND ASC(char$) <= 71) THEN
     COLOR 8
     PRINT CHR$(179);

     COLOR colorbrand(curcolorbrand)
     curcolorbrand = (curcolorbrand + 1) MOD colorbrands
     IF (ASC(char$) > 66) THEN
        curnote = ASC(char$) - 66
     ELSE
        curnote = ASC(char$) - 59
     END IF

     coolstr$ = ""

     stopat = octave * 8 + curnote

     FOR i = 1 TO stopat
        coolstr$ = coolstr$ + CHR$(178)
     NEXT
     coolstr$ = coolstr$ + CHR$(177) + CHR$(176) + " " + CHR$(176) + CHR$(177)
     FOR i = 1 TO 33 - stopat
        coolstr$ = coolstr$ + CHR$(178)
     NEXT
     PRINT coolstr$;
     FOR i = 0 TO LEN(coolstr$) - 1
        PRINT MID$(coolstr$, LEN(coolstr$) - i, 1);
     NEXT
     COLOR 8
     PRINT CHR$(179)
  END IF

  lastone = nextone
WEND

exi:

   'bottom border
     COLOR 8
     PRINT CHR$(212);
     FOR i = 1 TO 76
        PRINT CHR$(205);
     NEXT
     PRINT CHR$(190)

PRINT
COLOR 14
PRINT "by mrb for blockparty 2008"
PRINT "1-day quickbasic-tro"
PRINT
COLOR 10
PRINT "greets: #mod_shrine"
PRINT "        #blockparty"
PRINT "        #vgfun"
PRINT "        #vgmix"
COLOR 12
PRINT "        " + CHR$(219);
COLOR 15
PRINT " Canada ";
COLOR 12
PRINT CHR$(219)
COLOR 7
PRINT


