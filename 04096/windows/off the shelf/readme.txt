
     __._        _.____   _.____   _.____   _.__    ____._    ____._
   _/  |/________\|_   \__\|_   \__\|_   \__\|__)__/  _ |/___/  __|/____
  _)   _/      /   /    /   /    /   /    /      (_   __|  (_____      (_
  \    \      /        /        /   /     \       /         /   /       /
  /_____\_____\________\________\___\______\______\_________\___________\
 - -diP--------------------------------------------------------------uP!- -


                             Off The Shelf
                        2nd at Break Point 2008 
                     4kb generated graphics compo
	
Credits
=======
Code: Psycho
Some design: Laika

Crinkler used for compression.


Compatibility
=============
OpenGL, loong shader, meaning dx10 level hardware, that is:
Radeon HD 2x00+ or Geforce 8x00+


Versions
========
off_the_shelf_30 - 30 rays per pixel for slow gfx card
off_the_shelf - normal version, 200 rays
off_the_shelf_compo - party version, nvidia only, following the compo rules, 400 rays

Rendertime for the normal version is 25s on HD3870 and 135s on mobile 8600GT. Shader
compile time is pretty long (~10s) on the ati cards (seems like it's unrolling 
everything but the ray loop).

Info
====
I wanted to do something more (CSG, refraction, fake caustics..), but neither the 
hardware nor the drivers did quite as expected, so I fell back to this instead. 
Raytracing using a path tracing like approach featuring depth of field, soft shadows 
and soft reflections at planes and  cutted stretched spheres.

Final version adds ATI compatibility, improved noise reduction filter, basic error 
checking (lots of space left..) and some minor adjustments.
Technically it is quite different and not quite like as I would like it, to work
around problems in the drivers of both vendors.

It's made on my 1k setup, so it's kinda dirty. Just hold escape, not the mouse to 
exit during or after rendering. 


Additional info
===============
http://www.loonies.dk



