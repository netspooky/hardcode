
     __._        _.____   _.____   _.____   _.__    ____._    ____._
   _/  |/________\|_   \__\|_   \__\|_   \__\|__)__/  _ |/___/  __|/____
  _)   _/      /   /    /   /    /   /    /      (_   __|  (_____      (_
  \    \      /        /        /   /     \       /         /   /       /
  /_____\_____\________\________\___\______\______\_________\___________\
 - -diP--------------------------------------------------------------uP!- -


                    Maybe the real party is outside?        
                      Released at Revision 2012
                    4 kb executable graphics compo
	
Credits
=======
Code: Psycho (psycho@loonies.dk)
 
Crinkler (1.3) used for compression.


Compatibility
=============
DirectX 11 graphics card.


Info
====
Four compute shader passes:
-Raymarching 
-Pre filtering (bloom + laplacian)
-Paint filter with actual stroke drawing (many passes)
-reducing/tonemapping to screen

stage1.jpg is the pure raymarch (revealing some cheating here and there).
stage2.jpg is after the first large-stroke passes on a white canvas.

Yeah, technical this borrows a lot from my last picture, with some more
focus on ligthing, a much larger distance function (but most shapes 
are quite simple), and some tune up of the painter.
After dropping the planned Revision intro, plan B was to do develop some of 
it's tech for a picture as a prototype. When time ran out for that one too, 
plan C was "just a picture with known tech"... :)
Was fun to arrive and figure that my rough "modelling" from pictures the 
day before was actually pretty accurate. Forgive me for not covering the 
windows though.


Additional info
===============
http://www.loonies.dk