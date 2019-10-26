
Hi.

Farbrausch Consumer Consulting presents: 
Things rotting on our HD part XVI, aka the MS2000 invtro source

KB speaking,

please be welcome to the source code of the Mekka & Symposium 2000
invitation intro by Cubic + $een, Smash Designs and Witchcraft. I
really do not know what you might expect from this, but I'll explain
a few things anyway.

To compile and run this, you will ened a few things:

- Watcom C/C++ 11.0
- NASM 0.98
- TASM (maybe WASM or MASM do, too, or translate matrix.tas to NASM
        synax, ahve fun ;)
- UPX 0.89


... or any later versions. Yes, most of you might ask "why the heck
didn't they use VC++ for this?". And the easy answer is: Because
all of us were familiar with it (and weren't with VC then) and 
liked it. And because doing small EXEs with Watcom was a little more
straightforward than doing so with VC. Technical reasons? None.

The whole source of the intro itself is in the "invtro" directory,
and there are a few subdirs:

DATA    - binary data to be linked with the intro. Some bitmaps, the music
          and the texts.
PACKAGE - you could call this "bin", includes the final .exe and the
          readmes
TEXTE   - raw .txt own-fake-richtext versions of the texts including a 
          converter tool
TOOLS   - sound related tools: modified XM2MXM (which strips out the 
          samples) and the MakeSamples tool which writes the softsynth 
          waves as .XI to load them into FT2. Oh, and the 'leet speech
          analyzer and compressor which even I don't understand anymore :)

I haven't found all other tools, such as bitmap converters etc, but at
least for the sound side (read: the maybe only interesting things in this
source) everything should be there and usable.

Read the LICENSE file for info about how to copy/rip/use all this (or
don't if you know what a BSD license is)

Anyway, have a good time with this,

   Tammo "kb" Hinrichs
   Freunde Gepflegter Trinkgewohnheiten e.V.i.G
   Schatzmeisterpraktikant
