Mandelkern - Realtime Mandelbulb in 1k, with some additional effects.

- General:
Has been tested to work on WinXP 32bit with a Geforce 8600M, and WindowsXP 64bit with Radeon 4850. Since it's based on the "Windows 7 fix" version of 1kPack, this demo should be relatively compatible. The 2560x1600 has not been tested because my screen does not support it... Recommended resolution by GPU based on my tests:

Geforce 8600 and similar: 800x600
Geforce 9600/Radeon 3870: 1024x768
Geforce 9800/Radeon 4850: 1280x1024
Geforce GTX/Radeon 4890: 1600x1200/1920x1080
Radeon 58x0: 1920x1200, or even 2560x1600

- Why and what:
Breakpoint 2010 was my second demoparty so far, and even though I was there just as a spectator, I showed my Mandelbulb implementation to a few people, and they suggested I make a 4k demo out of it. Well, I might still finish that 4k eventually (with better performance, more accurate ambient occlusion, blablabla...), but for now here is a 1k demo which raymarches a Mandelbulb and can get decent frame rates at good resolutions on a fast computer. Since the final code was significantly smaller than 1k, I added some additional effects until I reached 1k (well, technically 1k=1000, so it's really 1Ki or 1.024k, but whatever...).

- Algorithm:
The iteration of the Mandelbulb itself is well known, as is the Mandelbrot fractal with orbit traps, so I will just refer to Google for that. The colors are made using a simple Hue-saturation function, which is applied to both the Mandelbulb and the Mandelbrot. The (possibly) new aspect of this visualization here, however, is the tracer, which has a very complex (but still compact) distance estimation function. There are only up to 25 ray marches for each pixel. The (fake) ambient occlusion is based on this tracer, by checking the evolution of the distance function during the tracing. 

- Size:
This demo uses hitchhikr's packer and sources, which are essential for making this possible, but there are also a few techniques which help make shader code as small as possible which I discovered during the creation of this demo. Some of those may be obvious, but I will just list all of them here anyway:
- All variables should be just one letter
- Make everything lowercase. The shader in this demo contains not a single uppercase letter.
- All variables should be declared in one place
- Variables should be reused whenever possible in order to minimize the amount of variables which need to be declared (this shader uses 1 float2, 3 float4s and 10 floats)
- Since repetitive strings can be compressed better and some letter are more frequent than others, "1000" may compress better than "999", or "z*z*z*z" may be better than "pow(z,4)"
- Use all features of c++ whenever possible, such as "o=d=1", "while(z<400&&i++<11)" or "x=o-=log(b*b+u*u)*.15"
- DirectX has a few additional features which can be useful. "if(h<1)v=v.gbra" reorders the indices of v while being very compact. 
- Truncate floats as much as possible, always ommit the leading zero and remove all unnecessary spaces and brackets.
- Macros are usually not worth it.
- At least on my machine the program would occasionally refuse to start at random. Adding "1*" or "0+" to some line might help.
- Some variables may require an initilization, but the exact value might be not so important. In that case, just initialize them in combination with some other variable ("o=b=a.y;") or reuse them when you know what the last value will look like approximately.

- Credits:
Compressor&template - hitchhikr
Mandelbulb - Whoever discovered it first ;-)
Code - me (teraflop)

- Respect to (sorry if I forgot someone, I don't really have an overview over all important groups in the Demoscene - this is my first demo afterall):
- Exceed
- Plastic
- Andromeda Software Development
- $
- Farbrausch
- Fairlight
- A.N.D.
- Moppi Productions
- Sunflower
- Cocoon
- Matt Current
- Andromeda
- RGBA
- TBC
- Conspiracy
- The Black Lotus
- MFX
- Kewler
- Calodox
- Candela
- Haujobb
- Broncs
- Bauknecht
