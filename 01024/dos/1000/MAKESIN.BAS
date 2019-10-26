' €¬«æ «¦ §¨áš£˜, ­« á®¤œ  « ª « £œª «žª ©¬¤˜¨«ž©žª «¦¬ ž£ «æ¤¦¬
' §¦¬ ®¨ž© £¦§¦ é ©«¦ asm.
In% = 0
OPEN "SIN.INC" FOR OUTPUT AS 1
FOR i% = 0 TO 127
    ' 128    angle! |
    ' 360      a!   |  a! = 360 * angle! / 128
    '
    a! = 360! * i% / 128
    aInPI! = a! * 3.141593 / 180
    n% = SIN(aInPI!) * 128
    IF n% = 128 THEN n% = 127
    IF In% = 0 THEN
        PRINT #1, "db"; CHR$(9); CHR$(9); n%;
    ELSE
        PRINT #1, ","; n%;
    END IF
    In% = In% + 1
    IF In% >= 10 THEN
        PRINT #1, ""
        In% = 0
    END IF
NEXT i%
CLOSE

