Lander 4K by Fulcrum
====================
Yep, a saccharine-sweet little babytro. No apologies :)

Credits:
--------
Code, design:		Seven/Fulcrum
Music:			El Blanco/Fulcrum
3th party tools used: 4Klang, Crinkler, and Shader Minifier

Requirements
------------
* A fast video card with lots of Pixel Shader 4.0 compatible shader pipelines.
* 300 Mb ram for the Crinkler decompression
* Windows XP or higher
* 4 kb diskspace
* a soundcard if you like your intros with sound

About the intro
---------------
This little babytro was supposed to be a remote entry for Rewired 2013, to explain why I couldn't (once again) visit our only Belgian PC demoparty. But Lander arrived 2 weeks earlier than expected, and while I could thus go to the party, I didn't have time nor inspiration to make anything else :) El Blanco made the music to be loopable, but I lacked the time and space for that, hence the sudden stop. Also, most versions are slightly bigger than 4K because the changes to the resolutions sometimes make Crinkler compress tens of bytes less well, and because of a last-minute fix for AMD cards.


Thank you to...
---------------
- Kaatje & Merel for support, and Lander for being the inspiration for this intro!
- IQ for Shadertoy.com, and his shadow explanation.
- Rune L. H. Stubbe (Mentor/TBC) and Aske Simon Christensen (Blueberry/Loonies) for Crinkler.
- Dominik ´Gopher´ Ries and Paul ´pOWL´ Kraus of Alcatraz for 4klang.
- Ctrl-Alt-Test for their Shader minifier.

Greetings to SubDream, Horology, Brainstorm, CMR, Psycho, Pixtur, Smash and other nice people I talked to at Revision. One day I'll make a demo again, with room for proper greetings...


Troubleshooting
---------------

* Help, it crashes!

Hmm, sorry for that. If you want to help troubleshoot this (test debug versions and send back logfiles), mention the crash at the Pouet.net page for this production. Note that the intro doesn't use any exotic libraries, only opengl32.dll and stuff like kernel32.dll. So even though it was compressed with Crinklers /UNSAFEIMPORT (which does not warn if dlls are missing), that really shouldn't be a problem.


* I can hear the music, but I only see a red screen!

This means the video card drivers could not compile the shaders correctly. First, you need a Pixel Shader 4.0 compatible graphics card. Next, *UPDATE YOUR VIDEO CARD DRIVERS*. To save space, this intro uses some tricks such as using integer numbers instead of floats, which saves a byte (no dot needed). This is allowed in recent OpenGL Shader Language revisions, but old drivers are more strict and will refuse to compile the shaders, even if the hardware could run the shader. So, update those drivers! The intro has been tested on AMD and Nvidia cards. Intel HD chipsets won't work, I'm afraid.


* Man, this thing runs slow!

As with all raymarching intros, the speed depends only on the number and speed of shader pipelines on your graphic cards, versus the number of pixels that need to be rendered. The speed of your CPU, the amount of RAM, the amount of video card memory etc have very little influence. Try running one of the alternate versions at a lower resolution.

Also make sure to disable all other programs that draw on the screen, such as WinAmp in always-on-top mode, or stuff that displays notifications.

* My anti-virus program says your intro is a VIIIIRUUUS!1!!

Your anti-virus program is overly paranoid. The intro is compressed with the latest Crinkler version (1.4), which does lovely little tricks like storing data in unused fields of the executable header. This make the executable look unusual and scares your AV program. Feel free to report this intro as a false alarm, but don't hold your breath. Demoscene programs are not a priority for AV studios...