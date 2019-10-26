/******************************o.

Here are some settings you may want to fix :)
VIDEO and AUDIO are set in the makefile.	 
*/

#define BUFW 320
#define BUFH 200
/*
	The size (width&height) of the display buffer.
	
	320x200 is smooth on a 386.

	Svgalib: the best-fitting 256 color mode will be searched
	automatically.
*/

#define VGARETRACE 0
/* 
	1 = Svgalib waits for the vertical retrace before dumping the
       framebuffer.       
*/

#define ASMLOOPS 386
/*
	386 = use the i386-optimized asm loops (slightly buggy)
	0   = pure c source (recommended for non-pc machines :)
*/

#define OUTFREQ 22050
/*
	Audio output frequency. 
*/

#define FRAGSIZE 10	/* size = 2^n, n=7..17 */
#define NUMFRAGS 40	/* somewhere between 2..255, i think */
/*
	The number and size of the audio buffers.

	If your machine has problems in keeping the mixbuffer filled, you
	an try to increase these values. However those 10,40 are quite ok
	for a 386dx/25 with an old soundblaster.
	
	Prefer increasing NUMFRAGS unless you want an action-halt-
	action-halt style multimedia performance a la windows.

	We still have problems in keeping the audio up in all
	circumstances.. such as leaving the svgalib console or while
	performing some window manager functions.		
*/

#define WINNAME "3x666"
/*
	The name for the x window.
*/

#define SLEEPY 0
/* 
	1 = sleep between frames if there's nothing to do
	    originally implemented for a better cpu usage
	    but i don't think it is of any relevant use here
	    
	0 = use dummyloop

 */
/*	All right! Now save the file and type make ("em ay kee ee")
/ \

.o*************/

/* don't touch these: */

#define DEMOHZ 100

/* maybe these shouldn't be here */
#define ROWTIX 6
#define MAXROWLGT TIKLGT*ROWTIX

#define vga 0
#define X11 1
