
           N  E  O  N  T  U  B  E      6 3 b  /  5 2 b 

-------------------------------------------------------------------

H e a d e r

63/52 bytes MSDOS Demo Effect by HellMood / DESiRE
placed 3rd at combined 256 bytes compo at Synchrony 2016
http://synchrony.nyc/

-------------------------------------------------------------------

I n f o r m a t i o n

In the past months, I've done a lot of tunnel-like effects or
similar (just have a look at 
http://www.pouet.net/user.php?who=97586&show=credits)
When it comes down to the 64 bytes category, there seems to be
one demo, which counts as THE tunnel effect, namely "constant
evolution" from ryg/Farbrausch, winning the 64b compo of the
"0a000h" party in 2003. While i was never basing my effects on rygs
code (what becomes apparent when you compare sources) i was asking
myself, how much can i improve on the state of the art tunnel in
64b and/or how small could the size of a percieveable tunnel effect
be? Things i didnt like in "constant evolution" (after being 
amazed, of course ;)

 - Not ESCapable
 Absolutely not a sin back then, but still a nice to have feature
 and of course one of the best ways to make use of spared bytes

 - Not centered
 This bugs me maybe WAY more than it should, but a tunnel has to
 be centered perfectly in the center of the screen. "constant evo-
 lution" does some kind of two pass calculation for each x and y,
 allowing just one offset to be added to either of x and y. ryg
 went for 130, obviously right in the middle of 100 (200 / 2) and
 160 (320 / 2). 

 - Colors
 Hands down, the colors are UGLY. I understand, that the low
 resolution based flickering is toned down by colors which
 have low distances to each other, but still! 

 - Depth perception
 This one is a little bit more subtle. As the tunnel spins exactly
 the distance you "move in", parts of the texture seem not to move
 resulting in a stationary and local feeling.

All the things mentioned above are "fixed" in NeonTube, while the
size is even smaller - 63 bytes. If i go wild and just optimize
for size, ignoring quality and user-friendlyness, the tunnel can
be done in 52 bytes. This does not count for the two bytes needed
for improving the standard VGA palette (making a 50 bytes version
possible, but beeing ugly and pointless imho)

It's noteworthy, that there are - literally - thousands of ways
to fill 12 bytes with extra functionality and features. For the
"nano" competition of Synchrony 2016 i went for smoothness,
tuneable speed, texture completion (no hard cuts on either axis)
and platform compability. The 63b version is by no means the "best"
,nor is it fully size optimized, it's just one you show in a com-
petition, rather than a chunky, misaligned, way too fast running
52 bytes version, which cannot be "ESC"aped :D

A note on compability : All versions are verified to run on DosBox,
FreeDos, and Windows XP Dos. Should run fine on MSDOS, too. If you
experience any errors or problems, don't hesitate to contact me!

-------------------------------------------------------------------

Y o u t u b e

The 63b version is available here :
https://www.youtube.com/watch?v=zxw-XFgdC7s

Note : it's WAY smoother if you watch on a real system. The speed
is actually tuned for real machines, thus improving the smoothness.
If you just have a DosBox at hand, wait for my "easy tunnel config"
extra, or change the speed manually at "add word [bp+si],byte 23"

-------------------------------------------------------------------

T h e   t r i c k s

You're eager to see how the hell it was possible to "beat" an 
already excellent 64b effect by 12 bytes? You'll have to be patient
just a little more :D Seriously, there is a LOT stuff going on in
these tiny bastards, and if i do a writeup, i'd rather do it right
and later, than now and sloppy ;)

-------------------------------------------------------------------

G r e e t s   a n d   R e s p e c t

go to : 

homecoded, rrrola, frag, Baudsurfer, Optimus, p01
Sensenstahl, Whizart, g0blinish, Rudi, orbitaldecay,
igor, Drift, Oscar Toledo, wysiwtf, ryg
 ... and all DESiRE members =)

-------------------------------------------------------------------

C o n t a c t

helmut.toedtmann@gmail.com

-------------------------------------------------------------------
