'
'Written by: Draeden /VLA
'      Date: 03/15/93
'
'     Notes: Used for generating 'random' data for Stars.asm
'


	NumStars = 400
	dim     RndArray(NumStars)
	randomize (timer)

	'fill the array with numbers from -Numstars/2 to -10
	'and from 10 to Numstars/2

	i=10
	for r = 0 to NumStars/2
		RndArray(r)=i
		i=i+1
	next
	i=-10
	for r = NumStars/2 to NumStars
		RndArray(r)=i
		i=i-1
	next

	'randomly shuffle them..

	print "Total numbers: ";NumStars
	print "Shuffling - Please wait... "

	for q = 1 to numstars/5
		for r = 0 to NumStars
			swnum1 = int(rnd*NumStars+.5)
			swap RndArray(swnum1),RndArray(r)
		next
	next

	'write the numbers neatly to a file

	open "starrnd.dw" for output as 1
	cc= 0
	print#1, "StarRnd dw ";:print#1, using"####";RndArray(0)
	for r = 1 to NumStars

		IF cc=0 THEN
			print#1, "dw ";:print#1, using"####" ;RndArray(r);
		ELSE 
			print#1, ",";:print#1, using"####"; RndArray(r);
		END IF

		cc=cc+1:if cc= 10 then cc=0:print#1," "
	next
	close #1



