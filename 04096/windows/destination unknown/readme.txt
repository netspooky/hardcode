
     __._        _.____   _.____   _.____   _.__    ____._    ____._
   _/  |/________\|_   \__\|_   \__\|_   \__\|__)__/  _ |/___/  __|/____
  _)   _/      /   /    /   /    /   /    /      (_   __|  (_____      (_
  \    \      /        /        /   /     \       /         /   /       /
  /_____\_____\________\________\___\______\______\_________\___________\
 - -diP--------------------------------------------------------------uP!- -

 
                           Destination Unknown
                          Released at TRSAC 2017
                            4 kb Intro compo
													 		

Credits
=======
Music: Booster
Code, scripting, etc: Psycho (psycho@loonies.dk)


Crinkler for compression
Rocket for scripting
Oidos synth for music
Internal shader compactor


Compatibility
=============
Windows 10 Creators update (I think)
DirectX 11.1, feature level 11_0
Recently the use of typed uav loads, including unorm formats has been allowed in windows - tested working on at least gtx 750m and r9 290.
(error checking is for debug mode..)

Tech
====
Plain old raymarching, direct tracing for the beam.
2D fake DOF + bloom + motionblur post pass
Single compute call pass

Expect an improved final using the full 4kb :)
(a couple of cameras, better object in the first room etc)


Additional info
===============
http://www.loonies.dk
http://www.trsac.dk
