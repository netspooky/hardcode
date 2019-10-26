Victori Te Salutant by Fulcrum
==============================
A party-coded single effect 4K intro for Outline 2014

Credits:
--------
Code, "design":	Seven
Music, "design":  The Watcher
3th party tools used: Clinkster, Crinkler

Requirements
------------
* A fast video card with lots of Pixel Shader 4.0 compatible shader pipelines. The compo machine has a nvidia Titan, so excuse us for not going the last mile. Tested on both Nvidia and AMD cards
* 300 Mb ram for the Crinkler decompression
* Windows XP or higher
* 4 kb diskspace

About the intro
---------------
This intro was entirely coded at the partyplace. For the one time there are 2 Fulcrum members present, it won't do not to submit something, no matter how horrible. Hence the Comic Sans.
And the text colorscheme, which is inspired by the Outline party T-shirts.

The idea for this intro was formed at the Revision 8K compo, when I said I had added greetings just because I had room left, to which the guy sitting next to me (whose name I forgot, sorry) remarked that in 8K, you could probably greet everyone at the party. So...


Thank you to...
---------------
- Rune L. H. Stubbe (Mentor/TBC) and Aske Simon Christensen (Blueberry/Loonies) for Crinkler and Clinkster
- Iq for shadertoy, and the orbit-trapped mandelbrot fractal we used as inspiration for the floor.

Troubleshooting
---------------

* Help, it crashes!

Hmm, sorry for that. If you want to help troubleshoot this (test debug versions and send back logfiles), mention the crash at the Pouet.net page for this production. Note that the intro doesn't use any exotic libraries, only opengl32.dll and stuff like kernel32.dll. So even though it was compressed with Crinklers /UNSAFEIMPORT (which does not warn if dlls are missing), that really shouldn't be a problem. The intro partycoded on an Nvidia card, and fixed at home on and AMD card.

* I can hear the music, but I only see a solid green or red screen!

This means the video card drivers could not compile the shaders correctly. First, you need a Pixel Shader 4.0 compatible graphics card. Next, *UPDATE YOUR VIDEO CARD DRIVERS*. To save space, this intro uses some tricks such as using integer numbers instead of floats, which saves a byte (no dot needed). This is allowed in recent OpenGL Shader Language revisions, but old drivers are more strict and will refuse to compile the shaders, even if the hardware could run the shader. So, update those drivers!


* Man, this thing runs slow!

Sorry, raymarching is not very fast, and we didn't have the time or motivation to speed things up (re-calculating a static mandelbrot fractal is a crime against GPUs, I know. Sorry). Try the low-res version.

Also make sure to disable all other programs that draw on the screen, such as WinAmp in always-on-top mode, or stuff that displays notifications.
