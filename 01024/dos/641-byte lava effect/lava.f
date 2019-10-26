(
	lava.f
	plasma effect in mode 13h, for ForthEC
	/Mic, 2005
)

VARIABLE sinetable 256 ALLOT
VARIABLE x1
VARIABLE x2
VARIABLE x3
VARIABLE x4
VARIABLE y1
VARIABLE y2
VARIABLE y3
VARIABLE y4

\ Set mode 13h
0x13 A! 0x10 INTERRUPT

\ Set up ES to point to video memory
0xa000 ES!

\ calculate the sine table 
sinetable
256 0 DO
	I FLOAT 0.02554e0 F* FCOS 31.4e0 FSWAP FOVER F* F+
	FLOOR OVER C! 1+ LOOP

\ Set up the palette
256 0 DO
	I 0x3C8 OUTP
	I 127 > IF 63 ELSE I 1 >> THEN 0x3C9 OUTP
	I 1 >> DUP 63 > IF DROP 63 THEN 0x3C9 OUTP
 	I 2 >> 0x3C9 OUTP LOOP

\ Initialize variables
0 x3 W! 0 x4 W! 0 y3 W! 0 y4 W!

BEGIN
y3 W@ y1 C! y4 W@ y2 C!			\ Copy variables
0					\ Screen offset
200 0 DO
	y1 C@ 1- y1 C! y2 C@ 2 + y2 C!	\ Update variables
	x3 W@ x1 C! x4 W@ x2 C!		\ Copy variables
	320 0 DO
		x1 C@ 1+ x1 C! x2 C@ 2 + x2 C!
 		sinetable DUP DUP DUP
 		C@ SWAP x1 C@ + C@ + SWAP x2 C@ y1 C@ + 255 AND + C@ +
		SWAP y2 C@ + C@ +
		OVER C:ES!		\ Store pixel data
		1+			\ Increment screen offset
	 	LOOP
	LOOP DROP
x3 C@ 1- x3 C! x4 C@ 3 + x4 C! y3 C@ 2 - y3 C! y4 C@ 1+ y4 C!
0x60 INP A@ 255 AND 1- 0= UNTIL		\ Check if [Esc] is pressed
3 A! 0x10 INTERRUPT			\ Set textmode
BYE					\ Exit to DOS

