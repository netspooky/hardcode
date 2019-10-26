Fractus by Fulcrum
==================
This started as a quick test to see if I could get cone marching working in a simple 4K. It failed pretty hard on the quick and simple criteria.

Credits:
--------
Code, design:	Seven
Music:		El Blanco
3th party tools used: 4Klang, Crinkler, and Shader Minifier

Requirements
------------
* A fast video card with lots of Pixel Shader 4.0 compatible shader pipelines.
* 300 Mb ram for the Crinkler decompression
* Windows XP or higher
* 4 kb diskspace

About the intro
---------------
The idea for this intro started a few weeks after the release of The 3/4 Delusion, when I got contacted by a group that wondered if I could share the fast mandelbox trick. Feeling a bit torn between wanting to help them and not wanting to share my trick with a single group, I decided to participate in the new mini-seminars at Revision and explain it to everyone at once. But I was curious if it was possible to make cone marching fit in 4K, so I decided to do a quick test 4K, and maybe add some promotion for the Belgian summer demoparty Rewired. Once I got it working and started adding scenes, I couldn't stop and spend the better part of a month improving the intro and pestering the musician for changes to the soundtrack. The Rewired promo got left out in favor of more content, sorry Franky! (Everyone, see www.rewired.be for info about Belgiums finest demoparty!)
I managed to find enough space to add the "Busy cursor on Windows 7" fix, although Crinkler was a pain in the rear at the end. I had to remove just 9 bytes, and I found various small fixed that gave a smaller exe size at low compression, but with the full 10-minute heavy compression, I ended up with larger and larger files. With the final small fix, the size suddenly dropped 20 bytes at once...

A couple of notes:
- I tried to find a good balance between the speedup cone marching gives, the artifacts it produces and the other raymarching artifacts that it interacts with. After testing a bit on the compo machine, I increased the quality a bit more, but I still wanted it to run fine on slightly less powerful hardware as well. I don really like the current "it should run OK on the compo machine and everyone else can watch it on YouTube"-attitude. But I don't have much hardware to test it with here, so my apologies if it turns out to be too slow on your hardware.
- A detailed explanation of cone marching will be available on our site, www.fulcrum-demo.org . It will be a bit more in-depth than the slides from the Revision seminar, because I had to cut some material to fit in 8 minutes.
- The cone marching makes the intro quite resolution-dependant. If the intro is played in a different resolution then the one mentioned in the filename, visible corruption will result. See the Troubleshooting section for possible fixes.

Thank you to...
---------------
- Kaatje & Merel for support
- Yncke for AMD videocard testing
- Knighty for the original pseudo-kleinian fractal
- Rune L. H. Stubbe (Mentor/TBC) and Aske Simon Christensen (Blueberry/Loonies) for Crinkler.
- Dominik ´Gopher´ Ries and Paul ´pOWL´ Kraus of Alcatraz for 4klang.
- Ctrl-Alt-Test for their Shader minifier.


Troubleshooting
---------------

* Help, it crashes!

Hmm, sorry for that. If you want to help troubleshoot this (test debug versions and send back logfiles), mention the crash at the Pouet.net page for this production. Note that the intro doesn't use any exotic libraries, only opengl32.dll and stuff like kernel32.dll. So even though it was compressed with Crinklers /UNSAFEIMPORT (which does not warn if dlls are missing), that really shouldn't be a problem.


* I can hear the music, but I only see a solid green or red screen!

This means the video card drivers could not compile the shaders correctly. First, you need a Pixel Shader 4.0 compatible graphics card. Next, *UPDATE YOUR VIDEO CARD DRIVERS*. To save space, this intro uses some tricks such as using integer numbers instead of floats, which saves a byte (no dot needed). This is allowed in recent OpenGL Shader Language revisions, but old drivers are more strict and will refuse to compile the shaders, even if the hardware could run the shader. So, update those drivers!


* Man, this thing runs slow!

As with all spheretracing/raymarching with distance fields intros, the speed depends only on the number and speed of shader pipelines on your graphic cards, versus the number of pixels that need to be rendered. The speed of your CPU, the amount of RAM, the amount of video card memory etc have very little influence. Try running one of the alternate versions at a lower resolution, but be sure to read the next question and answer as well.

Also make sure to disable all other programs that draw on the screen, such as WinAmp in always-on-top mode, or stuff that displays notifications.

* Is it supposed to look like this?

This intro should be AMD and Nvidia compatible, but due to the cone marching, it is picky about the display resolution, which should be divisable by 16 in both X and Y directions. All the versions in the archive are for resolutions that satisfy this condition. If you have a different resolution (such as 1600*1050 or 1366*768), pick a lower resolution one.

If you still see corruption (in the form of distorted objects in a strip at the top or right side of the screen), try the following:
- Set your desktop resolution to the same resolution of the intro you want to run.
- Turn the auto-scaling options off in the Nvidia control panel or Catalyst Center, use letterboxing if possible. 

The aim is to make sure the actual resolution matches the size of the rendertargets that are used internally, if those do not match the intro will look corrupt.

Also, if objects have holes in  them or are black, try updating your video drivers.
