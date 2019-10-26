Solar Prominence by Fulcrum
===========================
A quick remote entry to support Belgiums only demoparty. 

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

About the intro
---------------
We started working on this right after releasing Schtrombloxke at @party, so that's 2 and a half weeks to coble something together. Since it's a remote entry, it's not going to win any prizes, it's aim is just to support the intro compo at Rewired 2012 with an extra release. So I put in a couple of things that interested me, but that I hadn't so far got the time/occasion for to use in a 4K. I got the idea of dense julia fractals projected on spheres from Mikael Hvidtfeldt Christensen excellent blog, http://blog.hvidtfeldts.net/ (and he got it from Samuel Monnier here http://algorithmic-worlds.net/blog/blog.php?Post=20120316). The soft shadowing is based on IQ's Strawberry site. The godrays postprocessing is based on Akronyme Analogiker's released sourcecode for Hartverdrahtet, although I assume it's based on the GPU Gems 3 godrays code. I kept the scenes as simple as possible, because I wanted the intro to run fairly fast: the intros look much nicer at high resolutions. 

- The cone marching makes the intro quite resolution-dependant. If the intro is played in a different resolution then the one mentioned in the filename, visible corruption will result. See the Troubleshooting section for possible fixes.

Thank you to...
---------------
- ps for reminding us that every Fulcrum release should contain fractals. I hope you're happy now!
- Rune L. H. Stubbe (Mentor/TBC) and Aske Simon Christensen (Blueberry/Loonies) for Crinkler.
- Dominik ´Gopher´ Ries and Paul ´pOWL´ Kraus of Alcatraz for 4klang.
- Ctrl-Alt-Test for their Shader minifier.


Troubleshooting
---------------

* Help, it crashes!

Hmm, sorry for that. If you want to help troubleshoot this (test debug versions and send back logfiles), mention the crash at the Pouet.net page for this production. Note that the intro doesn't use any exotic libraries, only opengl32.dll and stuff like kernel32.dll. So even though it was compressed with Crinklers /UNSAFEIMPORT (which does not warn if dlls are missing), that really shouldn't be a problem.

One thing I noticed, is that all my programs compiled with VS6 (yes, ancient...) trigger an "this program tries to access the internet" warning from ZoneAlarm. Not sure what causes this, as I'm certainly not doing anything net-related.

* I can hear the music, but I only see a solid green or red screen!

This means the video card drivers could not compile the shaders correctly. First, you need a Pixel Shader 4.0 compatible graphics card. Next, *UPDATE YOUR VIDEO CARD DRIVERS*. To save space, this intro uses some tricks such as using integer numbers instead of floats, which saves a byte (no dot needed). This is allowed in recent OpenGL Shader Language revisions, but old drivers are more strict and will refuse to compile the shaders, even if the hardware could run the shader. So, update those drivers!

* Man, this thing runs slow!
As with all spheretracing/raymarching with distance fields intros, the speed depends only on the number and speed of shader pipelines on your graphic cards, versus the number of pixels that need to be rendered. The speed of your CPU, the amount of RAM, the amount of video card memory etc have very little influence. Try running one of the alternate versions at a lower resolution, but be sure to read the next question and answer as well.

Also make sure to disable all other programs that draw on the screen, such as WinAmp in always-on-top mode, things that use the GPU as well (accelerated video decoding, including youtube browsing), or stuff that displays always-on-top notifications.

* Is it supposed to look like this?

This intro should be AMD and Nvidia compatible (tested on an AMD 5770HD and Nvidia GT540M), but due to the cone marching, it is picky about the display resolution, which should be divisable by 16 in both X and Y directions. All the versions in the archive are for resolutions that satisfy this condition. If you have a different resolution (such as 1600*1050 or 1366*768), pick a lower resolution one.

If you still see corruption (in the form of distorted objects in a strip at the top or right side of the screen), try the following:
- Set your desktop resolution to the same resolution of the intro you want to run.
- Turn the auto-scaling options off in the Nvidia control panel or Catalyst Center, use letterboxing if possible. 

The aim is to make sure the actual resolution matches the size of the rendertargets that are used internally, if those do not match the intro will look corrupt.

Also, if objects have holes in them or are black, try updating your video drivers.
