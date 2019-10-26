                                                by Matthew Wilhelm

                           Tiny Parallax Starfield

First:
        STARNOKB.COM DOES NOT CHECK FOR A KEYSTROKE TO EXIT. IT IS AN
INFINITE LOOP. UNLESS YOU RUN IT UNDER A DOS SHELL (OS/2, WINDOWS 95,
ETC) YOU WILL NEED TO REBOOT YOUR MACHINE.


Description:

        These files are a modification of my winning entry to the small,
randomized ~200 star 4+ speed parallax scroller speed competition. The
code delivers multicolor stars at many different scroll rates, exceeding
the specifications of the competition.

        It runs tolerably on my 486/50 with ET4000 ISA video card.
        It runs quite nicely on a my p133 with ET6000 PCI card.

        As you may notice, text mode is not restored.

        STAR.* include keyboard checking and is slow.
        STARNOKB.*, removes the keyboard check. It runs much more smoothly.


Code notes:

        I compile this code with Borland Turbo Assembler (TASM) 4.0
        using the following commands:

        tasm star
        tlink /t star

        to produce star.com. Starnokb.asm may be compiled the same way.

        The algorithm used is very small, albeit slow. An explanation
        follows:

                              -Setup Code-
        Some registers are assumed to be 0 on program entry (per DOS
specification). First, graphics mode 13h is set by calling BIOS interrupt
10h with AH=0 (video mode set routine) and AL=13h (320x200x256). This
code is unavoidable and cannot be optimized. BX is 0. Setting the high
byte to a0 sets BX = A000, the segment of video memory. This is stored in
ES. (This code is the same size as push 0a000h / pop es). An optional
'dec ch' will wrap ch from 00 to FFh, creating a very large number of stars.
                         -Random Star Generator-
This routine not only generates stars but also draws them on the screen.
AL is loaded with a value from port 40h, the timer, for randomness.
The AAA instruction converts the value in AL for specific reasons: The
value from port 40h can vary widely, however, the display of stars looks
ugly when there are too many random colors. In addition, with a large
scroll distance/frame (associated with color), a star doesn't really
appear to scroll; it appears to jerk around randomly. AAA takes care of
this problem by filtering the random value from port 40h. AX (or AL,
since AH = 0) is subtracted from DI providing a new location on the display
for each pixel. The pixel color (AL), is stored at ES:[DI] with STOSB.
LOOP GENSTAR repeats the process CX times. After the random star generation
is finished, execution will procede through the loop statement.
                             -Star Scrolling-
        The next section of code performs animation. First, AX is cleared.
XCHG AL,ES:[DI] does two things, erases the pixel on the screen (sets it
equal to AL, which is 0 after the clear) and loads the pixel value in AL.
CX is incremented (set to 1) so that execution will simply pass through
LOOP GENSTAR. This allows the code after SCROLL: to serve double duty as
part of both the randomizing and animation routines. Again, DI is
decremented, moving the pixel to the left. The pixel is replotted with
STOSB. LOOP decreases the value in CX, then compares it to 0. Since we
set CX to 1, it will never loop to the first routine. The keyboard-checking
version sets AH to 1 and calls interrupt 16H, checking for an available
keystroke. (Note that this code was NOT optimized) If there is a keystroke
(based on Zero flag), the byte at hidden_ret + 1 is executed. This is a RET
instruction encoded by MOV ES,AX (a small optimization).
The scrolling routine essentially reads a pixel, erases it, replots it at
a position to the left equal to its color value. STOSB, used to plot, also
increments DI. The pixel one unit to the right of the newly displaced pixel
is read. Its value is 0 if blank. 0 loaded to AL, erased on the screen
(set to 0 again), subtracted from DI and stored again. When a 0 is
encountered, it passes through the engine as any other pixel, however, the
only net result is the incrementation of DI. In this manner, the algorithm
goes through video memory searching for pixels.
        When a pixel goes off the left side of the screen, it reappears
