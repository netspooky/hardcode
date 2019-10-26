SMALLPONG
Brad Smith, 2008


My goal for this project was to create a version of Pong that could fit into a 256 byte limit. I eventually achieved this goal, but I have included 3 versions of the program (with source code) to show how it was done. All versions were assembled with FASM (http://flatassembler.net/).

In all versions you control the left paddle with the CTRL and ALT keys. Press any other key to quit. The right paddle is controlled by the computer. The following are some version highlights:


Version 1.0: pong10.com (547 bytes)

This was written without too much concern for code size. I was really trying to get a complete set of Pong features sketched out, and getting an idea of how much code that took. 547 bytes was bigger than I had hoped.


Version 1.4: pong14.com (450 bytes)

This was the last version before I started cutting features. I had managed to cut 97 bytes away without changing the functionality of the program at all. There was a lot more that could be trimmed here, but I decided to set my sights a little lower before proceeding. It might be possible to do the 1.0 feature set in 256 bytes, but at this point it was looking like it would take a long time to figure that out.


Version 2.1: pong21.com (255 bytes)

After version 1.4, I immediately cut out any features I could that wouldn't turn this into some sort of mutant sub-Pong. I removed the score bar, coloured paddles, and took away the half-second delay after a goal, which after some minor rearangement cut me down to about 306 bytes, and my goal of 256 started to look really attainable.

After settling on this more minimal feature set, it was just a matter of time, slowly finding all the things that could be trimmed down. Replacing duplicate code with calls, rearranging the order of events and trying to maintain all my variables in the register and stack, using 8 bit immediate values wherever possible. Eventually I got it down to 255 bytes and was satisfied. I'm sure it could be smaller, but I won't be the one to figure out how.


Read comparisons.txt for a more detailed explanation of the differences from version to version.


-- Brad Smith
http://switch.to/unleaded
http://rainwarrior.thenoos.net
rainwarrior@gmail.com
