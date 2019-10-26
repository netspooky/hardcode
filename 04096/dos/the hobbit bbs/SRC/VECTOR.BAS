CONST PI = 3.141595
DIM ARRAY(1000)
PIXELS = 0
BYTES = 0
SCREEN 13
RESTORE DATI
READ XOFF, YOFF
DO
  READ A
  IF A <> -1 THEN
     READ B, C, D
     A = A + XOFF - 160: B = B + YOFF
     C = C + XOFF - 160: D = D + YOFF
     ARRAY(BYTES + 0) = A - 256 * INT(A / 256)
     ARRAY(BYTES + 1) = INT(A / 256)
     ARRAY(BYTES + 2) = B
     ARRAY(BYTES + 3) = C - 256 * INT(C / 256)
     ARRAY(BYTES + 4) = INT(C / 256)
     ARRAY(BYTES + 5) = D
     BYTES = BYTES + 6
     PIXELS = PIXELS + ABS(C - A) * ABS(D - B)
     LINE (A + 160, B)-(C + 160, D), , B
  ELSE
     ARRAY(BYTES) = 255
     ARRAY(BYTES + 1) = 255
     BYTES = BYTES + 2
  END IF
LOOP WHILE A <> -1
LOCATE 18, 1
PRINT "Total bytes:  "; USING "######"; BYTES
LOCATE 19, 1
PRINT "Total boxes:  "; USING "######"; (BYTES - 2) / 6
LOCATE 20, 1
PRINT "Total pixels: "; USING "######"; PIXELS
LOCATE 21, 1
PRINT "Press any key to animate"
COLOR 15
DO
  A$ = INKEY$
LOOP WHILE A$ = ""
IF A$ = CHR$(27) THEN END
ANGLE = 0
DO
  CLS
  LOCATE 21, 1
  PRINT "Press any key to save data"
  BY = 0
  DO
    X0 = ARRAY(BY + 0) + ARRAY(BY + 1) * 256
    IF X0 <> 65535 THEN
       Y0 = ARRAY(BY + 2)
       X1 = ARRAY(BY + 3) + ARRAY(BY + 4) * 256
       Y1 = ARRAY(BY + 5)
       X0 = X0 * COS(ANGLE) + 160: X1 = X1 * COS(ANGLE) + 160
       LINE (X0, Y0)-(X1, Y1), , BF
       BY = BY + 6
    END IF
  LOOP WHILE X0 <> 65535
ANGLE = ANGLE + PI / 10
A$ = INKEY$
LOOP WHILE A$ = ""
IF A$ = CHR$(27) THEN END
OPEN "VECTOR.ASM" FOR OUTPUT AS #1
N = 0
FOR I = 0 TO BYTES - 1
        IF N = 0 THEN
                PRINT #1,
                PRINT #1, CHR$(9); "DB"; CHR$(9);
        ELSE
                PRINT #1, ",";
        END IF
        N = N + 1: IF N = 8 THEN N = 0
        PRINT #1, ARRAY(I);
NEXT I
CLOSE #1
END


DATI:
        REM  CENTRAGGIO
        DATA 0, 50

        REM T
        DATA 1,0,58,6
        DATA 23,7,33,49

        REM h
        DATA 41,10,48,49
        DATA 64,35,49,31
        DATA 57,36,64,49

        REM e
        DATA 69,31,74,49
        DATA 75,31,82,35
        DATA 75,39,82,41
        DATA 83,31,85,41
        DATA 75,48,85,49

        REM H
        DATA 104,0,111,49
        DATA 112,27,128,32
        DATA 129,0,136,49

        REM o
        DATA 141,31,145,49
        DATA 146,31,157,35
        DATA 146,46,157,49
        DATA 153,36,157,45

        REM b
        DATA 161,15,166,49
        DATA 167,31,173,35
        DATA 167,46,173,49
        DATA 174,31,179,49
        
        REM B
        DATA 183,0,190,49
        DATA 191,0,203,5
        DATA 191,21,216,26
        DATA 191,45,216,49
        DATA 204,0,210,20
        DATA 207,27,216,44

        REM I
        DATA 220,0,228,49

        REM T
        DATA 232,0,276,6
        DATA 249,7,258,49

        REM BBS
        DATA 281,27,283,49
        DATA 284,27,289,29
        DATA 284,37,291,39
        DATA 284,48,291,49
        DATA 288,30,289,36
        DATA 289,40,291,47

        DATA 294,27,296,49
        DATA 297,27,302,29
        DATA 297,37,304,39
        DATA 297,48,304,49
        DATA 301,30,302,36
        DATA 302,40,304,47
        
        DATA 307,27,319,28
        DATA 307,29,308,39
        DATA 309,37,319,39
        DATA 318,40,319,47
        DATA 307,48,319,49
        DATA -1

