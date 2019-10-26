Schtrombloxke by RBBS and Fulcrum
=================================
A small invitro to Belgiums biggest, coolest, hippest, funkiest and only demoparty! From 6 to 8 july, in scenic Hasselt, Belgium! Compos include Music, Graphics, Intro, Demo and Gravedigging for your favourite pelvis (Elvis not available). Party features chairs, tables, power, network, internet, food across the street, a golf club around the corner and a cemetery next door - you know, for the pelvis thing.  And yes, we'll try for that communal barbeque thing too. No corpse grilling, please - thats nasty.  More info: see www.rewired.be

Credits:
--------
Code, design:		Seven/Fulcrum
Music:			El Blanco/Fulcrum
Fluffmans design:		Luna Design
Scrolltext & name: 	Franky/RBBS
3th party tools used: 4Klang, Crinkler, and Shader Minifier

Requirements
------------
* A fast video card with lots of Pixel Shader 4.0 compatible shader pipelines.
* 300 Mb ram for the Crinkler decompression
* Windows XP or higher
* 4 kb diskspace

About the intro
---------------
Just a small intro with Rewired's mascotte, Fluffmans. The model took most of the complexity in the intro, and the various "difficult" shapes are responsible for the slowness: the squashed spheres for the ears, a bended torus for the mouth, the electric wire tail are all stepped with a factor less then 1, to get accurate results. There was quite some confusion about which musician Franky could convince to write the music, resulting in no music at all 10 days before the party. Luckily El Blanco could help us out, although I had reserved not nearly enough space for the 4klang track. Instead of forcing him to start over (and spend lots of time byte-hunting myself), I decided to rip out the conemarching from the compoversion, so it fits the 4K limit. The non-compo versions are about 3 times faster, but technically not 4Ks. But hey, as long as it serves its purpose as an invitation...

- The cone marching makes the intro quite resolution-dependant. If the intro is played in a different resolution then the one mentioned in the filename, visible corruption will result. See the Troubleshooting section for possible fixes.

Thank you to...
---------------
- El Blanco for the impromptu music fix
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
The compo version of this intro is *very* slow, because I had to cut an important optimisation to stay under the 4K limit. The alternate versions are much faster.

As with all spheretracing/raymarching with distance fields intros, the speed depends only on the number and speed of shader pipelines on your graphic cards, versus the number of pixels that need to be rendered. The speed of your CPU, the amount of RAM, the amount of video card memory etc have very little influence. Try running one of the alternate versions at a lower resolution, but be sure to read the next question and answer as well.

Also make sure to disable all other programs that draw on the screen, such as WinAmp in always-on-top mode, things that use the GPU as well (accelerated video decoding, including youtube browsing), or stuff that displays always-on-top notifications.

* Is it supposed to look like this?

This intro should be AMD and Nvidia compatible (tested on an AMD 5770HD and Nvidia GT540M), but due to the cone marching, it is picky about the display resolution, which should be divisable by 16 in both X and Y directions. All the versions in the archive are for resolutions that satisfy this condition. If you have a different resolution (such as 1600*1050 or 1366*768), pick a lower resolution one.

If you still see corruption (in the form of distorted objects in a strip at the top or right side of the screen), try the following:
- Set your desktop resolution to the same resolution of the intro you want to run.
- Turn the auto-scaling options off in the Nvidia control panel or Catalyst Center, use letterboxing if possible. 

The aim is to make sure the actual resolution matches the size of the rendertargets that are used internally, if those do not match the intro will look corrupt.

Also, if objects have holes in them or are black, try updating your video drivers.
