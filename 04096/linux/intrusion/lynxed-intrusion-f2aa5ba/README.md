intrusion
=========

What is it?
-----------
A linux
[4k intro](http://en.wikipedia.org/wiki/Demo_\(computer_programming\)#Intros) and my first demo-production :o)

It's best viewed in realtime, but needs a linux-PC with a recent graphics card and the ability to run i386-code.
If you don't have access to one, here's a capture of the output on YouTube: http://www.youtube.com/watch?v=kzC-IOtw_cQ

Basically, it's a camera movement through a changing mandelbox fractal, raytraced in realtime on the GPU, with some sound.
See section _Anatomy of intrusion_ for further technical description.

Running
-------
To make running _intrusion_ easy, the final less-than-4k-binary is included in the git-repository. It's named _intrusion.release_. Assuming the dependencies are fullfilled, just execute and enjoy it.

If they're not, you won't get just an error about unlocatable libraries or unresolved symbols, but a SIGSEGV or a window not displaying anything meaningful. This is due some very dirty hackery to keep the binary small. Details on this can be found later in this document.

So, if it doesn't work, you're most likey missing one of:

- glibc (or binary compatible, version 6) ([Homepage](http://www.gnu.org/software/libc/))
- SDL (version 1.2) ([Homepage](http://www.libsdl.org/))
- OpenGL (version 3.3.0)
- XZ Utils ([Homepage](http://tukaani.org/xz/))
- a POSIX conform implementation of sh

Since _intrusion_ is build as 32-bit binary, remember you need the i386 versions of the libraries, if running on an amd64 system.

Originally, the goal was not to use anything not present on a freshly installed 32-bit Ubuntu with only the most recent graphics drivers added. This was achieved and missed at the same time -- while libsdl is present in the base-system of older Ubuntu-versions, it isn't anymore in the most recent, at the time it was finished.

Building
--------
Building _intrusion_ should be possible and is tested on both i386 and amd64 systems. On both, i386 code is emitted.

A list with build-tools/-dependencies follows. The version numbers are the ones _intrusion.release_ was built with, on an amd64-system. Others should work, too, but could produce binaries > 4k.

- clang (version 3.2) ([Homepage](http://clang.llvm.org/))
- nasm (version 2.10.01) ([Homepage](http://www.nasm.us/))
- sstrip (version 2.1) ([Homepage](http://www.muppetlabs.com/~breadbox/software/elfkickers.html))
- shader-minifier (version 1.1) ([Homepage](http://www.ctrl-alt-test.fr/?p=358))
- Python (version 2.7.4) ([Homepage](http://www.python.org/))
- Mako (version 0.7.3) ([Homepage](http://www.makotemplates.org/))
- PIL (version 1.1.7) ([Homepage](http://www.pythonware.com/products/pil/))
- GNU ld (version 2.23.2) ([Homepage](http://www.gnu.org/software/binutils/))
- GNU sed (version 4.2.1) ([Homepage](http://www.gnu.org/software/sed/))
- GNU Make ([Homepage](http://www.gnu.org/software/make/))
- XZ Utils (version 5.1.0alpha) ([Homepage](http://tukaani.org/xz/))
- glibc (or binary compatible, version 6) ([Homepage](http://www.gnu.org/software/libc/))
- SDL (version 1.2) ([Homepage](http://www.libsdl.org/))
- OpenGL (version 3.3.0)

When OUTPUT_INFO is defined while compiling main.c, the framerate and time is written to the terminal while running, on cost of a bigger binary and slower execution.

Anatomy of intrusion
--------------------
### Overview
The core of _intrusion_ is a GLSL-shader, raymarching a [mandelbox](http://en.wikipedia.org/wiki/Mandelbox)-fractal in realtime of the GPU. While there was some code for dynamic lighting in the beginning of the development, another approach was chosen later. Instead of calculate lighting, the number of distance-estimations used to find if the fragment's ray intercepts the fractal is used to colorize the mandelbox. This saves a lot of code, and, more important, makes execution way faster -- with real lighting, normals of the surfaces would have to been known. To get them, a lot of additional rays would need to be cast.

Since I had some space after the initial size-optimizations left, I added some text rendered to the framebuffer, telling a simple story.
This is mostly done in CPU-code, by rendering to a texture, that is just copied to the frame-buffer by the shader.

The sound was sequenced in [Reaper](http://www.reaper.fm/) and is rendered by [4klang](http://4klang.untergrund.net/), a synthesizer designed for use in 4k intros. The _intrusion_-specific code to output it is quite boring. It spawns a thread to render the samples and passes a callback to SDL to copy the data.

More interesting are the various tricks to keep the binary small.
First of all, less code usually means -- surprise -- a smaller binary. While I'm pretty sure there's some potential left for shortening things, I think I found a good compromise between optimal and readable code.

All C-code is implemented to compile to a single object file. More specific, everything, except for _main.c_, is implemented in header-files. Doing this allows the compiler to get way more information about the code and perform much better optimizations.

These optimizations are that good, that implementing simple libc-functions within the source of intrusion leads to a smaller binary than calling them in libc. Therefore, _clib.h_ contains implementations of some syscalls and utility-functions.

More code is saved by stripping away unneeded stuff from the binary. While the normal _strip_ from binutils does a good job removing unneeded sections, _sstrip_ does it even better by removing everything that's not loaded to memory when executing the binary.

Last but not least, some compilerflags are set. Optimization is set to size, of course, while, surprisingly, using clangs _-Os_ gave smaller binaries than _-Oz_. Allowing non-IEEE-conform math-code to be emitted also saves some bytes,
as setting the target-achitecture does. I played around with various flags to get an optimal result, with both clang and gcc, and had to realize clang always emitted smaller binaries than gcc.

Other optimizations are done at linker-level. While no real linktime-optimizations are done, the order of the sections in the binary has a big impact on the compression described in the next section of this document. To get an optimal result, a linker-script is used in conjunction with a small python-script, trying all possible orders.

Some other, smaller optimizations are done, have a look at the source-code if you're interested.

### Compression
One big point to make the keep the binary small is compression.
LZMA, using xz, is utilized fot this. The Makefile adds a line of shellscript in front to the compressed binary, to extract and execute it, when it is ran.

This compression had quite interesting consequences. Several times in development, less code meant the binary was bigger. 
Especially with the shaders it was a lot of try and error to find an optimal result -- there were times, when comparing an variable with itself for inequality added to conditions gave better results, than just omitting it.

### Runtime linking
Dynamic linking requires a bunch of space. The libraries linked, including the versions, and the names of the symbols used, have to be stored in the binary.

Using _libdl_ to load them at runtime saves some bytes, since the version-information can be omitted.
But with some dirty hackery, much more can be saved. _libdl_ is just a wrapper around some internal functions of _libc_. Calling them -- _\_libc\_dlopen\_mode()_ to get a library mapped to the processes memory -- directly, allows to omit linking to libdl.

This is what is done to load _libsdl_. _libgl_ is loaded by _libsdl_ when initializing with GL-support enabled, so we get the dependencies -- with the exception of _libc_ -- loaded with a single function call.
Since _libc_ is used to load libraries, I don't see a way to get it loaded, without linking it traditionally.

A was thinking about implementing library loading directly in _intrusion_. But all the relocation-stuff would need a whole bunch of code, so I expect linking _libc_ is the lesser evil in terms of size.

Having the libraries loaded is the first step. Functions from it have to be called. Directly calling them isn't a good option. It causes the linker to add the function names and a reference to the library they're in to the dynamic-sections of the binary.

To avoid this overhead, not the function-names are saved in the binary, but just a hash of them.
Knowing, that a pointer to the \_link_map_, the datastructure used to store information about loaded libraries, is always the second entry of the _Global Offset Table_, we can use the linker-script to get a symbol to it.
By traversing the \_link_map_, we can locate the tables of the libraries.

Originally, I wrote code to use the gnu-hash-table of the library to lookup
symbols. But I had to realize, that some libraries, the
NVIDIA-OpenGL-implementation, in my case, still use the old SYSV-style
hash-tables.
Instead of wasting space by having code to read both of them around, I decided
for a much simpler approach:
When looking up a symbol, the symbol table is iterated, the symbol name is
hashed and compared with the stored hash.
This is slow, and leads to segfaults, if the symbol isn't present, since there
is no simple way to get the symbol-tables length, but, well, it is small :o)

This is done for every external function used -- with one exception.
One call using the usual mechanisms to libc is required, to prevent ld from
assuming no shared libraries are used at all and to remove the dynamic sections
of the binary.

### Abusing ELF
There're some fields of ELF-headers, the Linux-kernel doesn't care about. Filling these with zeros violates the ELF-standard, but doesn't prevent the binary from being executed and allows the compression to do a better job. Therefore, a script is ran over the binary doing this after build.
Inspired by [an Article by Brian Raiter](http://www.muppetlabs.com/~breadbox/software/tiny/teensy.html), I also moved some data -- more concrete, a string used by the binary -- to the ELF-header. This way, it doesn't need to be stored in the binaries data-section.

### Text rendering
To realize the text-rendering, information how to render the glyphs is needed. To keep the binary small, I decided four byte to save the face of a letter is enough. This leads to having 4x8 pixels available per letter.
I draw the letters in GIMP and added a small script reading the bitmaps and generating a header-file with the letters encoded as integers. While doing this, the scripts parses the source-code for letters really used. Unneeded letters are just to zero in the generated header to allow better compression.

The rendering itself is done by just writing the pixels of the letters to a texture, that if copied to the framebuffer by the fragment shader.

### Shaders
While the shaders are the core of _intrusion_, keeping them small is quite important. Since they have to be stored as text in the binary -- the graphics driver compiles them at runtime -- they can consume a lot of space.
[Shader Minifier](http://www.ctrl-alt-test.fr/?p=358) is used to shorten them, saving a lot of space.
But since it cannot modify names of the externals without breaking the code, I had to set the names of the externela to single letters manually.
To keep the code readable, the C-preprocessor is used to do this.

### Smaller floats
The camera-movement is realized by having a linear transition between predefined points. These points occupy a lot of space in the binary. To keep this as small as possible, I was playing around with the _fp.h_ I found [on the internet](http://www.iquilezles.org/www/articles/float4k/float4k.htm). But, well, writing a simple script, similar to to the one described in the article, turned out to save much more space.

What didn't work
----------------
While developing _intrusion_, I had some some ideas to make the binary smaller, that didn't help.

### String compression
I tried to get the large amount strings of strings, for both the displayed ones and the shaders smaller.

I experimented with [Huffmann coding](http://en.wikipedia.org/wiki/Huffman_coding). I expected it to compress the strings more effective than the LZMA compression applied to the whole binary, providing some size-gain, even with LZMA unable to compress these parts of the program effective afterwards.
I was right in terms of the better compression of the strings, but the gain was smaller than the amount of code needed to decode the strings. Therefore, no Huffman.

Another idea was grounded of the observation I didn't need the whole range of ASCII-characters. In fact, 6 bit are enough to cover the whole range of used characters. This means, three bytes would be enough to save four characters. But, again, there was an impact on the LZMA-compression, causing the size-gain to be that small, that the binary had the original size again, after adding the code needed to decode the strings.

### Fixed-point arithmetic
I tried to replace all floating-point arithmetic with fixed-point, hoping to get a smaller binary. This also didn't work out. The problem was, that I needed floats in the shader, so they had to be converted to floats again. Independently of the place where to do this -- on the CPU or GPU -- it caused too much code to be generated.

What's next?
------------
Several times while developing, I was really wishing for a [Crinkler](http://www.crinkler.net/)-like linker for Linux, thinking about writing one. While I decided against, to finish _intrusion_ first, but I may feel like do it one day.

With a custom linker, all the _linker.h_-stuff could be done transparently, without the problem that ld omits the dynamic-sections, when nothing is linked dynamically the traditional way.

Also, it could rearrange the code more effective than _optimize\_linkerscript.py_, do nasty stuff to the ELF-header automatically, and so on.

Resources Used
--------------
- The project contains code from [4klang](http://4klang.untergrund.net/), a
great 4k-intro software-synthesizer
- I've leared almost everything a know and needed for this project about
fractals from [Fractal Forums](http://www.fractalforums.com/)
- [Reaper](http://www.reaper.fm/) was used to sequence the sound
- [GIMP](http://www.gimp.org/) was used to draw the font
- ... and I visited a lot of OpenGL- and demo-related websites, I didn't keep track of.
