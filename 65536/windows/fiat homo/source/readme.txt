      ________________________________
     /   /   /   /   /    /  /   /   /
    /   / / / / /   /    /  / / /   /
   /_  /   /   / __/_   /  / / /   /
    / /  \/ / /   / /  /  / / / / /
   /_/_/_/_/_/___/ /__/__/___/_/_/

Fiat Homo by Traction - the source release
------------------------------------------
As promised in the Fiat Homo info file, here are the full sources for the intro.

Some points:
------------
 * I use weird Finnish/English variable/function names, so it's most likely quite unreadable.
 * check main.cpp if you're looking for a place to start
 * It was made with no tools, just by coding
 * It includes snippets of NeHe stuff like the font engine, sorry :D
 * I'm not a professional programmer, nor want to be one. So don't be scared if you
   find stuff that looks horrible ;)
 * rename music.bin into .xm and you got the demo tune
 * The packer (kkrunchy by ryg/Farbrausch) is not included, so you'll get a >200kb exe

As far as I'm concerned, the source is yours. Do what you want with it, there's very little
worth ripping but personally I like the intro "engine" and will keep on using it. Doing it
the old way > tools, at least in my opinion. SSRI, my intro for Function'05, was made using
the same framework. 

But, if you use the source code or find it useful, consider giving us greetings in your
next production :)

Feel free to contact me at syksyisin@gmail.com or mnurmika@cc.hut.fi for questions or general
chitchat. Thanks!

 - Preacher/Traction


----------
Port Notes
----------
First of all huge thanks to preacher for releasing the source code :)

Greetings to port testers/helpers: habbie, hth, hupe, jylam, ricemunk, vsync, wolf

The port has been compiled in Linux, OS X and Windows(Dev-C++)

Port changes
- Music:        FMOD
- Window/input: SDL
- Text:         Pictures (uh oh :-))
- some other small changes and fixes

 - Waffle/ExHouse

---additional notes from Sir Garbagetruck/Accession
  fuckings to osX sdl for not freaking handling the goddamn mouse pointer correctly when using openGL.  I applied a lame fix of warping the mouse away... but due to it leaving the mouse movable and all that crap, you have to do it each frame which prolly eats a cycle or two. Plus it's just LAME!
  I used g++3.3 to get it to compile, 4.0 had some odd linker issues which seem to pop up in some openGL apps (per googlage.)
  Other than that it was all Waffle, I just compiled it. And added more text. And removed ^M from this readme (which should have at least ONE ascii logo, so... added them.
  Oh, and I also used gzex
    ____________________________
   /   / / / / /   / / /   /   /
  / __/   /   / / / / / __/ __/
 / __/   / / / / / / /\  / __/
(___(_/_/_/_/___/___/___/___/
