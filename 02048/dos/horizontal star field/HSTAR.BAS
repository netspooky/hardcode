	print "This creates the file 'HSTARS.DW'"

	open "hStars.dw" for output as 1
	print #1, "TheStars Star ";

	count = 2
	Randomize (Timer)

	for I = 0 to 100
		x= int (rnd*320)
		y= int (rnd*200)

		count = count +1
		if i = 100 then

			print #1, "<";:print#1, using "###"; x;:print #1, ",";
			print #1, using "###"; Y;
			print #1, ",0>"

		else
			if count > 6 then

				print #1, "<";:print#1, using "###"; x;:print #1, ",";
				print #1, using "###"; Y;
				print #1, ",0>"
				count = 1:print #1, " Star ";

			else

				print #1, "<";:print#1, using "###"; x;:print #1, ",";
				print #1, using "###"; Y;
				print #1, ",0>,";

			end if
		end if
	NEXT

	close #1
