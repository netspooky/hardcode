Frozen Light by Fulcrum
=======================
This is a quick remote contribution to the TUM 2013 demoparty, which I sadly couldn't visit :(

Credits:
--------
Code, design:	Seven
Music:		El Blanco
Original Music: Tchaikovsky - Dance Of The Sugarplum Fairy
3th party tools used: Clinkster, Crinkler, and Shader Minifier

Requirements
------------
* A fast video card with lots of Pixel Shader 4.0 compatible shader pipelines.
* 300 Mb ram for the Crinkler decompression
* Windows XP or higher
* 4 kb diskspace

About the intro
---------------
I got the idea for this intro from these excellent macro photos of snowflakes:
http://chaoticmind75.blogspot.ru/2013/08/my-technique-for-snowflakes-shooting.html
Of course, my first reaction was "hmm, I wonder if you could raymarch that...". Since TUM was getting close, I just wanted to make a filler entry with snowflakes and greetings. I asked the Fulcrum musicians if they could remix a traditional christmas carol. El Blanco stepped in with a remix of "Dance Of The Sugarplum Fairy". Unfortunately, Mr. Tchaikovsky *really* liked to use a lot of notes, so the Clinkster note data was much bigger than expected, and we had to sacrifice a lot of sleep to get the code+music in 4K... It doesn't have all the bells and whistles I had planned, but I'm getting tired of looking at the code. Also, since my friendly demoparty-chauffeur Santa has fallen ill, I won't be able to attend TUM so this is a remote entry. Hope you like it!


Thank you to...
---------------
- Kaatje, Merel & Lander for support
- Rune L. H. Stubbe (Mentor/TBC) and Aske Simon Christensen (Blueberry/Loonies) for Crinkler and Clinkster
- Ctrl-Alt-Test for their Shader minifier.


Troubleshooting
---------------

* Help, it crashes!

Hmm, sorry for that. If you want to help troubleshoot this (test debug versions and send back logfiles), mention the crash at the Pouet.net page for this production. Note that the intro doesn't use any exotic libraries, only opengl32.dll and stuff like kernel32.dll. So even though it was compressed with Crinklers /UNSAFEIMPORT (which does not warn if dlls are missing), that really shouldn't be a problem. The intro has been tested on an AMD and Nvidia card.


* I can hear the music, but I only see a solid green or red screen!

This means the video card drivers could not compile the shaders correctly. First, you need a Pixel Shader 4.0 compatible graphics card. Next, *UPDATE YOUR VIDEO CARD DRIVERS*. To save space, this intro uses some tricks such as using integer numbers instead of floats, which saves a byte (no dot needed). This is allowed in recent OpenGL Shader Language revisions, but old drivers are more strict and will refuse to compile the shaders, even if the hardware could run the shader. So, update those drivers!


* Man, this thing runs slow!

As with all spheretracing/raymarching with distance fields intros, the speed depends only on the number and speed of shader pipelines on your graphic cards, versus the number of pixels that need to be rendered. The speed of your CPU, the amount of RAM, the amount of video card memory etc have very little influence. Try running one of the alternate versions at a lower resolution, but be sure to read the next question and answer as well.

Also make sure to disable all other programs that draw on the screen, such as WinAmp in always-on-top mode, or stuff that displays notifications.
