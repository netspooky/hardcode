Regression by Fulcrum
=====================
A single effect 8K intro for Revision 2014

Credits:
--------
Code, design:	Seven
Poem:			Coplan
Music:		Ranger Rick
3th party tools used: Clinkster, Crinkler

Requirements
------------
* A very fast video card with lots of Pixel Shader 4.0 compatible shader pipelines. It probably needs something like a 7950 to run nicely. Should run on Nvidia and AMD, unless I broke something at the partyplace, in which case I'll fix the AMD version at home. If the card can't show the intro at 60 FPS, the music will run out before the intro ends, because it can't skip frames. 
* vertical retrace sync should be enabled in the driver!
* 300 Mb ram for the Crinkler decompression
* Windows XP or higher
* 8 kb diskspace

About the intro
---------------
I started exploring ideas for an 8K in Januari, but they all proved to be dead-ends. At the end of Februari, I decided to revisit an old effect I made 15 years ago: reverse filter effects. I used those in 2 DOS 4K intros (Turn it Back 1 and 2, see here http://www.pouet.net/groups.php?which=11618 ) and I was curious if I could get them ported to a modern videocard. That turned out to be possible, but the old fire and water effects haven't aged well.

Then I started wondering about fluid dynamics, which is a few orders of magnitude harder to revert, because it uses 4-5 times more memory, 30-50 times more GPU power and keeps state around forever. Yet, by choosing your content carefully, and counting on the very high-end compo machine videocard, a demo can get around the mathematical impossibility :) Designing the intro was a pain because the effect is fully sequential, you can't skip frames, and fluid dynamics are chaotic, every little change can have a big impact a few seconds later. So after every tweak, I had to rewatch most of the intro again and again and again, at slower than realtime speed...

While I didn't have the time to fully exploit the 8K space that's available, I'm quite happy with the result. I hope you like it!


Thank you to...
---------------
- Kaatje, Merel & Lander for support
- Rune L. H. Stubbe (Mentor/TBC) and Aske Simon Christensen (Blueberry/Loonies) for Crinkler and Clinkster
- Pixtur for his awesome design seminar
- Las and Chaos for being patient with me testing this on the compo machine.
- the rest of the greetings are in the intro, for once :)


Troubleshooting
---------------

* Help, it crashes!

Hmm, sorry for that. If you want to help troubleshoot this (test debug versions and send back logfiles), mention the crash at the Pouet.net page for this production. Note that the intro doesn't use any exotic libraries, only opengl32.dll and stuff like kernel32.dll. So even though it was compressed with Crinklers /UNSAFEIMPORT (which does not warn if dlls are missing), that really shouldn't be a problem. The intro was started on an AMD card, and finished at the partyplace on an Nvidia card. If it doesn't run on both, I'll fix things at home.


* I can hear the music, but I only see a solid green or red screen!

This means the video card drivers could not compile the shaders correctly. First, you need a Pixel Shader 4.0 compatible graphics card. Next, *UPDATE YOUR VIDEO CARD DRIVERS*. To save space, this intro uses some tricks such as using integer numbers instead of floats, which saves a byte (no dot needed). This is allowed in recent OpenGL Shader Language revisions, but old drivers are more strict and will refuse to compile the shaders, even if the hardware could run the shader. So, update those drivers!


* Man, this thing runs slow!

Sorry, despite not doing raymarching for once, I still managed to make a rather slow intro... Reverse fluid dynamics are rather difficult to do, and I've already resisted the temptation to increase the quality just because the compo machine could run it... Notice that the 1920*1080 version uses 1280*720 textures internally, because otherwise the effect looks completely different. So the two versions should run about the same speed.

Also make sure to disable all other programs that draw on the screen, such as WinAmp in always-on-top mode, or stuff that displays notifications.
