                            --- Darwinism ---

                    4k intro  :   entry for Breakpoint 2010


Technical details:

This creature’s movements are physics based, and it learns to move  through 
a Genetic Algorithm. While one "life" is shown on the screen,  720 other 
lives are simulated in the back ground. (1440 for worms) 
The Genetic Algorithm, which takes a lot of time, runs during the intro, to
avoid long pre calculation.  The actual best animation is shown every time.
The first animation is broken because only 50 simulations are done in precalc.
The not-so-optimized  rendering runs on a separate CPU core.
Btw, genetic algorithms only work properly with strong random number 
generator,  this one has a state (seed) vector of 98 floats, and a very long
period. It doesn't work with simple random number generator.

To show that the animation is not stored, there is darwinism_randomizer.exe,
which runs differently every time.

On slow computers the animation is behind the music.

Music:     SlySpy
Thx:       crinkler


Archee  ( peterdutch@freemail.hu )
