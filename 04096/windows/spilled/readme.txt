
***************************        Spilled       ****************************
                          4k procedural graphics entry
                                  by Archee
                                  
                                  
                             for Function 2009
                             

Web: www.gravitysensation.com/spilled

On the content:                    
A very simple implementation of Smooth Particle Hydrodynamics is ran
on CPU for about 600 steps with 6000 particles, taking about 5secs.
Then the resulting scene is raytraced on CPU as blobs with limited 
influence radius, using raymarching with binary search. 
The glassy part is raytraced by solving the line-intersection equations. 
This runs in 4 threads to make use of all cores.
The final image is blurred to reduce high frequency noize.
Rendering takes about 30secs on a dual core. 
Its a bit far from realtime, but it may get realtime for another compo:)
A prerendered animation of the scene will be made public on the website.
                             
.. the end ..

Archee < peterlurker (at) googlemail.com >
