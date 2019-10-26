Worm256.com      Written by Robin J. Patenall
----------------------------------------------

This is my entry for the 256 byte worm game competition.

Requirements
------------
* 386+ Processor.
* VGA card with 256K RAM.
* Colour monitor.
* Enough RAM for DOS + 1K.
* Keyboard.
* H/D or F/D with 1 cluster free.

Files include in ZIP file
-------------------------
Readme.txt		You're reading it!
worm256.com		Executable game.
Worm256.asm		Assembler source code.
Worm256.dbg		Debug script for building executable.

Building the executable	(if you want to)
----------------------------------------
* Unzip the files

* 'DEBUG < Worm256.dbg'

Running the game
----------------
* unzip the files

* 'Worm256'

Game Instructions
-----------------
The object of the game is not to crash (into yourself, the other worm, or the
bounding wall), while trying to make your opponent crash (into themselves,
you or the wall). When one or both of the worms crash the game is over and the
screen will clear to the colour of the winning worm, or yellow if the game was
a draw. Pressing any key will return you to the dos prompt (Sorry, yes I know
the mode doesn't change back. Use 'mode co80')

The keys for the red worm (starts of the left going right)
 Z :- Turn left. (From the worm's point of view)
 X :- Turn right.

The keys for the green worm (starts of the right going left)
 < :- Turn left. (From the worm's point of view)
 > :- Turn right.


-
Robin J Patenall
ee41rp@ee.surrey.ac.uk