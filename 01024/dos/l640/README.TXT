             HTTP://WWW.MYCHOICE.NET/R396
           Technical papers for programming the pc.I have written
a small demo in assembly language that shows how to access the mode 5dh.This
mode is normally the one windows uses and i have seen a lot of game demos 
use it as well.Mode 5dh is 640x480 in 256 colors.The demo sets up the screen
and displays all 256 colors in a row down the screen then it waits for you
to press a key before returning to the default text mode which is normally
0x03.This demo would be too slow to make a game out of since it uses dos
write dot routine.I am writeing a updated demo that display directly to the
screen without dos which will be as fast as you can get.If anyone is working
with the mode 13h which is 320x200x256 colors and they are haveing trouble,
email me at the address at the bottom and i will help you with the code for it.
Now if you hit a key and the demo does not return to the default text screen,
that means you have hit a special key and you will have to hit another key.
I have wrote the program to repoll the keyboard if the return is 0 in al.
I have also included the source code for you to improve on or do what you
want to with it.I used tasm assembler from borland to assemble it but most
should work.If you are new to assembly programming and you have downloaded
this then i would suggest you go to game developers jumpsite and look around.
There is a lot of info on the instruction set and examples on most of them.
http://www.ben2.ucla.edu/~permadi/gamelink/gamelink.html
------------------------------------------------------------------------------
Programming in assembly is not that difficult,i have been programming for 10
years.I started on the color computer 2 from radio shack/tandy corp.I have
made several game demos for the cocos and i am now makeing them for the pc.
I can be reached at r396@mychoice.net for any questions you might have.
Thank you
sidekick
