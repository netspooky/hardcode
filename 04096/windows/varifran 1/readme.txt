Varifrån 1
by Yzi/Fit^L!T^Saunagroup
Windows 4k intro
for Tokyo Demo Fest 2015

Use Nvidia.

Youtube video for ATI owners: http://www.youtube.com/watch?v=EiGVKS3qUAU


Once again, it's a compofiller made in a few hours, with a 4klang tune
and a simple GLSL raymarcher with some chunks of code copy/pasted from
shadertoy.com and/or glslsandbox.com, run through Shader Minifier. The
fog effect is taken from https://www.shadertoy.com/view/4ts3z2
(Xyptonjtroz by nimitz)

I'm using glColor3us() and glRecti() to pass the time to the GLSL code
in gl_Color, in a mixture of old fixed-function OpenGL calls and newer
stuff. The structure is made for 1k intros, so it leaves lots of room
for shader code, but it unfortunately only works on Nvidia. There's
plenty of space in a 4k, so maybe some day I'll start using a proper
way with uniform variables.



The letter å is Unicode code point U+00E5, LATIN SMALL LETTER A WITH RING ABOVE
