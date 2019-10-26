Hi m8s,

This is a 1k intro for Linux called "You Massive Clod" released at Function 2008.

Should work on Nvidia and ATI but needs a really fast PS3.0 card (ie. nv 8600 or more).
Apparently this was shown on quite a slow machine at the party but it runs solidly on my
Geforce 8600 gts.

I will release the source shortly with some explainations.

It's basically ray marching of a distorted pow(cos(xyz), 2.0) surface with 2 directional
lights. The more interesting part is the small setup code and hacked ELF header which 
makes this possible in 1k. The latter is the result of research by myself an leblane and
some help from tyranid and a few others.

RUN THIS AT YOUR OWN RISK:
Try the windowed version first. If the driver reverts to software mode then your X will 
probably crash (sorry about that) in which case you're pretty much screwed. If you get a 
white screen you need a more recent gfx card.

To exit, close the window in the windowed version or press any key in the fullscreen version.

You might need to change permissions on the files once you've extracted them from the archive. 
Run them from the terminal.

The fullscreen version occasionally doesn't restore desktop resolution; this is a known bug 
in SDL.

Greetings: deltafire (thanks for testing), auld, meaty (sorry!), leblane, blokey, #ukscene, 
ryg, iq, hitchhikr, mentor and probably a million others that I forgot.

Massive thanks to auld for help getting the shader running on ATI and for his blog from which
I got the technique for calculating surface normals.

parcelshit^fearmoths
