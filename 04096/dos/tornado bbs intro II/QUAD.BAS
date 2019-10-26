CLS
DIM Inpt AS STRING * 1
OPEN "bob.raw" FOR BINARY AS #1
OPEN "bob.qad" FOR BINARY AS #2
FOR a = 0 TO 29
FOR i = 1 TO 30
GET #1, i + (a * 60), Inpt
PUT #2, i + (a * 30), Inpt
NEXT i
NEXT a
CLOSE #2
CLOSE #1

