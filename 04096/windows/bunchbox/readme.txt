Bunchbox 4k Intro

Brad Smith
9/18/2009
http://switch.to/unleaded
rainwarrior@gmail.com


My primary goal for this program was to learn how to make a modern program that fits into 4096 bytes. In addition to this I wanted it to make 3D graphics and music, have scrolling text (for nostalgia), and have the graphics synchronized precisely with the music. I also wanted to make a guide for others on how to make a 4k intro, since I had to cobble together the knowledge I needed from scraps here and there, which is why I have made the source code available.


To compile this program you will need:

1. Visual C++ 2008
   I used the free Visual C++ 2008 Express Edition Version 9.0.30729.1 SP.
   http://www.microsoft.com/express/

2. The Crinkler
   * I used version 1.2
   * http://www.crinkler.net/
   * Copy crinkler.exe into the same directory as demo0.sln and rename it link.exe.
   * Add "$(SolutionDir)" to the top of Visual Studio's executable directory list.
   * See Crinkler's manual for more explanation.
   * Crinkler is not required to compile this program, but the executable will be considerably smaller.

Creating a 4k intro is not a task for someone who isn't interested in experimenting with their compiler and learning some nitty gritty details, so I'm not going to explain everything here; I'm just trying to give enough to get you started. Between these tips and the source code you should be able to start your own 4k intro.

1. Some of my compiler settings:
   * No debug information.
   * Optimize for size (/O1)
   * Default inline function expansion.
   * No intrinsic functions.
   * Favour small code (/Os)
   * Omit frame pointers
   * String pooling (/GF)
   * Multi-threaded runtime library (/MT)
   * Align structs to 1 byte (/Zp1)
   * No buffer security check (/GS-)
   * Fast floating point model (/fp:fast)
   * No RTTI (/GR-)
   * __fastcall calling convention (/Gr)
   * Omit default library names (/Zl)
   * Extra command line: /QIfist

2. For suitable linker settings, read the Crinkler manual, or check my settings for the Release or Best build. A lot of the Microsoft settings are ignored by Crinkler.

   * No incremental linking (/INCREMENTAL:NO)
   * Do not link library dependencies.
   * Ignore all default libraries (/NODEFAULTLIB)
   * No debug info
   * Eliminate unreferenced data (/OPT:REF)
   * Remove redundant COMDATs (/OPF:ICF)

3. Define your own entry point (I called mine WinMain).
   This also means you can't use static instances of C++ classes that require a non-empty constructor, because these are normally called by an internal C runtime entry point (see http://www.codeproject.com/KB/library/tlibc.aspx for an interesting article about replacing the C runtime).

4. Define atexit. It doesn't have to do anything, but you will need it.

5. Without the C runtime library you will need this magic line somewhere in a cpp file in order to use floating points:
   * extern "C" int _fltused = 1;

6. Define your own memset and memcpy; even if you do not explicitly use these functions MSVC will probably implicitly use them for you (sometimes it will even replace simple for loops). Because you are not using the C runtime library, you will therefore need your own. You may want to use #pragma function(memset) to force explicit usage as well.

7. Use Crinkler's build information output to analyze your source and how big each part of it is. It is an amazing tool.

Anyhow, I hope you enjoyed this. Have fun!

-- Brad Smith
rainwarrior@gmail.com
