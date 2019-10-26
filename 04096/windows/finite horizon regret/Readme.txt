Finite Horizon Regret by Fulcrum
================================
Finally a big 4K again :) 

Credits:
--------
Code, design:		Seven/Fulcrum
Music:			Coplan/Fulcrum
3th party tools used: 4Klang, Crinkler, and Shader Minifier

Requirements
------------
* A fast video card with lots of Pixel Shader 4.0 compatible shader pipelines.
* 300 Mb ram for the Crinkler decompression
* Windows XP or higher
* 4 kb diskspace

About the intro
---------------
After Revision, and the defeat of our Fractus 4K to the artistically way superior Hartverdrahtet
by Akronyme Analogiker, I knew we had to get an artist involved to improve our 4Ks. But
unfortunately the intersection between artists and people comfortable with GLSL is not so big...
So I had an idea to make a tool a la Werkzeug, with immediate visual feedback for selected
variables.

Of course, developing such a thing blindly is a receipt for something unusable, so I alpha-
tested the tool by making a quick invitro-4K (Schtrombloxke) for Rewired, a Belgian demoparty,
and then a remote entry for Rewired itself, which won the intro/democompo (Schtrombloxke).
During this time, plenty of missing functionality was identified and haphazardly added (better
responsiveness, hardcoded 4Klang integration, error logging,...). We also tried to find the
elusive artist with some code knowledge, or coder with a sense of aestethics, but our best bet
had a serious real-life interruption (Hi A0a! Congrats again on becoming a father!)

With Rewired having moved a week, we had less than a month for the real, polished 4K, that I
wanted to do for Assembly. I had some vague idea about clockwork fractals morphing into flowers,
and Coplan volunteered to do the music (probably without knowing how many tweaks and changes
he'd have to make the next week :)) The final result doesn't quite match what I was aiming for
at the start in some areas (no room for text greeting f.e.), but exceeds it in others. All in
all I'm quite happy with it, and all the work on the tool payed off even though it was used by me
instead of a real artist.

There is still a problem with the fonts at resolutions different than the compo version, so I'll
make different versions later, when I'm less sleep-deprived...

Thank you to...
---------------
- Patson/Lost Function for his valuable feedback at Assembly, the idea to try something
  depth-of-field like, and his monitor I could use at Assembly.
- Rune L. H. Stubbe (Mentor/TBC) and Aske Simon Christensen (Blueberry/Loonies) for Crinkler.
- Dominik ´Gopher´ Ries and Paul ´pOWL´ Kraus of Alcatraz for 4klang.
- Ctrl-Alt-Test for their Shader minifier.


Troubleshooting
---------------

* Help, it crashes!

Hmm, sorry for that. If you want to help troubleshoot this (test debug versions and send back
logfiles), mention the crash at the Pouet.net page for this production. Note that the intro
doesn't use any exotic libraries, only opengl32.dll and stuff like kernel32.dll. So even though
it was compressed with Crinklers /UNSAFEIMPORT (which does not warn if dlls are missing), that
really shouldn't be a problem.

One thing I noticed, is that all my programs compiled with VS6 (yes, ancient...) trigger an
"this program tries to access the internet" warning from ZoneAlarm. Not sure what causes this,
as I'm certainly not doing anything net-related.

* I can hear the music, but I only see a solid green or red screen!

This means the video card drivers could not compile the shaders correctly. First, you need a
Pixel Shader 4.0 compatible graphics card. Next, *UPDATE YOUR VIDEO CARD DRIVERS*. To save space,
this intro uses some tricks such as using integer numbers instead of floats, which saves a byte
(no dot needed). This is allowed in recent OpenGL Shader Language revisions, but old drivers are
more strict and will refuse to compile the shaders, even if the hardware could run the shader.
So, update those drivers!

* Man, this thing runs slow!
As with all spheretracing/raymarching with distance fields intros, the speed depends only on the
number and speed of shader pipelines on your graphic cards, versus the number of pixels that need
to be rendered. The speed of your CPU, the amount of RAM, the amount of video card memory etc
have very little influence. Try running one of the alternate versions at a lower resolution,
but be sure to read the next question and answer as well.

Also make sure to disable all other programs that draw on the screen, such as WinAmp in
always-on-top mode, things that use the GPU as well (accelerated video decoding, including
youtube browsing), or stuff that displays always-on-top notifications.

* Is it supposed to look like this?

This intro should be AMD and Nvidia compatible (tested on an AMD 5770HD and Nvidia GT540M, but
both are too slow to run it at 720p), but due to the cone marching, it is picky about the display
resolution, which should be divisable by 32 in both X and Y directions. All the versions in the
archive are for resolutions that satisfy this condition. If you have a different resolution
(such as 1600*1050 or 1366*768), pick a lower resolution one.

If you still see corruption (in the form of distorted objects in a strip at the top or right side
of the screen), try the following:
- Set your desktop resolution to the same resolution of the intro you want to run.
- Turn the auto-scaling options off in the Nvidia control panel or Catalyst Center, use 
  letterboxing if possible. 

The aim is to make sure the actual resolution matches the size of the rendertargets that are used
internally, if those do not match the intro will look corrupt.

Also, if objects have holes in them or are black, try updating your video drivers.
