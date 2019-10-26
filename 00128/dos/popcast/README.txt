hi there!

this is the readme to "Popcast", an entry
for the 128b Compo of the "Outline" in 2014

this folder should contain 6 files:

README.txt - this file
popcast.com - a binary file for use with MSDos
popcast.asm - documented source code
popcast.nfo - the nfo file
p1popcast.png - a screenshot of the first effect
p2dragon.png - a screenshot of the second effect

the demo was tested with DosBox 0.74 on Windows 7
and with an MsDos 6.22 on Oracle VM Virtual Box

*** SHORT GUIDE :

Right after the Start, you should see the popcast effect.
the intended effect is the fusion of light and matter
from the top left, down to the right bottom

Hit -SPACE- to see the next effect.

The second effect is a real classic, the dragon, 
this time in 640*480 with iteration history coloring.

Hit -ENTER- to see the previous effect.

Hit -ESC- to quit the demo at any time.

*** ATTENTION :

This Demo alters between two resolutions
320*200*256   and   640*480*16
Please give your hardware time to switch
and be aware of possibly odd effects
on projectors and similar hardware

On the Oracle VM Virtual Bos with MsDos 6.22
the mouse can interfere with Port 0x60
It is totally possible to switch and exit
with mousemovments. Please be aware!

The Dragon should require no hardware power
at all, but the Popcast effect may be slow
on old hardware. 60'000 Cycles on DosBox is
a good value to show this effect.

*** BACKGROUND :

Not long ago, i saw the rerelease of "Floorcast"
by Baudsurfer, fitting the effect in 64b
I thought about doing something similar
but way more colors and light, through 
indexing our beloved VGA palette. After reaching
the 64b border myself, and beeing satisfied
somewhat, i asked myself if and how to fill the
rest of 128b. After having a talk to a good friend
of mine, Felix, who released "DragOnDrop" at the
JS1K 2014, i was inspired to do something similar
myself. I ended up with suprisingly small code
which even allowed me to integrate some sloppy
keyboard menueing. Bla. Bla. Just kidding ;)

In case of emergency (a.k.a the demo does not
work) please contact me :

storrryteller@hotmail.com
