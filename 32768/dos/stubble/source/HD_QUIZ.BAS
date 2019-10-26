TYPE kerdestype
 kerdes AS STRING * 90
 valaszok AS STRING * 60
 jovalasz AS STRING * 1
END TYPE

DATA "1. How old is HarDread?","[A] 5 years [B] 10 years [C] 13 years","C"
DATA "2. How many compos have HarDread won so far?","[A] 0  [B] 4 [C] 1","B"
DATA "3. Which musician did NOT make music for HarDread?","[A] Gargaj [B] slyspy [C] Pasy (guitar+singing)","C"
DATA "4. Which is the worst result of HarDread in a compo?","[A] 17th at NVScene 2008 [B] 9th at Breakpoint 2004 [C] 12th at Breakpoint 2005","A"
DATA "5. Who fixed the intro called `stubble` at Breakpoint 2005?","[A] tsw [B] gargaj [C] Pasy","A"
DATA "6. How many times did HarDread release something at Function (including this one)?","[A] 3 [B] 7 [C] 13","B"
DATA "7. How many podcast episodes did HarDread release?","[A] 23 [B] 37 [C] 44","C"
DATA "8. Which game did HarDread release at Function 2012?","[A] never_ending_warning [B] space invaders 2p [C] psychocat","B"
DATA "9. What platform did `Do you love` demo use?","[A] C64 [B] Amiga 1200 [C] Lego Mindstorms NXT","C"
DATA "10. Which Conspiracy 64k was remade in 4k by HarDread?","[A] A place called universe [B] Beyond [C] Chaos theory","A"

REM init
CLS
score = 0
DIM kerdesrek AS kerdestype

REM intro
PRINT "HarDread Quiz"

FOR i = 1 TO 10
READ kerdesrek.kerdes, kerdesrek.valaszok, kerdesrek.jovalasz
PRINT
PRINT kerdesrek.kerdes
PRINT kerdesrek.valaszok
INPUT a$
IF UCASE$(a$) = kerdesrek.jovalasz THEN score = score + 1
NEXT

REM vege
PRINT "Score: "; score; "/10"
PRINT "Thank you for playing our little game! :)"
PRINT
PRINT "Code: pohar"
PRINT "Released at Function 2014"
INPUT a$

END



