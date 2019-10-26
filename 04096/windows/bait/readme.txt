Bait by Fulcrum
===============
A cautionary tale in 4K, finally answering the question: the world may what now?

Credits:
--------
Code, design;	Seven
Music:		Coplan
3th party tools used: 4Klang, Crinkler, and GLSL minifier


Requirements
------------
* A very fast video card with lots of Pixel Shader 4.0 compatible shader pipelines.
  The intro runs very smoothly at 1280*720 on an Nvidia 480 GTX (the compo setup at
  Assembly), but was developed on a Geforce 8800 GTX and a Radeon HD 5770.
* 300 Mb ram for the Crinkler decompression
* Windows XP or higher
* 4 kb diskspace

About the intro
---------------
This is our second 4K with raymarching, and I dare say we've improved a bit. The original idea was to have a spaceship diving into a wormhole and encountering a giant alien ship. I had some extra ideas such as planets or asteroid fields, but I wasn't quite sure if I could fit all that in 4K... In the end, I've managed to put almost everything in it, and then some. The only missing feature is having the rounded cubes lit up just before the alien tech does something, but the extra scripting required was the byte that broke the camels back.

Major breakthroughts along the way were:
- Realizing Crinkler has these nifty options to compress much better than the default (doh!)
- going from one monolitic shader to composing a shader per scene out of common parts, as seen in Muon Baryon (thanks Youth Uprising!)
- using GLSL minifier. It's a great tool that shaved 200 bytes from the (admittedly unoptimised) shader. It needs a bit of handholding though, especially when your shaders are split in parts, and running an already-optimised-but-updated shader through the program again leads to "interesting" code such as "float m(vec3 t,float t){..." which can't be good news. Still, it gave some ideas to optimise stuff by hand.
- Coplan experimenting heavily with 4klang, resulting in a version of the music that crashed at first, but when coaxed into running was 100 bytes smaller and sounded not nearly as bad (to my coder ears) as Coplan made it out to be... As a compromise, about 20 bytes of those were used to add 4klang's samples exported with the highest quality options instead of the lower quality ones.
- And finally converting the intro to assembler, which isn't that much work since 3/4th of the intro is shader strings. And due to Crinkler, messing around with strange opcodes becomes counterproductive very quickly.

The story might not win any awards, it was shamelessly optimised for:
a) maximum emotional impact/memorability for the sleep-deprived audience that probably will be watching 15 similar raymarching intros in a row. 
b) heavy reuse of the few objects I could fit in.


Thank you to...
---------------
- Kaatje & Merel for giving me the time and support to make this thing in the past 3 weeks.
- Yncke for giving some much-needed design/color/timing advice.
- Iq/rgba for posting the rounded box distance function on Pouet.
- Rune L. H. Stubbe (Mentor/TBC) and Aske Simon Christensen (Blueberry/Loonies) for Crinkler.
- Dominik ´Gopher´ Ries and Paul ´pOWL´ Kraus of Alcatraz for 4klang.
- Ctrl-Alt-Test for their GLSL minifier.
- Whizzter/Woorlic&TPOLM for on-party help with debugging the Windows 7 busy cursor problem.


Troubleshooting
---------------

* Help, it crashes!

Hmm, sorry for that. If you want to help troubleshoot this (test debug versions and send back logfiles), mention the crash at the Pouet.net page for this production. Note that the intro doesn't use any exotic libraries, only opengl32.dll and stuff like kernel32.dll. So even though it was compressed with Crinklers /UNSAFEIMPORT (which does not warn if dlls are missing), that really shouldn't be a problem.


* I can hear the music, but I only see a solid green or red screen!

This means the video card drivers could not compile the shaders correctly. First, you need a Pixel Shader 4.0 compatible graphics card. Next, *UPDATE YOUR VIDEO CARD DRIVERS*. To save space, this intro uses some tricks such as using integer numbers instead of floats, which saves a byte (no dot needed). This is allowed in recent OpenGL Shader Language revisions, but old drivers are more strict and will refuse to compile the shaders, even if the hardware could run the shader. So, update those
drivers!


* Man, this thing runs slow!

As with all spheretracing/raymarching with distance fields intros, the speed depends only on the number and speed of shader pipelines on your graphic cards, versus the number of pixels that need to be rendered. The speed of your CPU, the amount of RAM, the amount of video card memory etc have very little influence. Try running one of the alternate versions at a lower resolution.

I also noticed a large drop in smoothness (without dropping the FPS, strange enough) when Winamp was open in the background, even if not playing. Maybe 4Klang doesn't like Winamp?

But yeah, I wanted to tell a story in this intro, so methods that render faster but were bigger had to be sacrificed for more scenes and more detailed models. And on the other hand, hardware is getting so much faster with each new generation (real, not rebranded, NVidia!) that I don't want to limit myself to yester-years hardware. The slowest parts of the intro run at nearly 20 FPS on a 120 euro (on sale) Radeon 5770, while the Radeon 5870 in the compo machine should be exactly twice as fast . I remember Muon Baryons framerate troubles at last year's Assembly and the audience didn't seem to mind, so making the intro uglier but faster doesn't sound like a great strategy.


* Is it supposed to look like this?

If you have a Geforce 8600 or higher, or some Radeon HD 5000, with the latest drivers, the answer is probably yes.But my previous 4K intro had some display artifacts on a Radeon HD 4000, and since I don't have (access to) a Radeon X2000, HD 3000 or HD 4000 cards, I can't guarantee that it looks as it should on those.


* What's up with the busy cursor on Windows 7?

Windows 7 displays a busy cursor if your program does not reads the messages that Windows 7 sends it, even if you hide the cursor. Simply removing the messages without handling them fixes this, but takes 25 bytes extra after compression. But that would break the 4K limit, so just move the mouse to a corner, please. The compo team at Assembly used a program to completely hide the mouse before running the entries, since half of them had this problem. I've heard only OpenGL intros have this problem, not DirectX ones, but I don't know for sure.

