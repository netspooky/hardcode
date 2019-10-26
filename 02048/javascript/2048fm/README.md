2048b FM
=====

## What is this?
This is a FM (PM) synthesizer that runs in your web browser. Its file size is 2048bytes (index.html). You can check out the commented source in uncompressed.html.

## Features

* 6 Operators
* ADS (Attack, Decay, Sustain) Envelope
* Theoretical 32-voice polyphony (on my computer, no keyboard events fired after holding down 6 keys)
* Arbitrary operator routing. Any operators can route to any other operators, even self. They can be carriers and/or modulators. 
* Saving and loading patches
* C4-A5 keyboard (corresponding to 2 top rows on your keyboard, Q to backslash).

## Components

* Bitmap font 0-9ADSICTO at 160 bytes + 59 bytes (for pixel drawing)
* Bresenham line drawing at 159 bytes + 59 bytes (for pixel drawing)
* DSP + keyboard mapping is at 668 bytes
* The rest: GUI, mouse, patch save/load 754 bytes

## Caveats

* It is not possible for modulators (that does not go directly to output) to be silent. I did this so that we can skip calculations if an operator have zero volume.
* No release envelope stage :c
* No fixed frequency mode. 
* It is not a DX7 emulator :c I first wanted it to be one.
* On my machine, if you don't have any modulation, it doesn't lag. But if you do, it usually lags out at 3-4 voices. On my machine, it appears that Firefox's script processor isn't as fast. 
* `<meta charset=utf8>` was added so the GUI would render correctly in Firefox and Edge.

## Diagram of parameters

This part assumes you know synthesis concepts. Here's a diagram:

![diagram](diagram.png)

## Example Patches

* [Glass Keys](https://khoin.github.io/2048fm/#0,99,0,0,0,0,0,23,49,64,1,0,79,0,0,0,0,0,0,0,18,26,0,7,0,1,0,99,0,0,0,0,0,22,49,65,1,1,73,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
* [Saw Bass](https://khoin.github.io/2048fm/#95,0,0,0,0,0,0,22,24,49,0,12,99,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
* [Chord Brass-like Synth](https://khoin.github.io/2048fm/#60,0,0,0,0,0,2,12,57,43,0,49,81,0,68,0,0,0,0,2,12,54,58,1,0,74,0,0,65,0,0,0,5,21,47,58,0,62,79,0,0,0,82,0,0,4,27,48,31,1,25,71,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
* [Organ](https://khoin.github.io/2048fm/#0,0,0,0,0,0,0,14,63,0,1,0,66,0,0,0,0,0,0,0,26,71,0,1,1,74,0,0,0,0,0,99,0,0,26,99,6,0,29,0,0,0,0,0,0,0,0,21,0,4,1,34,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,99,0,0,3,3)
* [Flute](https://khoin.github.io/2048fm/#99,0,0,0,0,0,3,0,99,99,0,0,3,71,0,0,0,0,0,0,4,3,99,0,0,44,0,0,8,99,0,0,2,98,0,99,1,0,99,0,0,0,0,0,0,0,0,99,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) (You have to turn the Tune parameter to some other value, then back to 0 again to feed the noise)

## Acknowledgments

* Thanks [Werner](http://bpmdj.yellowcouch.org/) for showing me more efficient way of PM/FM synthesis
* [p01](https://github.com/p01) for such awesome 1k demos that got me into this.

## License

Public Domain.


