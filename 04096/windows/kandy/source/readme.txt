This is the source code for the kandy 4k intro.

It is written entirely in assembly language, which makes it insanely small but
also difficult to understand. I try to keep things well-commented and follow
the format described in style.txt. The most useful source file is probably
main.asm, which contains some fairly nice OpenGL and DirectSound setup code.
The synth.asm and math.inc files might also be useful, since they contain
some pretty sweet math routines you can recycle in your demos.

Here are the files I've written:

main.asm - setup code
math.asm - math support routines (the _path function is totally boss)
demo.asm - graphics code
synth.asm - wave-generation code

music.inc - music and instrument parameters
math.inc - insane math code. super useful

build.mak - windows makefile
debug.c - never really used this file

makefile - linux makefile
audio.c - renders the audio to a wave file on linux

The concept/ folder contains some concept art. It's kinda funny to see what
made it into the final intro and what got cut out. Mainly, I ran out of time
rather than space. Believe it or not, the biggest inspiration for this 4K was
actually Moral Hard Candy, even though it looks nothing like this prod.

Have fun and stuff!
