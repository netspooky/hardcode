ÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛ
Û                                  Blaze                                   Û
ÛÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÛ
Û  Source code for Blaze                                                   Û
Û                                                                          Û
Û  Programmer: Gopher aka Anthony J. Mills <softwaremills@geocities.com>   Û
Û                                                                          Û
Û  Mail address: Box 4566                                                  Û
Û                Three Hills, AB                                           Û
Û                Canada T0M 2N0                                            Û
Û                                                                          Û
Û  Visit my web page at http://www.geocities.com/CapeCanaveral/7258 for    Û
Û  my latest computer gadgets.                                             Û
Û                                                                          Û
Û  Blaze is freeware. Even if you use it for an extended period of time,   Û
Û  you are NOT in any way obligated to send me any money. However, having  Û
Û  said that, IF you like the program, send me a postcard or an email      Û
Û  message. If you use any of the source code, please send me a copy of    Û
Û  the resulting program and give acknowledgment in your source code,      Û
Û  even as I have in mine.                                                 Û
ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ


* The Fire Algorithm:

Most fire routines are built on two simple ideas: the heat of a fire dis-
sipates as it rises and as it rises, it 'blurs' together. This means that if
you think about the screen, pixels just below the screen are written with a
value of either 255 or 0, depending on a random number. Each pixel on the
screen, if assigned a coordinate (x,y), is really the average of the pixel
values at (x-1,y+1), (x,y+1), and (x+1,y+1).

That is the basic idea in fire simulations. Few adaptations (including this
one) follow the formula precisely.


* This implementation:

The Palette

The palette set up by the program, going from colours 0 to 255, increases
from black to red to yellow to orange to white to blue to black.

The Algorithm

Instead of calculating each pixel, Blaze takes a slightly lazier, yet no
less visually stunning, approach. It calculates the fire in 2x2 blocks
(called pocks for "pixel blocks"). Mathematically expressed, the pixel value
for each pock is calculated as follows:

  p(x,y) = (p(x-1,y+1) + p(x,y+1) + p(x+1,y+1) + p(x+1,y+2)) / 4 - 1

Once the pocks are calculated and placed in the program's inner buffer, the
image is blurred to the screen. Instead of simply copying each pixel, the
pixel put on the screen is actually the average of the four adjacent pixels.
This creates the illusion that the image is seamless and not pixellated.

If enough enthusiasm is generated, I may write a fire tutor and post it to
the Internet.


* Acknowledgments:

First and foremost, I could never have taken up assembly language without
Eric J. Isaacson's wonderful A86 assembler. Though shareware and one-sixth
the size of Microsoft's MASM, it is vastly superior. Pick it up from
www.eji.com.

The functions LRnd and Randomize were taken from Mark Adler's library TCRND
(and those algorithms were taken from Knuth's _Art_of_Computer_Programming_,
vol 2, 2nd ed.)

The flame algorithm was taken from code written by Keith DeGruce included
with TMT Pascal Lite.

The vertical retrace wait section was taken from _PC_Underground_ by
Bertelsons, Rasch, & Hoffmann.


* Development history:

Keith DeGruce's Pascal code provided the starting point for Blaze. When I
ran it for the first time I was struck by the coolness of the effect. In
fact, I haven't seen, even now, a better computer fire simulation. However,
even with protected mode Pascal, the flames were jerky and only took up half
the screen. Worse, the simulation ran in mode 13h with 2x2 "pixels" giving
a rather blocky effect. I knew if it were rewritten in assembler it would
run faster, but I didn't know how to program random numbers in assembler.

Then I remembered TCRND, a library I had downloaded off the Internet. I took
a few routines from it and found to my surprise I had random numbers! After
about a day, the simulation ran well.

My next idea was to implement a video buffer for faster rewrites. It did
pick up the speed by a wide margin.

Fooling around with the original in Pascal, I found a way to increase the
height of the flames. I also readjusted the palette to make the flames seem
hotter.

Pixellation was still a problem. After trying desperately to change the
algorithm to calculate each pixel, I hit on a solution: just blur the image
when transferring it to the screen. I used about the simplest blur filter I
knew and it worked perfectly! The image quality has increased fourfold just
because of that minor adjustment.

Many of the people I showed the program to asked for it in a screen saver.
So, I browsed around on the Internet and found how to make a screen saver.

This final incarnation is a result of the hassles of keeping up six source
files or more. !BLAZEMC.8 has all the macros necessary for building any one
of the programs. It also is extensively documented. For an example of how
to use the macros, look at BLAZE0.8.


* Special thanks:

First, to Keith DeGruce; without his algorithm I would never have thought of
this.

Second, to Mark Adler, for making TCRND.

Third, to my father, for making suggestions.

Fourth, to everyone who reads this file. I wish you a happy time under-
standing my code. It is always hard to read another person's code, even if
it is the best-documented code in the world. Which mine isn't, but I did try
to make it the best I could.


* About the author:

I, Anthony J. "Tony" Mills, am a high school senior at Prairie High School in
Three Hills, Alberta. Besides computer programming, which I took up in fourth
grade, I like to read, play chess, tear around on my mountain bike (espec-
ially in the winter), surf the Internet, and send email. When I'm not spend-
ing time with my girlfriend :-).


* How to use the macros:

Look at BLAZE?.8. They provide examples. When you compile them, the command
line is:

  a86 !blazemc.8 blaze0.8 blaze0.com

If you know how to use A86, you can think of some easier ways.
