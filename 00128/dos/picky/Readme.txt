Picky by Seven/Fulcrum
----------------------

This little intro shows the interior of a Mandelbrot fractal filled with pickover stalks. When I started coding this, I wasn't quite sure if it was possible to fit it in 128 bytes, but after many ugly hacks I even had space left to rotate the palette. The speed is very dependant on how quickly the OS handles floating-point exceptions from the FPU, since I don't check for values nearing infinity. The uneven zoom speed happens because I use an integer decrement on the middle 16 bits of a 32-bit float value, it was the only way to get it animated without breaking the size limit. It runs forever, but after a while it zooms into a non-interesting part of the fractal, so just press escape to quit.

I'll probably publish the source code with an explanation in the next issue of PAiN.

Fulcrum is still looking for 2D/3D artists! Feel free to use the contact form at fulcrum.antisoc.net
