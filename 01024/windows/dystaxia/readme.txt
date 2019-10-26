Dystaxia by Fulcrum
===================
Our first 1K intro! This was fun to make!

Now with an OpenGL safe version that doesn't depend on the framerate for timing. Use that one if you don't have a very fast videocard.

Credits:
--------
Code, design:		Seven/Fulcrum
Music:			Coplan/Fulcrum
3th party tools used: 1Kpack by Hitchhikr/Neural for the party version, Crinkler by Blueberry& Mentor for the safe version	


Requirements
------------
* A fast video card with lots of Pixel Shader 3.0 compatible shader pipelines, at least as fast as a AMD HD 7870. VSync (aka vertical retrace) should be on in the video card settings, or it might run too fast on fast cards. If the video card is too slow, the entire intro will slow down, including the music.
* The DirectX9 runtime, specifically the d3dx9_30.dll
* Only tested on Windows 7, but it should run on Windows XP or higher
* 1 kb diskspace
* a soundcard with MIDI support if you like your intros with sound.

About the intro
---------------
I did this 1K instead of our usual 4K because I thought it would take less time. 1 hour before I left to Assembly, I removed the final byte to get it down to 1K.

In the meantime (more than a week), the code switched from C++ to MASM to NASM, the shader from GLSL to HLSL, the packer from Crinkler to 1KPack and back and back again, and the music from 8-bit experimental C programs (http://pouet.net/topic.php?which=8357) to Midi. A slight miscommunication between coder and musician about wether a pattern contains notes for all instruments or 1 instrument left us with music that was 100 bytes to big, which was simplified and stamped into the intro in an ugly way. Thanks to Coplan for his patience with my unreasonable demands :)

I've also added a safe version which uses OpenGL and Crinkler, since some people had trouble with the party version.

Thank you to...
---------------
- Kaatje, Merel & Lander for putting up with my lack of time, attention and sleep while making this.
- Hitchhikr/Neural for his 1K packer and examples.	
- IQ for his 1K framework for inspiration
- Rune L. H. Stubbe (Mentor/TBC) and Aske Simon Christensen (Blueberry/Loonies) for Crinkler, which was the first approach taken, but ultimately not used.

Greetings to SubDream, Horology, Brainstorm, CMR, Psycho, Pixtur, Smash, RBBS and other nice people I talked to at Revision and Rewired


Troubleshooting
---------------

* Help, it crashes!

Have you tried the safe version? If even that crashes, I'm sorry for that. The intro has been tested on a AMD HD 7870, HD 7970 (compomachine) and a nvidia GTX 780 (other compo machine). It used to crash instantly on my laptops Nvidia GT 540 M, but after updating the drivers to 320.49 it runs fine and then crashes when returning to Windows (it's still way too slow on that card, though).

If you have a multi-monitor setup, you might try to enable only 1 screen. 

If that and updating your drivers doesn't help, you can probably watch the Youtube version the Assembly orgos put online after the party. Sorry again but 1K doesn't leave much space for compatibility...

* Man, this thing runs slow!

As with all raymarching intros, the speed depends only on the number and speed of shader pipelines on your graphic cards, versus the number of pixels that need to be rendered. The speed of your CPU, the amount of RAM, the amount of video card memory etc have very little influence.

Also make sure to disable all other programs that draw on the screen, such as WinAmp in always-on-top mode, or stuff that displays notifications.

* My anti-virus program says your intro is a VIIIIRUUUS!1!!

Your anti-virus program is overly paranoid. The intro is compressed with 1KPack, which does lovely little tricks like storing data in unused fields of the executable header. This make the executable look unusual and scares your AV program. Feel free to report this intro as a false alarm, but don't hold your breath. Demoscene programs are not a priority for AV studios...