on the right side one column above. Subtracting a value from DI, after
all, will never produce a value outside the 64k area allocated to video
memory. Normally, it will just move the pixel left. In this case
it wraps around the side. Similarly, when a pixel scrolls off the first
line, it will reappear near the end of video memory. Since 2^16 = 65536
and 320*200 = 64000, there are 1536 bytes of buffer that are not
displayed at the end of the screen. The star moves along in this hidden
area for a bit before becoming visible around DI=64000.

        To my knowledge, there are no more optimizations that can be
performed without sacrificing quality.

        The SBB instructions are interchangeable for SUB. SBB just
looks cooler :)

        When a star passes a slower one, an interesting
effect occurs: a star will appear to leap. The animation routine
traces through video memory from the point of the last star write.
A fast star will be relocated behind a slower star that has already
been processed in the iteration. The slower star will be processed
again when the routine traces through memory to it. The slower star
effectively moves twice as far as it normally would. I leave it as
an exercise for the reader to explain this effect in astrophysical
terms :)

        Stars disappear after a while. Disappearing occurs when a
star jumps on top of another one. Since the only information about
a star is itself (the pixel's color), overwriting this value
deletes the star entirely.


Modifications:

        One day, BigCheese of #coders (Adam Letts) came to me and said
he had lopped off another byte from my program. The xchg instruction
used to erase the pixel was his idea. Coupled with the support code
(xor ax,ax) it was a byte smaller than my original entry (27 bytes
opposed to 28). I had previously thought that there was no more
optimization possible on the code. How wrong an assumption that was :)
Vowing that it could be made smaller, we both shrunk the code an
additional 3 bytes to its current 24 bytes (working independently of
each other). It is possible to reduce it even further (see code
comments) but that involves sacrifices in quality. Adam suggested
the substitution of 'in al,40h' with 'inc ax.' This saves a byte but
the star positioning is no longer random. He also suggested that I
try to make use of the overlapping code in the generate/draw routines
(sbb di,ax/stosb) which I had previously been too lazy to do :)


Critical Acclaim:

   Chris Hargrove, Programmer at Raven Software
        <kd> At some point, size optimization ceases to be optimization
        and becomes compression. :)

   ThaDragon, #coders channel
        <ThaDragon> os\2: fuck 3d starfields can prolly be made smaller
        than that ;}

   Pascal of Cubic Team, CubicPlayer guy
        <pascal> strange.
        <pascal> very strange.
        <pascal> your program is too strange..

   Moopy, #coders channel
        <Moopy> could you sent it to lewpy

   Lewpy, #coders channel
        <Lewpy> Stumpy Oleg McNoleg

   BigCheese, #coders channel
        <BigCheese> os2man: it's crap, but hey :)
        <BigCheese> os2man: Why don't you follow the standard and call it
        tinystar.com or something? :)


About me (blab):
        My name is Matt Wilhelm. I am an 18 year old student about
to enter freshman year at the California Institute of Technology
(CIT, Caltech). My interests include computer graphics, algorithm
optimizations, Intel assembly code tweaking, and structured/OOP
programming in C++. My current project is a graphics engine for
Microsoft DirectX (c) (TM) (whatever) that features realtime lossless
image decompression, color conversion between various hi/trucolor
formats, dynamic memory management (NOT as in Windows swapping), and
many other useful features. I may or may not finish and release this
C++/ASM library depending on how much programming time I have once
school begins. I have also become interested in non-polygon 3D methods
including Splines, NURBS, and fast raytracing. I may work on modeling
worlds with mechanical and visual correctness.

        Until 9/20/96, I may be mailed at:
        FDWilhelm@worldnet.att.net

_PLEASE_DO_NOT_ use this address after that date. I will start Caltech
the following day and have a nice, fast ethernet connection. I do not
know what my e-mail address will be.

I am often in the IRC #coders channel on the European side of EFNet.
To connect to this network from inside the US, try the server
irc-2.stealth.net(:6667). My IRC nick is os\2man.