
     __._        _.____   _.____   _.____   _.__    ____._    ____._
   _/  |/________\|_   \__\|_   \__\|_   \__\|__)__/  _ |/___/  __|/____
  _)   _/      /   /    /   /    /   /    /      (_   __|  (_____      (_
  \    \      /        /        /   /     \       /         /   /       /
  /_____\_____\________\________\___\______\______\_________\___________\
 - -diP--------------------------------------------------------------uP!- -

 
                             Cycle Of Nature
                        Released at Revision 2017
                             4 kb Intro compo
													 		

Credits
=======
Code, scripting, etc: Psycho (psycho@loonies.dk)
Synth, additional x86: Blueberry
Music: Punqtured

Crinkler for compression
Rocket for scripting
Oidos synth for music


Compatibility
=============
Windows 8.1+
DirectX 11.1, feature level 11_1 required!
That means a least a (fast!) AMD GCN (7000 series) or NVIDIA Maxwell v2 (900 series) graphics card.
Will try to do a downscaled version with fewer particles later, resolution scaling alone is not enough.


Tech
====
Particle simulation, bucket sorting and rendering done in geometry shader (particle-updating UAV writes from geometry shader requires 11.1)
Single pass, single draw call.
1.5M particles, 512 buckets, supporting bucket overflow.
Geometry shader rendering traversing whole bucket space (8 particles per thread, so it skips fast) - not particular performant, but small...
99+% of particles are spawned raycasted onto SDF scene, rest are larger and range spawned.


Additional info
===============
http://www.loonies.dk
http://www.revision-party.net
