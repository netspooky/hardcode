
     __._        _.____   _.____   _.____   _.__    ____._    ____._
   _/  |/________\|_   \__\|_   \__\|_   \__\|__)__/  _ |/___/  __|/____
  _)   _/      /   /    /   /    /   /    /      (_   __|  (_____      (_
  \    \      /        /        /   /     \       /         /   /       /
  /_____\_____\________\________\___\______\______\_________\___________\
 - -diP--------------------------------------------------------------uP!- -


                               Leggy       
                      Released at NVScene 2014
                    4 kb executable graphics compo
	
Credits
=======
Code: Psycho (psycho@loonies.dk)
Modeling and stuff: Maytz (maytz@loonies.dk)
 
Crinkler (1.4) used for compression.


Requirements
============
DirectX 11 graphics card (and maybe not too slow to avoid time outs)
DirectX Runtime June 2010 installed - OR d3dcompiler_47.dll (faster)


Info
====
113 metaballs (using custom modeller)
Rest distance function modelled
Metaball object baked into 256^3 distance field texture
Texture simulated/manipulated for slime
Raymarching and shading the opaque scene, rendering out normals for the slime.
Filtering the opaque scene (for translucency) and the normals (smoothing), shading slime and composition
Final pass for DOF and bloom
Lots of noise and seed tweaking..


generate_hires.exe won't show the picture, but save a 2560x1440 supersampled png image - after some time.


Additional info
===============
http://www.loonies.dk